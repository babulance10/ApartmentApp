import { Controller, Get, Post, Body, Delete, Param, Query, UseGuards } from '@nestjs/common';
import { ExpenseTemplatesService } from './expense-templates.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('expense-templates')
export class ExpenseTemplatesController {
  constructor(private templatesService: ExpenseTemplatesService) {}

  @Get()
  findAll(@Query('apartmentId') apartmentId: string) {
    return this.templatesService.findAll(apartmentId);
  }

  @Post()
  create(@Body() dto: { apartmentId: string; category: string; description: string; amount: number }) {
    return this.templatesService.create(dto);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.templatesService.delete(id);
  }
}

@UseGuards(JwtAuthGuard)
@Controller('expense-template-sets')
export class ExpenseTemplateSetsController {
  constructor(private templatesService: ExpenseTemplatesService) {}

  @Get()
  findAll(@Query('apartmentId') apartmentId: string) {
    return this.templatesService.findAllSets(apartmentId);
  }

  @Post()
  create(@Body() dto: { apartmentId: string; name: string; items: { category: string; description: string; amount: number }[] }) {
    return this.templatesService.createSet(dto);
  }

  @Post('from-month')
  createFromMonth(@Body() dto: { apartmentId: string; name: string; month: number; year: number }) {
    return this.templatesService.createSetFromMonth(dto);
  }

  @Post(':id/apply')
  apply(@Param('id') id: string, @Body() dto: { month: number; year: number; itemIds?: string[] }) {
    return this.templatesService.applySet(id, dto);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.templatesService.deleteSet(id);
  }
}
