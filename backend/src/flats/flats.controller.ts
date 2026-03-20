import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { FlatsService } from './flats.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('flats')
export class FlatsController {
  constructor(private flatsService: FlatsService) {}

  @Get()
  findAll(@Query('apartmentId') apartmentId: string) {
    return this.flatsService.findAll(apartmentId);
  }

  @Get('my')
  findMyFlats(@Request() req: any) {
    return this.flatsService.findByUser(req.user.id, req.user.roles);
  }

  @Get(':id')
  findOne(@Param('id') id: string) { return this.flatsService.findOne(id); }

  @Post()
  create(@Body() dto: { flatNumber: string; floor: number; apartmentId: string }) {
    return this.flatsService.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: { flatNumber?: string; floor?: number }) {
    return this.flatsService.update(id, dto);
  }

  @Post(':id/assign-owner')
  assignOwner(@Param('id') id: string, @Body() dto: { userId: string; fromDate: string }) {
    return this.flatsService.assignOwner(id, dto.userId, new Date(dto.fromDate));
  }

  @Post(':id/assign-tenant')
  assignTenant(@Param('id') id: string, @Body() dto: { userId: string; fromDate: string }) {
    return this.flatsService.assignTenant(id, dto.userId, new Date(dto.fromDate));
  }

  @Post(':id/remove-owner')
  removeOwner(@Param('id') id: string) { return this.flatsService.removeOwner(id); }

  @Post(':id/remove-tenant')
  removeTenant(@Param('id') id: string) { return this.flatsService.removeTenant(id); }
}
