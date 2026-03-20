import { Controller, Get, Post, Body, Patch, Param, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get('me')
  getMe(@Request() req: any) {
    return this.usersService.findMe(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Post()
  create(@Body() dto: { name: string; email: string; phone?: string; password: string; roles?: any[] }) {
    return this.usersService.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: { name?: string; phone?: string; roles?: any[] }) {
    return this.usersService.update(id, dto);
  }

  @Patch(':id/password')
  changePassword(@Param('id') id: string, @Body() dto: { password: string }) {
    return this.usersService.changePassword(id, dto.password);
  }

  @Post('me/change-password')
  changeMyPassword(@Request() req: any, @Body() dto: { oldPassword: string; newPassword: string }) {
    return this.usersService.changeMyPassword(req.user.id, dto.oldPassword, dto.newPassword);
  }

}
