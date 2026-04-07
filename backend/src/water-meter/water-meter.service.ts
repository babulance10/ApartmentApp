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
    
    // Calculate price per liter from actual tanker purchases for this month
    let pricePerLiter = dto.pricePerLiter ?? 0.088;
    
    if (!dto.pricePerLiter) {
      // Get flat's apartment to find tanker purchases
      const flat = await this.prisma.flat.findUnique({ where: { id: dto.flatId } });
      if (flat) {
        const purchases = await this.prisma.waterPurchase.findMany({
          where: {
            apartmentId: flat.apartmentId,
            month: dto.month,
            year: dto.year,
          },
        });
        
        if (purchases.length > 0) {
          const totalLiters = purchases.reduce((sum, p) => sum + p.capacityLiters, 0);
          const totalCost = purchases.reduce((sum, p) => sum + p.amountPaid, 0);
          pricePerLiter = totalLiters > 0 ? totalCost / totalLiters : 0.088;
        }
      }
    }
    
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

  async recalculateAll() {
    const readings = await this.prisma.waterMeterReading.findMany({
      include: { flat: true },
    });

    let updated = 0;
    for (const reading of readings) {
      // Get tanker purchases for this month/year
      const purchases = await this.prisma.waterPurchase.findMany({
        where: {
          apartmentId: reading.flat.apartmentId,
          month: reading.month,
          year: reading.year,
        },
      });

      if (purchases.length > 0) {
        const totalLiters = purchases.reduce((sum, p) => sum + p.capacityLiters, 0);
        const totalCost = purchases.reduce((sum, p) => sum + p.amountPaid, 0);
        const pricePerLiter = totalLiters > 0 ? totalCost / totalLiters : 0.088;
        const waterAmount = Math.round(reading.litersConsumed * pricePerLiter);

        // Update if different
        if (reading.pricePerLiter !== pricePerLiter || reading.waterAmount !== waterAmount) {
          await this.prisma.waterMeterReading.update({
            where: { id: reading.id },
            data: { pricePerLiter, waterAmount },
          });
          updated++;
        }
      }
    }

    return { total: readings.length, updated };
  }
}
