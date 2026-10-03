import { Module } from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import { ExpensesController } from './expenses.controller';
import { ExpenseTemplatesService } from './expense-templates.service';
import { ExpenseTemplatesController, ExpenseTemplateSetsController } from './expense-templates.controller';

@Module({
  providers: [ExpensesService, ExpenseTemplatesService],
  controllers: [ExpensesController, ExpenseTemplatesController, ExpenseTemplateSetsController],
})
export class ExpensesModule {}
