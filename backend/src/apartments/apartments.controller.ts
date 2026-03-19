import { Controller, Get, Post, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { ApartmentsService } from './apartments.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('apartments')
export class ApartmentsController {
  constructor(private apartmentsService: ApartmentsService) {}

  @Get()
  findAll() { return this.apartmentsService.findAll(); }

  @Get(':id')
  findOne(@Param('id') id: string) { return this.apartmentsService.findOne(id); }

  @Post()
  create(@Body() dto: { name: string; address: string; city: string; upiNumber?: string; upiName?: string }) {
    return this.apartmentsService.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: any) {
    return this.apartmentsService.update(id, dto);
  }
}
