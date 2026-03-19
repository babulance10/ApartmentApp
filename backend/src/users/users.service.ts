import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcryptjs';
import { Role } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({
      select: { id: true, name: true, email: true, phone: true, role: true, createdAt: true },
    });
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: { id: true, name: true, email: true, phone: true, role: true, createdAt: true },
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
        id: true, name: true, email: true, phone: true, role: true,
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

  async create(dto: { name: string; email: string; phone?: string; password: string; role?: Role }) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) throw new ConflictException('Email already in use');
    const hashed = await bcrypt.hash(dto.password, 10);
    const user = await this.prisma.user.create({
      data: { ...dto, password: hashed },
    });
    const { password: _, ...result } = user;
    return result;
  }

  async update(id: string, dto: { name?: string; phone?: string; role?: Role }) {
    return this.prisma.user.update({
      where: { id },
      data: dto,
      select: { id: true, name: true, email: true, phone: true, role: true },
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

  async setOwnerTenant(id: string, isOwnerTenant: boolean) {
    return this.prisma.user.update({
      where: { id },
      data: { isOwnerTenant },
      select: { id: true, name: true, email: true, role: true, isOwnerTenant: true },
    });
  }
}
