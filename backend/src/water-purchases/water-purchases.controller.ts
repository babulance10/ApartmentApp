import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards } from '@nestjs/common';
import { WaterPurchasesService } from './water-purchases.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('water-purchases')
export class WaterPurchasesController {
  constructor(private service: WaterPurchasesService) {}

  @Get()
  findAll(
    @Query('apartmentId') apartmentId: string,
    @Query('month') month?: string,
    @Query('year') year?: string,
  ) {
    return this.service.findAll(apartmentId, month ? +month : undefined, year ? +year : undefined);
  }

  @Get('summary')
  getSummary(
    @Query('apartmentId') apartmentId: string,
    @Query('month') month: string,
    @Query('year') year: string,
  ) {
    return this.service.getSummary(apartmentId, +month, +year);
  }

  @Post()
  create(@Body() dto: any) {
    return this.service.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: any) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
