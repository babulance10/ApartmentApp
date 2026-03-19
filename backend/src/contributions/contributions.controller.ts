import { Controller, Get, Post, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ContributionsService } from './contributions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('contributions')
export class ContributionsController {
  constructor(private contributionsService: ContributionsService) {}

  @Get()
  findAll(
    @Query('flatId') flatId: string,
    @Query('month') month: string,
    @Query('year') year: string,
  ) {
    return this.contributionsService.findAll({
      flatId,
      month: month ? parseInt(month) : undefined,
      year: year ? parseInt(year) : undefined,
    });
  }

  @Get('summary')
  getSummary(
    @Query('apartmentId') apartmentId: string,
    @Query('month') month: string,
    @Query('year') year: string,
  ) {
    return this.contributionsService.getSummaryByApartment(apartmentId, parseInt(month), parseInt(year));
  }

  @Post()
  create(@Body() dto: {
    flatId: string;
    userId: string;
    month: number;
    year: number;
    type: any;
    amount: number;
    description?: string;
  }) {
    return this.contributionsService.create(dto);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.contributionsService.delete(id);
  }
}
