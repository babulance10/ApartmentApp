import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class WaterMeterService {
  constructor(private prisma: PrismaService) {}

  findAll(filters: { flatId?: string; month?: number; year?: number }) {
    return this.prisma.waterMeterReading.findMany({
      where: {
        ...(filters.flatId && { flatId: filters.flatId }),
        ...(filters.month && { month: filters.month }),
        ...(filters.year && { year: filters.year }),
      },
      include: { flat: true },
      orderBy: [{ year: 'desc' }, { month: 'desc' }],
    });
  }

  async findOne(id: string) {
    const r = await this.prisma.waterMeterReading.findUnique({ where: { id }, include: { flat: true } });
    if (!r) throw new NotFoundException('Reading not found');
    return r;
  }

  async upsert(dto: {
    flatId: string; month: number; year: number;
    previousReading: number; currentReading: number; pricePerLiter?: number;
  }) {
    const litersConsumed = dto.currentReading - dto.previousReading;
    const pricePerLiter = dto.pricePerLiter ?? 0.088;
    const waterAmount = Math.round(litersConsumed * pricePerLiter);

    return this.prisma.waterMeterReading.upsert({
      where: { flatId_month_year: { flatId: dto.flatId, month: dto.month, year: dto.year } },
      update: { previousReading: dto.previousReading, currentReading: dto.currentReading, litersConsumed, pricePerLiter, waterAmount },
      create: { flatId: dto.flatId, month: dto.month, year: dto.year, previousReading: dto.previousReading, currentReading: dto.currentReading, litersConsumed, pricePerLiter, waterAmount },
    });
  }

  async bulkUpsert(readings: Array<{ flatId: string; month: number; year: number; previousReading: number; currentReading: number; pricePerLiter?: number }>) {
    return Promise.all(readings.map(r => this.upsert(r)));
  }

  getByApartment(apartmentId: string, month: number, year: number) {
    return this.prisma.waterMeterReading.findMany({
      where: { month, year, flat: { apartmentId } },
      include: { flat: true },
      orderBy: { flat: { flatNumber: 'asc' } },
    });
  }
}
