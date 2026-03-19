import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ExpensesService {
  constructor(private prisma: PrismaService) {}

  findAll(filters: { apartmentId?: string; month?: number; year?: number; category?: string }) {
    return this.prisma.expense.findMany({
      where: {
        ...(filters.apartmentId && { apartmentId: filters.apartmentId }),
        ...(filters.month && { month: filters.month }),
        ...(filters.year && { year: filters.year }),
        ...(filters.category && { category: filters.category }),
      },
      orderBy: [{ year: 'desc' }, { month: 'desc' }, { expenseDate: 'desc' }],
    });
  }

  async findOne(id: string) {
    const expense = await this.prisma.expense.findUnique({ where: { id } });
    if (!expense) throw new NotFoundException('Expense not found');
    return expense;
  }

  create(dto: { apartmentId: string; month: number; year: number; category: string; description: string; amount: number; expenseDate: string }) {
    return this.prisma.expense.create({ data: { ...dto, expenseDate: new Date(dto.expenseDate) } });
  }

  update(id: string, dto: any) {
    return this.prisma.expense.update({ where: { id }, data: dto });
  }

  delete(id: string) {
    return this.prisma.expense.delete({ where: { id } });
  }

  async getSummaryByMonth(apartmentId: string, year: number) {
    const expenses = await this.prisma.expense.findMany({ where: { apartmentId, year } });
    const byMonth: Record<number, { total: number; byCategory: Record<string, number> }> = {};
    for (const e of expenses) {
      if (!byMonth[e.month]) byMonth[e.month] = { total: 0, byCategory: {} };
      byMonth[e.month].total += e.amount;
      byMonth[e.month].byCategory[e.category] = (byMonth[e.month].byCategory[e.category] || 0) + e.amount;
    }
    return byMonth;
  }
}
