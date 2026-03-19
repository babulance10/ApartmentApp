import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { MaintenanceService } from './maintenance.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('maintenance')
export class MaintenanceController {
  constructor(private maintenanceService: MaintenanceService) {}

  @Get()
  findAll(@Query('flatId') flatId: string, @Query('status') status: any) {
    return this.maintenanceService.findAll({ flatId, status });
  }

  @Get(':id')
  findOne(@Param('id') id: string) { return this.maintenanceService.findOne(id); }

  @Post()
  create(@Body() dto: any, @Request() req: any) {
    return this.maintenanceService.create({ ...dto, userId: req.user.id });
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body() dto: { status: any }) {
    return this.maintenanceService.updateStatus(id, dto.status);
  }

  @Delete(':id')
  delete(@Param('id') id: string) { return this.maintenanceService.delete(id); }
}
