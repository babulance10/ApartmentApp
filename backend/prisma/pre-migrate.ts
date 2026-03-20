/**
 * Pre-migration script: copies data from old `role` column to new `roles` array
 * before prisma db push drops the old column.
 * Run this ONCE before deploying the roles migration.
 */
import { PrismaClient } from '@prisma/client';

async function main() {
  // Use raw SQL since the Prisma client may not match the current DB schema
  const prisma = new PrismaClient();

  try {
    // Check if old 'role' column still exists
    const cols: any[] = await prisma.$queryRaw`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = 'User' AND column_name = 'role'
    `;

    if (cols.length > 0) {
      console.log('Found old "role" column — migrating to "roles" array...');

      // Check if 'roles' column exists yet
      const rolesCols: any[] = await prisma.$queryRaw`
        SELECT column_name FROM information_schema.columns 
        WHERE table_name = 'User' AND column_name = 'roles'
      `;

      if (rolesCols.length === 0) {
        // Add roles column first
        await prisma.$executeRaw`ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "roles" "Role"[] DEFAULT ARRAY['TENANT']::"Role"[]`;
        console.log('Added "roles" column');
      }

      // Copy role → roles for all users that have empty roles
      await prisma.$executeRaw`
        UPDATE "User" SET "roles" = ARRAY["role"]::"Role"[] 
        WHERE "roles" IS NULL OR array_length("roles", 1) IS NULL OR array_length("roles", 1) = 0
      `;
      console.log('Copied role → roles for all users');

      // Handle isOwnerTenant flag: add TENANT to owners who are also tenants
      const hasOwnerTenant: any[] = await prisma.$queryRaw`
        SELECT column_name FROM information_schema.columns 
        WHERE table_name = 'User' AND column_name = 'isOwnerTenant'
      `;
      if (hasOwnerTenant.length > 0) {
        await prisma.$executeRaw`
          UPDATE "User" SET "roles" = ARRAY['OWNER', 'TENANT']::"Role"[] 
          WHERE "isOwnerTenant" = true
        `;
        console.log('Updated isOwnerTenant users to have [OWNER, TENANT] roles');
      }

      console.log('Pre-migration complete!');
    } else {
      console.log('Old "role" column not found — migration already applied, skipping.');
    }
  } catch (e: any) {
    console.log('Pre-migration note:', e.message);
  } finally {
    await prisma.$disconnect();
  }
}

main();
