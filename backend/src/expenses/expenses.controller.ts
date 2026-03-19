import { Controller, Get, Post, Body, Patch, Delete, Param, Query, UseGuards } from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('expenses')
export class ExpensesController {
  constructor(private expensesService: ExpensesService) {}

  @Get()
  findAll(
    @Query('apartmentId') apartmentId: string,
    @Query('month') month: string,
    @Query('year') year: string,
    @Query('category') category: string,
  ) {
    return this.expensesService.findAll({ apartmentId, month: month ? +month : undefined, year: year ? +year : undefined, category });
  }

  @Get('summary')
  getSummary(@Query('apartmentId') apartmentId: string, @Query('year') year: string) {
    return this.expensesService.getSummaryByMonth(apartmentId, +year);
  }

  @Get(':id')
  findOne(@Param('id') id: string) { return this.expensesService.findOne(id); }

  @Post()
  create(@Body() dto: any) { return this.expensesService.create(dto); }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: any) { return this.expensesService.update(id, dto); }

  @Delete(':id')
  delete(@Param('id') id: string) { return this.expensesService.delete(id); }
}
