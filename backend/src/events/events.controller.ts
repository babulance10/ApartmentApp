import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { EventsService } from './events.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('events')
export class EventsController {
  constructor(private eventsService: EventsService) {}

  @Get()
  findAll(@Query('apartmentId') apartmentId: string) {
    return this.eventsService.findAll(apartmentId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.eventsService.findOne(id);
  }

  @Post()
  create(@Body() dto: { apartmentId: string; name: string; description?: string; targetAmount?: number; startDate?: string; endDate?: string }) {
    return this.eventsService.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: any) {
    return this.eventsService.update(id, dto);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.eventsService.delete(id);
  }

  @Post(':id/collections')
  addCollection(@Param('id') eventId: string, @Body() dto: { flatId: string; userId?: string; amount: number; paidDate?: string; notes?: string }) {
    return this.eventsService.addCollection({ ...dto, eventId });
  }

  @Delete('collections/:collectionId')
  removeCollection(@Param('collectionId') id: string) {
    return this.eventsService.removeCollection(id);
  }

  @Post(':id/expenses')
  addExpense(@Param('id') eventId: string, @Body() dto: { category: string; description: string; amount: number; expenseDate?: string }) {
    return this.eventsService.addExpense({ ...dto, eventId });
  }

  @Delete('expenses/:expenseId')
  removeExpense(@Param('expenseId') id: string) {
    return this.eventsService.removeExpense(id);
  }
}
