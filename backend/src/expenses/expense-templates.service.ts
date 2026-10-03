import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type TemplateItemInput = { category: string; description: string; amount: number };

@Injectable()
export class ExpenseTemplatesService {
  constructor(private prisma: PrismaService) {}

  /** Standalone (non-set) templates only - the single-expense shortcuts. */
  findAll(apartmentId: string) {
    return this.prisma.expenseTemplate.findMany({
      where: { ...(apartmentId && { apartmentId }), setId: null },
      orderBy: { createdAt: 'desc' },
    });
  }

  create(dto: { apartmentId: string; category: string; description: string; amount: number }) {
    return this.prisma.expenseTemplate.create({ data: dto });
  }

  delete(id: string) {
    return this.prisma.expenseTemplate.delete({ where: { id } });
  }

  findAllSets(apartmentId: string) {
    return this.prisma.expenseTemplateSet.findMany({
      where: { ...(apartmentId && { apartmentId }) },
      include: { items: { orderBy: { createdAt: 'asc' } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  createSet(dto: { apartmentId: string; name: string; items: TemplateItemInput[] }) {
    return this.prisma.expenseTemplateSet.create({
      data: {
        apartmentId: dto.apartmentId,
        name: dto.name,
        items: {
          create: (dto.items ?? []).map(i => ({
            apartmentId: dto.apartmentId,
            category: i.category,
            description: i.description,
            amount: i.amount,
          })),
        },
      },
      include: { items: true },
    });
  }

  /** Snapshots every expense already recorded in a month into a reusable set. */
  async createSetFromMonth(dto: { apartmentId: string; name: string; month: number; year: number }) {
    const expenses = await this.prisma.expense.findMany({
      where: {
        apartmentId: dto.apartmentId,
        month: dto.month,
        year: dto.year,
        // The "[Auto-Water]" row is regenerated every month from the actual
        // water tanker purchases, so capturing it into a reusable template
        // would double-count water once the template is applied.
        NOT: { description: { contains: '[Auto-Water]' } },
      },
      orderBy: { expenseDate: 'asc' },
    });
    return this.createSet({
      apartmentId: dto.apartmentId,
      name: dto.name,
      items: expenses.map(e => ({ category: e.category, description: e.description, amount: e.amount })),
    });
  }

  async deleteSet(id: string) {
    const set = await this.prisma.expenseTemplateSet.findUnique({ where: { id } });
    if (!set) throw new NotFoundException('Template set not found');
    return this.prisma.expenseTemplateSet.delete({ where: { id } });
  }

  /**
   * Creates one expense per selected template item in the target month.
   * `itemIds` lets the caller apply only part of a set; omit it to apply all.
   */
  async applySet(id: string, dto: { month: number; year: number; itemIds?: string[] }) {
    const set = await this.prisma.expenseTemplateSet.findUnique({
      where: { id },
      include: { items: true },
    });
    if (!set) throw new NotFoundException('Template set not found');

    const selected = dto.itemIds?.length
      ? set.items.filter(i => dto.itemIds!.includes(i.id))
      : set.items;

    const now = new Date();
    const isCurrentPeriod = now.getMonth() + 1 === dto.month && now.getFullYear() === dto.year;
    const expenseDate = isCurrentPeriod ? now : new Date(dto.year, dto.month - 1, 1);

    return this.prisma.$transaction(
      selected.map(i =>
        this.prisma.expense.create({
          data: {
            apartmentId: set.apartmentId,
            month: dto.month,
            year: dto.year,
            category: i.category,
            description: i.description,
            amount: i.amount,
            expenseDate,
          },
        }),
      ),
    );
  }
}
