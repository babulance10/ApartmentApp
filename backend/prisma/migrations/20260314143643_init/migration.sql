-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'OWNER', 'TENANT');

-- CreateEnum
CREATE TYPE "BillStatus" AS ENUM ('PENDING', 'PARTIAL', 'PAID');

-- CreateEnum
CREATE TYPE "MaintenanceStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED');

-- CreateEnum
CREATE TYPE "MaintenancePriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "password" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'TENANT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Apartment" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "upiNumber" TEXT,
    "upiName" TEXT,

    CONSTRAINT "Apartment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Flat" (
    "id" TEXT NOT NULL,
    "flatNumber" TEXT NOT NULL,
    "floor" INTEGER NOT NULL,
    "apartmentId" TEXT NOT NULL,

    CONSTRAINT "Flat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FlatOwnership" (
    "id" TEXT NOT NULL,
    "flatId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "fromDate" TIMESTAMP(3) NOT NULL,
    "toDate" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "FlatOwnership_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FlatTenancy" (
    "id" TEXT NOT NULL,
    "flatId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "fromDate" TIMESTAMP(3) NOT NULL,
    "toDate" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "FlatTenancy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WaterMeterReading" (
    "id" TEXT NOT NULL,
    "flatId" TEXT NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "previousReading" DOUBLE PRECISION NOT NULL,
    "currentReading" DOUBLE PRECISION NOT NULL,
    "litersConsumed" DOUBLE PRECISION NOT NULL,
    "pricePerLiter" DOUBLE PRECISION NOT NULL DEFAULT 0.088,
    "waterAmount" DOUBLE PRECISION NOT NULL,
    "readingDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WaterMeterReading_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonthlyBill" (
    "id" TEXT NOT NULL,
    "flatId" TEXT NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "maintenanceAmount" DOUBLE PRECISION NOT NULL DEFAULT 2000,
    "waterAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "previousDue" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "totalAmount" DOUBLE PRECISION NOT NULL,
    "paidAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status" "BillStatus" NOT NULL DEFAULT 'PENDING',
    "generatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MonthlyBill_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "billId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "paymentDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "paymentMethod" TEXT,
    "transactionRef" TEXT,
    "notes" TEXT,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Expense" (
    "id" TEXT NOT NULL,
    "apartmentId" TEXT NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "expenseDate" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Expense_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MaintenanceRequest" (
    "id" TEXT NOT NULL,
    "flatId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" "MaintenanceStatus" NOT NULL DEFAULT 'OPEN',
    "priority" "MaintenancePriority" NOT NULL DEFAULT 'MEDIUM',
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MaintenanceRequest_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Flat_flatNumber_apartmentId_key" ON "Flat"("flatNumber", "apartmentId");

-- CreateIndex
CREATE UNIQUE INDEX "WaterMeterReading_flatId_month_year_key" ON "WaterMeterReading"("flatId", "month", "year");

-- CreateIndex
CREATE UNIQUE INDEX "MonthlyBill_flatId_month_year_key" ON "MonthlyBill"("flatId", "month", "year");

-- AddForeignKey
ALTER TABLE "Flat" ADD CONSTRAINT "Flat_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES "Apartment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FlatOwnership" ADD CONSTRAINT "FlatOwnership_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES "Flat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FlatOwnership" ADD CONSTRAINT "FlatOwnership_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FlatTenancy" ADD CONSTRAINT "FlatTenancy_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES "Flat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FlatTenancy" ADD CONSTRAINT "FlatTenancy_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WaterMeterReading" ADD CONSTRAINT "WaterMeterReading_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES "Flat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MonthlyBill" ADD CONSTRAINT "MonthlyBill_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES "Flat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_billId_fkey" FOREIGN KEY ("billId") REFERENCES "MonthlyBill"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES "Apartment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceRequest" ADD CONSTRAINT "MaintenanceRequest_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES "Flat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceRequest" ADD CONSTRAINT "MaintenanceRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
