import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { Client, LocalAuth, MessageMedia } from 'whatsapp-web.js';
import * as QRCode from 'qrcode';
import { EventEmitter } from 'events';

export type WAStatus = 'disconnected' | 'qr_pending' | 'connecting' | 'ready';

@Injectable()
export class WhatsappService extends EventEmitter implements OnModuleDestroy {
  private readonly logger = new Logger(WhatsappService.name);
  private client: Client | null = null;
  private _status: WAStatus = 'disconnected';
  private _qr: string | null = null;

  get status(): WAStatus { return this._status; }
  get qrDataUrl(): string | null { return this._qr; }

  async initialize() {
    if (this.client) {
      this.logger.log('Client already initialized');
      return;
    }

    this._status = 'connecting';
    this._qr = null;

    this.client = new Client({
      authStrategy: new LocalAuth({ dataPath: '/tmp/whatsapp-session' }),
      puppeteer: {
        headless: true,
        args: [
          '--no-sandbox',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-accelerated-2d-canvas',
          '--no-first-run',
          '--no-zygote',
          '--single-process',
          '--disable-gpu',
        ],
      },
    });

    this.client.on('qr', async (qr) => {
      this._status = 'qr_pending';
      this._qr = await QRCode.toDataURL(qr);
      this.logger.log('QR code generated');
      this.emit('qr', this._qr);
    });

    this.client.on('ready', () => {
      this._status = 'ready';
      this._qr = null;
      this.logger.log('WhatsApp client ready');
      this.emit('ready');
    });

    this.client.on('authenticated', () => {
      this._status = 'connecting';
      this.logger.log('WhatsApp authenticated');
    });

    this.client.on('auth_failure', (msg) => {
      this._status = 'disconnected';
      this.logger.error('Auth failure: ' + msg);
      this.client = null;
      this.emit('disconnected');
    });

    this.client.on('disconnected', () => {
      this._status = 'disconnected';
      this._qr = null;
      this.logger.warn('WhatsApp disconnected');
      this.client = null;
      this.emit('disconnected');
    });

    await this.client.initialize();
  }

  async disconnect() {
    if (this.client) {
      await this.client.destroy();
      this.client = null;
    }
    this._status = 'disconnected';
    this._qr = null;
  }

  async sendMessage(phone: string, message: string): Promise<void> {
    if (!this.client || this._status !== 'ready') {
      throw new Error('WhatsApp client not ready');
    }
    const digits = phone.replace(/\D/g, '');
    const intl = digits.startsWith('91') ? digits : `91${digits}`;
    const chatId = `${intl}@c.us`;
    await this.client.sendMessage(chatId, message);
  }

  async onModuleDestroy() {
    await this.disconnect();
  }
}
