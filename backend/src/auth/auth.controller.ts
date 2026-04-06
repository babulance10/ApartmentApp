import { Controller, Post, Body, UseGuards, Request, Get, Response } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @UseGuards(AuthGuard('local'))
  @Post('login')
  async login(@Request() req: any, @Response() res: any) {
    const result = await this.authService.login(req.user);
    
    // Set secure cookie with correct domain for Cloudflare
    res.cookie('token', result.access_token, {
      httpOnly: true,
      secure: true,
      sameSite: 'none',
      domain: process.env.COOKIE_DOMAIN || '.sarvavidha.in',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    return res.json(result);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me')
  getProfile(@Request() req: any) {
    return req.user;
  }
}
