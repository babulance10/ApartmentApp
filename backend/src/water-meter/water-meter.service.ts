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
    
    // Get flat's apartment to find tanker purchases and total consumption
    const flat = await this.prisma.flat.findUnique({ where: { id: dto.flatId } });
    if (!flat) throw new Error('Flat not found');

    const purchases = await this.prisma.waterPurchase.findMany({
      where: {
        apartmentId: flat.apartmentId,
        month: dto.month,
        year: dto.year,
      },
    });

    let pricePerLiter = 0.088;
    let waterAmount = Math.round(litersConsumed * pricePerLiter);

    if (purchases.length > 0) {
      const totalTankerLiters = purchases.reduce((sum, p) => sum + p.capacityLiters, 0);
      const totalCost = purchases.reduce((sum, p) => sum + p.amountPaid, 0);
      
      // Get all readings for this month to calculate total consumption
      const allReadings = await this.prisma.waterMeterReading.findMany({
        where: {
          month: dto.month,
          year: dto.year,
          flat: { apartmentId: flat.apartmentId },
        },
      });
      
      // Calculate total consumption (including this flat's updated consumption)
      let totalConsumed = litersConsumed; // Start with current flat
      allReadings.forEach(r => {
        if (r.flatId !== dto.flatId) {
          totalConsumed += r.litersConsumed;
        }
      });
      
      // Proportional distribution: (flat liters / total liters) × total cost
      if (totalConsumed > 0) {
        waterAmount = Math.round((litersConsumed / totalConsumed) * totalCost);
        pricePerLiter = totalCost / totalConsumed;
      }
    }

    return this.prisma.waterMeterReading.upsert({
      where: { flatId_month_year: { flatId: dto.flatId, month: dto.month, year: dto.year } },
      update: { previousReading: dto.previousReading, currentReading: dto.currentReading, litersConsumed, pricePerLiter, waterAmount },
      create: { flatId: dto.flatId, month: dto.month, year: dto.year, previousReading: dto.previousReading, currentReading: dto.currentReading, litersConsumed, pricePerLiter, waterAmount },
    });
  }

  async bulkUpsert(readings: Array<{ flatId: string; month: number; year: number; previousReading: number; currentReading: number; pricePerLiter?: number }>) {
    if (readings.length === 0) return [];

    // Get apartment info from first reading
    const firstFlat = await this.prisma.flat.findUnique({ where: { id: readings[0].flatId } });
    if (!firstFlat) throw new Error('Flat not found');

    const month = readings[0].month;
    const year = readings[0].year;

    // Get tanker purchases for this month
    const purchases = await this.prisma.waterPurchase.findMany({
      where: {
        apartmentId: firstFlat.apartmentId,
        month,
        year,
      },
    });

    let pricePerLiter = 0.088;
    let totalCost = 0;
    let totalConsumed = 0;

    if (purchases.length > 0) {
      totalCost = purchases.reduce((sum, p) => sum + p.amountPaid, 0);
      // Calculate total consumption from the new readings
      totalConsumed = readings.reduce((sum, r) => sum + (r.currentReading - r.previousReading), 0);
      pricePerLiter = totalConsumed > 0 ? totalCost / totalConsumed : 0.088;
    }

    // Save all readings with calculated amounts
    const results: any[] = [];
    for (const dto of readings) {
      const litersConsumed = dto.currentReading - dto.previousReading;
      const waterAmount = purchases.length > 0 && totalConsumed > 0
        ? Math.round((litersConsumed / totalConsumed) * totalCost)
        : Math.round(litersConsumed * 0.088);

      const result = await this.prisma.waterMeterReading.upsert({
        where: { flatId_month_year: { flatId: dto.flatId, month: dto.month, year: dto.year } },
        update: { previousReading: dto.previousReading, currentReading: dto.currentReading, litersConsumed, pricePerLiter, waterAmount },
        create: { flatId: dto.flatId, month: dto.month, year: dto.year, previousReading: dto.previousReading, currentReading: dto.currentReading, litersConsumed, pricePerLiter, waterAmount },
      });
      results.push(result);
    }

    return results;
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
    let noTankerData = 0;
    const details: any[] = [];

    // Group readings by apartment/month/year for batch processing
    const groups = new Map<string, any[]>();
    readings.forEach(r => {
      const key = `${r.flat.apartmentId}-${r.month}-${r.year}`;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(r);
    });

    // Process each group
    for (const [key, groupReadings] of groups) {
      const parts = key.split('-');
      const apartmentId = parts[0];
      const month = parseInt(parts[1], 10);
      const year = parseInt(parts[2], 10);
      
      // Get tanker purchases for this month/year
      const purchases = await this.prisma.waterPurchase.findMany({
        where: {
          apartmentId,
          month,
          year,
        },
      });

      if (purchases.length > 0) {
        const totalCost = purchases.reduce((sum, p) => sum + p.amountPaid, 0);
        const totalConsumed = groupReadings.reduce((sum, r) => sum + r.litersConsumed, 0);
        const pricePerLiter = totalConsumed > 0 ? totalCost / totalConsumed : 0.088;

        // Update each reading with proportional distribution
        for (const reading of groupReadings) {
          const waterAmount = totalConsumed > 0 
            ? Math.round((reading.litersConsumed / totalConsumed) * totalCost)
            : Math.round(reading.litersConsumed * 0.088);

          await this.prisma.waterMeterReading.update({
            where: { id: reading.id },
            data: { pricePerLiter, waterAmount },
          });
          updated++;
          
          if (details.length < 10) {
            details.push({
              flat: reading.flat.flatNumber,
              month: reading.month,
              year: reading.year,
              consumed: reading.litersConsumed,
              oldAmount: reading.waterAmount,
              newAmount: waterAmount,
              rate: parseFloat(pricePerLiter.toFixed(4)),
            });
          }
        }
      } else {
        noTankerData += groupReadings.length;
      }
    }

    return { 
      total: readings.length, 
      updated,
      noTankerData,
      message: `Updated ${updated} readings. ${noTankerData} readings skipped (no tanker data for that month/year)`,
      details,
    };
  }
}
