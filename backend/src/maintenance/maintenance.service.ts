import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MaintenanceStatus, MaintenancePriority } from '@prisma/client';

@Injectable()
export class MaintenanceService {
  constructor(private prisma: PrismaService) {}

  findAll(filters: { flatId?: string; status?: MaintenanceStatus }) {
    return this.prisma.maintenanceRequest.findMany({
      where: {
        ...(filters.flatId && { flatId: filters.flatId }),
        ...(filters.status && { status: filters.status }),
      },
      include: { flat: true, user: { select: { id: true, name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const req = await this.prisma.maintenanceRequest.findUnique({
      where: { id },
      include: { flat: true, user: { select: { id: true, name: true, email: true } } },
    });
    if (!req) throw new NotFoundException('Request not found');
    return req;
  }

  create(dto: { flatId: string; userId: string; title: string; description: string; priority?: MaintenancePriority }) {
    return this.prisma.maintenanceRequest.create({ data: { ...dto, priority: dto.priority ?? MaintenancePriority.MEDIUM } });
  }

  async updateStatus(id: string, status: MaintenanceStatus) {
    return this.prisma.maintenanceRequest.update({
      where: { id },
      data: { status, ...(status === MaintenanceStatus.RESOLVED && { resolvedAt: new Date() }) },
    });
  }

  delete(id: string) {
    return this.prisma.maintenanceRequest.delete({ where: { id } });
  }
}
