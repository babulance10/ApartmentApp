import { Module } from '@nestjs/common';
import { ContributionsService } from './contributions.service';
import { ContributionsController } from './contributions.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ContributionsController],
  providers: [ContributionsService],
  exports: [ContributionsService],
})
export class ContributionsModule {}
