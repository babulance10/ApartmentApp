import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { BillsService } from './bills.service';
import { BillsController } from './bills.controller';
import { BillsSchedulerService } from './bills-scheduler.service';

@Module({
  imports: [ScheduleModule.forRoot()],
  providers: [BillsService, BillsSchedulerService],
  controllers: [BillsController],
  exports: [BillsService],
})
export class BillsModule {}
