import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class EventsService {
  constructor(private prisma: PrismaService) {}

  async findAll(apartmentId: string) {
    return this.prisma.event.findMany({
      where: { apartmentId },
      include: {
        collections: { include: { flat: true } },
        expenses: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const event = await this.prisma.event.findUnique({
      where: { id },
      include: {
        collections: { include: { flat: true, user: { select: { id: true, name: true } } } },
        expenses: { orderBy: { expenseDate: 'desc' } },
      },
    });
    if (!event) throw new NotFoundException('Event not found');
    return event;
  }

  async create(dto: { apartmentId: string; name: string; description?: string; targetAmount?: number; startDate?: string; endDate?: string }) {
    return this.prisma.event.create({
      data: {
        apartmentId: dto.apartmentId,
        name: dto.name,
        description: dto.description,
        targetAmount: dto.targetAmount || 0,
        startDate: dto.startDate ? new Date(dto.startDate) : null,
        endDate: dto.endDate ? new Date(dto.endDate) : null,
        status: 'ACTIVE',
      },
    });
  }

  async update(id: string, dto: { name?: string; description?: string; targetAmount?: number; status?: string; startDate?: string; endDate?: string }) {
    const data: any = {};
    if (dto.name !== undefined) data.name = dto.name;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.targetAmount !== undefined) data.targetAmount = dto.targetAmount;
    if (dto.status !== undefined) data.status = dto.status;
    if (dto.startDate !== undefined) data.startDate = new Date(dto.startDate);
    if (dto.endDate !== undefined) data.endDate = new Date(dto.endDate);
    return this.prisma.event.update({ where: { id }, data });
  }

  async delete(id: string) {
    await this.prisma.eventExpense.deleteMany({ where: { eventId: id } });
    await this.prisma.eventCollection.deleteMany({ where: { eventId: id } });
    return this.prisma.event.delete({ where: { id } });
  }

  // Collections
  async addCollection(dto: { eventId: string; flatId: string; userId?: string; amount: number; paidDate?: string; notes?: string }) {
    return this.prisma.eventCollection.create({
      data: {
        eventId: dto.eventId,
        flatId: dto.flatId,
        userId: dto.userId,
        amount: dto.amount,
        paidDate: dto.paidDate ? new Date(dto.paidDate) : new Date(),
        notes: dto.notes,
      },
      include: { flat: true },
    });
  }

  async removeCollection(id: string) {
    return this.prisma.eventCollection.delete({ where: { id } });
  }

  // Expenses
  async addExpense(dto: { eventId: string; category: string; description: string; amount: number; expenseDate?: string }) {
    return this.prisma.eventExpense.create({
      data: {
        eventId: dto.eventId,
        category: dto.category,
        description: dto.description,
        amount: dto.amount,
        expenseDate: dto.expenseDate ? new Date(dto.expenseDate) : new Date(),
      },
    });
  }

  async removeExpense(id: string) {
    return this.prisma.eventExpense.delete({ where: { id } });
  }
}
