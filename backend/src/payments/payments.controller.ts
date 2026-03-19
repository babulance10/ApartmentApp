import { Controller, Get, Post, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Get()
  findAll(@Query('billId') billId: string) {
    return this.paymentsService.findAll(billId);
  }

  @Post()
  create(@Body() dto: { billId: string; amount: number; paymentDate?: string; paymentMethod?: string; transactionRef?: string; notes?: string }) {
    return this.paymentsService.create(dto);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.paymentsService.delete(id);
  }
}
