import { PrismaService } from '../src/prisma/prisma.service';

const prisma = new PrismaService();

async function main() {
  // Get the Common flat
  const commonFlat = await prisma.flat.findUnique({
    where: { flatNumber_apartmentId: { flatNumber: 'Common', apartmentId: 'psa-main' } },
  });

  if (!commonFlat) {
    console.log('Common flat not found');
    return;
  }

  // Check if reading already exists for March 2026
  const existingReading = await prisma.waterMeterReading.findUnique({
    where: { flatId_month_year: { flatId: commonFlat.id, month: 3, year: 2026 } },
  });

  if (existingReading) {
    console.log('Common water reading for March 2026 already exists');
    return;
  }

  // Create water meter reading for Common area
  // Common area consumed 1,500 L in March 2026
  const reading = await prisma.waterMeterReading.create({
    data: {
      flatId: commonFlat.id,
      month: 3,
      year: 2026,
      previousReading: 0,
      currentReading: 1500,
      litersConsumed: 1500,
      pricePerLiter: 0.088,
      waterAmount: 0, // Will be calculated by recalculate endpoint
    },
  });

  console.log('Common water reading created:', reading);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
