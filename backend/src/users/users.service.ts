import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcryptjs';
import { Role } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({
      select: { id: true, name: true, email: true, phone: true, roles: true, createdAt: true },
    });
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: { id: true, name: true, email: true, phone: true, roles: true, createdAt: true },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findMe(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true, name: true, email: true, phone: true, roles: true,
        tenancies: {
          where: { isActive: true },
          include: { flat: { include: { apartment: true } } },
        },
        ownedFlats: {
          where: { isActive: true },
          include: {
            flat: {
              include: {
                apartment: true,
                tenancies: {
                  where: { isActive: true },
                  include: { user: { select: { id: true, name: true, phone: true, email: true } } },
                },
              },
            },
          },
        },
      },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async create(dto: { name: string; email: string; phone?: string; password: string; roles?: Role[] }) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) throw new ConflictException('Email already in use');
    const hashed = await bcrypt.hash(dto.password, 10);
    const user = await this.prisma.user.create({
      data: { ...dto, password: hashed },
    });
    const { password: _, ...result } = user;
    return result;
  }

  private readonly VALID_ROLES: Role[] = ['ADMIN', 'OWNER', 'TENANT', 'VIEWER', 'WATER_MANAGER'] as Role[];

  async update(id: string, dto: { name?: string; phone?: string; roles?: string[] }) {
    const data: any = {};
    if (dto.name !== undefined) data.name = dto.name;
    if (dto.phone !== undefined) data.phone = dto.phone;
    if (dto.roles !== undefined) {
      data.roles = dto.roles.filter(r => this.VALID_ROLES.includes(r as Role)) as Role[];
    }
    return this.prisma.user.update({
      where: { id },
      data,
      select: { id: true, name: true, email: true, phone: true, roles: true },
    });
  }

  async changePassword(id: string, newPassword: string) {
    const hashed = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({ where: { id }, data: { password: hashed } });
    return { message: 'Password updated' };
  }

  async changeMyPassword(id: string, oldPassword: string, newPassword: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    const valid = await bcrypt.compare(oldPassword, user.password);
    if (!valid) throw new Error('Current password is incorrect');
    const hashed = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({ where: { id }, data: { password: hashed } });
    return { message: 'Password updated successfully' };
  }

}
