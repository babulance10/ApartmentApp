-- AlterTable
ALTER TABLE "ExpenseTemplate" ADD COLUMN     "setId" TEXT;

-- CreateTable
CREATE TABLE "ExpenseTemplateSet" (
    "id" TEXT NOT NULL,
    "apartmentId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExpenseTemplateSet_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "ExpenseTemplateSet" ADD CONSTRAINT "ExpenseTemplateSet_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES "Apartment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExpenseTemplate" ADD CONSTRAINT "ExpenseTemplate_setId_fkey" FOREIGN KEY ("setId") REFERENCES "ExpenseTemplateSet"("id") ON DELETE CASCADE ON UPDATE CASCADE;
