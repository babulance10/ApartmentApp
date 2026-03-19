import { Injectable, NotFoundException } from '@nestjs/common';
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

  async create(dto: {
    flatId: string;
    userId: string;
    month: number;
    year: number;
    type: ContributionType;
    amount: number;
    description?: string;
  }) {
    return this.prisma.flatContribution.create({
      data: dto,
      include: {
        flat: true,
        user: { select: { id: true, name: true } },
      },
    });
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
