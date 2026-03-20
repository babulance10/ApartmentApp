import { Controller, Get, Post, Delete, UseGuards } from '@nestjs/common';
import { WhatsappService } from './whatsapp.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('whatsapp')
export class WhatsappController {
  constructor(private wa: WhatsappService) {}

  @Get('status')
  getStatus() {
    return { status: this.wa.status, qr: this.wa.qrDataUrl };
  }

  @Post('connect')
  async connect() {
    if (this.wa.status === 'ready') return { status: 'ready' };
    await this.wa.initialize();
    return { status: this.wa.status };
  }

  @Delete('disconnect')
  async disconnect() {
    await this.wa.disconnect();
    return { status: 'disconnected' };
  }
}
