import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { BillsService } from './bills.service';
import { BillsController, BillsCronController } from './bills.controller';
import { BillsSchedulerService } from './bills-scheduler.service';
import { WhatsappModule } from '../whatsapp/whatsapp.module';

@Module({
  imports: [ScheduleModule.forRoot(), WhatsappModule],
  providers: [BillsService, BillsSchedulerService],
  controllers: [BillsController, BillsCronController],
  exports: [BillsService],
})
export class BillsModule {}
