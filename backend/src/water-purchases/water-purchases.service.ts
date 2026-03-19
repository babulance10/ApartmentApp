import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class WaterPurchasesService {
  constructor(private prisma: PrismaService) {}

  findAll(apartmentId: string, month?: number, year?: number) {
    return this.prisma.waterPurchase.findMany({
      where: {
        apartmentId,
        ...(month && { month }),
        ...(year && { year }),
      },
      orderBy: [{ year: 'desc' }, { month: 'desc' }, { srNo: 'asc' }],
    });
  }

  async create(dto: {
    apartmentId: string; month: number; year: number;
    srNo: number; capacityLiters?: number; tokenNo: string;
    bookedOn: string; deliveredOn: string; amountPaid: number; vehicleNo: string;
  }) {
    return this.prisma.waterPurchase.create({
      data: {
        apartmentId: dto.apartmentId,
        month: dto.month,
        year: dto.year,
        srNo: dto.srNo,
        capacityLiters: dto.capacityLiters ?? 10000,
        tokenNo: dto.tokenNo,
        bookedOn: new Date(dto.bookedOn),
        deliveredOn: new Date(dto.deliveredOn),
        amountPaid: dto.amountPaid,
        vehicleNo: dto.vehicleNo,
      },
    });
  }

  async update(id: string, dto: {
    srNo?: number; capacityLiters?: number; tokenNo?: string;
    bookedOn?: string; deliveredOn?: string; amountPaid?: number; vehicleNo?: string;
  }) {
    const existing = await this.prisma.waterPurchase.findUnique({ where: { id } });
    if (!existing) throw new NotFoundException('Purchase not found');
    return this.prisma.waterPurchase.update({
      where: { id },
      data: {
        ...(dto.srNo !== undefined && { srNo: dto.srNo }),
        ...(dto.capacityLiters !== undefined && { capacityLiters: dto.capacityLiters }),
        ...(dto.tokenNo && { tokenNo: dto.tokenNo }),
        ...(dto.bookedOn && { bookedOn: new Date(dto.bookedOn) }),
        ...(dto.deliveredOn && { deliveredOn: new Date(dto.deliveredOn) }),
        ...(dto.amountPaid !== undefined && { amountPaid: dto.amountPaid }),
        ...(dto.vehicleNo && { vehicleNo: dto.vehicleNo }),
      },
    });
  }

  async remove(id: string) {
    return this.prisma.waterPurchase.delete({ where: { id } });
  }

  async getSummary(apartmentId: string, month: number, year: number) {
    const purchases = await this.findAll(apartmentId, month, year);
    const totalAmount = purchases.reduce((s, p) => s + p.amountPaid, 0);
    const totalLiters = purchases.reduce((s, p) => s + p.capacityLiters, 0);
    return { purchases, totalAmount, totalLiters, count: purchases.length };
  }
}
