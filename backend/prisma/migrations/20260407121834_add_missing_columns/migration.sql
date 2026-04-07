/*
  Warnings:

  - You are about to drop the column `isOwnerTenant` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `role` on the `User` table. All the data in the column will be lost.

*/
-- CreateEnum
CREATE TYPE "EventStatus" AS ENUM ('PLANNING', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "Role" ADD VALUE 'VIEWER';
ALTER TYPE "Role" ADD VALUE 'WATER_MANAGER';

-- AlterTable
ALTER TABLE "Apartment" ADD COLUMN     "maintenanceAmount" DOUBLE PRECISION NOT NULL DEFAULT 2000;

-- AlterTable
ALTER TABLE "User" DROP COLUMN "isOwnerTenant",
DROP COLUMN "role",
ADD COLUMN     "roles" "Role"[] DEFAULT ARRAY['TENANT']::"Role"[];

-- CreateTable
CREATE TABLE "Event" (
    "id" TEXT NOT NULL,
    "apartmentId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "targetAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status" "EventStatus" NOT NULL DEFAULT 'PLANNING',
    "startDate" TIMESTAMP(3),
    "endDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventCollection" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "flatId" TEXT NOT NULL,
    "userId" TEXT,
    "amount" DOUBLE PRECISION NOT NULL,
    "paidDate" TIMESTAMP(3),
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EventCollection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventExpense" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "expenseDate" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EventExpense_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES "Apartment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventCollection" ADD CONSTRAINT "EventCollection_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "Event"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventCollection" ADD CONSTRAINT "EventCollection_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES "Flat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventCollection" ADD CONSTRAINT "EventCollection_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventExpense" ADD CONSTRAINT "EventExpense_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "Event"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
