import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards, Request, Headers, UnauthorizedException } from '@nestjs/common';
import { BillsService } from './bills.service';
import { ConfigService } from '@nestjs/config';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { WhatsappService } from '../whatsapp/whatsapp.service';

// Public endpoint — no JWT, protected by CRON_SECRET header for cron-job.org
@Controller('bills')
export class BillsCronController {
  constructor(private billsService: BillsService, private config: ConfigService) {}

  @Post('cron-trigger')
  async cronTrigger(
    @Headers('x-cron-secret') secret: string,
    @Body() body: { apartmentId?: string; month?: number; year?: number },
  ) {
    const expected = this.config.get<string>('CRON_SECRET', '');
    if (!expected || secret !== expected) throw new UnauthorizedException('Invalid cron secret');
    const now = new Date();
    const month = body.month ?? now.getMonth() + 1;
    const year = body.year ?? now.getFullYear();
    const apartmentId = body.apartmentId ?? this.config.get<string>('APARTMENT_ID', 'psa-main');
    return this.billsService.bulkSendEmails(apartmentId, month, year);
  }
}

@UseGuards(JwtAuthGuard)
@Controller('bills')
export class BillsController {
  constructor(private billsService: BillsService, private wa: WhatsappService) {}

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

  @Post('bulk-send-whatsapp')
  async bulkSendWhatsApp(@Body() dto: { apartmentId: string; month: number; year: number }) {
    if (this.wa.status !== 'ready') {
      return { error: 'WhatsApp not connected. Please connect first via /api/whatsapp/connect.' };
    }
    const summary = await this.billsService.getSummary(dto.apartmentId, dto.month, dto.year);
    const bills = (summary as any).bills ?? [];
    const unpaid = bills.filter((b: any) => b.status !== 'PAID');
    const sent: string[] = [];
    const failed: string[] = [];
    const skipped: string[] = [];

    for (const bill of unpaid) {
      const tenant = bill.flat?.tenancies?.[0]?.user;
      const phone = tenant?.phone;
      const flat = bill.flat?.flatNumber;
      if (!phone) { skipped.push(flat); continue; }

      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      const balance = bill.totalAmount - bill.paidAmount;
      const msg =
        `Dear ${tenant.name},\n\n` +
        `Your maintenance bill for *${months[dto.month - 1]} ${dto.year}*:\n` +
        `• Flat: *${flat}*\n` +
        `• Maintenance: ₹${bill.maintenanceAmount}\n` +
        (bill.waterAmount > 0 ? `• Water: ₹${bill.waterAmount}\n` : '') +
        (bill.previousDue > 0 ? `• Previous Due: ₹${bill.previousDue}\n` : '') +
        `• *Total: ₹${bill.totalAmount}*\n` +
        (bill.paidAmount > 0 ? `• Paid: ₹${bill.paidAmount}\n` : '') +
        `• *Balance Due: ₹${balance}*\n\n` +
        `Please pay via UPI at your earliest convenience.\n\nThank you!\n— PSA Association`;

      try {
        await this.wa.sendMessage(phone, msg);
        sent.push(flat);
        await new Promise(r => setTimeout(r, 1500));
      } catch (e: any) {
        failed.push(flat);
      }
    }

    return { sent, failed, skipped };
  }

  @Patch(':id')
  updateBill(@Param('id') id: string, @Body() dto: { maintenanceAmount?: number; waterAmount?: number; previousDue?: number }) {
    return this.billsService.updateBill(id, dto);
  }

  @Post(':id/update-status')
  updateStatus(@Param('id') id: string) { return this.billsService.updateStatus(id); }
}
