import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ApartmentsService {
  constructor(private prisma: PrismaService) {}

  findAll() {
    return this.prisma.apartment.findMany({ include: { flats: true } });
  }

  async findOne(id: string) {
    const apt = await this.prisma.apartment.findUnique({ where: { id }, include: { flats: true } });
    if (!apt) throw new NotFoundException('Apartment not found');
    return apt;
  }

  create(dto: { name: string; address: string; city: string; upiNumber?: string; upiName?: string }) {
    return this.prisma.apartment.create({ data: dto });
  }

  update(id: string, dto: { name?: string; address?: string; city?: string; upiNumber?: string; upiName?: string; maintenanceAmount?: number }) {
    return this.prisma.apartment.update({ where: { id }, data: dto });
  }
}
