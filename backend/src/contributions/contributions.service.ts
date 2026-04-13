import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ContributionType } from '@prisma/client';

@Injectable()
export class ContributionsService {
  constructor(private prisma: PrismaService) {}

  findAll(filters: { flatId?: string; month?: number; year?: number }) {
    return this.prisma.flatContribution.findMany({
      where: {
        ...(filters.flatId && { flatId: filters.flatId }),
        ...(filters.month && { month: filters.month }),
        ...(filters.year && { year: filters.year }),
      },
      include: {
        flat: true,
        user: { select: { id: true, name: true, email: true, phone: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  private readonly MONTH_NAMES = ['', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'];

  async create(dto: {
    flatId: string;
    userId: string;
    month: number;
    year: number;
    type: ContributionType;
    amount: number;
    description?: string;
  }) {
    const flat = await this.prisma.flat.findUnique({ where: { id: dto.flatId } });

    const contribution = await this.prisma.flatContribution.create({
      data: dto,
      include: {
        flat: true,
        user: { select: { id: true, name: true } },
      },
    });

    if (flat?.apartmentId) {
      const categoryMap: Record<string, string> = { WATER: 'Water', MAINTENANCE: 'Maintenance', OTHER: 'Other' };
      const expenseDescription = dto.description || `Flat ${flat.flatNumber} Contribution - ${this.MONTH_NAMES[dto.month]} ${dto.year}`;
      
      // Check if expense already exists to prevent duplicates
      const existingExpense = await this.prisma.expense.findFirst({
        where: {
          apartmentId: flat.apartmentId,
          category: categoryMap[dto.type] ?? 'Other',
          description: expenseDescription,
          amount: dto.amount,
          month: dto.month,
          year: dto.year,
        },
      });

      if (!existingExpense) {
        await this.prisma.expense.create({
          data: {
            apartmentId: flat.apartmentId,
            category: categoryMap[dto.type] ?? 'Other',
            description: expenseDescription,
            amount: dto.amount,
            month: dto.month,
            year: dto.year,
            expenseDate: new Date(dto.year, dto.month - 1, 1),
          },
        });
      }
    }

    return contribution;
  }

  async resetApplied(id: string) {
    const exists = await this.prisma.flatContribution.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException('Contribution not found');
    return this.prisma.flatContribution.update({ where: { id }, data: { appliedToBillId: null } });
  }

  async delete(id: string) {
    const exists = await this.prisma.flatContribution.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException('Contribution not found');
    return this.prisma.flatContribution.delete({ where: { id } });
  }

  async getPendingCreditsForFlat(flatId: string, upToMonth: number, upToYear: number) {
    const all = await this.prisma.flatContribution.findMany({
      where: { flatId, appliedToBillId: null },
    });
    return all.filter(c => {
      const cDate = c.year * 100 + c.month;
      const uDate = upToYear * 100 + upToMonth;
      return cDate < uDate;
    });
  }

  async applyContributionsToBill(billId: string, contributionIds: string[]) {
    await this.prisma.flatContribution.updateMany({
      where: { id: { in: contributionIds } },
      data: { appliedToBillId: billId },
    });
    return { applied: contributionIds.length };
  }

  async applyToExistingBill(id: string, month: number, year: number) {
    const contribution = await this.prisma.flatContribution.findUnique({ where: { id } });
    if (!contribution) throw new NotFoundException('Contribution not found');
    if (contribution.appliedToBillId) throw new BadRequestException('Contribution already applied');

    const bill = await this.prisma.monthlyBill.findUnique({
      where: { flatId_month_year: { flatId: contribution.flatId, month, year } },
    });
    if (!bill) throw new NotFoundException('Bill not found for the specified month/year');

    // Apply credit to previousDue (can go negative = credit balance)
    const newPreviousDue = bill.previousDue - contribution.amount;
    const newTotalAmount = bill.maintenanceAmount + bill.waterAmount + newPreviousDue;
    
    // Recalculate status: if already paid, paidAmount stays same but status may change
    let newStatus = bill.status;
    if (bill.paidAmount >= newTotalAmount) {
      newStatus = 'PAID';
    } else if (bill.paidAmount > 0) {
      newStatus = 'PARTIAL';
    } else {
      newStatus = 'PENDING';
    }

    await this.prisma.monthlyBill.update({
      where: { id: bill.id },
      data: { previousDue: newPreviousDue, totalAmount: newTotalAmount, status: newStatus },
    });

    await this.prisma.flatContribution.update({
      where: { id },
      data: { appliedToBillId: bill.id },
    });

    return { applied: true, contributionId: id, billId: bill.id, newTotal: newTotalAmount, newStatus };
  }

  async getSummaryByApartment(apartmentId: string, month: number, year: number) {
    const flats = await this.prisma.flat.findMany({ where: { apartmentId } });
    const flatIds = flats.map(f => f.id);
    const contributions = await this.prisma.flatContribution.findMany({
      where: { flatId: { in: flatIds }, month, year },
      include: {
        flat: true,
        user: { select: { id: true, name: true } },
      },
    });
    return contributions;
  }
}
