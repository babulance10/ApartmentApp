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
    const apartment = await this.prisma.apartment.findUnique({ where: { id: apartmentId } });
    const amount = maintenanceAmount ?? (apartment as any)?.maintenanceAmount ?? 2000;
    const flats = await this.prisma.flat.findMany({ where: { apartmentId } });
    const created: any[] = [];
    let commonWaterAmount = 0;
    
    for (const flat of flats) {
      const prevBill = await this.prisma.monthlyBill.findFirst({
        where: { flatId: flat.id },
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
      });
      const previousDue = prevBill ? (prevBill.totalAmount - prevBill.paidAmount) : 0;

      // Get water reading from previous month (water is billed in the following month)
      let prevMonth = month - 1;
      let prevYear = year;
      if (prevMonth === 0) {
        prevMonth = 12;
        prevYear--;
      }
      const waterReading = await this.prisma.waterMeterReading.findUnique({
        where: { flatId_month_year: { flatId: flat.id, month: prevMonth, year: prevYear } },
      });
      const waterAmount = waterReading ? waterReading.waterAmount : 0;

      // Common flat: maintenance = 0, track water amount for expense
      const isCommon = flat.flatNumber === 'Common';
      const flatMaintenance = isCommon ? 0 : amount;
      
      if (isCommon && waterAmount > 0) {
        commonWaterAmount = waterAmount;
      }

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
    
    // Create expense for Common flat water amount
    if (commonWaterAmount > 0) {
      const MONTH_NAMES = ['', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
      await this.prisma.expense.create({
        data: {
          apartmentId,
          category: 'Water',
          description: `Common Area Water - ${MONTH_NAMES[month]} ${year}`,
          amount: commonWaterAmount,
          month,
          year,
          expenseDate: new Date(year, month - 1, 1),
        },
      });
    }
    
    return created;
  }

  async regenerateBills(apartmentId: string, month: number, year: number, maintenanceAmount?: number) {
    // Delete existing bills for this month/year
    await this.prisma.monthlyBill.deleteMany({
      where: { flat: { apartmentId }, month, year },
    });

    // Regenerate bills with current water amounts
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

  async updateBill(id: string, dto: { maintenanceAmount?: number; waterAmount?: number; previousDue?: number }) {
    const bill = await this.prisma.monthlyBill.findUnique({ where: { id }, include: { payments: true } });
    if (!bill) throw new NotFoundException('Bill not found');
    const maintenanceAmount = dto.maintenanceAmount ?? bill.maintenanceAmount;
    const waterAmount = dto.waterAmount ?? bill.waterAmount;
    const previousDue = dto.previousDue ?? bill.previousDue;
    const totalAmount = maintenanceAmount + waterAmount + previousDue;
    const paidAmount = bill.payments.reduce((sum, p) => sum + p.amount, 0);
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

  async getAllTimeTotals(apartmentId: string) {
    // Authoritative total from Spend Details sheet (Jun 2020 – Mar 2026)
    const SPEND_DETAILS_TOTAL_RECEIVED = 1651504;
    const expensesResult = await this.prisma.expense.aggregate({
      where: { apartmentId },
      _sum: { amount: true },
    });
    const totalExpenses = expensesResult._sum.amount ?? 0;
    const remaining = SPEND_DETAILS_TOTAL_RECEIVED - totalExpenses;
    return { totalReceived: SPEND_DETAILS_TOTAL_RECEIVED, totalExpenses, remaining };
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
