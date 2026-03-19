import { Module } from '@nestjs/common';
import { WaterPurchasesService } from './water-purchases.service';
import { WaterPurchasesController } from './water-purchases.controller';

@Module({
  providers: [WaterPurchasesService],
  controllers: [WaterPurchasesController],
})
export class WaterPurchasesModule {}
