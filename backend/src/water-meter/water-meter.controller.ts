import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { WaterMeterService } from './water-meter.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('water-meter')
export class WaterMeterController {
  constructor(private waterMeterService: WaterMeterService) {}

  @Get()
  findAll(@Query('flatId') flatId: string, @Query('month') month: string, @Query('year') year: string) {
    return this.waterMeterService.findAll({ flatId, month: month ? +month : undefined, year: year ? +year : undefined });
  }

  @Get('apartment')
  getByApartment(@Query('apartmentId') apartmentId: string, @Query('month') month: string, @Query('year') year: string) {
    return this.waterMeterService.getByApartment(apartmentId, +month, +year);
  }

  @Get(':id')
  findOne(@Param('id') id: string) { return this.waterMeterService.findOne(id); }

  @Post()
  upsert(@Body() dto: any) { return this.waterMeterService.upsert(dto); }

  @Post('bulk')
  bulkUpsert(@Body() dto: { readings: any[] }) { return this.waterMeterService.bulkUpsert(dto.readings); }
}
