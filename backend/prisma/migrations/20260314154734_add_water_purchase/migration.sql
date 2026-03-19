-- CreateTable
CREATE TABLE "WaterPurchase" (
    "id" TEXT NOT NULL,
    "apartmentId" TEXT NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "srNo" INTEGER NOT NULL,
    "capacityLiters" INTEGER NOT NULL DEFAULT 10000,
    "tokenNo" TEXT NOT NULL,
    "bookedOn" TIMESTAMP(3) NOT NULL,
    "deliveredOn" TIMESTAMP(3) NOT NULL,
    "amountPaid" DOUBLE PRECISION NOT NULL,
    "vehicleNo" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WaterPurchase_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "WaterPurchase" ADD CONSTRAINT "WaterPurchase_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES "Apartment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
