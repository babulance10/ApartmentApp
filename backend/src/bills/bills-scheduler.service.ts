import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { ConfigService } from '@nestjs/config';
import { BillsService } from './bills.service';

@Injectable()
export class BillsSchedulerService {
  private readonly logger = new Logger(BillsSchedulerService.name);
  private readonly APARTMENT_ID: string;

  constructor(private billsService: BillsService, private config: ConfigService) {
    this.APARTMENT_ID = this.config.get<string>('APARTMENT_ID', 'psa-main');
  }

  // Runs on the 5th of every month at 9:00 AM IST (3:30 AM UTC)
  @Cron('30 3 5 * *', { timeZone: 'Asia/Kolkata' })
  async sendMonthlyReminders() {
    const now = new Date();
    const month = now.getMonth() + 1;
    const year = now.getFullYear();
    this.logger.log(`Scheduled email reminder: ${month}/${year}`);
    try {
      const result = await this.billsService.bulkSendEmails(this.APARTMENT_ID, month, year);
      this.logger.log(`Sent: ${result.sent.length}, Skipped: ${result.skipped.length}, Failed: ${result.failed.length}`);
    } catch (err) {
      this.logger.error('Scheduled email failed', err);
    }
  }

  // Also runs on the 15th as a second reminder for unpaid bills
  @Cron('30 3 15 * *', { timeZone: 'Asia/Kolkata' })
  async sendMidMonthReminders() {
    const now = new Date();
    const month = now.getMonth() + 1;
    const year = now.getFullYear();
    this.logger.log(`Mid-month reminder: ${month}/${year}`);
    try {
      const result = await this.billsService.bulkSendEmails(this.APARTMENT_ID, month, year);
      this.logger.log(`Sent: ${result.sent.length}, Skipped: ${result.skipped.length}, Failed: ${result.failed.length}`);
    } catch (err) {
      this.logger.error('Mid-month email failed', err);
    }
  }
}
