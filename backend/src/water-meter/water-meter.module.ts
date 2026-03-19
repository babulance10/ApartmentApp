import { Module } from '@nestjs/common';
import { WaterMeterService } from './water-meter.service';
import { WaterMeterController } from './water-meter.controller';

@Module({
  providers: [WaterMeterService],
  controllers: [WaterMeterController],
  exports: [WaterMeterService],
})
export class WaterMeterModule {}
