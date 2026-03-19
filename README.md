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