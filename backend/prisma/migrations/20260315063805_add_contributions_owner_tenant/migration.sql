-- CreateEnum
CREATE TYPE "ContributionType" AS ENUM ('WATER', 'MAINTENANCE', 'OTHER');

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "isOwnerTenant" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "FlatContribution" (
    "id" TEXT NOT NULL,
    "flatId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "type" "ContributionType" NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "description" TEXT,
    "appliedToBillId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FlatContribution_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "FlatContribution" ADD CONSTRAINT "FlatContribution_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES "Flat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FlatContribution" ADD CONSTRAINT "FlatContribution_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
