import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BillsService } from '../bills/bills.service';

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService, private billsService: BillsService) {}

  findAll(billId?: string) {
    return this.prisma.payment.findMany({
      where: billId ? { billId } : undefined,
      include: { bill: { include: { flat: true } } },
      orderBy: { paymentDate: 'desc' },
    });
  }

  async create(dto: { billId: string; amount: number; paymentDate?: string; paymentMethod?: string; transactionRef?: string; notes?: string }) {
    const payment = await this.prisma.payment.create({
      data: {
        billId: dto.billId,
        amount: dto.amount,
        paymentDate: dto.paymentDate ? new Date(dto.paymentDate) : new Date(),
        paymentMethod: dto.paymentMethod,
        transactionRef: dto.transactionRef,
        notes: dto.notes,
      },
    });
    await this.billsService.updateStatus(dto.billId);
    return payment;
  }

  async delete(id: string) {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment) throw new NotFoundException('Payment not found');
    await this.prisma.payment.delete({ where: { id } });
    await this.billsService.updateStatus(payment.billId);
    return { message: 'Payment deleted' };
  }
}
