import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BillStatus } from '@prisma/client';
import * as nodemailer from 'nodemailer';

@Injectable()
export class BillsService {
  constructor(private prisma: PrismaService) {}

  findAll(filters: { flatId?: string; month?: number; year?: number; status?: BillStatus }) {
    return this.prisma.monthlyBill.findMany({
      where: {
        ...(filters.flatId && { flatId: filters.flatId }),
        ...(filters.month && { month: filters.month }),
        ...(filters.year && { year: filters.year }),
        ...(filters.status && { status: filters.status }),
      },
      include: { flat: true, payments: true },
      orderBy: [{ year: 'desc' }, { month: 'desc' }],
    });
  }

  async findOne(id: string) {
    const bill = await this.prisma.monthlyBill.findUnique({
      where: { id },
      include: { flat: { include: { apartment: true } }, payments: true },
    });
    if (!bill) throw new NotFoundException('Bill not found');
    return bill;
  }

  async findForFlat(flatId: string) {
    return this.prisma.monthlyBill.findMany({
      where: { flatId },
      include: { payments: true },
      orderBy: [{ year: 'desc' }, { month: 'desc' }],
    });
  }

  async generateMonthlyBills(apartmentId: string, month: number, year: number, maintenanceAmount?: number) {
    const MONTH_NAMES = ['', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    const apartment = await this.prisma.apartment.findUnique({ where: { id: apartmentId } });
    const amount = maintenanceAmount ?? (apartment as any)?.maintenanceAmount ?? 2000;
    const flats = await this.prisma.flat.findMany({ where: { apartmentId } });
    const created: any[] = [];

    // Compute previous month/year once (water is billed in the following month)
    let prevMonth = month - 1;
    let prevYear = year;
    if (prevMonth === 0) {
      prevMonth = 12;
      prevYear--;
    }

    for (const flat of flats) {
      const prevBill = await this.prisma.monthlyBill.findFirst({
        where: { flatId: flat.id },
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
      });
      const previousDue = prevBill ? (prevBill.totalAmount - prevBill.paidAmount) : 0;

      // Get water reading from previous month (water is billed in the following month)
      const waterReading = await this.prisma.waterMeterReading.findUnique({
        where: { flatId_month_year: { flatId: flat.id, month: prevMonth, year: prevYear } },
      });
      const waterAmount = waterReading ? waterReading.waterAmount : 0;

      // Common flat: maintenance = 0, track water amount for expense
      const isCommon = flat.flatNumber === 'Common';
      const flatMaintenance = isCommon ? 0 : amount;
      
      // Auto-deduct unapplied contributions from previous months
      const pendingContributions = await this.prisma.flatContribution.findMany({
        where: {
          flatId: flat.id,
          appliedToBillId: null,
          OR: [
            { year: { lt: year } },
            { year, month: { lt: month } },
          ],
        },
      });
      const creditAmount = pendingContributions.reduce((s, c) => s + c.amount, 0);
      const netPreviousDue = previousDue - creditAmount;

      const totalAmount = flatMaintenance + waterAmount + netPreviousDue;

      const existing = await this.prisma.monthlyBill.findUnique({
        where: { flatId_month_year: { flatId: flat.id, month, year } },
      });

      if (!existing) {
        const bill = await this.prisma.monthlyBill.create({
          data: { flatId: flat.id, month, year, maintenanceAmount: flatMaintenance, waterAmount, previousDue: netPreviousDue, totalAmount },
        });
        // Mark contributions as applied
        if (pendingContributions.length > 0) {
          await this.prisma.flatContribution.updateMany({
            where: { id: { in: pendingContributions.map(c => c.id) } },
            data: { appliedToBillId: bill.id },
          });
        }
        created.push({ ...bill, creditApplied: creditAmount });
      }
    }

    // Auto-create water expense from previous month's tanker purchases
    const waterPurchases = await this.prisma.waterPurchase.findMany({
      where: { apartmentId, month: prevMonth, year: prevYear },
    });
    if (waterPurchases.length > 0) {
      const totalWaterCost = waterPurchases.reduce((sum, p) => sum + p.amountPaid, 0);
      const existingWaterExpense = await this.prisma.expense.findFirst({
        where: { apartmentId, month, year, category: 'Water', description: { contains: '[Auto-Water]' } },
      });
      if (!existingWaterExpense && totalWaterCost > 0) {
        await this.prisma.expense.create({
          data: {
            apartmentId, month, year, category: 'Water',
            description: `Water tanker - ${MONTH_NAMES[prevMonth]} ${prevYear} [Auto-Water]`,
            amount: totalWaterCost,
            expenseDate: new Date(`${year}-${String(month).padStart(2, '0')}-01`),
          },
        });
      }
    }

    return created;
  }

  async regenerateBills(apartmentId: string, month: number, year: number, maintenanceAmount?: number) {
    // Step 1: Find current bills being deleted and clear their linked contributions
    const billsToDelete = await this.prisma.monthlyBill.findMany({
      where: { flat: { apartmentId }, month, year },
      select: { id: true },
    });
    const billIds = billsToDelete.map(b => b.id);
    if (billIds.length > 0) {
      await this.prisma.flatContribution.updateMany({
        where: { appliedToBillId: { in: billIds } },
        data: { appliedToBillId: null },
      });
    }

    // Step 2: Find all contributions for this apartment's flats that were for
    // prior months and have a stale appliedToBillId (pointing to a deleted bill)
    const flats = await this.prisma.flat.findMany({ where: { apartmentId }, select: { id: true } });
    const flatIds = flats.map(f => f.id);
    const priorContributions = await this.prisma.flatContribution.findMany({
      where: {
        flatId: { in: flatIds },
        appliedToBillId: { not: null },
        OR: [
          { year: { lt: year } },
          { year, month: { lt: month } },
        ],
      },
    });
    // Clear any that point to a bill that no longer exists
    const staleIds: string[] = [];
    for (const c of priorContributions) {
      const bill = await this.prisma.monthlyBill.findUnique({ where: { id: c.appliedToBillId! } });
      if (!bill) staleIds.push(c.id);
    }
    if (staleIds.length > 0) {
      await this.prisma.flatContribution.updateMany({
        where: { id: { in: staleIds } },
        data: { appliedToBillId: null },
      });
    }

    // Step 3: Delete existing bills for this month/year
    await this.prisma.monthlyBill.deleteMany({
      where: { flat: { apartmentId }, month, year },
    });

    // Step 3b: Delete auto-created water expense so it gets recreated with fresh data
    await this.prisma.expense.deleteMany({
      where: { apartmentId, month, year, category: 'Water', description: { contains: '[Auto-Water]' } },
    });

    // Step 4: Regenerate — will now pick up all pending contributions
    return this.generateMonthlyBills(apartmentId, month, year, maintenanceAmount);
  }

  async create(dto: { flatId: string; month: number; year: number; maintenanceAmount?: number; waterAmount?: number; previousDue?: number }) {
    const maintenanceAmount = dto.maintenanceAmount ?? 2000;
    const waterAmount = dto.waterAmount ?? 0;
    const previousDue = dto.previousDue ?? 0;
    const totalAmount = maintenanceAmount + waterAmount + previousDue;
    return this.prisma.monthlyBill.create({
      data: { ...dto, maintenanceAmount, waterAmount, previousDue, totalAmount },
    });
  }

  async updateBill(id: string, dto: { maintenanceAmount?: number; waterAmount?: number; previousDue?: number; paidAmount?: number }) {
    const bill = await this.prisma.monthlyBill.findUnique({ where: { id }, include: { payments: true } });
    if (!bill) throw new NotFoundException('Bill not found');
    const maintenanceAmount = dto.maintenanceAmount ?? bill.maintenanceAmount;
    const waterAmount = dto.waterAmount ?? bill.waterAmount;
    const previousDue = dto.previousDue ?? bill.previousDue;
    const totalAmount = maintenanceAmount + waterAmount + previousDue;
    // Allow direct paidAmount update (admin correction) or calculate from payments
    const paidAmount = dto.paidAmount !== undefined ? dto.paidAmount : bill.payments.reduce((sum, p) => sum + p.amount, 0);
    let status: BillStatus = BillStatus.PENDING;
    if (paidAmount >= totalAmount) status = BillStatus.PAID;
    else if (paidAmount > 0) status = BillStatus.PARTIAL;
    return this.prisma.monthlyBill.update({
      where: { id },
      data: { maintenanceAmount, waterAmount, previousDue, totalAmount, paidAmount, status },
    });
  }

  async updateStatus(id: string) {
    const bill = await this.prisma.monthlyBill.findUnique({ where: { id }, include: { payments: true } });
    if (!bill) throw new NotFoundException('Bill not found');
    const paidAmount = bill.payments.reduce((sum, p) => sum + p.amount, 0);
    let status: BillStatus = BillStatus.PENDING;
    if (paidAmount >= bill.totalAmount) status = BillStatus.PAID;
    else if (paidAmount > 0) status = BillStatus.PARTIAL;
    return this.prisma.monthlyBill.update({ where: { id }, data: { paidAmount, status } });
  }

  async recalculateAllStatuses() {
    const bills = await this.prisma.monthlyBill.findMany({ include: { payments: true } });
    let fixed = 0;
    for (const bill of bills) {
      const paidAmount = bill.payments.reduce((s, p) => s + p.amount, 0);
      let status: BillStatus = BillStatus.PENDING;
      if (paidAmount >= bill.totalAmount && bill.totalAmount > 0) status = BillStatus.PAID;
      else if (paidAmount > 0) status = BillStatus.PARTIAL;
      if (bill.paidAmount !== paidAmount || bill.status !== status) {
        await this.prisma.monthlyBill.update({ where: { id: bill.id }, data: { paidAmount, status } });
        fixed++;
      }
    }
    return { total: bills.length, fixed };
  }

  /**
   * Finances are reported as a verified opening balance at the 31 Mar 2026
   * cut-over, plus two separately tracked accounts from 1 Apr 2026 onwards.
   *
   * Why the cut-over: before 2026 a paid water bill was only ticked off as
   * "paid" - the amount was never written down, only outstanding amounts were.
   * So pre-cut-over water collections look near-zero in the data even though
   * the money was collected, and any water/maintenance split across that
   * period would be fiction. Everything up to 31 Mar 2026 is therefore sealed
   * into a single opening balance (reconciled line-by-line against the
   * historical "Primark Spend amount" workbook), and only the period from
   * Apr 2026 - where payments are captured properly - is split out.
   *
   * Passing month/year reports the position *as at the end of that month*, so
   * the dashboard's period picker moves these figures instead of always
   * showing the all-time total. Months on or before the cut-over cannot be
   * broken down (the opening figure is a single lump sum for Jun 2020 -
   * Mar 2026), so those report the opening balance with beforeCutoff set.
   */
  async getAllTimeTotals(apartmentId: string, upToMonth?: number, upToYear?: number) {
    // Collections Jun 2020 - Mar 2026, per the historical workbook (its
    // =SUM(B1:B70) grand total). Verified to reconcile with that sheet.
    const OPENING_RECEIVED = 1651504;
    const CUTOFF_MONTH = 3;
    const CUTOFF_YEAR = 2026;

    const hasUpTo = !!upToMonth && !!upToYear;
    const beforeCutoff =
      hasUpTo && (upToYear! < CUTOFF_YEAR || (upToYear === CUTOFF_YEAR && upToMonth! <= CUTOFF_MONTH));

    const upToCond = { OR: [{ year: { lt: upToYear } }, { year: upToYear, month: { lte: upToMonth } }] };
    const beforeCutoffCond = {
      OR: [{ year: { lt: CUTOFF_YEAR } }, { year: CUTOFF_YEAR, month: { lte: CUTOFF_MONTH } }],
    };
    const afterCutoffCond = {
      OR: [{ year: { gt: CUTOFF_YEAR } }, { year: CUTOFF_YEAR, month: { gt: CUTOFF_MONTH } }],
    };
    // Window for the tracked period: after the cut-over, and (when a period is
    // selected) no later than the selected month.
    const trackedWindow: any = hasUpTo ? { AND: [afterCutoffCond, upToCond] } : afterCutoffCond;

    // Tanker spend is mirrored into Expense as "[Auto-Water]" rows purely for
    // display; WaterPurchase is the authoritative ledger, so the mirrors are
    // excluded everywhere to avoid counting the same money twice.
    const realExpense = { apartmentId, NOT: { description: { contains: '[Auto-Water]' } } };

    const flats = await this.prisma.flat.findMany({ where: { apartmentId }, select: { id: true } });
    const flatIds = flats.map(f => f.id);

    const [
      openingNonWater, openingWaterBills, openingTankers,
      postNonWater, postWaterBills, postTankers,
      postBills,
    ] = await Promise.all([
      this.prisma.expense.aggregate({ where: { ...realExpense, category: { not: 'Water' }, ...beforeCutoffCond }, _sum: { amount: true } }),
      this.prisma.expense.aggregate({ where: { ...realExpense, category: 'Water', ...beforeCutoffCond }, _sum: { amount: true } }),
      this.prisma.waterPurchase.aggregate({ where: { apartmentId, ...beforeCutoffCond }, _sum: { amountPaid: true } }),
      this.prisma.expense.aggregate({ where: { ...realExpense, category: { not: 'Water' }, ...trackedWindow }, _sum: { amount: true } }),
      this.prisma.expense.aggregate({ where: { ...realExpense, category: 'Water', ...trackedWindow }, _sum: { amount: true } }),
      this.prisma.waterPurchase.aggregate({ where: { apartmentId, ...trackedWindow }, _sum: { amountPaid: true } }),
      this.prisma.monthlyBill.findMany({
        where: { flatId: { in: flatIds }, ...trackedWindow },
        select: { waterAmount: true, totalAmount: true, paidAmount: true },
      }),
    ]);

    const n = (v: number | null | undefined) => v ?? 0;

    const openingSpent = n(openingNonWater._sum.amount) + n(openingWaterBills._sum.amount) + n(openingTankers._sum.amountPaid);
    const openingBalance = OPENING_RECEIVED - openingSpent;

    // A payment settles a bill as a whole, so attribute it across that bill's
    // water and non-water portions in the same proportion it was billed.
    let collected = 0;
    let waterCollected = 0;
    if (!beforeCutoff) {
      for (const b of postBills) {
        collected += b.paidAmount;
        if (b.totalAmount > 0 && b.waterAmount > 0) {
          waterCollected += b.paidAmount * (b.waterAmount / b.totalAmount);
        }
      }
    }
    const maintenanceCollected = collected - waterCollected;

    const waterSpent = beforeCutoff ? 0 : n(postWaterBills._sum.amount) + n(postTankers._sum.amountPaid);
    const maintenanceSpent = beforeCutoff ? 0 : n(postNonWater._sum.amount);

    const totalReceived = OPENING_RECEIVED + collected;
    const totalExpenses = openingSpent + waterSpent + maintenanceSpent;

    return {
      cutoff: { month: CUTOFF_MONTH, year: CUTOFF_YEAR },
      asOf: hasUpTo ? { month: upToMonth, year: upToYear } : null,
      beforeCutoff,
      openingReceived: OPENING_RECEIVED,
      openingSpent,
      openingBalance,
      maintenanceCollected,
      maintenanceSpent,
      maintenanceBalance: maintenanceCollected - maintenanceSpent,
      waterCollected,
      waterSpent,
      waterBalance: waterCollected - waterSpent,
      totalReceived,
      totalExpenses,
      remaining: totalReceived - totalExpenses,
    };
  }

  async bulkSendEmails(apartmentId: string, month: number, year: number): Promise<{ sent: string[]; skipped: string[]; failed: string[] }> {
    const MONTH_NAMES = ['', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    const summary = await this.getSummary(apartmentId, month, year);
    const sent: string[] = [];
    const skipped: string[] = [];
    const failed: string[] = [];

    for (const bill of summary.bills) {
      if (bill.status === 'PAID') { skipped.push(bill.flat?.flatNumber); continue; }
      const tenant = bill.flat?.tenancies?.[0]?.user;
      if (!tenant?.email) { skipped.push(bill.flat?.flatNumber + ' (no email)'); continue; }

      const balance = bill.totalAmount - bill.paidAmount;
      const monthLabel = `${MONTH_NAMES[month]} ${year}`;
      const html = `
        <div style="font-family:Arial,sans-serif;max-width:500px;margin:0 auto;border:1px solid #e5e7eb;border-radius:8px;overflow:hidden">
          <div style="background:#1e40af;color:#fff;padding:16px 24px">
            <h2 style="margin:0;font-size:18px">Maintenance Bill — ${monthLabel}</h2>
            <p style="margin:4px 0 0;opacity:0.8;font-size:13px">PSA Sreenidhi Apartments</p>
          </div>
          <div style="padding:20px 24px">
            <p style="margin:0 0 16px">Dear <strong>${tenant.name}</strong>,</p>
            <p style="margin:0 0 16px;color:#6b7280;font-size:14px">Your maintenance bill for <strong>${monthLabel}</strong> — Flat <strong>${bill.flat?.flatNumber}</strong>:</p>
            <table style="width:100%;border-collapse:collapse;font-size:14px">
              <tr style="border-bottom:1px solid #f3f4f6">
                <td style="padding:8px 0;color:#6b7280">Maintenance</td>
                <td style="padding:8px 0;text-align:right;font-weight:500">₹${bill.maintenanceAmount.toLocaleString('en-IN')}</td>
              </tr>
              ${bill.waterAmount > 0 ? `<tr style="border-bottom:1px solid #f3f4f6">
                <td style="padding:8px 0;color:#6b7280">Water${bill.litersConsumed > 0 ? ` (${bill.litersConsumed.toLocaleString('en-IN')} L)` : ''}</td>
                <td style="padding:8px 0;text-align:right;font-weight:500">₹${bill.waterAmount.toLocaleString('en-IN')}</td>
              </tr>` : ''}
              ${bill.previousDue > 0 ? `<tr style="border-bottom:1px solid #f3f4f6">
                <td style="padding:8px 0;color:#dc2626">Previous Due</td>
                <td style="padding:8px 0;text-align:right;font-weight:500;color:#dc2626">₹${bill.previousDue.toLocaleString('en-IN')}</td>
              </tr>` : ''}
              ${bill.previousDue < 0 ? `<tr style="border-bottom:1px solid #f3f4f6">
                <td style="padding:8px 0;color:#16a34a">Credit Adjusted</td>
                <td style="padding:8px 0;text-align:right;font-weight:500;color:#16a34a">-₹${Math.abs(bill.previousDue).toLocaleString('en-IN')}</td>
              </tr>` : ''}
              <tr style="border-bottom:1px solid #e5e7eb">
                <td style="padding:10px 0;font-weight:700">Total</td>
                <td style="padding:10px 0;text-align:right;font-weight:700">₹${bill.totalAmount.toLocaleString('en-IN')}</td>
              </tr>
              ${bill.paidAmount > 0 ? `<tr style="border-bottom:1px solid #f3f4f6">
                <td style="padding:8px 0;color:#16a34a">Paid</td>
                <td style="padding:8px 0;text-align:right;font-weight:500;color:#16a34a">₹${bill.paidAmount.toLocaleString('en-IN')}</td>
              </tr>` : ''}
              <tr>
                <td style="padding:10px 0;font-weight:700;color:#dc2626">Balance Due</td>
                <td style="padding:10px 0;text-align:right;font-weight:700;color:#dc2626">₹${balance.toLocaleString('en-IN')}</td>
              </tr>
            </table>
            <div style="margin-top:20px;padding:12px 16px;background:#eff6ff;border-radius:6px;font-size:13px;color:#1d4ed8">
              Please make the payment via UPI at your earliest convenience.<br>Thank you for your cooperation.
            </div>
          </div>
          <div style="padding:12px 24px;background:#f9fafb;font-size:12px;color:#9ca3af;border-top:1px solid #f3f4f6">
            PSA Sreenidhi Apartments Association
          </div>
        </div>`;

      try {
        await transporter.sendMail({
          from: `"PSA Sreenidhi Apartments" <${process.env.SMTP_USER}>`,
          to: tenant.email,
          subject: `Maintenance Bill — ${monthLabel} — Flat ${bill.flat?.flatNumber}`,
          html,
        });
        sent.push(bill.flat?.flatNumber);
      } catch (err: any) {
        failed.push(bill.flat?.flatNumber + ': ' + err.message);
      }
    }
    return { sent, skipped, failed };
  }

  async getSummary(apartmentId: string, month: number, year: number) {
    const flats = await this.prisma.flat.findMany({ where: { apartmentId } });
    const flatIds = flats.map(f => f.id);
    
    // Get water readings from previous month (water is billed in the following month)
    let prevMonth = month - 1;
    let prevYear = year;
    if (prevMonth === 0) {
      prevMonth = 12;
      prevYear--;
    }
    
    const [bills, waterReadings] = await Promise.all([
      this.prisma.monthlyBill.findMany({
        where: { flatId: { in: flatIds }, month, year },
        include: {
          payments: true,
          flat: {
            include: {
              tenancies: {
                where: { isActive: true },
                include: { user: { select: { id: true, name: true, phone: true, email: true } } },
              },
            },
          },
        },
        orderBy: { flat: { flatNumber: 'asc' } },
      }),
      this.prisma.waterMeterReading.findMany({
        where: { flatId: { in: flatIds }, month: prevMonth, year: prevYear },
      }),
    ]);
    const billsWithLiters = bills.map(b => {
      const wr = waterReadings.find(w => w.flatId === b.flatId);
      return { ...b, litersConsumed: wr?.litersConsumed ?? 0 };
    });
    const totalDue = bills.reduce((s, b) => s + b.totalAmount, 0);
    const totalCollected = bills.reduce((s, b) => s + b.paidAmount, 0);
    return { bills: billsWithLiters, totalDue, totalCollected, pending: totalDue - totalCollected };
  }
}
