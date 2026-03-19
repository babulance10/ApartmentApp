import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const waterRecords: any[] = require('/tmp/water_import.json');
const expenseRecords: any[] = require('/tmp/expense_import.json');

const APARTMENT_ID = 'psa-main';

async function main() {
  // --- Water Meter Readings ---
  const flats = await prisma.flat.findMany({ where: { apartmentId: APARTMENT_ID } });
  const flatMap = Object.fromEntries(flats.map(f => [f.flatNumber, f.id]));

  let wmCreated = 0, wmSkipped = 0;
  for (const r of waterRecords) {
    const flatId = flatMap[r.flat];
    if (!flatId) { wmSkipped++; continue; }
    try {
      await prisma.waterMeterReading.upsert({
        where: { flatId_month_year: { flatId, month: r.month, year: r.year } },
        update: {},
        create: {
          flatId,
          month: r.month,
          year: r.year,
          previousReading: r.prev,
          currentReading: r.curr,
          litersConsumed: r.liters,
          waterAmount: r.waterAmount,
          pricePerLiter: 0.088,
        },
      });
      wmCreated++;
    } catch (e: any) {
      wmSkipped++;
    }
  }
  console.log(`Water meter: ${wmCreated} upserted, ${wmSkipped} skipped`);

  // --- Expenses ---
  const CATEGORY_MAP: Record<string, string> = {
    'watch man salary': 'Security',
    'watchman salary': 'Security',
    'watchman': 'Security',
    'security': 'Security',
    'electric city': 'Electricity',
    'electricity': 'Electricity',
    'electriciy': 'Electricity',
    'lift maintenance': 'Maintenance',
    'lift maintence': 'Maintenance',
    'lift maintanance': 'Maintenance',
    'grabage payment': 'Cleaning',
    'garbage payment': 'Cleaning',
    'garbage': 'Cleaning',
    'housekeeping': 'Cleaning',
    'cleaning': 'Cleaning',
    'diesel': 'Fuel',
    'water': 'Water',
    'water bill': 'Water',
    'water tanker': 'Water',
    'common water bill': 'Water',
    'manjeera': 'Water',
    'plumber': 'Maintenance',
    'miscellaneous': 'Miscellaneous',
  };

  function mapCategory(raw: string): string {
    const lower = raw.toLowerCase();
    for (const [key, val] of Object.entries(CATEGORY_MAP)) {
      if (lower.includes(key)) return val;
    }
    return 'Miscellaneous';
  }

  let exCreated = 0, exSkipped = 0;
  for (const r of expenseRecords) {
    const cat = mapCategory(r.category);
    try {
      await prisma.expense.create({
        data: {
          apartmentId: APARTMENT_ID,
          month: r.month,
          year: r.year,
          category: cat,
          description: r.category,
          amount: r.amount,
          expenseDate: new Date(`${r.year}-${String(r.month).padStart(2, '0')}-01`),
        },
      });
      exCreated++;
    } catch (e: any) {
      exSkipped++;
    }
  }
  console.log(`Expenses: ${exCreated} created, ${exSkipped} skipped`);
}

main().catch(console.error).finally(() => prisma.$disconnect());
