import { Module } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { BillsModule } from '../bills/bills.module';

@Module({
  imports: [BillsModule],
  providers: [PaymentsService],
  controllers: [PaymentsController],
})
export class PaymentsModule {}
