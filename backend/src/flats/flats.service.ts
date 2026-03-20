import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FlatsService {
  constructor(private prisma: PrismaService) {}

  findAll(apartmentId?: string) {
    return this.prisma.flat.findMany({
      where: apartmentId ? { apartmentId } : undefined,
      include: {
        ownerships: { where: { isActive: true }, include: { user: { select: { id: true, name: true, email: true, phone: true } } } },
        tenancies: { where: { isActive: true }, include: { user: { select: { id: true, name: true, email: true, phone: true } } } },
      },
      orderBy: { flatNumber: 'asc' },
    });
  }

  async findOne(id: string) {
    const flat = await this.prisma.flat.findUnique({
      where: { id },
      include: {
        apartment: true,
        ownerships: { include: { user: { select: { id: true, name: true, email: true, phone: true } } } },
        tenancies: { include: { user: { select: { id: true, name: true, email: true, phone: true } } } },
      },
    });
    if (!flat) throw new NotFoundException('Flat not found');
    return flat;
  }

  async findByUser(userId: string, roles: string[]) {
    if (roles?.includes('OWNER')) {
      return this.prisma.flat.findMany({
        where: { ownerships: { some: { userId, isActive: true } } },
        include: {
          ownerships: { where: { isActive: true }, include: { user: { select: { id: true, name: true } } } },
          tenancies: { where: { isActive: true }, include: { user: { select: { id: true, name: true } } } },
        },
      });
    }
    return this.prisma.flat.findMany({
      where: { tenancies: { some: { userId, isActive: true } } },
      include: { apartment: true },
    });
  }

  create(dto: { flatNumber: string; floor: number; apartmentId: string }) {
    return this.prisma.flat.create({ data: dto });
  }

  update(id: string, dto: { flatNumber?: string; floor?: number }) {
    return this.prisma.flat.update({ where: { id }, data: dto });
  }

  async assignOwner(flatId: string, userId: string, fromDate: Date) {
    await this.prisma.flatOwnership.updateMany({ where: { flatId, isActive: true }, data: { isActive: false, toDate: new Date() } });
    return this.prisma.flatOwnership.create({ data: { flatId, userId, fromDate, isActive: true } });
  }

  async assignTenant(flatId: string, userId: string, fromDate: Date) {
    await this.prisma.flatTenancy.updateMany({ where: { flatId, isActive: true }, data: { isActive: false, toDate: new Date() } });
    return this.prisma.flatTenancy.create({ data: { flatId, userId, fromDate, isActive: true } });
  }

  async removeOwner(flatId: string) {
    return this.prisma.flatOwnership.updateMany({ where: { flatId, isActive: true }, data: { isActive: false, toDate: new Date() } });
  }

  async removeTenant(flatId: string) {
    return this.prisma.flatTenancy.updateMany({ where: { flatId, isActive: true }, data: { isActive: false, toDate: new Date() } });
  }
}
