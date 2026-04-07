import { Module } from '@nestjs/common';
import { WaterMeterService } from './water-meter.service';
import { WaterMeterController, WaterMeterAuthController } from './water-meter.controller';

@Module({
  providers: [WaterMeterService],
  controllers: [WaterMeterController, WaterMeterAuthController],
  exports: [WaterMeterService],
})
export class WaterMeterModule {}
