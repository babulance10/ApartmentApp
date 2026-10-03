import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ExpenseTemplatesService {
  constructor(private prisma: PrismaService) {}

  findAll(apartmentId: string) {
    return this.prisma.expenseTemplate.findMany({
      where: { ...(apartmentId && { apartmentId }) },
      orderBy: { createdAt: 'desc' },
    });
  }

  create(dto: { apartmentId: string; category: string; description: string; amount: number }) {
    return this.prisma.expenseTemplate.create({ data: dto });
  }

  delete(id: string) {
    return this.prisma.expenseTemplate.delete({ where: { id } });
  }
}
