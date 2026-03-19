import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const adminPassword = await bcrypt.hash('admin123', 10);
  const tenantPassword = await bcrypt.hash('tenant123', 10);
  const ownerPassword = await bcrypt.hash('owner123', 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@psa.com' },
    update: {},
    create: { name: 'PSA Admin', email: 'admin@psa.com', password: adminPassword, role: Role.ADMIN, phone: '7093991333' },
  });

  const owner101 = await prisma.user.upsert({
    where: { email: 'owner101@psa.com' },
    update: {},
    create: { name: 'Owner Flat 101', email: 'owner101@psa.com', password: ownerPassword, role: Role.OWNER, phone: '9000000101' },
  });

  const apartment = await prisma.apartment.upsert({
    where: { id: 'psa-main' },
    update: {},
    create: {
      id: 'psa-main',
      name: 'PRIMARK SREENIDHI APARTMENT',
      address: 'Kondapur',
      city: 'Hyderabad',
      upiNumber: '7093991333',
      upiName: 'PSA Association',
    },
  });

  const flats = [
    { flatNumber: '101', floor: 1 }, { flatNumber: '102', floor: 1 }, { flatNumber: '103', floor: 1 },
    { flatNumber: '201', floor: 2 }, { flatNumber: '202', floor: 2 }, { flatNumber: '203', floor: 2 },
    { flatNumber: '301', floor: 3 }, { flatNumber: '302', floor: 3 }, { flatNumber: '303', floor: 3 },
    { flatNumber: '401', floor: 4 }, { flatNumber: '402', floor: 4 }, { flatNumber: '403', floor: 4 },
    { flatNumber: '501', floor: 5 }, { flatNumber: '502', floor: 5 }, { flatNumber: '503', floor: 5 },
  ];

  for (const f of flats) {
    const flat = await prisma.flat.upsert({
      where: { flatNumber_apartmentId: { flatNumber: f.flatNumber, apartmentId: apartment.id } },
      update: {},
      create: { ...f, apartmentId: apartment.id },
    });

    const tenantEmail = `flat${f.flatNumber}@psa.com`;
    const tenant = await prisma.user.upsert({
      where: { email: tenantEmail },
      update: {},
      create: {
        name: `Resident ${f.flatNumber}`,
        email: tenantEmail,
        password: tenantPassword,
        role: Role.TENANT,
      },
    });

    const existingTenancy = await prisma.flatTenancy.findFirst({
      where: { flatId: flat.id, userId: tenant.id, isActive: true },
    });
    if (!existingTenancy) {
      await prisma.flatTenancy.create({
        data: { flatId: flat.id, userId: tenant.id, fromDate: new Date('2024-01-01'), isActive: true },
      });
    }

    if (f.flatNumber === '101') {
      const existingOwnership = await prisma.flatOwnership.findFirst({
        where: { flatId: flat.id, userId: owner101.id, isActive: true },
      });
      if (!existingOwnership) {
        await prisma.flatOwnership.create({
          data: { flatId: flat.id, userId: owner101.id, fromDate: new Date('2024-01-01'), isActive: true },
        });
      }
    }
  }

  const expenseData = [
    { month: 10, year: 2025, category: 'Security', description: 'Security guard salary', amount: 8000 },
    { month: 10, year: 2025, category: 'Cleaning', description: 'Housekeeping', amount: 3000 },
    { month: 10, year: 2025, category: 'Electricity', description: 'Common area electricity', amount: 2500 },
    { month: 10, year: 2025, category: 'Maintenance', description: 'Lift maintenance', amount: 2000 },
    { month: 1, year: 2026, category: 'Security', description: 'Security guard salary', amount: 8000 },
    { month: 1, year: 2026, category: 'Cleaning', description: 'Housekeeping', amount: 3000 },
    { month: 1, year: 2026, category: 'Electricity', description: 'Common area electricity', amount: 2500 },
    { month: 1, year: 2026, category: 'Water', description: 'Water tanker', amount: 5000 },
    { month: 2, year: 2026, category: 'Security', description: 'Security guard salary', amount: 8000 },
    { month: 2, year: 2026, category: 'Cleaning', description: 'Housekeeping', amount: 3000 },
    { month: 2, year: 2026, category: 'Electricity', description: 'Common area electricity', amount: 2500 },
  ];

  for (const e of expenseData) {
    await prisma.expense.create({
      data: { ...e, apartmentId: apartment.id, expenseDate: new Date(`${e.year}-${String(e.month).padStart(2, '0')}-01`) },
    });
  }

  console.log('Seed complete!');
  console.log('Admin login: admin@psa.com / admin123');
  console.log('Owner login: owner101@psa.com / owner123');
  console.log('Tenant login: flat101@psa.com / tenant123 (replace 101 with any flat number)');
}

main().catch(console.error).finally(() => prisma.$disconnect());
