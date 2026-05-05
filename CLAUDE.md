# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Apartment management application with a NestJS backend, Lit web components frontend, and a WhatsApp notification tool. Deployed on Render.com with a Neon PostgreSQL (serverless) database.

## Commands

### Backend (`/backend`)
```bash
npm run start:dev       # Watch mode (development)
npm run build           # Compile TypeScript
npm start               # Development mode
npm run start:prod      # Production (node dist/main)
npm run prisma:migrate  # Run DB migrations (prisma migrate dev)
npm run prisma:seed     # Seed database
npm test                # Unit tests
npm run test:e2e        # E2E tests
npm run render-build    # CI build: prisma generate + migrate deploy + nest build
```

### Frontend (`/lit-frontend`)
```bash
npm run dev     # Dev server on port 3000
npm run build   # Production build
npm run preview # Preview production build
```

### WhatsApp Sender (`/whatsapp-sender`)
```bash
npm run send    # Send WhatsApp notifications
```

## Architecture

### Backend (NestJS 11, TypeScript)

Standard NestJS module structure in `backend/src/`, each module has its own controller, service, and DTOs. Key modules:

- **`auth/`** — JWT + Passport.js strategy; login returns JWT stored client-side
- **`bills/`** — Core billing logic: auto-generates monthly bills combining flat maintenance + water charges + previous dues; sends email reminders via SMTP
- **`water-meter/`** / **`water-purchases/`** — Water meter readings and bulk tanker purchases feed into bill calculations
- **`contributions/`** — Manual contributions that auto-deduct from subsequent bills
- **`events/`** — Special event-based collections
- **`whatsapp/`** — WhatsApp notifications via WhatsApp-web.js (Playwright browser automation)
- **`prisma/`** — Singleton `PrismaService` that extends `PrismaClient`, injected across all modules

API prefix: `/api`. Backend runs on port `3001`.

Cron-triggered endpoints are protected by a custom `x-cron-secret` header (validated against env var), not JWT.

### Database (PostgreSQL via Prisma)

Schema at `backend/prisma/schema.prisma`. Key relationships:

- **Apartment** → **Flat** (one-to-many)
- **Flat** → **FlatOwnership** / **FlatTenancy** (date-ranged; active record has no `endDate`)
- **Flat** → **MonthlyBill** (status: `PENDING`, `PARTIAL`, `PAID`)
- **MonthlyBill** → **Payment** (one-to-many partial payments)
- **WaterMeterReading** — Per-flat monthly readings; delta from previous month drives water charge
- **WaterPurchase** — Bulk tanker purchases for the apartment
- **FlatContribution** — Applied to reduce the next generated bill
- **User** roles: `ADMIN`, `OWNER`, `TENANT`, `VIEWER`, `WATER_MANAGER`

Migrations live in `backend/prisma/migrations/`. Always run `prisma:migrate` after schema changes.

### Frontend (Lit 3.2, Vite 6.3, Tailwind CSS 4)

Entry point: `lit-frontend/src/main.ts` — registers all custom elements and routes.

**Routing:** Custom hash-based router (`lit-frontend/src/router.ts`) with role-based guards. Routes follow the pattern `#/role/page` (e.g., `#/admin/bills`, `#/tenant/my-bills`).

**Auth:** Token and user stored in `localStorage`. `lib/api.ts` provides an Axios instance that injects `Bearer` token on every request and auto-redirects to login on 401.

**Key libs:**
- `lib/auth.ts` — Token/user get/set/clear helpers
- `lib/api.ts` — Axios instance with auth interceptor
- `lib/utils.ts` — Currency formatting (`₹`), month names, status badge colors
- `lib/icons.ts` — SVG icon strings

Role-separated page directories: `pages/admin/`, `pages/owner/`, `pages/tenant/`.

## Environment Variables

**Backend** (see `backend/.env.example`):
```
DATABASE_URL=postgresql://...
JWT_SECRET=...
PORT=3001
NODE_ENV=production
CORS_ORIGIN=...          # Comma-separated allowed origins
SMTP_HOST/PORT/USER/PASS
CRON_SECRET=...          # Header value for cron-protected endpoints
```

**Frontend** (`lit-frontend/.env`):
```
VITE_API_URL=http://localhost:3001/api
```

## Key Billing Logic

Bill generation (in `bills/bills.service.ts`) combines:
1. Flat's base maintenance amount
2. Water charge = liters consumed × price per liter (from `WaterMeterReading` delta)
3. Previous unpaid balance carried forward
4. Minus any pending `FlatContribution` amounts

The "Common" flat is excluded from bill generation and printed bills — it's used only to track shared expenses.
