import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { BillsService } from './bills.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('bills')
export class BillsController {
  constructor(private billsService: BillsService) {}

  @Get()
  findAll(
    @Query('flatId') flatId: string,
    @Query('month') month: string,
    @Query('year') year: string,
    @Query('status') status: any,
  ) {
    return this.billsService.findAll({
      flatId,
      month: month ? parseInt(month) : undefined,
      year: year ? parseInt(year) : undefined,
      status,
    });
  }

  @Get('my')
  findMyBills(@Request() req: any, @Query('flatId') flatId: string) {
    return this.billsService.findForFlat(flatId);
  }

  @Get('all-time-totals')
  getAllTimeTotals(@Query('apartmentId') apartmentId: string) {
    return this.billsService.getAllTimeTotals(apartmentId);
  }

  @Get('summary')
  getSummary(
    @Query('apartmentId') apartmentId: string,
    @Query('month') month: string,
    @Query('year') year: string,
  ) {
    return this.billsService.getSummary(apartmentId, parseInt(month), parseInt(year));
  }

  @Get(':id')
  findOne(@Param('id') id: string) { return this.billsService.findOne(id); }

  @Post()
  create(@Body() dto: any) { return this.billsService.create(dto); }

  @Post('generate')
  generateMonthlyBills(@Body() dto: { apartmentId: string; month: number; year: number; maintenanceAmount?: number }) {
    return this.billsService.generateMonthlyBills(dto.apartmentId, dto.month, dto.year, dto.maintenanceAmount);
  }

  @Post('bulk-send-email')
  bulkSendEmails(@Body() dto: { apartmentId: string; month: number; year: number }) {
    return this.billsService.bulkSendEmails(dto.apartmentId, dto.month, dto.year);
  }

  @Patch(':id')
  updateBill(@Param('id') id: string, @Body() dto: { maintenanceAmount?: number; waterAmount?: number; previousDue?: number }) {
    return this.billsService.updateBill(id, dto);
  }

  @Post(':id/update-status')
  updateStatus(@Param('id') id: string) { return this.billsService.updateStatus(id); }
}
