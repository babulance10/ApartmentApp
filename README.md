# Apartment Maintenance App

A modern apartment maintenance and management application built with Flutter and Laravel.

## Features

- Apartment Management
- Tenant Management
- Expense Tracking
- Water Meter Management
- Financial Reports
- Maintenance Requests

How to Push to Production DB
The SQL dump is saved at apartment_app_data.sql.

Option 1 — If your production DB is on a remote server (e.g. Render/Railway/Supabase):

bash
# Replace with your production DATABASE_URL
psql "postgresql://USER:PASSWORD@HOST:PORT/DBNAME" < backend/prisma/apartment_app_data.sql
Option 2 — If you want to deploy the full app + DB together:

Run schema migrations first on production:
bash
DATABASE_URL="<production-url>" npx prisma migrate deploy
Then import the data:
bash
psql "<production-url>" < backend/prisma/apartment_app_data.sql
Option 3 — Export only bills/payments (safer, no user passwords):

bash
pg_dump -U postgres -h localhost -d apartment_app \
  --data-only \
  -t '"MonthlyBill"' -t '"Payment"' -t '"Expense"' \
  -t '"WaterMeterReading"' -t '"WaterPurchase"' \
  -f bills_only.sql


  Let me check the current git status and push everything to that repo.

No remote is configured. Let me set it up and push.

First, let me create a proper `.gitignore` to avoid pushing sensitive files and unnecessary files:

Let me create a proper `.gitignore` first to keep sensitive data out:

Now create an `.env.example` file so Render knows what env vars are needed (without exposing real values):

Now commit and push everything to the GitHub repo:

Now let me add all files and commit:

Let me verify what got staged, then commit and push:

Good — all the right files are staged. The DB dump files and screenshots are included which is fine. Now let me commit and push:

Now push to GitHub:

Pushed successfully! Here's what to do next on Render.com:

---

## Render Deployment Steps

### Step 1: Setup Neon Database (do this first)
1. Go to **[neon.tech](https://neon.tech)** → Sign up with Google
2. **New Project** → Name: `psa-portal` → Region: `Asia Pacific (Singapore)`
3. Copy the connection string (looks like `postgresql://neondb_owner:xxx@ep-xxx.ap-southeast-1.aws.neon.tech/neondb?sslmode=require`)

### Step 2: Import Your Data into Neon
Run these two commands on your Mac (replace `<NEON_URL>` with your actual string):
```bash
# Apply schema migrations
cd /Users/sameer.nalla/Projects/Apartment-App/backend
DATABASE_URL="<NEON_URL>" npx prisma migrate deploy

# Import all 2000+ rows of data
psql "<NEON_URL>" < prisma/full_db_dump.sql
```

### Step 3: Deploy Backend on Render
1. Go to **[render.com](https://render.com)** → Sign up with GitHub
2. **New +** → **Web Service** → Connect `babulance10/ApartmentApp`
3. Settings:
   - **Root Directory**: `backend`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm run start:prod`
   - **Instance**: `Free`
4. **Environment Variables**:
   | Key | Value |
   |-----|-------|
   | `DATABASE_URL` | Your Neon connection string |
   | `JWT_SECRET` | `psa-sreenidhi-secret-2024` |
   | `PORT` | `3001` |
   | `CORS_ORIGIN` | *(leave blank for now, add after step 4)* |

5. Click **Create Web Service** → wait for deploy → note the URL (e.g. `https://psa-backend-xxxx.onrender.com`)

### Step 4: Deploy Frontend on Render
1. **New +** → **Static Site** → Same repo `babulance10/ApartmentApp`
2. Settings:
   - **Root Directory**: `lit-frontend`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist`
3. **Environment Variable**:
   | Key | Value |
   |-----|-------|
   | `VITE_API_URL` | `https://psa-backend-xxxx.onrender.com/api` |

4. Click **Create Static Site** → note your frontend URL (e.g. `https://psa-portal-xxxx.onrender.com`)

### Step 5: Update CORS
Go back to **backend service** → **Environment** → Add:
```
CORS_ORIGIN=https://psa-portal-xxxx.onrender.com
```
Click **Save Changes** → it will auto-redeploy.

### Step 6: Keep Backend Awake (free trick)
1. Go to **[cron-job.org](https://cron-job.org)** → Sign up free
2. Create job → URL: `https://psa-backend-xxxx.onrender.com/api`
3. Schedule: **Every 14 minutes**
4. This prevents the free tier from sleeping

---

Let me know once you have the Neon connection string and I can run the migration + import commands for you directly.