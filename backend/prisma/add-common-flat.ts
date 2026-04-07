import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Find the psa-main apartment
  const apartment = await prisma.apartment.findUnique({
    where: { id: 'psa-main' },
  });

  if (!apartment) {
    console.log('Apartment psa-main not found');
    return;
  }

  // Check if Common flat already exists
  const existingCommon = await prisma.flat.findUnique({
    where: { flatNumber_apartmentId: { flatNumber: 'Common', apartmentId: 'psa-main' } },
  });

  if (existingCommon) {
    console.log('Common flat already exists');
    return;
  }

  // Create Common flat
  const commonFlat = await prisma.flat.create({
    data: {
      flatNumber: 'Common',
      floor: 0,
      apartmentId: 'psa-main',
    },
  });

  console.log('Common flat created:', commonFlat);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
