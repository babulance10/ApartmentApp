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
    
    // Set secure cookie with correct domain
    // For production (sarvavidha.in): use .sarvavidha.in
    // For localhost/development: omit domain so browser uses current host
    const cookieOptions: any = {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production', // Only secure in production
      sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'lax',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    };

    // Only set domain for production
    if (process.env.COOKIE_DOMAIN) {
      cookieOptions.domain = process.env.COOKIE_DOMAIN;
    }

    res.cookie('token', result.access_token, cookieOptions);
    return res.json(result);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me')
  getProfile(@Request() req: any) {
    return req.user;
  }
}
