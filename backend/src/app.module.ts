import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ApartmentsModule } from './apartments/apartments.module';
import { FlatsModule } from './flats/flats.module';
import { BillsModule } from './bills/bills.module';
import { PaymentsModule } from './payments/payments.module';
import { WaterMeterModule } from './water-meter/water-meter.module';
import { ExpensesModule } from './expenses/expenses.module';
import { MaintenanceModule } from './maintenance/maintenance.module';
import { WaterPurchasesModule } from './water-purchases/water-purchases.module';
import { ContributionsModule } from './contributions/contributions.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UsersModule,
    ApartmentsModule,
    FlatsModule,
    BillsModule,
    PaymentsModule,
    WaterMeterModule,
    ExpensesModule,
    MaintenanceModule,
    WaterPurchasesModule,
    ContributionsModule,
  ],
})
export class AppModule {}
