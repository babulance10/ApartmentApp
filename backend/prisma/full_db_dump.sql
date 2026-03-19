--
-- PostgreSQL database dump
--

-- Dumped from database version 14.17 (Homebrew)
-- Dumped by pg_dump version 14.17 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public."WaterPurchase" DROP CONSTRAINT IF EXISTS "WaterPurchase_apartmentId_fkey";
ALTER TABLE IF EXISTS ONLY public."WaterMeterReading" DROP CONSTRAINT IF EXISTS "WaterMeterReading_flatId_fkey";
ALTER TABLE IF EXISTS ONLY public."Payment" DROP CONSTRAINT IF EXISTS "Payment_billId_fkey";
ALTER TABLE IF EXISTS ONLY public."MonthlyBill" DROP CONSTRAINT IF EXISTS "MonthlyBill_flatId_fkey";
ALTER TABLE IF EXISTS ONLY public."MaintenanceRequest" DROP CONSTRAINT IF EXISTS "MaintenanceRequest_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."MaintenanceRequest" DROP CONSTRAINT IF EXISTS "MaintenanceRequest_flatId_fkey";
ALTER TABLE IF EXISTS ONLY public."Flat" DROP CONSTRAINT IF EXISTS "Flat_apartmentId_fkey";
ALTER TABLE IF EXISTS ONLY public."FlatTenancy" DROP CONSTRAINT IF EXISTS "FlatTenancy_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."FlatTenancy" DROP CONSTRAINT IF EXISTS "FlatTenancy_flatId_fkey";
ALTER TABLE IF EXISTS ONLY public."FlatOwnership" DROP CONSTRAINT IF EXISTS "FlatOwnership_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."FlatOwnership" DROP CONSTRAINT IF EXISTS "FlatOwnership_flatId_fkey";
ALTER TABLE IF EXISTS ONLY public."FlatContribution" DROP CONSTRAINT IF EXISTS "FlatContribution_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."FlatContribution" DROP CONSTRAINT IF EXISTS "FlatContribution_flatId_fkey";
ALTER TABLE IF EXISTS ONLY public."Expense" DROP CONSTRAINT IF EXISTS "Expense_apartmentId_fkey";
DROP INDEX IF EXISTS public."WaterMeterReading_flatId_month_year_key";
DROP INDEX IF EXISTS public."User_email_key";
DROP INDEX IF EXISTS public."MonthlyBill_flatId_month_year_key";
DROP INDEX IF EXISTS public."Flat_flatNumber_apartmentId_key";
ALTER TABLE IF EXISTS ONLY public._prisma_migrations DROP CONSTRAINT IF EXISTS _prisma_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public."WaterPurchase" DROP CONSTRAINT IF EXISTS "WaterPurchase_pkey";
ALTER TABLE IF EXISTS ONLY public."WaterMeterReading" DROP CONSTRAINT IF EXISTS "WaterMeterReading_pkey";
ALTER TABLE IF EXISTS ONLY public."User" DROP CONSTRAINT IF EXISTS "User_pkey";
ALTER TABLE IF EXISTS ONLY public."Payment" DROP CONSTRAINT IF EXISTS "Payment_pkey";
ALTER TABLE IF EXISTS ONLY public."MonthlyBill" DROP CONSTRAINT IF EXISTS "MonthlyBill_pkey";
ALTER TABLE IF EXISTS ONLY public."MaintenanceRequest" DROP CONSTRAINT IF EXISTS "MaintenanceRequest_pkey";
ALTER TABLE IF EXISTS ONLY public."Flat" DROP CONSTRAINT IF EXISTS "Flat_pkey";
ALTER TABLE IF EXISTS ONLY public."FlatTenancy" DROP CONSTRAINT IF EXISTS "FlatTenancy_pkey";
ALTER TABLE IF EXISTS ONLY public."FlatOwnership" DROP CONSTRAINT IF EXISTS "FlatOwnership_pkey";
ALTER TABLE IF EXISTS ONLY public."FlatContribution" DROP CONSTRAINT IF EXISTS "FlatContribution_pkey";
ALTER TABLE IF EXISTS ONLY public."Expense" DROP CONSTRAINT IF EXISTS "Expense_pkey";
ALTER TABLE IF EXISTS ONLY public."Apartment" DROP CONSTRAINT IF EXISTS "Apartment_pkey";
DROP TABLE IF EXISTS public._prisma_migrations;
DROP TABLE IF EXISTS public."WaterPurchase";
DROP TABLE IF EXISTS public."WaterMeterReading";
DROP TABLE IF EXISTS public."User";
DROP TABLE IF EXISTS public."Payment";
DROP TABLE IF EXISTS public."MonthlyBill";
DROP TABLE IF EXISTS public."MaintenanceRequest";
DROP TABLE IF EXISTS public."FlatTenancy";
DROP TABLE IF EXISTS public."FlatOwnership";
DROP TABLE IF EXISTS public."FlatContribution";
DROP TABLE IF EXISTS public."Flat";
DROP TABLE IF EXISTS public."Expense";
DROP TABLE IF EXISTS public."Apartment";
DROP TYPE IF EXISTS public."Role";
DROP TYPE IF EXISTS public."MaintenanceStatus";
DROP TYPE IF EXISTS public."MaintenancePriority";
DROP TYPE IF EXISTS public."ContributionType";
DROP TYPE IF EXISTS public."BillStatus";
--
-- Name: BillStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BillStatus" AS ENUM (
    'PENDING',
    'PARTIAL',
    'PAID'
);


--
-- Name: ContributionType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ContributionType" AS ENUM (
    'WATER',
    'MAINTENANCE',
    'OTHER'
);


--
-- Name: MaintenancePriority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MaintenancePriority" AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH'
);


--
-- Name: MaintenanceStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MaintenanceStatus" AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'RESOLVED'
);


--
-- Name: Role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Role" AS ENUM (
    'ADMIN',
    'OWNER',
    'TENANT'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Apartment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Apartment" (
    id text NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    "upiNumber" text,
    "upiName" text
);


--
-- Name: Expense; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Expense" (
    id text NOT NULL,
    "apartmentId" text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    category text NOT NULL,
    description text NOT NULL,
    amount double precision NOT NULL,
    "expenseDate" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Flat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Flat" (
    id text NOT NULL,
    "flatNumber" text NOT NULL,
    floor integer NOT NULL,
    "apartmentId" text NOT NULL
);


--
-- Name: FlatContribution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FlatContribution" (
    id text NOT NULL,
    "flatId" text NOT NULL,
    "userId" text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    type public."ContributionType" NOT NULL,
    amount double precision NOT NULL,
    description text,
    "appliedToBillId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: FlatOwnership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FlatOwnership" (
    id text NOT NULL,
    "flatId" text NOT NULL,
    "userId" text NOT NULL,
    "fromDate" timestamp(3) without time zone NOT NULL,
    "toDate" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: FlatTenancy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FlatTenancy" (
    id text NOT NULL,
    "flatId" text NOT NULL,
    "userId" text NOT NULL,
    "fromDate" timestamp(3) without time zone NOT NULL,
    "toDate" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: MaintenanceRequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MaintenanceRequest" (
    id text NOT NULL,
    "flatId" text NOT NULL,
    "userId" text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    status public."MaintenanceStatus" DEFAULT 'OPEN'::public."MaintenanceStatus" NOT NULL,
    priority public."MaintenancePriority" DEFAULT 'MEDIUM'::public."MaintenancePriority" NOT NULL,
    "resolvedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: MonthlyBill; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MonthlyBill" (
    id text NOT NULL,
    "flatId" text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "maintenanceAmount" double precision DEFAULT 2000 NOT NULL,
    "waterAmount" double precision DEFAULT 0 NOT NULL,
    "previousDue" double precision DEFAULT 0 NOT NULL,
    "totalAmount" double precision NOT NULL,
    "paidAmount" double precision DEFAULT 0 NOT NULL,
    status public."BillStatus" DEFAULT 'PENDING'::public."BillStatus" NOT NULL,
    "generatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Payment" (
    id text NOT NULL,
    "billId" text NOT NULL,
    amount double precision NOT NULL,
    "paymentDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "paymentMethod" text,
    "transactionRef" text,
    notes text
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    phone text,
    password text NOT NULL,
    role public."Role" DEFAULT 'TENANT'::public."Role" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "isOwnerTenant" boolean DEFAULT false NOT NULL
);


--
-- Name: WaterMeterReading; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WaterMeterReading" (
    id text NOT NULL,
    "flatId" text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "previousReading" double precision NOT NULL,
    "currentReading" double precision NOT NULL,
    "litersConsumed" double precision NOT NULL,
    "pricePerLiter" double precision DEFAULT 0.088 NOT NULL,
    "waterAmount" double precision NOT NULL,
    "readingDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: WaterPurchase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WaterPurchase" (
    id text NOT NULL,
    "apartmentId" text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "srNo" integer NOT NULL,
    "capacityLiters" integer DEFAULT 10000 NOT NULL,
    "tokenNo" text,
    "bookedOn" timestamp(3) without time zone NOT NULL,
    "deliveredOn" timestamp(3) without time zone NOT NULL,
    "amountPaid" double precision NOT NULL,
    "vehicleNo" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Data for Name: Apartment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Apartment" (id, name, address, city, "upiNumber", "upiName") FROM stdin;
psa-main	PRIMARK SREENIDHI APARTMENT	Kondapur	Hyderabad	7093991333	PSA Association
\.


--
-- Data for Name: Expense; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Expense" (id, "apartmentId", month, year, category, description, amount, "expenseDate", "createdAt") FROM stdin;
cmmryc60c0001r5j0bo901py0	psa-main	6	2020	Cleaning	Garbage Payment	1200	2020-06-01 00:00:00	2026-03-15 16:11:22.861
cmmryc60g0003r5j0utl8l2qu	psa-main	6	2020	Water	Water Bill	1922	2020-06-01 00:00:00	2026-03-15 16:11:22.864
cmmryc60h0005r5j047rpbj0t	psa-main	6	2020	Miscellaneous	eletricity bill	5814	2020-06-01 00:00:00	2026-03-15 16:11:22.865
cmmryc60h0007r5j0fg9d8y1w	psa-main	7	2020	Water	Water Bill	1923	2020-07-01 00:00:00	2026-03-15 16:11:22.866
cmmryc60i0009r5j01g6t59qz	psa-main	7	2020	Miscellaneous	Eletricity bill	4245	2020-07-01 00:00:00	2026-03-15 16:11:22.867
cmmryc60j000br5j06mfpel1a	psa-main	8	2020	Miscellaneous	Eletricity bill	5428	2020-08-01 00:00:00	2026-03-15 16:11:22.867
cmmryc60k000dr5j0tkbz2fl5	psa-main	8	2020	Cleaning	Garbage Payment	1200	2020-08-01 00:00:00	2026-03-15 16:11:22.868
cmmryc60k000fr5j0yeif50t1	psa-main	9	2020	Security	Watch Man Salary	7000	2020-09-01 00:00:00	2026-03-15 16:11:22.869
cmmryc60l000hr5j05l210rvv	psa-main	9	2020	Miscellaneous	Eletricity bill	5042	2020-09-01 00:00:00	2026-03-15 16:11:22.87
cmmryc60m000jr5j0nebmc2ko	psa-main	9	2020	Cleaning	Garbage Payment	1200	2020-09-01 00:00:00	2026-03-15 16:11:22.87
cmmryc60m000lr5j0w65ul54u	psa-main	9	2020	Fuel	Diesel	1000	2020-09-01 00:00:00	2026-03-15 16:11:22.871
cmmryc60n000nr5j04tucd2ga	psa-main	9	2020	Miscellaneous	miscellaneous	560	2020-09-01 00:00:00	2026-03-15 16:11:22.872
cmmryc60n000pr5j0ro2gcp2c	psa-main	10	2020	Miscellaneous	Bulbs	280	2020-10-01 00:00:00	2026-03-15 16:11:22.872
cmmryc60o000rr5j0qdnj8hcu	psa-main	10	2020	Miscellaneous	Eletricity bill	4949	2020-10-01 00:00:00	2026-03-15 16:11:22.872
cmmryc60o000tr5j0j5ldv9f3	psa-main	10	2020	Security	Watch Man Salary	7000	2020-10-01 00:00:00	2026-03-15 16:11:22.873
cmmryc60p000vr5j0c49vxlgp	psa-main	10	2020	Maintenance	Lift Maintence	800	2020-10-01 00:00:00	2026-03-15 16:11:22.873
cmmryc60p000xr5j0ijextc3e	psa-main	10	2020	Cleaning	Garbage Payment	1200	2020-10-01 00:00:00	2026-03-15 16:11:22.874
cmmryc60q000zr5j0ti6ayvw7	psa-main	10	2020	Fuel	Diesel	1050	2020-10-01 00:00:00	2026-03-15 16:11:22.874
cmmryc60q0011r5j0kvfde88g	psa-main	10	2020	Water	Water Bill	6376	2020-10-01 00:00:00	2026-03-15 16:11:22.875
cmmryc60r0013r5j0ojne29ck	psa-main	11	2020	Security	Watch Man Salary	7000	2020-11-01 00:00:00	2026-03-15 16:11:22.875
cmmryc60r0015r5j042nevmmb	psa-main	11	2020	Electricity	Electric City	6081	2020-11-01 00:00:00	2026-03-15 16:11:22.876
cmmryc60s0017r5j0s03fh500	psa-main	11	2020	Maintenance	Lift Maintence	800	2020-11-01 00:00:00	2026-03-15 16:11:22.876
cmmryc60t0019r5j0jec2y565	psa-main	11	2020	Cleaning	Grabage Payment	1200	2020-11-01 00:00:00	2026-03-15 16:11:22.877
cmmryc60t001br5j0aefg7cbt	psa-main	11	2020	Security	Diwali bonus watch man	5000	2020-11-01 00:00:00	2026-03-15 16:11:22.878
cmmryc60u001dr5j0atfmtcjb	psa-main	11	2020	Miscellaneous	Diwali Decoration	400	2020-11-01 00:00:00	2026-03-15 16:11:22.878
cmmryc60u001fr5j0fecl1u3n	psa-main	11	2020	Miscellaneous	miscellaneous	500	2020-11-01 00:00:00	2026-03-15 16:11:22.879
cmmryc60v001hr5j0vugqk25n	psa-main	11	2020	Cleaning	Water Tank cleaning	12000	2020-11-01 00:00:00	2026-03-15 16:11:22.879
cmmryc60v001jr5j0tgbjcy9b	psa-main	11	2020	Cleaning	Water Tank cleaning tip	200	2020-11-01 00:00:00	2026-03-15 16:11:22.88
cmmryc60w001lr5j0771eiodb	psa-main	12	2020	Security	Watch Man Salary	7000	2020-12-01 00:00:00	2026-03-15 16:11:22.88
cmmryc60w001nr5j0gxigx0kn	psa-main	12	2020	Electricity	Electric City	6145	2020-12-01 00:00:00	2026-03-15 16:11:22.88
cmmryc60w001pr5j00qrnk66g	psa-main	12	2020	Maintenance	Lift Maintence	800	2020-12-01 00:00:00	2026-03-15 16:11:22.881
cmmryc60x001rr5j09o8w3l55	psa-main	12	2020	Cleaning	Grabage Payment	1200	2020-12-01 00:00:00	2026-03-15 16:11:22.881
cmmryc60x001tr5j0tv3l8eb8	psa-main	12	2020	Water	Water Bill	2050	2020-12-01 00:00:00	2026-03-15 16:11:22.882
cmmryc60y001vr5j00odch3vr	psa-main	12	2020	Water	Water Bill	1922	2020-12-01 00:00:00	2026-03-15 16:11:22.882
cmmryc60y001xr5j0a4gs6vzi	psa-main	1	2021	Security	Watch Man Salary	7000	2021-01-01 00:00:00	2026-03-15 16:11:22.883
cmmryc60y001zr5j01zoy5ckw	psa-main	1	2021	Electricity	Electric City	5102	2021-01-01 00:00:00	2026-03-15 16:11:22.883
cmmryc60z0021r5j03mq5zwnx	psa-main	1	2021	Maintenance	Lift Maintence	800	2021-01-01 00:00:00	2026-03-15 16:11:22.883
cmmryc60z0023r5j0mb01oj0f	psa-main	2	2021	Security	Watch Man Salary	7000	2021-02-01 00:00:00	2026-03-15 16:11:22.884
cmmryc6100025r5j0ukeau045	psa-main	2	2021	Electricity	Electric City	4323	2021-02-01 00:00:00	2026-03-15 16:11:22.885
cmmryc6110027r5j0qy4un0cd	psa-main	2	2021	Maintenance	Lift Maintence	800	2021-02-01 00:00:00	2026-03-15 16:11:22.885
cmmryc6110029r5j0bppk8axh	psa-main	2	2021	Cleaning	Grabage Payment	1200	2021-02-01 00:00:00	2026-03-15 16:11:22.886
cmmryc612002br5j03c9da7y1	psa-main	2	2021	Miscellaneous	miscellaneous	500	2021-02-01 00:00:00	2026-03-15 16:11:22.886
cmmryc612002dr5j0u0m3wn9t	psa-main	3	2021	Security	Watch Man Salary	7000	2021-03-01 00:00:00	2026-03-15 16:11:22.886
cmmryc612002fr5j05g5rs6z0	psa-main	3	2021	Electricity	Electric City	4323	2021-03-01 00:00:00	2026-03-15 16:11:22.887
cmmryc613002hr5j0ss8pjviv	psa-main	3	2021	Fuel	Diesel	1000	2021-03-01 00:00:00	2026-03-15 16:11:22.887
cmmryc614002jr5j0p9lncvdz	psa-main	3	2021	Cleaning	Grabage Payment	1200	2021-03-01 00:00:00	2026-03-15 16:11:22.889
cmmryc614002lr5j0cdi36exd	psa-main	4	2021	Security	Watch Man Salary	7000	2021-04-01 00:00:00	2026-03-15 16:11:22.889
cmmryc615002nr5j0f3kug3qd	psa-main	4	2021	Electricity	Electric City	6389	2021-04-01 00:00:00	2026-03-15 16:11:22.889
cmmryc615002pr5j084m3bhn0	psa-main	4	2021	Cleaning	Water Tank cleaning tip	200	2021-04-01 00:00:00	2026-03-15 16:11:22.89
cmmryc615002rr5j08km7tm7d	psa-main	4	2021	Maintenance	Lift Maintence	800	2021-04-01 00:00:00	2026-03-15 16:11:22.89
cmmryc616002tr5j0wdfjn7rz	psa-main	4	2021	Fuel	Diesel	1000	2021-04-01 00:00:00	2026-03-15 16:11:22.89
cmmryc616002vr5j033sobblg	psa-main	4	2021	Cleaning	Grabage Payment	1200	2021-04-01 00:00:00	2026-03-15 16:11:22.89
cmmryc616002xr5j0oicwltrd	psa-main	4	2021	Miscellaneous	miscellaneous	500	2021-04-01 00:00:00	2026-03-15 16:11:22.891
cmmryc617002zr5j0dtwrlzfy	psa-main	4	2021	Water	Water Tanker	1050	2021-04-01 00:00:00	2026-03-15 16:11:22.891
cmmryc6170031r5j0ygp93qj7	psa-main	4	2021	Water	Water Tanker	1050	2021-04-01 00:00:00	2026-03-15 16:11:22.891
cmmryc6170033r5j03y7lv0mm	psa-main	4	2021	Miscellaneous	Sanitizer and dispenser and Stand	1620	2021-04-01 00:00:00	2026-03-15 16:11:22.892
cmmryc6170035r5j0r97dplo0	psa-main	4	2021	Water	Water Tanker	1100	2021-04-01 00:00:00	2026-03-15 16:11:22.892
cmmryc6180037r5j0jrfitmz7	psa-main	4	2021	Water	Water Tanker	1100	2021-04-01 00:00:00	2026-03-15 16:11:22.892
cmmryc6180039r5j0p8pl3zmm	psa-main	4	2021	Water	Water Tanker	1100	2021-04-01 00:00:00	2026-03-15 16:11:22.893
cmmryc618003br5j06yk0y8dl	psa-main	4	2021	Fuel	Diesel	1000	2021-04-01 00:00:00	2026-03-15 16:11:22.893
cmmryc619003dr5j04nl53t96	psa-main	4	2021	Water	Water Tanker	1100	2021-04-01 00:00:00	2026-03-15 16:11:22.893
cmmryc619003fr5j0i5njudto	psa-main	5	2021	Security	Watch Man Salary	8000	2021-05-01 00:00:00	2026-03-15 16:11:22.893
cmmryc619003hr5j07ptlpl91	psa-main	5	2021	Electricity	Electric City	4517	2021-05-01 00:00:00	2026-03-15 16:11:22.894
cmmryc619003jr5j0kdr234rw	psa-main	5	2021	Maintenance	Lift Maintence	800	2021-05-01 00:00:00	2026-03-15 16:11:22.894
cmmryc61a003lr5j05kikpru5	psa-main	5	2021	Fuel	Diesel	1050	2021-05-01 00:00:00	2026-03-15 16:11:22.894
cmmryc61a003nr5j0p4aroae9	psa-main	5	2021	Cleaning	Grabage Payment	1200	2021-05-01 00:00:00	2026-03-15 16:11:22.894
cmmryc61a003pr5j05sbld9fk	psa-main	6	2021	Security	Watch Man Salary	8000	2021-06-01 00:00:00	2026-03-15 16:11:22.895
cmmryc61b003rr5j0yeokvj3o	psa-main	6	2021	Electricity	Electric City	4431	2021-06-01 00:00:00	2026-03-15 16:11:22.895
cmmryc61b003tr5j0kpf85sw1	psa-main	6	2021	Maintenance	Lift Maintence	800	2021-06-01 00:00:00	2026-03-15 16:11:22.895
cmmryc61b003vr5j0wildwsag	psa-main	6	2021	Miscellaneous	Blubs(4)	880	2021-06-01 00:00:00	2026-03-15 16:11:22.896
cmmryc61b003xr5j0w1bf2b5e	psa-main	6	2021	Miscellaneous	Miscellaneous	500	2021-06-01 00:00:00	2026-03-15 16:11:22.896
cmmryc61c003zr5j0hy79uxbn	psa-main	6	2021	Cleaning	Grabage Payment	1200	2021-06-01 00:00:00	2026-03-15 16:11:22.896
cmmryc61c0041r5j084a5xmyp	psa-main	6	2021	Fuel	Diesel	1050	2021-06-01 00:00:00	2026-03-15 16:11:22.896
cmmryc61c0043r5j08fx808xw	psa-main	7	2021	Security	Watch Man Salary	8000	2021-07-01 00:00:00	2026-03-15 16:11:22.897
cmmryc61c0045r5j0tejwh1fd	psa-main	7	2021	Electricity	Electric City	4803	2021-07-01 00:00:00	2026-03-15 16:11:22.897
cmmryc61d0047r5j0lkzagudu	psa-main	7	2021	Maintenance	Lift Maintence	800	2021-07-01 00:00:00	2026-03-15 16:11:22.897
cmmryc61d0049r5j0qys5lmjs	psa-main	7	2021	Cleaning	Grabage Payment	1200	2021-07-01 00:00:00	2026-03-15 16:11:22.897
cmmryc61d004br5j0v2st6cgm	psa-main	7	2021	Maintenance	Lift Button	2800	2021-07-01 00:00:00	2026-03-15 16:11:22.898
cmmryc61d004dr5j00efqo4up	psa-main	7	2021	Maintenance	Motor Switch	150	2021-07-01 00:00:00	2026-03-15 16:11:22.898
cmmryc61e004fr5j0pf775wxg	psa-main	8	2021	Security	Watch Man Salary	8000	2021-08-01 00:00:00	2026-03-15 16:11:22.898
cmmryc61e004hr5j0q4f0yssh	psa-main	8	2021	Electricity	Electric City	5642	2021-08-01 00:00:00	2026-03-15 16:11:22.898
cmmryc61e004jr5j0jkw92uwm	psa-main	8	2021	Maintenance	Lift Maintence	800	2021-08-01 00:00:00	2026-03-15 16:11:22.899
cmmryc61e004lr5j02zd0qhb4	psa-main	8	2021	Cleaning	Grabage Payment	1200	2021-08-01 00:00:00	2026-03-15 16:11:22.899
cmmryc61f004nr5j0atn6ku3b	psa-main	8	2021	Maintenance	Pipe blockage	537	2021-08-01 00:00:00	2026-03-15 16:11:22.899
cmmryc61f004pr5j04u0dj6wc	psa-main	8	2021	Fuel	Diesel	1500	2021-08-01 00:00:00	2026-03-15 16:11:22.899
cmmryc61f004rr5j0v2mhqjm6	psa-main	8	2021	Maintenance	Motor Switch	100	2021-08-01 00:00:00	2026-03-15 16:11:22.9
cmmryc61g004tr5j0d4kmz1tz	psa-main	8	2021	Miscellaneous	Miscellaneous	200	2021-08-01 00:00:00	2026-03-15 16:11:22.9
cmmryc61g004vr5j0ds4o9t0e	psa-main	9	2021	Security	Watch Man Salary	8000	2021-09-01 00:00:00	2026-03-15 16:11:22.9
cmmryc61g004xr5j0dxtxgokc	psa-main	9	2021	Electricity	Electric City	5642	2021-09-01 00:00:00	2026-03-15 16:11:22.901
cmmryc61g004zr5j000kdnwc6	psa-main	9	2021	Maintenance	Lift Maintence	800	2021-09-01 00:00:00	2026-03-15 16:11:22.901
cmmryc61h0051r5j0otchhs9h	psa-main	9	2021	Cleaning	Grabage Payment	1200	2021-09-01 00:00:00	2026-03-15 16:11:22.901
cmmryc61h0053r5j0s1z8f9qy	psa-main	9	2021	Miscellaneous	Ganesh Puja flowers	200	2021-09-01 00:00:00	2026-03-15 16:11:22.901
cmmryc61h0055r5j0i5bua9cp	psa-main	9	2021	Miscellaneous	Blub	440	2021-09-01 00:00:00	2026-03-15 16:11:22.902
cmmryc61h0057r5j02cgj6hy0	psa-main	9	2021	Maintenance	Lift Mats(2) and Lizol(2)	650	2021-09-01 00:00:00	2026-03-15 16:11:22.902
cmmryc61i0059r5j02ezbg1yd	psa-main	9	2021	Maintenance	Lift Mats(4)	565	2021-09-01 00:00:00	2026-03-15 16:11:22.902
cmmryc61i005br5j0a0xlaa83	psa-main	10	2021	Security	Watch Man Salary	8000	2021-10-01 00:00:00	2026-03-15 16:11:22.903
cmmryc61i005dr5j0y5eb3mgv	psa-main	10	2021	Electricity	Electric City	6090	2021-10-01 00:00:00	2026-03-15 16:11:22.903
cmmryc61j005fr5j0nptzur9b	psa-main	10	2021	Maintenance	Lift Maintence	800	2021-10-01 00:00:00	2026-03-15 16:11:22.903
cmmryc61j005hr5j08yqquewb	psa-main	10	2021	Cleaning	Grabage Payment	1200	2021-10-01 00:00:00	2026-03-15 16:11:22.903
cmmryc61j005jr5j0w60qp7w3	psa-main	11	2021	Security	Watch Man Salary	8000	2021-11-01 00:00:00	2026-03-15 16:11:22.904
cmmryc61j005lr5j02awquq9b	psa-main	11	2021	Electricity	Electric City	6505	2021-11-01 00:00:00	2026-03-15 16:11:22.904
cmmryc61k005nr5j04cwhnwen	psa-main	11	2021	Maintenance	Lift Maintence	800	2021-11-01 00:00:00	2026-03-15 16:11:22.904
cmmryc61k005pr5j02b6iw6qw	psa-main	11	2021	Cleaning	Grabage Payment	1200	2021-11-01 00:00:00	2026-03-15 16:11:22.905
cmmryc61k005rr5j0k3iwos66	psa-main	12	2021	Security	Watch Man Salary	8000	2021-12-01 00:00:00	2026-03-15 16:11:22.905
cmmryc61l005tr5j0hddx05mg	psa-main	12	2021	Electricity	Electric City	5763	2021-12-01 00:00:00	2026-03-15 16:11:22.905
cmmryc61l005vr5j0rsw512q6	psa-main	12	2021	Maintenance	Lift Maintence	800	2021-12-01 00:00:00	2026-03-15 16:11:22.906
cmmryc61m005xr5j0jgsaz63s	psa-main	12	2021	Cleaning	Grabage Payment	1200	2021-12-01 00:00:00	2026-03-15 16:11:22.906
cmmryc61m005zr5j03klr7nma	psa-main	1	2022	Security	Watch Man Salary	8000	2022-01-01 00:00:00	2026-03-15 16:11:22.907
cmmryc61n0061r5j00engkmgg	psa-main	1	2022	Electricity	Electric City	6809	2022-01-01 00:00:00	2026-03-15 16:11:22.907
cmmryc61n0063r5j0plj58z8z	psa-main	1	2022	Maintenance	Lift Maintence	800	2022-01-01 00:00:00	2026-03-15 16:11:22.908
cmmryc61o0065r5j06r7ooqdy	psa-main	1	2022	Cleaning	Grabage Payment	1200	2022-01-01 00:00:00	2026-03-15 16:11:22.908
cmmryc61p0067r5j0cqsj8bd7	psa-main	2	2022	Security	Watch Man Salary	8000	2022-02-01 00:00:00	2026-03-15 16:11:22.909
cmmryc61p0069r5j07dslk3mb	psa-main	2	2022	Electricity	Electric City	8645	2022-02-01 00:00:00	2026-03-15 16:11:22.909
cmmryc61p006br5j0tiate6dn	psa-main	2	2022	Maintenance	Lift Maintence	800	2022-02-01 00:00:00	2026-03-15 16:11:22.91
cmmryc61q006dr5j0m6ovtpep	psa-main	2	2022	Cleaning	Grabage Payment	1200	2022-02-01 00:00:00	2026-03-15 16:11:22.91
cmmryc61q006fr5j0d8gdv4mt	psa-main	3	2022	Security	Watch Man Salary	8000	2022-03-01 00:00:00	2026-03-15 16:11:22.911
cmmryc61q006hr5j0w5rr5b9c	psa-main	3	2022	Electricity	Electric City	8952	2022-03-01 00:00:00	2026-03-15 16:11:22.911
cmmryc61r006jr5j0jlxz26ng	psa-main	3	2022	Maintenance	Lift Maintence	800	2022-03-01 00:00:00	2026-03-15 16:11:22.911
cmmryc61r006lr5j0xywmhfml	psa-main	3	2022	Cleaning	Grabage Payment	1200	2022-03-01 00:00:00	2026-03-15 16:11:22.912
cmmryc61r006nr5j0c231km2o	psa-main	3	2022	Water	Bouten - Water Bill	43826	2022-03-01 00:00:00	2026-03-15 16:11:22.912
cmmryc61s006pr5j0nhx2poj9	psa-main	3	2022	Maintenance	Plumber Charges	7260	2022-03-01 00:00:00	2026-03-15 16:11:22.912
cmmryc61s006rr5j018u7acb9	psa-main	4	2022	Security	Watch Man Salary	8000	2022-04-01 00:00:00	2026-03-15 16:11:22.912
cmmryc61s006tr5j0mrzk0gnh	psa-main	4	2022	Electricity	Electric City	6231	2022-04-01 00:00:00	2026-03-15 16:11:22.913
cmmryc61t006vr5j08tcgsge1	psa-main	4	2022	Maintenance	Lift Maintence	800	2022-04-01 00:00:00	2026-03-15 16:11:22.913
cmmryc61t006xr5j0908tyopr	psa-main	4	2022	Cleaning	Grabage Payment	1200	2022-04-01 00:00:00	2026-03-15 16:11:22.914
cmmryc61t006zr5j0z8dkbt2b	psa-main	4	2022	Water	Pradeep water bill	771	2022-04-01 00:00:00	2026-03-15 16:11:22.914
cmmryc61u0071r5j0hg0ap6ir	psa-main	4	2022	Water	Santosh Water Bill	1009	2022-04-01 00:00:00	2026-03-15 16:11:22.914
cmmryc6270073r5j0g2siwir0	psa-main	4	2022	Water	Common Water Bill	1737	2022-04-01 00:00:00	2026-03-15 16:11:22.927
cmmryc6280075r5j0v1s0g5ms	psa-main	5	2022	Security	Watch Man Salary	8000	2022-05-01 00:00:00	2026-03-15 16:11:22.928
cmmryc6280077r5j0ay3bpdfl	psa-main	5	2022	Electricity	Electric City	3711	2022-05-01 00:00:00	2026-03-15 16:11:22.929
cmmryc6290079r5j0tvqnevx0	psa-main	5	2022	Maintenance	Lift Maintence	800	2022-05-01 00:00:00	2026-03-15 16:11:22.929
cmmryc629007br5j0do61k0kg	psa-main	5	2022	Cleaning	Grabage Payment	1200	2022-05-01 00:00:00	2026-03-15 16:11:22.93
cmmryc62a007dr5j0oe3c1r9f	psa-main	5	2022	Water	Pradeep water bill	443	2022-05-01 00:00:00	2026-03-15 16:11:22.93
cmmryc62a007fr5j071u0xhhw	psa-main	5	2022	Water	Santosh Water Bill	1280	2022-05-01 00:00:00	2026-03-15 16:11:22.931
cmmryc62b007hr5j0zg0588m7	psa-main	5	2022	Water	Common Water Bill	2770	2022-05-01 00:00:00	2026-03-15 16:11:22.931
cmmryc62b007jr5j0zitiry4k	psa-main	5	2022	Electricity	Motor Electrical Amount	2000	2022-05-01 00:00:00	2026-03-15 16:11:22.931
cmmryc62b007lr5j0s40fz10d	psa-main	5	2022	Cleaning	Floor Cleaner	325	2022-05-01 00:00:00	2026-03-15 16:11:22.932
cmmryc62c007nr5j00j0vmbes	psa-main	5	2022	Fuel	Diesel	1500	2022-05-01 00:00:00	2026-03-15 16:11:22.932
cmmryc62c007pr5j0cussfz3k	psa-main	6	2022	Security	Watch Man Salary	8000	2022-06-01 00:00:00	2026-03-15 16:11:22.932
cmmryc62c007rr5j0yys4epw9	psa-main	6	2022	Electricity	Electric City	4954	2022-06-01 00:00:00	2026-03-15 16:11:22.933
cmmryc62d007tr5j04kd2l1sv	psa-main	6	2022	Maintenance	Lift Maintence	800	2022-06-01 00:00:00	2026-03-15 16:11:22.933
cmmryc62d007vr5j0baue3by2	psa-main	6	2022	Cleaning	Grabage Payment	1500	2022-06-01 00:00:00	2026-03-15 16:11:22.934
cmmryc62e007xr5j0bt1hm1mw	psa-main	6	2022	Water	Pradeep water bill	1135	2022-06-01 00:00:00	2026-03-15 16:11:22.934
cmmryc62e007zr5j0q6yvv6k3	psa-main	6	2022	Water	Santosh Water Bill	856	2022-06-01 00:00:00	2026-03-15 16:11:22.935
cmmryc62f0081r5j0ddvyzfdc	psa-main	6	2022	Water	Common Water Bill	4067	2022-06-01 00:00:00	2026-03-15 16:11:22.935
cmmryc62f0083r5j09ijaur60	psa-main	6	2022	Fuel	Diesel	1500	2022-06-01 00:00:00	2026-03-15 16:11:22.936
cmmryc62g0085r5j0ft1xtvfh	psa-main	7	2022	Security	Watch Man Salary	8000	2022-07-01 00:00:00	2026-03-15 16:11:22.936
cmmryc62g0087r5j040tmc3nl	psa-main	7	2022	Electricity	Electric City	5599	2022-07-01 00:00:00	2026-03-15 16:11:22.937
cmmryc62h0089r5j0d2s5h6bd	psa-main	7	2022	Maintenance	Lift Maintence	800	2022-07-01 00:00:00	2026-03-15 16:11:22.937
cmmryc62h008br5j04awnh0ka	psa-main	7	2022	Cleaning	Grabage Payment	1500	2022-07-01 00:00:00	2026-03-15 16:11:22.937
cmmryc62h008dr5j08qlp96iq	psa-main	7	2022	Water	Santosh Water Bill	420	2022-07-01 00:00:00	2026-03-15 16:11:22.938
cmmryc62h008fr5j02khqg2nk	psa-main	7	2022	Water	Common Water Bill	652	2022-07-01 00:00:00	2026-03-15 16:11:22.938
cmmryc62i008hr5j0icalfonm	psa-main	7	2022	Security	Watch Man Room Fan	1550	2022-07-01 00:00:00	2026-03-15 16:11:22.938
cmmryc62i008jr5j01s5sqklk	psa-main	7	2022	Electricity	Electrician	700	2022-07-01 00:00:00	2026-03-15 16:11:22.939
cmmryc62i008lr5j0ybn1dr3u	psa-main	7	2022	Miscellaneous	Miscellaneous	120	2022-07-01 00:00:00	2026-03-15 16:11:22.939
cmmryc62j008nr5j05ek7rqyw	psa-main	8	2022	Security	Watch Man Salary	8000	2022-08-01 00:00:00	2026-03-15 16:11:22.939
cmmryc62j008pr5j0k80u31q5	psa-main	8	2022	Electricity	Electric City	6769	2022-08-01 00:00:00	2026-03-15 16:11:22.94
cmmryc62k008rr5j0oxs56pdu	psa-main	8	2022	Maintenance	Lift Maintence	800	2022-08-01 00:00:00	2026-03-15 16:11:22.94
cmmryc62k008tr5j0dstm6tm3	psa-main	8	2022	Cleaning	Grabage Payment	1500	2022-08-01 00:00:00	2026-03-15 16:11:22.94
cmmryc62k008vr5j0xwfuw7et	psa-main	8	2022	Cleaning	Lizol and mop stick	330	2022-08-01 00:00:00	2026-03-15 16:11:22.941
cmmryc62l008xr5j0np3v6tzv	psa-main	8	2022	Miscellaneous	carpet and Flood Light	5450	2022-08-01 00:00:00	2026-03-15 16:11:22.941
cmmryc62l008zr5j0uux9hx5d	psa-main	8	2022	Miscellaneous	Miscellaneous	100	2022-08-01 00:00:00	2026-03-15 16:11:22.941
cmmryc62l0091r5j0hf0zo928	psa-main	9	2022	Security	Watch Man Salary	8000	2022-09-01 00:00:00	2026-03-15 16:11:22.942
cmmryc62l0093r5j090rv14s3	psa-main	9	2022	Electricity	Electric City	7531	2022-09-01 00:00:00	2026-03-15 16:11:22.942
cmmryc62m0095r5j05eemyh3l	psa-main	9	2022	Maintenance	Lift Maintence	800	2022-09-01 00:00:00	2026-03-15 16:11:22.942
cmmryc62m0097r5j0uy3fd635	psa-main	9	2022	Cleaning	Grabage Payment	1500	2022-09-01 00:00:00	2026-03-15 16:11:22.943
cmmryc62m0099r5j0jaqna35n	psa-main	9	2022	Maintenance	Lift Issue	2800	2022-09-01 00:00:00	2026-03-15 16:11:22.943
cmmryc62n009br5j0ijosaaoq	psa-main	10	2022	Security	Watch Man Salary	8000	2022-10-01 00:00:00	2026-03-15 16:11:22.943
cmmryc62n009dr5j06chhocgd	psa-main	10	2022	Electricity	Electric City	6830	2022-10-01 00:00:00	2026-03-15 16:11:22.943
cmmryc62n009fr5j0g51dmikf	psa-main	10	2022	Maintenance	Lift Maintence	800	2022-10-01 00:00:00	2026-03-15 16:11:22.944
cmmryc62o009hr5j00dxopx1z	psa-main	10	2022	Cleaning	Grabage Payment	1500	2022-10-01 00:00:00	2026-03-15 16:11:22.944
cmmryc62o009jr5j090gt35x2	psa-main	10	2022	Fuel	Diesel	1100	2022-10-01 00:00:00	2026-03-15 16:11:22.944
cmmryc62o009lr5j0a8emyi09	psa-main	11	2022	Security	Watch Man Salary	8000	2022-11-01 00:00:00	2026-03-15 16:11:22.945
cmmryc62p009nr5j0tsacqpsx	psa-main	11	2022	Electricity	Electric City	5897	2022-11-01 00:00:00	2026-03-15 16:11:22.945
cmmryc62p009pr5j0o7vhug3n	psa-main	11	2022	Maintenance	Lift Maintence	800	2022-11-01 00:00:00	2026-03-15 16:11:22.945
cmmryc62p009rr5j0zrmjihxq	psa-main	11	2022	Cleaning	Grabage Payment	1500	2022-11-01 00:00:00	2026-03-15 16:11:22.946
cmmryc62p009tr5j0shguytpt	psa-main	11	2022	Cleaning	Miscellaneous(lizol,broom stick,Mop etc)	500	2022-11-01 00:00:00	2026-03-15 16:11:22.946
cmmryc62q009vr5j0ryeq1bt6	psa-main	12	2022	Security	Watch Man Salary	8000	2022-12-01 00:00:00	2026-03-15 16:11:22.946
cmmryc62q009xr5j0j1d2hflu	psa-main	12	2022	Electricity	Electric City	7055	2022-12-01 00:00:00	2026-03-15 16:11:22.947
cmmryc62r009zr5j077lfw5fb	psa-main	12	2022	Maintenance	Lift Maintence	800	2022-12-01 00:00:00	2026-03-15 16:11:22.947
cmmryc62r00a1r5j03kccwyoy	psa-main	12	2022	Cleaning	Grabage Payment	1500	2022-12-01 00:00:00	2026-03-15 16:11:22.947
cmmryc62r00a3r5j0lrvbmym3	psa-main	12	2022	Miscellaneous	Miscellaneous	120	2022-12-01 00:00:00	2026-03-15 16:11:22.948
cmmryc62r00a5r5j0zwlgv4wy	psa-main	12	2022	Fuel	Diesel	2050	2022-12-01 00:00:00	2026-03-15 16:11:22.948
cmmryc62s00a7r5j0msz3yndv	psa-main	1	2023	Security	Watch Man Salary	8000	2023-01-01 00:00:00	2026-03-15 16:11:22.948
cmmryc62s00a9r5j0t942yb89	psa-main	1	2023	Electricity	Electric City	7321	2023-01-01 00:00:00	2026-03-15 16:11:22.949
cmmryc62s00abr5j0tvpmg6a9	psa-main	1	2023	Maintenance	Lift Maintence	800	2023-01-01 00:00:00	2026-03-15 16:11:22.949
cmmryc62t00adr5j07foy6t9y	psa-main	1	2023	Cleaning	Grabage Payment	1500	2023-01-01 00:00:00	2026-03-15 16:11:22.949
cmmryc62t00afr5j0q0cppc3f	psa-main	1	2023	Water	Water Bill	1009	2023-01-01 00:00:00	2026-03-15 16:11:22.95
cmmryc62u00ahr5j0r1v8wqj7	psa-main	1	2023	Water	water tanker	1100	2023-01-01 00:00:00	2026-03-15 16:11:22.95
cmmryc62u00ajr5j09c2kzwzu	psa-main	2	2023	Security	Watch Man Salary	8000	2023-02-01 00:00:00	2026-03-15 16:11:22.951
cmmryc62v00alr5j09k3jaaye	psa-main	2	2023	Electricity	Electric City	6307	2023-02-01 00:00:00	2026-03-15 16:11:22.951
cmmryc62v00anr5j0brzj7868	psa-main	2	2023	Maintenance	Lift Maintence	800	2023-02-01 00:00:00	2026-03-15 16:11:22.951
cmmryc62v00apr5j0gefj6jmy	psa-main	2	2023	Cleaning	Grabage Payment	1500	2023-02-01 00:00:00	2026-03-15 16:11:22.952
cmmryc62v00arr5j0qd6y5btq	psa-main	2	2023	Fuel	Diesel	2100	2023-02-01 00:00:00	2026-03-15 16:11:22.952
cmmryc62w00atr5j0n4e7bg82	psa-main	2	2023	Cleaning	Miscellaneous (Lizol)	250	2023-02-01 00:00:00	2026-03-15 16:11:22.952
cmmryc62w00avr5j04lsyp2lf	psa-main	2	2023	Water	Common Water Bill	945	2023-02-01 00:00:00	2026-03-15 16:11:22.953
cmmryc62w00axr5j0zuxj6vfi	psa-main	2	2023	Water	Santosh Water Bill	851	2023-02-01 00:00:00	2026-03-15 16:11:22.953
cmmryc62x00azr5j0bzs9kz4j	psa-main	3	2023	Security	Watch Man Salary	8000	2023-03-01 00:00:00	2026-03-15 16:11:22.953
cmmryc62x00b1r5j0qro9qdol	psa-main	3	2023	Electricity	Electric City	5778	2023-03-01 00:00:00	2026-03-15 16:11:22.953
cmmryc62x00b3r5j0xt12ca8b	psa-main	3	2023	Maintenance	Lift Maintence	800	2023-03-01 00:00:00	2026-03-15 16:11:22.954
cmmryc62x00b5r5j0gewsptav	psa-main	3	2023	Cleaning	Grabage Payment	1500	2023-03-01 00:00:00	2026-03-15 16:11:22.954
cmmryc62y00b7r5j0o5e8pk0c	psa-main	3	2023	Water	Common Water Bill	755	2023-03-01 00:00:00	2026-03-15 16:11:22.954
cmmryc62y00b9r5j0n9vk4081	psa-main	3	2023	Water	Santosh Water Bill	639	2023-03-01 00:00:00	2026-03-15 16:11:22.954
cmmryc62y00bbr5j043qjz902	psa-main	4	2023	Security	Watch Man Salary	8000	2023-04-01 00:00:00	2026-03-15 16:11:22.955
cmmryc62y00bdr5j08m097e7g	psa-main	4	2023	Electricity	Electric City	5074	2023-04-01 00:00:00	2026-03-15 16:11:22.955
cmmryc62z00bfr5j061n0ln06	psa-main	4	2023	Maintenance	Lift Maintence	800	2023-04-01 00:00:00	2026-03-15 16:11:22.955
cmmryc62z00bhr5j08olozjon	psa-main	4	2023	Cleaning	Grabage Payment	1500	2023-04-01 00:00:00	2026-03-15 16:11:22.955
cmmryc63000bjr5j06thedq49	psa-main	4	2023	Water	Common Water Bill	1269	2023-04-01 00:00:00	2026-03-15 16:11:22.956
cmmryc63000blr5j0ojndpo4e	psa-main	4	2023	Water	Santosh Water Bill	1230	2023-04-01 00:00:00	2026-03-15 16:11:22.957
cmmryc63100bnr5j02pmy9ryy	psa-main	4	2023	Fuel	Diesel	1500	2023-04-01 00:00:00	2026-03-15 16:11:22.957
cmmryc63100bpr5j0fvj8tzlq	psa-main	5	2023	Security	Watch Man Salary	8000	2023-05-01 00:00:00	2026-03-15 16:11:22.957
cmmryc63100brr5j0oesmdieu	psa-main	5	2023	Electricity	Electric City	4994	2023-05-01 00:00:00	2026-03-15 16:11:22.958
cmmryc63100btr5j0ddhmlgpa	psa-main	5	2023	Maintenance	Lift Maintence	800	2023-05-01 00:00:00	2026-03-15 16:11:22.958
cmmryc63200bvr5j0c0tpxxdm	psa-main	5	2023	Cleaning	Grabage Payment	1500	2023-05-01 00:00:00	2026-03-15 16:11:22.958
cmmryc63200bxr5j0juda32a7	psa-main	6	2023	Security	Watch Man Salary	8000	2023-06-01 00:00:00	2026-03-15 16:11:22.958
cmmryc63200bzr5j0lj41kli9	psa-main	6	2023	Electricity	Electric City	6917	2023-06-01 00:00:00	2026-03-15 16:11:22.959
cmmryc63200c1r5j0bsihvy0d	psa-main	6	2023	Maintenance	Lift Maintence	800	2023-06-01 00:00:00	2026-03-15 16:11:22.959
cmmryc63300c3r5j0dlzvvj65	psa-main	6	2023	Cleaning	Grabage Payment	1500	2023-06-01 00:00:00	2026-03-15 16:11:22.959
cmmryc63300c5r5j0ea79d4eh	psa-main	6	2023	Cleaning	Miscellaneous(broom stick,Mop, Muggu Pindi etc)	650	2023-06-01 00:00:00	2026-03-15 16:11:22.959
cmmryc63300c7r5j0oz85f6ei	psa-main	6	2023	Fuel	Diesel	2000	2023-06-01 00:00:00	2026-03-15 16:11:22.96
cmmryc63400c9r5j0djjx8x1x	psa-main	6	2023	Cleaning	Dettol,Nimyle (floor cleaner)	669	2023-06-01 00:00:00	2026-03-15 16:11:22.96
cmmryc63400cbr5j04we477f2	psa-main	7	2023	Security	Watch Man Salary	8000	2023-07-01 00:00:00	2026-03-15 16:11:22.96
cmmryc63400cdr5j0u8w62yso	psa-main	7	2023	Electricity	Electric City	7917	2023-07-01 00:00:00	2026-03-15 16:11:22.961
cmmryc63400cfr5j0qn32fyf7	psa-main	7	2023	Maintenance	Lift Maintence	800	2023-07-01 00:00:00	2026-03-15 16:11:22.961
cmmryc63500chr5j0keqr2hjo	psa-main	7	2023	Cleaning	Grabage Payment	1500	2023-07-01 00:00:00	2026-03-15 16:11:22.961
cmmryc63500cjr5j0oqwnkafe	psa-main	7	2023	Miscellaneous	Hikvison Dvr Amount	250	2023-07-01 00:00:00	2026-03-15 16:11:22.961
cmmryc63500clr5j01t4wfwca	psa-main	7	2023	Miscellaneous	blubs(5)	540	2023-07-01 00:00:00	2026-03-15 16:11:22.962
cmmryc63500cnr5j0mjpe8bak	psa-main	7	2023	Water	common Water Biill	544	2023-07-01 00:00:00	2026-03-15 16:11:22.962
cmmryc63600cpr5j03q8vym0d	psa-main	7	2023	Water	Santosh Water Bill	616	2023-07-01 00:00:00	2026-03-15 16:11:22.962
cmmryc63600crr5j0pzl3w11w	psa-main	7	2023	Miscellaneous	Monitor	5310	2023-07-01 00:00:00	2026-03-15 16:11:22.962
cmmryc63600ctr5j0ogqc7y9y	psa-main	7	2023	Miscellaneous	Mouse	224	2023-07-01 00:00:00	2026-03-15 16:11:22.963
cmmryc63600cvr5j07dfqdf46	psa-main	7	2023	Cleaning	Gardening tools	700	2023-07-01 00:00:00	2026-03-15 16:11:22.963
cmmryc63700cxr5j0c2duo6bv	psa-main	8	2023	Security	Watch Man Salary	8000	2023-08-01 00:00:00	2026-03-15 16:11:22.963
cmmryc63700czr5j0w4khbya6	psa-main	8	2023	Electricity	Electric City	7544	2023-08-01 00:00:00	2026-03-15 16:11:22.963
cmmryc63700d1r5j093j75xnx	psa-main	8	2023	Maintenance	Lift Maintence	800	2023-08-01 00:00:00	2026-03-15 16:11:22.964
cmmryc63700d3r5j0ysl1l1lg	psa-main	8	2023	Cleaning	Grabage Payment	1500	2023-08-01 00:00:00	2026-03-15 16:11:22.964
cmmryc63800d5r5j003an7ks3	psa-main	8	2023	Cleaning	Floor Cleaner and dettol	669	2023-08-01 00:00:00	2026-03-15 16:11:22.964
cmmryc63800d7r5j0fb5ukrq3	psa-main	8	2023	Maintenance	Alarm	200	2023-08-01 00:00:00	2026-03-15 16:11:22.965
cmmryc63800d9r5j0zmu5uleu	psa-main	9	2023	Security	Watch Man Salary	8000	2023-09-01 00:00:00	2026-03-15 16:11:22.965
cmmryc63900dbr5j02v3qxtq1	psa-main	9	2023	Electricity	Electric City	8254	2023-09-01 00:00:00	2026-03-15 16:11:22.965
cmmryc63900ddr5j0hqyox7k1	psa-main	9	2023	Maintenance	Lift Maintence	800	2023-09-01 00:00:00	2026-03-15 16:11:22.965
cmmryc63900dfr5j0ilumgrsf	psa-main	9	2023	Cleaning	Grabage Payment	1500	2023-09-01 00:00:00	2026-03-15 16:11:22.966
cmmryc63900dhr5j0t7c0ml4w	psa-main	10	2023	Security	Watch Man Salary	8000	2023-10-01 00:00:00	2026-03-15 16:11:22.966
cmmryc63a00djr5j0tuslf6mw	psa-main	10	2023	Electricity	Electric City	6358	2023-10-01 00:00:00	2026-03-15 16:11:22.966
cmmryc63a00dlr5j0ri73lkxl	psa-main	10	2023	Maintenance	Lift Maintence	800	2023-10-01 00:00:00	2026-03-15 16:11:22.966
cmmryc63a00dnr5j0wocpy5e6	psa-main	10	2023	Cleaning	Grabage Payment	1500	2023-10-01 00:00:00	2026-03-15 16:11:22.967
cmmryc63a00dpr5j0viomty7r	psa-main	10	2023	Cleaning	Floor Cleaner and dettol	568	2023-10-01 00:00:00	2026-03-15 16:11:22.967
cmmryc63b00drr5j0bm2dswlg	psa-main	10	2023	Cleaning	Gardening Amount	500	2023-10-01 00:00:00	2026-03-15 16:11:22.967
cmmryc63b00dtr5j0k1gma0nh	psa-main	10	2023	Miscellaneous	Flowers and cow dung powder	200	2023-10-01 00:00:00	2026-03-15 16:11:22.967
cmmryc63b00dvr5j0oited8rl	psa-main	10	2023	Cleaning	Extra garbage amount	300	2023-10-01 00:00:00	2026-03-15 16:11:22.968
cmmryc63b00dxr5j0wh4cn3ku	psa-main	11	2023	Security	Watch Man Salary	8000	2023-11-01 00:00:00	2026-03-15 16:11:22.968
cmmryc63c00dzr5j0hjxgxd8c	psa-main	11	2023	Electricity	Electric City	5837	2023-11-01 00:00:00	2026-03-15 16:11:22.968
cmmryc63c00e1r5j0n53d49hw	psa-main	11	2023	Cleaning	Grabage Payment	1500	2023-11-01 00:00:00	2026-03-15 16:11:22.968
cmmryc63c00e3r5j05zywutmu	psa-main	11	2023	Maintenance	Hooter Alarm	450	2023-11-01 00:00:00	2026-03-15 16:11:22.969
cmmryc63c00e5r5j0amfvbrbc	psa-main	11	2023	Cleaning	Gardening Amount	500	2023-11-01 00:00:00	2026-03-15 16:11:22.969
cmmryc63d00e7r5j0odkv9mri	psa-main	11	2023	Cleaning	Broom Stick and Cleaning Items and rice powder	539	2023-11-01 00:00:00	2026-03-15 16:11:22.969
cmmryc63d00e9r5j0xjfmewsj	psa-main	12	2023	Security	Watch Man Salary	8000	2023-12-01 00:00:00	2026-03-15 16:11:22.969
cmmryc63d00ebr5j03481335b	psa-main	12	2023	Electricity	Electric City	5985	2023-12-01 00:00:00	2026-03-15 16:11:22.97
cmmryc63d00edr5j0ssec7ubh	psa-main	12	2023	Cleaning	Grabage Payment	1500	2023-12-01 00:00:00	2026-03-15 16:11:22.97
cmmryc63e00efr5j0qj5yeonl	psa-main	12	2023	Miscellaneous	Colors Powder	120	2023-12-01 00:00:00	2026-03-15 16:11:22.97
cmmryc63e00ehr5j009rb59jl	psa-main	12	2023	Cleaning	Mopping stick	200	2023-12-01 00:00:00	2026-03-15 16:11:22.97
cmmryc63e00ejr5j0lizvmav0	psa-main	12	2023	Cleaning	Gardening Amount	500	2023-12-01 00:00:00	2026-03-15 16:11:22.971
cmmryc63e00elr5j0jgpxdwut	psa-main	1	2024	Security	Watch Man Salary	8000	2024-01-01 00:00:00	2026-03-15 16:11:22.971
cmmryc63f00enr5j0bb0x5v7l	psa-main	1	2024	Electricity	Electric City	6128	2024-01-01 00:00:00	2026-03-15 16:11:22.971
cmmryc63f00epr5j0ceqislc8	psa-main	1	2024	Maintenance	Lift Maintence	800	2024-01-01 00:00:00	2026-03-15 16:11:22.971
cmmryc63f00err5j0f0byflx0	psa-main	1	2024	Cleaning	Grabage Payment	1500	2024-01-01 00:00:00	2026-03-15 16:11:22.972
cmmryc63f00etr5j0oirllw3h	psa-main	1	2024	Maintenance	Lift repair amount (Hardware card and CPU)	25000	2024-01-01 00:00:00	2026-03-15 16:11:22.972
cmmryc63g00evr5j0djzyxs1p	psa-main	1	2024	Cleaning	Gardening Amount	500	2024-01-01 00:00:00	2026-03-15 16:11:22.972
cmmryc63g00exr5j0epgpgd7u	psa-main	1	2024	Water	Water BIll	571	2024-01-01 00:00:00	2026-03-15 16:11:22.972
cmmryc63g00ezr5j0j7z4uy48	psa-main	1	2024	Maintenance	Motor check	300	2024-01-01 00:00:00	2026-03-15 16:11:22.973
cmmryc63g00f1r5j0vvx4zro4	psa-main	1	2024	Fuel	Diesel	2500	2024-01-01 00:00:00	2026-03-15 16:11:22.973
cmmryc63h00f3r5j09tc9wxei	psa-main	1	2024	Miscellaneous	Shri Ram Flag	200	2024-01-01 00:00:00	2026-03-15 16:11:22.973
cmmryc63h00f5r5j0849rhh4c	psa-main	2	2024	Electricity	Electric City	7018	2024-02-01 00:00:00	2026-03-15 16:11:22.973
cmmryc63h00f7r5j0l4kacdep	psa-main	2	2024	Maintenance	Lift Maintence	800	2024-02-01 00:00:00	2026-03-15 16:11:22.974
cmmryc63h00f9r5j0o7d6m258	psa-main	2	2024	Cleaning	Grabage Payment	1500	2024-02-01 00:00:00	2026-03-15 16:11:22.974
cmmryc63i00fbr5j09i1lw19z	psa-main	2	2024	Security	Pradeep paid remaining amount after paying to watchman in 10k	-1500	2024-02-01 00:00:00	2026-03-15 16:11:22.974
cmmryc63i00fdr5j04zrp5ss9	psa-main	2	2024	Water	Water BIll	364	2024-02-01 00:00:00	2026-03-15 16:11:22.975
cmmryc63i00ffr5j06opi3bdo	psa-main	2	2024	Maintenance	Locks for compond fencing	297	2024-02-01 00:00:00	2026-03-15 16:11:22.975
cmmryc63j00fhr5j068s07w7v	psa-main	3	2024	Security	Watch Man Salary	8000	2024-03-01 00:00:00	2026-03-15 16:11:22.975
cmmryc63j00fjr5j0kd4m11ur	psa-main	3	2024	Electricity	Electric City	5872	2024-03-01 00:00:00	2026-03-15 16:11:22.975
cmmryc63j00flr5j0yzlo6y6k	psa-main	3	2024	Maintenance	Lift Maintence	1000	2024-03-01 00:00:00	2026-03-15 16:11:22.976
cmmryc63j00fnr5j0invmylb1	psa-main	3	2024	Cleaning	Grabage Payment	1500	2024-03-01 00:00:00	2026-03-15 16:11:22.976
cmmryc63k00fpr5j09c7bmdmy	psa-main	3	2024	Cleaning	Gardening Amount	500	2024-03-01 00:00:00	2026-03-15 16:11:22.976
cmmryc63k00frr5j0ff7wznjs	psa-main	3	2024	Water	Water BIll	1346	2024-03-01 00:00:00	2026-03-15 16:11:22.976
cmmryc63k00ftr5j00dq8csm3	psa-main	3	2024	Cleaning	Floor Cleaner	804	2024-03-01 00:00:00	2026-03-15 16:11:22.977
cmmryc63l00fvr5j0nqx8rrol	psa-main	4	2024	Security	Watch Man Salary	8000	2024-04-01 00:00:00	2026-03-15 16:11:22.977
cmmryc63l00fxr5j016eve6nq	psa-main	4	2024	Electricity	Electric City	6467	2024-04-01 00:00:00	2026-03-15 16:11:22.978
cmmryc63l00fzr5j07nhbibzb	psa-main	4	2024	Maintenance	Lift Maintence	1000	2024-04-01 00:00:00	2026-03-15 16:11:22.978
cmmryc63m00g1r5j0vc1okvb8	psa-main	4	2024	Cleaning	Grabage Payment	1500	2024-04-01 00:00:00	2026-03-15 16:11:22.978
cmmryc63m00g3r5j0nc4c1wlp	psa-main	4	2024	Cleaning	Gardening Amount	500	2024-04-01 00:00:00	2026-03-15 16:11:22.979
cmmryc63m00g5r5j0btj1wt97	psa-main	4	2024	Water	Water BIll	1753	2024-04-01 00:00:00	2026-03-15 16:11:22.979
cmmryc63n00g7r5j0tc0xq0mc	psa-main	4	2024	Cleaning	Broom stick	75	2024-04-01 00:00:00	2026-03-15 16:11:22.979
cmmryc63n00g9r5j050egej1a	psa-main	4	2024	Miscellaneous	Ugadi Flower	790	2024-04-01 00:00:00	2026-03-15 16:11:22.98
cmmryc63n00gbr5j0kzbimb7d	psa-main	4	2024	Maintenance	Lift Mat	1500	2024-04-01 00:00:00	2026-03-15 16:11:22.98
cmmryc63o00gdr5j0jybofpu6	psa-main	5	2024	Security	Watch Man Salary	8000	2024-05-01 00:00:00	2026-03-15 16:11:22.98
cmmryc63o00gfr5j0kpil5v67	psa-main	5	2024	Electricity	Electric City	4221	2024-05-01 00:00:00	2026-03-15 16:11:22.98
cmmryc63o00ghr5j0wy484akn	psa-main	5	2024	Maintenance	Lift Maintence	1000	2024-05-01 00:00:00	2026-03-15 16:11:22.981
cmmryc63p00gjr5j03zeftx68	psa-main	5	2024	Cleaning	Grabage Payment	1500	2024-05-01 00:00:00	2026-03-15 16:11:22.981
cmmryc63p00glr5j0s9cfeg7i	psa-main	5	2024	Cleaning	Gardening Amount	500	2024-05-01 00:00:00	2026-03-15 16:11:22.981
cmmryc63p00gnr5j0u95z7zoe	psa-main	5	2024	Water	Water BIll	2011	2024-05-01 00:00:00	2026-03-15 16:11:22.982
cmmryc63q00gpr5j069jwop8q	psa-main	5	2024	Cleaning	10 Broom stick	1000	2024-05-01 00:00:00	2026-03-15 16:11:22.982
cmmryc63q00grr5j0k35p1dyq	psa-main	5	2024	Fuel	deisel	2000	2024-05-01 00:00:00	2026-03-15 16:11:22.982
cmmryc63q00gtr5j0mh0g8r1l	psa-main	6	2024	Security	Watch Man Salary	8000	2024-06-01 00:00:00	2026-03-15 16:11:22.983
cmmryc63r00gvr5j04a8kggtf	psa-main	6	2024	Electricity	Electric City	6154	2024-06-01 00:00:00	2026-03-15 16:11:22.983
cmmryc63r00gxr5j0pfq6v6w9	psa-main	6	2024	Maintenance	Lift Maintence	1000	2024-06-01 00:00:00	2026-03-15 16:11:22.984
cmmryc63s00gzr5j0jb9hr6r0	psa-main	6	2024	Cleaning	Grabage Payment	1500	2024-06-01 00:00:00	2026-03-15 16:11:22.984
cmmryc63s00h1r5j0amhhtypa	psa-main	6	2024	Cleaning	Gardening Amount	500	2024-06-01 00:00:00	2026-03-15 16:11:22.984
cmmryc63s00h3r5j0lslx01k6	psa-main	6	2024	Water	Water BIll	1438	2024-06-01 00:00:00	2026-03-15 16:11:22.985
cmmryc63s00h5r5j05o6mwi8d	psa-main	6	2024	Miscellaneous	miscelleanous from prashant	219	2024-06-01 00:00:00	2026-03-15 16:11:22.985
cmmryc63t00h7r5j064hwe19z	psa-main	7	2024	Security	Watch Man Salary	8000	2024-07-01 00:00:00	2026-03-15 16:11:22.985
cmmryc63t00h9r5j0rahfve1u	psa-main	7	2024	Electricity	Electric City	7887	2024-07-01 00:00:00	2026-03-15 16:11:22.985
cmmryc63t00hbr5j0htd6k22q	psa-main	7	2024	Maintenance	Lift Maintence	1000	2024-07-01 00:00:00	2026-03-15 16:11:22.986
cmmryc63u00hdr5j0i8qptiuh	psa-main	7	2024	Cleaning	Grabage Payment	1500	2024-07-01 00:00:00	2026-03-15 16:11:22.986
cmmryc63u00hfr5j0or2k756a	psa-main	7	2024	Cleaning	Gardening Amount	500	2024-07-01 00:00:00	2026-03-15 16:11:22.987
cmmryc63u00hhr5j009ab984k	psa-main	7	2024	Water	Water BIll	1013	2024-07-01 00:00:00	2026-03-15 16:11:22.987
cmmryc63v00hjr5j0bx0f51st	psa-main	8	2024	Security	Watch Man Salary	8000	2024-08-01 00:00:00	2026-03-15 16:11:22.987
cmmryc63v00hlr5j0uie47taq	psa-main	8	2024	Electricity	Electric City	7965	2024-08-01 00:00:00	2026-03-15 16:11:22.988
cmmryc63v00hnr5j031ox3vco	psa-main	8	2024	Maintenance	Lift Maintence	1000	2024-08-01 00:00:00	2026-03-15 16:11:22.988
cmmryc63w00hpr5j03p7d8qgk	psa-main	8	2024	Cleaning	Grabage Payment	1500	2024-08-01 00:00:00	2026-03-15 16:11:22.988
cmmryc63w00hrr5j0ea122b6a	psa-main	8	2024	Cleaning	Gardening Amount	500	2024-08-01 00:00:00	2026-03-15 16:11:22.989
cmmryc63w00htr5j0vg1axwy4	psa-main	8	2024	Water	Water BIll	494	2024-08-01 00:00:00	2026-03-15 16:11:22.989
cmmryc63x00hvr5j0a3wpumlr	psa-main	9	2024	Security	Watch Man Salary	8000	2024-09-01 00:00:00	2026-03-15 16:11:22.989
cmmryc63x00hxr5j057wwic9f	psa-main	9	2024	Electricity	Electric City	7922	2024-09-01 00:00:00	2026-03-15 16:11:22.99
cmmryc63x00hzr5j0xmee9qhf	psa-main	9	2024	Cleaning	Grabage Payment	1500	2024-09-01 00:00:00	2026-03-15 16:11:22.99
cmmryc63y00i1r5j0l22jdqy8	psa-main	9	2024	Cleaning	Gardening Amount	500	2024-09-01 00:00:00	2026-03-15 16:11:22.99
cmmryc63y00i3r5j0xw4jx8p4	psa-main	9	2024	Maintenance	CCTV Hard disk aamount	12100	2024-09-01 00:00:00	2026-03-15 16:11:22.991
cmmryc63y00i5r5j02rjhazc8	psa-main	9	2024	Fuel	Diesel	2500	2024-09-01 00:00:00	2026-03-15 16:11:22.991
cmmryc63z00i7r5j0nucn2qcv	psa-main	9	2024	Cleaning	Broom stick and muggu	180	2024-09-01 00:00:00	2026-03-15 16:11:22.991
cmmryc63z00i9r5j0ew52mol3	psa-main	10	2024	Security	Watch Man Salary	8000	2024-10-01 00:00:00	2026-03-15 16:11:22.992
cmmryc63z00ibr5j0689bftql	psa-main	10	2024	Electricity	Electric City	7355	2024-10-01 00:00:00	2026-03-15 16:11:22.992
cmmryc64000idr5j0b4rlp2k7	psa-main	10	2024	Maintenance	Lift Maintence	1000	2024-10-01 00:00:00	2026-03-15 16:11:22.992
cmmryc64000ifr5j0dfuz6p7v	psa-main	10	2024	Cleaning	Grabage Payment	1500	2024-10-01 00:00:00	2026-03-15 16:11:22.993
cmmryc64100ihr5j0tynuqjf9	psa-main	10	2024	Cleaning	Gardening Amount	500	2024-10-01 00:00:00	2026-03-15 16:11:22.993
cmmryc64100ijr5j02qu1aiga	psa-main	10	2024	Miscellaneous	Plants compost and plants	850	2024-10-01 00:00:00	2026-03-15 16:11:22.994
cmmryc64200ilr5j0frai8i8f	psa-main	10	2024	Miscellaneous	Puja flowers	400	2024-10-01 00:00:00	2026-03-15 16:11:22.994
cmmryc64200inr5j05e80wpus	psa-main	10	2024	Cleaning	Diwali Grabage amount	1500	2024-10-01 00:00:00	2026-03-15 16:11:22.994
cmmryc64200ipr5j0h1kyqlas	psa-main	11	2024	Security	Watch Man Salary	8000	2024-11-01 00:00:00	2026-03-15 16:11:22.995
cmmryc64300irr5j0vy8qktf5	psa-main	11	2024	Electricity	Electric City	8771	2024-11-01 00:00:00	2026-03-15 16:11:22.995
cmmryc64300itr5j06i8chie5	psa-main	11	2024	Maintenance	Lift Maintence	1000	2024-11-01 00:00:00	2026-03-15 16:11:22.996
cmmryc64300ivr5j0m9lo8g1o	psa-main	11	2024	Cleaning	Grabage Payment	1500	2024-11-01 00:00:00	2026-03-15 16:11:22.996
cmmryc64400ixr5j0d7zfnsz4	psa-main	11	2024	Cleaning	Gardening Amount	500	2024-11-01 00:00:00	2026-03-15 16:11:22.996
cmmryc64400izr5j0yg8f05tf	psa-main	11	2024	Cleaning	floor cleaner 5 liters	890	2024-11-01 00:00:00	2026-03-15 16:11:22.997
cmmryc64500j1r5j0z3ns3fqu	psa-main	12	2024	Security	Watch Man Salary	8000	2024-12-01 00:00:00	2026-03-15 16:11:22.997
cmmryc64500j3r5j0ympa3a2j	psa-main	12	2024	Electricity	Electric City	9634	2024-12-01 00:00:00	2026-03-15 16:11:22.997
cmmryc64500j5r5j0jsgatrfz	psa-main	12	2024	Cleaning	Grabage Payment	1500	2024-12-01 00:00:00	2026-03-15 16:11:22.998
cmmryc64500j7r5j04mgwa8em	psa-main	12	2024	Cleaning	Gardening Amount	500	2024-12-01 00:00:00	2026-03-15 16:11:22.998
cmmryc64600j9r5j0d4xdx214	psa-main	12	2024	Fuel	Diesel and bulb	3140	2024-12-01 00:00:00	2026-03-15 16:11:22.998
cmmryc64600jbr5j0oijo6cna	psa-main	12	2024	Cleaning	Miscelleanous(mop etc)	320	2024-12-01 00:00:00	2026-03-15 16:11:22.999
cmmryc64700jdr5j073vxiw7r	psa-main	1	2025	Security	Watch Man Salary	8000	2025-01-01 00:00:00	2026-03-15 16:11:22.999
cmmryc64700jfr5j0nd2fghdg	psa-main	1	2025	Electricity	Electric City	8519	2025-01-01 00:00:00	2026-03-15 16:11:23
cmmryc64700jhr5j0ruuk8sby	psa-main	1	2025	Maintenance	Lift Maintence	1000	2025-01-01 00:00:00	2026-03-15 16:11:23
cmmryc64800jjr5j0oheh7961	psa-main	1	2025	Cleaning	Grabage Payment	1500	2025-01-01 00:00:00	2026-03-15 16:11:23
cmmryc64800jlr5j0j3nstd4e	psa-main	1	2025	Cleaning	Gardening Amount	500	2025-01-01 00:00:00	2026-03-15 16:11:23.001
cmmryc64800jnr5j07wb8jjv5	psa-main	1	2025	Miscellaneous	Newyear decoration amount	310	2025-01-01 00:00:00	2026-03-15 16:11:23.001
cmmryc64900jpr5j0rf7cauad	psa-main	1	2025	Cleaning	broom stick	300	2025-01-01 00:00:00	2026-03-15 16:11:23.001
cmmryc64900jrr5j08dxcen4d	psa-main	1	2025	Fuel	diesel	2700	2025-01-01 00:00:00	2026-03-15 16:11:23.002
cmmryc64900jtr5j0kxjnhp7o	psa-main	1	2025	Miscellaneous	bulb	49	2025-01-01 00:00:00	2026-03-15 16:11:23.002
cmmryc64a00jvr5j0p0krnppc	psa-main	1	2025	Maintenance	CCTV DVR Amount	27500	2025-01-01 00:00:00	2026-03-15 16:11:23.002
cmmryc64a00jxr5j0n8gvjvm9	psa-main	1	2025	Miscellaneous	Installation with extra cameras and rack	20500	2025-01-01 00:00:00	2026-03-15 16:11:23.003
cmmryc64a00jzr5j0utjut1wm	psa-main	1	2025	Utilities	TV Cables	325	2025-01-01 00:00:00	2026-03-15 16:11:23.003
cmmryc64b00k1r5j0vgmz76o5	psa-main	1	2025	Water	Water amount	987	2025-01-01 00:00:00	2026-03-15 16:11:23.003
cmmryc64b00k3r5j0hao7lj25	psa-main	2	2025	Security	Watch Man Salary	8000	2025-02-01 00:00:00	2026-03-15 16:11:23.004
cmmryc64b00k5r5j0ffhfi98s	psa-main	2	2025	Electricity	Electric City	8954	2025-02-01 00:00:00	2026-03-15 16:11:23.004
cmmryc64c00k7r5j0l66k5cpv	psa-main	2	2025	Cleaning	Grabage Payment	1500	2025-02-01 00:00:00	2026-03-15 16:11:23.004
cmmryc64c00k9r5j0gbbguw5a	psa-main	2	2025	Cleaning	Gardening Amount	500	2025-02-01 00:00:00	2026-03-15 16:11:23.005
cmmryc64d00kbr5j0egvbrdbp	psa-main	2	2025	Water	water amount	1119	2025-02-01 00:00:00	2026-03-15 16:11:23.005
cmmryc64d00kdr5j0nn9fufo2	psa-main	2	2025	Utilities	Cable spike amount	400	2025-02-01 00:00:00	2026-03-15 16:11:23.005
cmmryc64d00kfr5j0k2kia2qr	psa-main	3	2025	Security	Watch Man Salary	8000	2025-03-01 00:00:00	2026-03-15 16:11:23.006
cmmryc64d00khr5j09e2nuipq	psa-main	3	2025	Electricity	Electric City	8782	2025-03-01 00:00:00	2026-03-15 16:11:23.006
cmmryc64e00kjr5j0x3t0mowb	psa-main	3	2025	Maintenance	Lift Maintence	1000	2025-03-01 00:00:00	2026-03-15 16:11:23.006
cmmryc64e00klr5j0e3eigpnv	psa-main	3	2025	Cleaning	Grabage Payment	1500	2025-03-01 00:00:00	2026-03-15 16:11:23.006
cmmryc64e00knr5j09yv35v7v	psa-main	3	2025	Cleaning	Gardening Amount	500	2025-03-01 00:00:00	2026-03-15 16:11:23.007
cmmryc64f00kpr5j0f8koiqqx	psa-main	3	2025	Water	water amount	1090	2025-03-01 00:00:00	2026-03-15 16:11:23.007
cmmryc64f00krr5j05ona22ax	psa-main	3	2025	Security	Watch Man tap and repair	900	2025-03-01 00:00:00	2026-03-15 16:11:23.007
cmmryc64f00ktr5j0naf7np81	psa-main	3	2025	Utilities	Internet amount	6357	2025-03-01 00:00:00	2026-03-15 16:11:23.008
cmmryc64g00kvr5j054ggmyak	psa-main	4	2025	Security	Watch Man Salary	8000	2025-04-01 00:00:00	2026-03-15 16:11:23.008
cmmryc64g00kxr5j0jkp43mmi	psa-main	4	2025	Electricity	Electric City	7749	2025-04-01 00:00:00	2026-03-15 16:11:23.008
cmmryc64g00kzr5j0f6ng6aw1	psa-main	4	2025	Maintenance	Lift Maintence	1000	2025-04-01 00:00:00	2026-03-15 16:11:23.009
cmmryc64h00l1r5j037nax4lf	psa-main	4	2025	Cleaning	Grabage Payment	1500	2025-04-01 00:00:00	2026-03-15 16:11:23.009
cmmryc64h00l3r5j091mvgypy	psa-main	4	2025	Cleaning	Gardening Amount	500	2025-04-01 00:00:00	2026-03-15 16:11:23.01
cmmryc64h00l5r5j0jxh0nim2	psa-main	4	2025	Water	water amount	1823	2025-04-01 00:00:00	2026-03-15 16:11:23.01
cmmryc64i00l7r5j0xev9yep9	psa-main	4	2025	Fuel	Deisel Amount	2500	2025-04-01 00:00:00	2026-03-15 16:11:23.01
cmmryc64i00l9r5j01itr2n9g	psa-main	4	2025	Maintenance	Terrace lock	99	2025-04-01 00:00:00	2026-03-15 16:11:23.011
cmmryc64j00lbr5j0zrqxp2w9	psa-main	5	2025	Security	Watch Man Salary	8000	2025-05-01 00:00:00	2026-03-15 16:11:23.011
cmmryc64j00ldr5j0tu6h57gf	psa-main	5	2025	Electricity	Electric City	7162	2025-05-01 00:00:00	2026-03-15 16:11:23.011
cmmryc64j00lfr5j0xqfuszc6	psa-main	5	2025	Maintenance	Lift Maintence	1000	2025-05-01 00:00:00	2026-03-15 16:11:23.012
cmmryc64j00lhr5j0tb8pk35l	psa-main	5	2025	Cleaning	Grabage Payment	1500	2025-05-01 00:00:00	2026-03-15 16:11:23.012
cmmryc64k00ljr5j0i7q4d7im	psa-main	5	2025	Cleaning	Gardening Amount	500	2025-05-01 00:00:00	2026-03-15 16:11:23.012
cmmryc64k00llr5j08ggbmgc3	psa-main	5	2025	Water	water amount	1613	2025-05-01 00:00:00	2026-03-15 16:11:23.012
cmmryc64k00lnr5j0ezurroje	psa-main	6	2025	Security	Watch Man Salary	8000	2025-06-01 00:00:00	2026-03-15 16:11:23.013
cmmryc64l00lpr5j0etscvl92	psa-main	6	2025	Electricity	Electric City	8115	2025-06-01 00:00:00	2026-03-15 16:11:23.013
cmmryc64l00lrr5j0gp5yymbg	psa-main	6	2025	Maintenance	Lift Maintence	1000	2025-06-01 00:00:00	2026-03-15 16:11:23.013
cmmryc64l00ltr5j07l792asn	psa-main	6	2025	Cleaning	Grabage Payment	1500	2025-06-01 00:00:00	2026-03-15 16:11:23.014
cmmryc64m00lvr5j03nw2fuuj	psa-main	6	2025	Cleaning	Gardening Amount	500	2025-06-01 00:00:00	2026-03-15 16:11:23.014
cmmryc64m00lxr5j02egc6cry	psa-main	6	2025	Water	water amount	1707	2025-06-01 00:00:00	2026-03-15 16:11:23.014
cmmryc64m00lzr5j0921ao3hy	psa-main	6	2025	Fuel	Desiel amount	3050	2025-06-01 00:00:00	2026-03-15 16:11:23.015
cmmryc64n00m1r5j0j8xo4jkv	psa-main	7	2025	Security	Watch Man Salary	8000	2025-07-01 00:00:00	2026-03-15 16:11:23.015
cmmryc64n00m3r5j0cohemb94	psa-main	7	2025	Electricity	Electric City	8810	2025-07-01 00:00:00	2026-03-15 16:11:23.016
cmmryc64n00m5r5j0cij74e4e	psa-main	7	2025	Cleaning	Grabage Payment	1500	2025-07-01 00:00:00	2026-03-15 16:11:23.016
cmmryc64o00m7r5j0zdws7l84	psa-main	7	2025	Cleaning	Gardening Amount	500	2025-07-01 00:00:00	2026-03-15 16:11:23.016
cmmryc64o00m9r5j0uisdzkzn	psa-main	7	2025	Water	water amount	1328	2025-07-01 00:00:00	2026-03-15 16:11:23.017
cmmryc64o00mbr5j0egj8pxpn	psa-main	7	2025	Cleaning	Miscellaneous (Wood Mob, Cleaning Broom,cocnut brooms)	210	2025-07-01 00:00:00	2026-03-15 16:11:23.017
cmmryc64p00mdr5j003tgn10d	psa-main	8	2025	Security	Watch Man Salary	8000	2025-08-01 00:00:00	2026-03-15 16:11:23.017
cmmryc64p00mfr5j079it06b3	psa-main	8	2025	Electricity	Electric City	9045	2025-08-01 00:00:00	2026-03-15 16:11:23.018
cmmryc64q00mhr5j0zczwjk1a	psa-main	8	2025	Cleaning	Grabage Payment	1500	2025-08-01 00:00:00	2026-03-15 16:11:23.018
cmmryc64q00mjr5j0gc9sswf2	psa-main	8	2025	Cleaning	Gardening Amount	500	2025-08-01 00:00:00	2026-03-15 16:11:23.018
cmmryc64q00mlr5j0axfmomly	psa-main	8	2025	Water	water amount	487	2025-08-01 00:00:00	2026-03-15 16:11:23.019
cmmryc64q00mnr5j09ry53341	psa-main	8	2025	Maintenance	Apt Generator AMC renewed	11600	2025-08-01 00:00:00	2026-03-15 16:11:23.019
cmmryc64r00mpr5j02z99e2pj	psa-main	8	2025	Fuel	Diesel	3000	2025-08-01 00:00:00	2026-03-15 16:11:23.019
cmmryc64r00mrr5j0qmgfvz45	psa-main	8	2025	Cleaning	Water cleaning	3600	2025-08-01 00:00:00	2026-03-15 16:11:23.02
cmmryc64r00mtr5j0zm5mnf0v	psa-main	8	2025	Maintenance	Plumber work	1775	2025-08-01 00:00:00	2026-03-15 16:11:23.02
cmmryc64s00mvr5j01fksqy1w	psa-main	9	2025	Security	Watch Man Salary	8000	2025-09-01 00:00:00	2026-03-15 16:11:23.02
cmmryc64s00mxr5j002dmntar	psa-main	9	2025	Electricity	Electric City	8711	2025-09-01 00:00:00	2026-03-15 16:11:23.02
cmmryc64s00mzr5j0sdxoz9uj	psa-main	9	2025	Cleaning	Grabage Payment	1500	2025-09-01 00:00:00	2026-03-15 16:11:23.021
cmmryc64s00n1r5j0lyvcv5d8	psa-main	9	2025	Cleaning	Gardening Amount	500	2025-09-01 00:00:00	2026-03-15 16:11:23.021
cmmryc64t00n3r5j0sqrima1m	psa-main	10	2025	Security	Watch Man Salary	8000	2025-10-01 00:00:00	2026-03-15 16:11:23.021
cmmryc64t00n5r5j0wxtwsdvc	psa-main	10	2025	Electricity	Electric City	7723	2025-10-01 00:00:00	2026-03-15 16:11:23.022
cmmryc64t00n7r5j05q3dhbsv	psa-main	10	2025	Cleaning	Grabage Payment	1500	2025-10-01 00:00:00	2026-03-15 16:11:23.022
cmmryc64u00n9r5j08difg2jb	psa-main	10	2025	Cleaning	Gardening Amount	500	2025-10-01 00:00:00	2026-03-15 16:11:23.022
cmmryc64u00nbr5j03tc4x6gd	psa-main	10	2025	Cleaning	Broom sticks	1000	2025-10-01 00:00:00	2026-03-15 16:11:23.023
cmmryc64v00ndr5j09oyrzwjc	psa-main	10	2025	Fuel	Diesel	2000	2025-10-01 00:00:00	2026-03-15 16:11:23.023
cmmryc64v00nfr5j0htvfirzq	psa-main	10	2025	Miscellaneous	flowers, green color	600	2025-10-01 00:00:00	2026-03-15 16:11:23.023
cmmryc64v00nhr5j0zd1jehas	psa-main	10	2025	Electricity	electrician charges	500	2025-10-01 00:00:00	2026-03-15 16:11:23.024
cmmryc64w00njr5j0yv9gvwel	psa-main	10	2025	Cleaning	floor cleaner	1344	2025-10-01 00:00:00	2026-03-15 16:11:23.024
cmmryc64w00nlr5j0p8aq0xki	psa-main	11	2025	Security	Watch Man Salary	8000	2025-11-01 00:00:00	2026-03-15 16:11:23.024
cmmryc64w00nnr5j03mq0gfws	psa-main	11	2025	Electricity	Electric City	8408	2025-11-01 00:00:00	2026-03-15 16:11:23.025
cmmryc64x00npr5j0argzqx5p	psa-main	11	2025	Maintenance	Lift Maintence	1000	2025-11-01 00:00:00	2026-03-15 16:11:23.025
cmmryc64x00nrr5j04ityrnuu	psa-main	11	2025	Cleaning	Grabage Payment	1500	2025-11-01 00:00:00	2026-03-15 16:11:23.025
cmmryc64x00ntr5j0ha1z1q7k	psa-main	11	2025	Cleaning	Gardening Amount	500	2025-11-01 00:00:00	2026-03-15 16:11:23.026
cmmryc64y00nvr5j0bsbi6kri	psa-main	11	2025	Miscellaneous	Mango tree	2100	2025-11-01 00:00:00	2026-03-15 16:11:23.026
cmmryc64y00nxr5j0qhbnmoph	psa-main	11	2025	Miscellaneous	Miscallenous (rangoli)	400	2025-11-01 00:00:00	2026-03-15 16:11:23.027
cmmryc64y00nzr5j0fc5pfojl	psa-main	11	2025	Miscellaneous	Flowers	330	2025-11-01 00:00:00	2026-03-15 16:11:23.027
cmmryc64z00o1r5j0b55qxujo	psa-main	12	2025	Security	Watch Man Salary	8000	2025-12-01 00:00:00	2026-03-15 16:11:23.027
cmmryc64z00o3r5j0urh6betn	psa-main	12	2025	Electricity	Electric City	9081	2025-12-01 00:00:00	2026-03-15 16:11:23.027
cmmryc64z00o5r5j08p37lr1a	psa-main	12	2025	Maintenance	Lift Maintence	1000	2025-12-01 00:00:00	2026-03-15 16:11:23.028
cmmryc65000o7r5j0rikoja2q	psa-main	12	2025	Cleaning	Grabage Payment	1500	2025-12-01 00:00:00	2026-03-15 16:11:23.028
cmmryc65000o9r5j01ofgfhig	psa-main	12	2025	Cleaning	Gardening Amount	500	2025-12-01 00:00:00	2026-03-15 16:11:23.028
cmmryc65000obr5j08vm7lue3	psa-main	12	2025	Miscellaneous	transfer fuse	500	2025-12-01 00:00:00	2026-03-15 16:11:23.029
cmmryc65100odr5j0fwecz9j1	psa-main	12	2025	Water	Tanker amount	7700	2025-12-01 00:00:00	2026-03-15 16:11:23.029
cmmryc65100ofr5j0ni33msrs	psa-main	12	2025	Miscellaneous	New year flours	500	2025-12-01 00:00:00	2026-03-15 16:11:23.029
cmmryc65100ohr5j00q09xoa7	psa-main	1	2026	Security	Watch Man Salary	8000	2026-01-01 00:00:00	2026-03-15 16:11:23.03
cmmryc65200ojr5j060zaecwm	psa-main	1	2026	Electricity	Electric City	9215	2026-01-01 00:00:00	2026-03-15 16:11:23.03
cmmryc65200olr5j0mqdmgrx7	psa-main	1	2026	Maintenance	Lift Maintence	1000	2026-01-01 00:00:00	2026-03-15 16:11:23.031
cmmryc65300onr5j0bt9guq8w	psa-main	1	2026	Cleaning	Grabage Payment	1500	2026-01-01 00:00:00	2026-03-15 16:11:23.031
cmmryc65300opr5j01i1n7is4	psa-main	1	2026	Cleaning	Gardening Amount	500	2026-01-01 00:00:00	2026-03-15 16:11:23.031
cmmryc65300orr5j0znqzd9kf	psa-main	2	2026	Security	Watch Man Salary	8000	2026-02-01 00:00:00	2026-03-15 16:11:23.032
cmmryc65400otr5j0dhfdsrom	psa-main	2	2026	Electricity	Electric City	7739	2026-02-01 00:00:00	2026-03-15 16:11:23.032
cmmryc65400ovr5j0t8ufx0jj	psa-main	2	2026	Maintenance	Lift Maintence	1000	2026-02-01 00:00:00	2026-03-15 16:11:23.032
cmmryc65400oxr5j0cbvre91b	psa-main	2	2026	Cleaning	Grabage Payment	1500	2026-02-01 00:00:00	2026-03-15 16:11:23.033
cmmryc65500ozr5j0cksww2ge	psa-main	2	2026	Cleaning	Gardening Amount	500	2026-02-01 00:00:00	2026-03-15 16:11:23.033
cmmryc65500p1r5j0bxe6v6g9	psa-main	2	2026	Cleaning	Miscellanous(Muggu,broom, etc..)	500	2026-02-01 00:00:00	2026-03-15 16:11:23.033
cmmryc65500p3r5j0cotsqvt4	psa-main	2	2026	Cleaning	floor cleaner	740	2026-02-01 00:00:00	2026-03-15 16:11:23.034
cmmryc65600p5r5j0zdpct1ml	psa-main	3	2026	Security	Watch Man Salary	8000	2026-03-01 00:00:00	2026-03-15 16:11:23.034
cmmryc65600p7r5j0vg4pbod6	psa-main	3	2026	Electricity	Electric City	7033	2026-03-01 00:00:00	2026-03-15 16:11:23.034
cmmryc65600p9r5j0hnlpoufp	psa-main	3	2026	Cleaning	Grabage Payment	1500	2026-03-01 00:00:00	2026-03-15 16:11:23.035
cmmryc65600pbr5j05i756od4	psa-main	3	2026	Cleaning	Gardening Amount	500	2026-03-01 00:00:00	2026-03-15 16:11:23.035
\.


--
-- Data for Name: Flat; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Flat" (id, "flatNumber", floor, "apartmentId") FROM stdin;
cmmqfin2s0002r5rig5gyl78u	101	1	psa-main
cmmqfin300007r5ri7hev5ck1	102	1	psa-main
cmmqfin34000cr5riujl5lkum	103	1	psa-main
cmmqfin37000hr5ri6v7crew3	201	2	psa-main
cmmqfin39000mr5rifitry7zu	202	2	psa-main
cmmqfin3c000rr5riaz9ygvbu	203	2	psa-main
cmmqfin3f000wr5riqmcfcwsy	301	3	psa-main
cmmqfin3h0011r5ri60yvcljp	302	3	psa-main
cmmqfin3k0016r5ri43nzr1pi	303	3	psa-main
cmmqfin3n001br5rinbkhyypl	401	4	psa-main
cmmqfin3q001gr5riuek21iw1	402	4	psa-main
cmmqfin3s001lr5ri9eb3mld8	403	4	psa-main
cmmqfin3v001qr5rik05d5yuh	501	5	psa-main
cmmqfin3x001vr5rixugbviaq	502	5	psa-main
cmmqfin400020r5ri8p9t0kvk	503	5	psa-main
\.


--
-- Data for Name: FlatContribution; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."FlatContribution" (id, "flatId", "userId", month, year, type, amount, description, "appliedToBillId", "createdAt") FROM stdin;
\.


--
-- Data for Name: FlatOwnership; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."FlatOwnership" (id, "flatId", "userId", "fromDate", "toDate", "isActive") FROM stdin;
cmmrcnslt0006r59e6isvpqny	cmmqfin2s0002r5rig5gyl78u	cmmrcnslh0001r59e6swro422	2024-01-01 00:00:00	\N	t
\.


--
-- Data for Name: FlatTenancy; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."FlatTenancy" (id, "flatId", "userId", "fromDate", "toDate", "isActive") FROM stdin;
cmmqfin2z0005r5rivdpc4ajq	cmmqfin2s0002r5rig5gyl78u	cmmqfin2v0003r5rid4lrhpg3	2024-01-01 00:00:00	\N	t
cmmqfin33000ar5riaxy4bgoh	cmmqfin300007r5ri7hev5ck1	cmmqfin310008r5rizm9dia5q	2024-01-01 00:00:00	\N	t
cmmqfin36000fr5rifmn9t5wx	cmmqfin34000cr5riujl5lkum	cmmqfin35000dr5rizrtqlucc	2024-01-01 00:00:00	\N	t
cmmqfin39000kr5ricnx8avzt	cmmqfin37000hr5ri6v7crew3	cmmqfin38000ir5ri6m0kii1w	2024-01-01 00:00:00	\N	t
cmmqfin3b000pr5riuw6tug18	cmmqfin39000mr5rifitry7zu	cmmqfin3a000nr5rifmdtmn4l	2024-01-01 00:00:00	\N	t
cmmqfin3f000ur5riqt4sj286	cmmqfin3c000rr5riaz9ygvbu	cmmqfin3d000sr5rihf8qwecl	2024-01-01 00:00:00	\N	t
cmmqfin3h000zr5ri6yncdnp3	cmmqfin3f000wr5riqmcfcwsy	cmmqfin3g000xr5ribkvvqrk0	2024-01-01 00:00:00	\N	t
cmmqfin3k0014r5rimka6693b	cmmqfin3h0011r5ri60yvcljp	cmmqfin3i0012r5rijo82cm7a	2024-01-01 00:00:00	\N	t
cmmqfin3n0019r5ripxty7hc2	cmmqfin3k0016r5ri43nzr1pi	cmmqfin3l0017r5ri167ce1oj	2024-01-01 00:00:00	\N	t
cmmqfin3p001er5ri4t67z1iz	cmmqfin3n001br5rinbkhyypl	cmmqfin3o001cr5ri5bpkv24a	2024-01-01 00:00:00	\N	t
cmmqfin3s001jr5ribi12xhg3	cmmqfin3q001gr5riuek21iw1	cmmqfin3q001hr5riwxj65axe	2024-01-01 00:00:00	\N	t
cmmqfin3v001or5ri24vymfea	cmmqfin3s001lr5ri9eb3mld8	cmmqfin3t001mr5ri6l8aibpi	2024-01-01 00:00:00	\N	t
cmmqfin3x001tr5rirpvuke8p	cmmqfin3v001qr5rik05d5yuh	cmmqfin3w001rr5ripkpb80vj	2024-01-01 00:00:00	\N	t
cmmqfin3z001yr5ri606nscml	cmmqfin3x001vr5rixugbviaq	cmmqfin3y001wr5rivfau0fn4	2024-01-01 00:00:00	\N	t
cmmqfin430023r5riqg5sj472	cmmqfin400020r5ri8p9t0kvk	cmmqfin410021r5riqey329rg	2024-01-01 00:00:00	\N	t
\.


--
-- Data for Name: MaintenanceRequest; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."MaintenanceRequest" (id, "flatId", "userId", title, description, status, priority, "resolvedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: MonthlyBill; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."MonthlyBill" (id, "flatId", month, year, "maintenanceAmount", "waterAmount", "previousDue", "totalAmount", "paidAmount", status, "generatedAt", "updatedAt") FROM stdin;
cmmqica13000dr5l8zpk4g9jw	cmmqfin3f000wr5riqmcfcwsy	3	2026	2000	537	334	2871	0	PENDING	2026-03-14 15:55:48.039	2026-03-16 05:46:02.014
cmmrdgxz1000jr5c3j8nqxt0l	cmmqfin3n001br5rinbkhyypl	2	2026	2000	745	0	2745	4000	PAID	2026-03-15 06:27:13.789	2026-03-16 03:48:31.562
cmmrdgxz4000lr5c38o35cqkf	cmmqfin3q001gr5riuek21iw1	2	2026	2000	611	0	2611	2000	PARTIAL	2026-03-15 06:27:13.792	2026-03-16 03:48:31.563
cmmrdgxza000nr5c3klf8fuot	cmmqfin3s001lr5ri9eb3mld8	2	2026	2000	555	0	2555	2000	PARTIAL	2026-03-15 06:27:13.798	2026-03-16 03:48:31.564
cmmqica17000hr5l8vda1nl2o	cmmqfin3k0016r5ri43nzr1pi	3	2026	2000	2577	0	4577	0	PENDING	2026-03-14 15:55:48.043	2026-03-16 05:46:02.012
cmmqica1h000rr5l8zeqqoftt	cmmqfin3x001vr5rixugbviaq	3	2026	2000	639	0	2639	0	PENDING	2026-03-14 15:55:48.053	2026-03-16 05:46:02.015
cmmqica15000fr5l81a8pd69b	cmmqfin3h0011r5ri60yvcljp	3	2026	2000	2432	0	4432	0	PENDING	2026-03-14 15:55:48.041	2026-03-16 05:46:02.017
cmmrdgxym0009r5c36icwkik3	cmmqfin39000mr5rifitry7zu	2	2026	2000	1049	2000	5049	2000	PARTIAL	2026-03-15 06:27:13.774	2026-03-16 03:48:31.558
cmmrdgxyj0007r5c3anonx7rw	cmmqfin37000hr5ri6v7crew3	2	2026	2000	326	0	2326	2000	PARTIAL	2026-03-15 06:27:13.771	2026-03-16 03:48:31.557
cmmrdgxzh000tr5c3tdwjmmfq	cmmqfin400020r5ri8p9t0kvk	2	2026	2000	1033	0	3033	4000	PAID	2026-03-15 06:27:13.806	2026-03-16 03:48:31.566
cmmrdgxyc0003r5c3z0y7a5cd	cmmqfin300007r5ri7hev5ck1	2	2026	2000	2016	2000	6016	2000	PARTIAL	2026-03-15 06:27:13.765	2026-03-16 03:48:31.555
cmmqica1a000lr5l8hfu45p3e	cmmqfin3q001gr5riuek21iw1	3	2026	2000	1422	0	3422	0	PENDING	2026-03-14 15:55:48.047	2026-03-16 05:46:02.018
cmmqica10000br5l8wi9ezeo9	cmmqfin3c000rr5riaz9ygvbu	3	2026	2000	825	0	2825	0	PENDING	2026-03-14 15:55:48.036	2026-03-16 05:46:02.019
cmmqica0x0009r5l8cm420uky	cmmqfin39000mr5rifitry7zu	3	2026	2000	1409	0	3409	0	PENDING	2026-03-14 15:55:48.034	2026-03-16 05:46:02.02
cmmrdgxyp000br5c3yrl8h0qp	cmmqfin3c000rr5riaz9ygvbu	2	2026	2000	614	0	2614	2000	PARTIAL	2026-03-15 06:27:13.777	2026-03-16 03:48:31.559
cmmqica1e000pr5l804mqa5ih	cmmqfin3v001qr5rik05d5yuh	3	2026	2000	1581	-29	3552	0	PENDING	2026-03-14 15:55:48.051	2026-03-16 05:46:02.021
cmmqica1j000tr5l8lhqr8uz3	cmmqfin400020r5ri8p9t0kvk	3	2026	2000	1770	3033	6803	0	PENDING	2026-03-14 15:55:48.055	2026-03-16 05:46:02.022
cmmqica0v0007r5l8jxn3q3yq	cmmqfin37000hr5ri6v7crew3	3	2026	2000	6	326	2332	0	PENDING	2026-03-14 15:55:48.031	2026-03-16 05:46:02.023
cmmrdgxyf0005r5c3gbuz6oag	cmmqfin34000cr5riujl5lkum	2	2026	2000	1015	0	3015	2000	PARTIAL	2026-03-15 06:27:13.768	2026-03-16 03:48:31.556
cmmqica19000jr5l88pvd21ec	cmmqfin3n001br5rinbkhyypl	3	2026	2000	1233	0	3233	0	PENDING	2026-03-14 15:55:48.045	2026-03-16 05:46:02.023
cmmrdgxzc000pr5c3u31ht8y2	cmmqfin3v001qr5rik05d5yuh	2	2026	2000	971	0	2971	2000	PARTIAL	2026-03-15 06:27:13.801	2026-03-16 03:48:31.565
cmmqica1c000nr5l8we9apak1	cmmqfin3s001lr5ri9eb3mld8	3	2026	2000	1460	0	3460	0	PENDING	2026-03-14 15:55:48.049	2026-03-16 05:46:02.024
cmmrdgxys000dr5c3ng9kx5ev	cmmqfin3f000wr5riqmcfcwsy	2	2026	2000	334	0	2334	2000	PARTIAL	2026-03-15 06:27:13.78	2026-03-16 03:48:31.559
cmmqica0s0005r5l81373z9zw	cmmqfin34000cr5riujl5lkum	3	2026	2000	2398	3015	7413	0	PENDING	2026-03-14 15:55:48.028	2026-03-16 05:46:02.024
cmmreqmh600mjr5luxuhoitfc	cmmqfin300007r5ri7hev5ck1	5	2021	3760	0	0	3760	5460	PAID	2026-03-15 07:02:45.067	2026-03-15 07:37:21.396
cmmreqmh800mnr5luetyz7fgb	cmmqfin37000hr5ri6v7crew3	5	2021	2076	0	0	2076	3776	PAID	2026-03-15 07:02:45.069	2026-03-15 07:37:21.397
cmmrdgxyu000fr5c3z3a1cl3e	cmmqfin3h0011r5ri60yvcljp	2	2026	2000	1554	0	3554	2000	PARTIAL	2026-03-15 06:27:13.783	2026-03-16 03:48:31.56
cmmreqmh900mpr5luxieirs7d	cmmqfin39000mr5rifitry7zu	5	2021	2262	0	0	2262	3962	PAID	2026-03-15 07:02:45.069	2026-03-15 07:37:21.397
cmmreqmh900mrr5luxyrijh32	cmmqfin3c000rr5riaz9ygvbu	5	2021	2569	0	0	2569	4269	PAID	2026-03-15 07:02:45.07	2026-03-15 07:37:21.397
cmmreqmha00mtr5lujfdxdoh8	cmmqfin3f000wr5riqmcfcwsy	5	2021	1988	0	0	1988	3688	PAID	2026-03-15 07:02:45.07	2026-03-15 07:37:21.397
cmmreqmha00mvr5luy38ch1po	cmmqfin3h0011r5ri60yvcljp	5	2021	2689	0	0	2689	4389	PAID	2026-03-15 07:02:45.071	2026-03-15 07:37:21.398
cmmreqmhb00mxr5lub0vp7l2y	cmmqfin3k0016r5ri43nzr1pi	5	2021	2653	0	0	2653	4353	PAID	2026-03-15 07:02:45.071	2026-03-15 07:37:21.398
cmmreqmhb00mzr5luhe3uclcr	cmmqfin3n001br5rinbkhyypl	5	2021	2654	0	0	2654	4354	PAID	2026-03-15 07:02:45.072	2026-03-15 07:37:21.398
cmmreqmhb00n1r5luitqiax0c	cmmqfin3s001lr5ri9eb3mld8	5	2021	1700	0	0	1700	3400	PAID	2026-03-15 07:02:45.072	2026-03-15 07:37:21.399
cmmreqmhd00n7r5luz4ang63p	cmmqfin400020r5ri8p9t0kvk	5	2021	5462	0	0	5462	7162	PAID	2026-03-15 07:02:45.073	2026-03-15 07:37:21.399
cmmreqmhc00n3r5lu8mcilngb	cmmqfin3v001qr5rik05d5yuh	5	2021	1700	0	0	1700	3400	PAID	2026-03-15 07:02:45.072	2026-03-15 07:37:21.399
cmmreqmhc00n5r5luik0e2u66	cmmqfin3x001vr5rixugbviaq	5	2021	2267	0	0	2267	3967	PAID	2026-03-15 07:02:45.073	2026-03-15 07:37:21.399
cmmreqmhd00n9r5luki37wig4	cmmqfin2s0002r5rig5gyl78u	5	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.074	2026-03-15 07:37:21.4
cmmreqmhd00nbr5ludo94eerw	cmmqfin300007r5ri7hev5ck1	5	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.074	2026-03-15 07:37:21.4
cmmreqmh800mlr5lud4i5dlnw	cmmqfin34000cr5riujl5lkum	5	2021	2240	0	0	2240	3940	PAID	2026-03-15 07:02:45.068	2026-03-15 07:37:21.4
cmmreqmhe00ndr5luirmlkqjo	cmmqfin34000cr5riujl5lkum	5	2023	1700	0	2846	4546	0	PENDING	2026-03-15 07:02:45.074	2026-03-15 07:37:21.401
cmmreqmhf00njr5luskel3ed9	cmmqfin3c000rr5riaz9ygvbu	5	2023	1700	0	1115	2815	1700	PARTIAL	2026-03-15 07:02:45.076	2026-03-15 07:37:21.401
cmmreqmhg00nlr5luldd5we7l	cmmqfin3f000wr5riqmcfcwsy	5	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.076	2026-03-15 07:37:21.402
cmmreqmhg00nnr5luykeraeaz	cmmqfin3h0011r5ri60yvcljp	5	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.076	2026-03-15 07:37:21.402
cmmreqmhg00npr5luohophshj	cmmqfin3k0016r5ri43nzr1pi	5	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.077	2026-03-15 07:37:21.402
cmmrdgxyx000hr5c3tfvpgj2y	cmmqfin3k0016r5ri43nzr1pi	2	2026	2000	1603	4000	7603	7603	PAID	2026-03-15 06:27:13.785	2026-03-16 05:42:54.913
cmmrdgxzf000rr5c3773x0pca	cmmqfin3x001vr5rixugbviaq	2	2026	2000	546	0	2546	2000	PARTIAL	2026-03-15 06:27:13.804	2026-03-16 03:48:31.566
cmmreqmhe00nfr5lupkc7jy9y	cmmqfin37000hr5ri6v7crew3	5	2023	1700	0	3608	5308	0	PENDING	2026-03-15 07:02:45.075	2026-03-15 07:37:21.404
cmmreqmhf00nhr5luakd36lic	cmmqfin39000mr5rifitry7zu	5	2023	1700	0	490	2190	3400	PAID	2026-03-15 07:02:45.075	2026-03-15 07:37:21.404
cmmqica0p0003r5l8ff5fd5g1	cmmqfin300007r5ri7hev5ck1	3	2026	2000	2944	16	4960	0	PENDING	2026-03-14 15:55:48.025	2026-03-19 09:21:41.954
cmmreqmhk00o3r5lu50rlkofr	cmmqfin2s0002r5rig5gyl78u	11	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.08	2026-03-15 07:37:21.405
cmmreqmhk00o5r5luf7jsa5bz	cmmqfin300007r5ri7hev5ck1	11	2023	1700	0	1700	3400	0	PENDING	2026-03-15 07:02:45.081	2026-03-15 07:37:21.405
cmmreqmho00ofr5lujy1vkmgx	cmmqfin3f000wr5riqmcfcwsy	11	2023	1700	0	1700	3400	0	PENDING	2026-03-15 07:02:45.084	2026-03-15 07:37:21.406
cmmreqmhp00ojr5luiplne72s	cmmqfin3k0016r5ri43nzr1pi	11	2023	1700	0	3400	5100	0	PENDING	2026-03-15 07:02:45.085	2026-03-15 07:37:21.406
cmmreqmhq00orr5luoybibfes	cmmqfin3v001qr5rik05d5yuh	11	2023	1700	0	1700	3400	0	PENDING	2026-03-15 07:02:45.087	2026-03-15 07:37:21.407
cmmreqmhr00ovr5luse60umlz	cmmqfin400020r5ri8p9t0kvk	11	2023	1700	0	1700	3400	0	PENDING	2026-03-15 07:02:45.087	2026-03-15 07:37:21.407
cmmreqmhs00ozr5luk25aquva	cmmqfin300007r5ri7hev5ck1	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.088	2026-03-15 07:37:21.407
cmmreqmhs00p1r5lu4s312bdc	cmmqfin34000cr5riujl5lkum	7	2023	1700	0	0	1700	5100	PAID	2026-03-15 07:02:45.089	2026-03-15 07:37:21.408
cmmreqmht00p3r5lur3crsvn4	cmmqfin37000hr5ri6v7crew3	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.089	2026-03-15 07:37:21.408
cmmreqmht00p5r5lu6edroll1	cmmqfin39000mr5rifitry7zu	7	2023	1700	0	38	1738	1700	PARTIAL	2026-03-15 07:02:45.09	2026-03-15 07:37:21.409
cmmreqmht00p7r5luxhsuisc0	cmmqfin3c000rr5riaz9ygvbu	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.09	2026-03-15 07:37:21.41
cmmreqmhu00p9r5luhpo49rv5	cmmqfin3f000wr5riqmcfcwsy	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.09	2026-03-15 07:37:21.41
cmmreqmhv00pdr5lu0jr7umsr	cmmqfin3k0016r5ri43nzr1pi	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.091	2026-03-15 07:37:21.41
cmmreqmhv00pfr5lujdagpf8m	cmmqfin3n001br5rinbkhyypl	7	2023	1700	0	-3	1697	3400	PAID	2026-03-15 07:02:45.091	2026-03-15 07:37:21.411
cmmreqmhv00phr5lunst4f1zj	cmmqfin3q001gr5riuek21iw1	7	2023	1700	0	0	1700	0	PENDING	2026-03-15 07:02:45.092	2026-03-15 07:37:21.411
cmmreqmhw00plr5luahxqd60a	cmmqfin3v001qr5rik05d5yuh	7	2023	1700	0	-664	1036	1700	PAID	2026-03-15 07:02:45.092	2026-03-15 07:37:21.412
cmmreqmhw00pnr5luk1lzpmq6	cmmqfin3x001vr5rixugbviaq	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.093	2026-03-15 07:37:21.412
cmmreqmhx00ppr5lu01um1j0a	cmmqfin400020r5ri8p9t0kvk	7	2023	1700	0	0	1700	0	PENDING	2026-03-15 07:02:45.093	2026-03-15 07:37:21.412
cmmreqmhx00ptr5luswcz1rj6	cmmqfin300007r5ri7hev5ck1	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.094	2026-03-15 07:37:21.413
cmmreqmhy00pvr5lux241htby	cmmqfin34000cr5riujl5lkum	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.094	2026-03-15 07:37:21.413
cmmreqmhy00pxr5lu2j6yhrrn	cmmqfin37000hr5ri6v7crew3	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.095	2026-03-15 07:37:21.414
cmmreqmhz00pzr5lujsilxmw0	cmmqfin39000mr5rifitry7zu	8	2023	1700	0	1738	3438	0	PENDING	2026-03-15 07:02:45.095	2026-03-15 07:37:21.414
cmmreqmhz00q3r5lu9a8mv0jm	cmmqfin3f000wr5riqmcfcwsy	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.096	2026-03-15 07:37:21.414
cmmreqmi000q5r5luwc5uux33	cmmqfin3h0011r5ri60yvcljp	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.096	2026-03-15 07:37:21.415
cmmreqmi000q7r5luftiznndu	cmmqfin3k0016r5ri43nzr1pi	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.097	2026-03-15 07:37:21.415
cmmreqmi100q9r5luj06k87i1	cmmqfin3n001br5rinbkhyypl	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.097	2026-03-15 07:37:21.416
cmmreqmi100qbr5luini3xamy	cmmqfin3q001gr5riuek21iw1	8	2023	1700	0	0	1700	0	PENDING	2026-03-15 07:02:45.097	2026-03-15 07:37:21.416
cmmreqmi200qhr5lug64hcq17	cmmqfin3x001vr5rixugbviaq	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.099	2026-03-15 07:37:21.417
cmmreqmi200qjr5luz1centsw	cmmqfin400020r5ri8p9t0kvk	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.099	2026-03-15 07:37:21.417
cmmreqmi300qlr5lump6j03qs	cmmqfin2s0002r5rig5gyl78u	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.099	2026-03-15 07:37:21.417
cmmreqmhi00ntr5lu1ukjebab	cmmqfin3q001gr5riuek21iw1	5	2023	1700	0	0	1700	0	PENDING	2026-03-15 07:02:45.078	2026-03-15 07:37:21.418
cmmreqmhj00o1r5lu91sudxg4	cmmqfin400020r5ri8p9t0kvk	5	2023	1700	0	61	1761	1700	PARTIAL	2026-03-15 07:02:45.08	2026-03-15 07:37:21.405
cmmreqmhi00nvr5lu2x8c6w8a	cmmqfin3s001lr5ri9eb3mld8	5	2023	1700	0	2769	4469	0	PENDING	2026-03-15 07:02:45.079	2026-03-15 07:37:21.418
cmmreqmhj00nxr5lu73lkak9o	cmmqfin3v001qr5rik05d5yuh	5	2023	1700	0	3389	5089	0	PENDING	2026-03-15 07:02:45.079	2026-03-15 07:37:21.419
cmmreqmhj00nzr5lu0h2v55pa	cmmqfin3x001vr5rixugbviaq	5	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.079	2026-03-15 07:37:21.419
cmmreqmhm00o7r5luhedzm7se	cmmqfin34000cr5riujl5lkum	11	2023	1700	0	3400	5100	0	PENDING	2026-03-15 07:02:45.083	2026-03-15 07:37:21.419
cmmreqmhn00o9r5lubhpukd1y	cmmqfin37000hr5ri6v7crew3	11	2023	1700	0	1700	3400	0	PENDING	2026-03-15 07:02:45.083	2026-03-15 07:37:21.42
cmmreqmhn00obr5lufo38b11w	cmmqfin39000mr5rifitry7zu	11	2023	1700	0	1700	3400	0	PENDING	2026-03-15 07:02:45.083	2026-03-15 07:37:21.42
cmmreqmhn00odr5luk90urdnh	cmmqfin3c000rr5riaz9ygvbu	11	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.084	2026-03-15 07:37:21.421
cmmreqmho00ohr5lundhuf6op	cmmqfin3h0011r5ri60yvcljp	11	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.085	2026-03-15 07:37:21.421
cmmreqmhp00olr5lunl1js04y	cmmqfin3n001br5rinbkhyypl	11	2023	1700	0	1700	3400	0	PENDING	2026-03-15 07:02:45.086	2026-03-15 07:37:21.421
cmmreqmhq00onr5lux1chmuos	cmmqfin3q001gr5riuek21iw1	11	2023	1700	0	0	1700	0	PENDING	2026-03-15 07:02:45.086	2026-03-15 07:37:21.422
cmmreqmhq00opr5luq1hgcfeb	cmmqfin3s001lr5ri9eb3mld8	11	2023	1700	0	1700	3400	2500	PARTIAL	2026-03-15 07:02:45.086	2026-03-15 07:37:21.422
cmmreqmhr00otr5luk1wp9xb0	cmmqfin3x001vr5rixugbviaq	11	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.087	2026-03-15 07:37:21.422
cmmreqmhr00oxr5luo7jyx5tt	cmmqfin2s0002r5rig5gyl78u	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.088	2026-03-15 07:37:21.423
cmmreqmhw00pjr5lu1xs3m71a	cmmqfin3s001lr5ri9eb3mld8	7	2023	1700	0	-100	1600	1700	PAID	2026-03-15 07:02:45.092	2026-03-15 07:37:21.423
cmmreqmhx00prr5luxdluwa9j	cmmqfin2s0002r5rig5gyl78u	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.094	2026-03-15 07:37:21.424
cmmreqmhz00q1r5lu35obrfdw	cmmqfin3c000rr5riaz9ygvbu	8	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.096	2026-03-15 07:37:21.424
cmmreqmi100qdr5lulacdwywc	cmmqfin3s001lr5ri9eb3mld8	8	2023	1700	0	-900	800	0	PENDING	2026-03-15 07:02:45.098	2026-03-15 07:37:21.424
cmmreqmi200qfr5lu3ihpqigc	cmmqfin3v001qr5rik05d5yuh	8	2023	1700	0	0	1700	1036	PARTIAL	2026-03-15 07:02:45.098	2026-03-15 07:37:21.425
cmmreqmi400qtr5luiz5a0zpu	cmmqfin39000mr5rifitry7zu	9	2023	1700	0	3438	5138	0	PENDING	2026-03-15 07:02:45.101	2026-03-15 07:37:21.425
cmmreqmi500qxr5lum7l47gum	cmmqfin3f000wr5riqmcfcwsy	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.102	2026-03-15 07:37:21.426
cmmreqmi600qzr5lu427ak2ml	cmmqfin3h0011r5ri60yvcljp	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.102	2026-03-15 07:37:21.426
cmmreqmi600r1r5luhock8ucg	cmmqfin3k0016r5ri43nzr1pi	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.102	2026-03-15 07:37:21.426
cmmreqmi600r3r5lutb6bwjnd	cmmqfin3n001br5rinbkhyypl	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.103	2026-03-15 07:37:21.427
cmmreqmi700r5r5lu0yt3vxoj	cmmqfin3q001gr5riuek21iw1	9	2023	1700	0	0	1700	0	PENDING	2026-03-15 07:02:45.103	2026-03-15 07:37:21.427
cmmreqmi700r9r5lu7xrxq97h	cmmqfin3v001qr5rik05d5yuh	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.104	2026-03-15 07:37:21.428
cmmreqmi800rbr5lu1hv20did	cmmqfin3x001vr5rixugbviaq	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.104	2026-03-15 07:37:21.428
cmmreqmi800rdr5lub44j7vuv	cmmqfin400020r5ri8p9t0kvk	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.105	2026-03-15 07:37:21.428
cmmreqmi900rfr5lugx8su8ch	cmmqfin2s0002r5rig5gyl78u	12	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.105	2026-03-15 07:37:21.429
cmmreqmi900rhr5lubjyaik8c	cmmqfin300007r5ri7hev5ck1	12	2023	1700	0	0	1700	3400	PAID	2026-03-15 07:02:45.106	2026-03-15 07:37:21.429
cmmreqmia00rjr5lub3ss93eh	cmmqfin34000cr5riujl5lkum	12	2023	1700	0	5100	6800	0	PENDING	2026-03-15 07:02:45.106	2026-03-15 07:37:21.429
cmmreqmic00rtr5luhj7qbkmf	cmmqfin3h0011r5ri60yvcljp	12	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.108	2026-03-15 07:37:21.43
cmmreqmic00rvr5lumbx5atpy	cmmqfin3k0016r5ri43nzr1pi	12	2023	1700	0	0	1700	5100	PAID	2026-03-15 07:02:45.108	2026-03-15 07:37:21.43
cmmreqmic00rxr5luor2njy77	cmmqfin3n001br5rinbkhyypl	12	2023	1700	0	0	1700	3400	PAID	2026-03-15 07:02:45.109	2026-03-15 07:37:21.431
cmmreqmic00rzr5luogq9ruvd	cmmqfin3q001gr5riuek21iw1	12	2023	1700	0	0	1700	0	PENDING	2026-03-15 07:02:45.109	2026-03-15 07:37:21.431
cmmreqmie00s7r5lu9s87pfy5	cmmqfin400020r5ri8p9t0kvk	12	2023	1700	0	0	1700	3400	PAID	2026-03-15 07:02:45.11	2026-03-15 07:37:21.431
cmmreqmie00s9r5lu5q1w1l4d	cmmqfin2s0002r5rig5gyl78u	1	2024	1700	540	0	2240	1700	PARTIAL	2026-03-15 07:02:45.111	2026-03-15 07:37:21.432
cmmreqmie00sbr5luf6f0wwxx	cmmqfin300007r5ri7hev5ck1	1	2024	1700	1036	0	2736	1700	PARTIAL	2026-03-15 07:02:45.111	2026-03-15 07:37:21.432
cmmreqmif00sdr5luxdaif8w8	cmmqfin34000cr5riujl5lkum	1	2024	1700	927	0	2627	6800	PAID	2026-03-15 07:02:45.111	2026-03-15 07:37:21.433
cmmreqmif00sfr5ludlcpjodi	cmmqfin37000hr5ri6v7crew3	1	2024	1700	5	0	1705	5100	PAID	2026-03-15 07:02:45.112	2026-03-15 07:37:21.433
cmmreqmif00shr5luwh8d1au9	cmmqfin39000mr5rifitry7zu	1	2024	1700	517	0	2217	5100	PAID	2026-03-15 07:02:45.112	2026-03-15 07:37:21.433
cmmreqmig00sjr5luiiwuzfnn	cmmqfin3c000rr5riaz9ygvbu	1	2024	1700	601	0	2301	1700	PARTIAL	2026-03-15 07:02:45.112	2026-03-15 07:37:21.434
cmmreqmig00slr5lud1pq50qq	cmmqfin3f000wr5riqmcfcwsy	1	2024	1700	555	0	2255	1700	PARTIAL	2026-03-15 07:02:45.113	2026-03-15 07:37:21.434
cmmreqmih00snr5lucubqbki7	cmmqfin3h0011r5ri60yvcljp	1	2024	1700	676	0	2376	1700	PARTIAL	2026-03-15 07:02:45.113	2026-03-15 07:37:21.435
cmmreqmih00spr5lu73htpsoo	cmmqfin3k0016r5ri43nzr1pi	1	2024	1700	774	0	2474	1700	PARTIAL	2026-03-15 07:02:45.113	2026-03-15 07:37:21.435
cmmreqmih00srr5lu8hfmm9wz	cmmqfin3n001br5rinbkhyypl	1	2024	1700	605	1700	4005	0	PENDING	2026-03-15 07:02:45.114	2026-03-15 07:37:21.435
cmmreqmij00sxr5lu7c8yggyb	cmmqfin3v001qr5rik05d5yuh	1	2024	1700	486	0	2186	5100	PAID	2026-03-15 07:02:45.115	2026-03-15 07:37:21.436
cmmreqmik00szr5lubtbb687x	cmmqfin3x001vr5rixugbviaq	1	2024	1700	245	0	1945	1700	PARTIAL	2026-03-15 07:02:45.116	2026-03-15 07:37:21.436
cmmreqmik00t1r5lu5jlj5jb3	cmmqfin400020r5ri8p9t0kvk	1	2024	1700	666	0	2366	1700	PARTIAL	2026-03-15 07:02:45.117	2026-03-15 07:37:21.436
cmmreqmil00t3r5lu1t1c5zkh	cmmqfin2s0002r5rig5gyl78u	2	2024	2000	2220	0	4220	1700	PARTIAL	2026-03-15 07:02:45.117	2026-03-15 07:37:21.437
cmmreqmil00t5r5lukmzeo30i	cmmqfin300007r5ri7hev5ck1	2	2024	2000	3695	0	5695	1700	PARTIAL	2026-03-15 07:02:45.118	2026-03-15 07:37:21.437
cmmreqmim00t7r5lu01naro83	cmmqfin34000cr5riujl5lkum	2	2024	2000	3100	0	5100	1700	PARTIAL	2026-03-15 07:02:45.118	2026-03-15 07:37:21.438
cmmreqmim00t9r5lux5nwh66s	cmmqfin37000hr5ri6v7crew3	2	2024	2000	1085	1705	4790	0	PENDING	2026-03-15 07:02:45.118	2026-03-15 07:37:21.438
cmmreqmin00tdr5lu0yxxrh67	cmmqfin3c000rr5riaz9ygvbu	2	2024	2000	1648	0	3648	1700	PARTIAL	2026-03-15 07:02:45.119	2026-03-15 07:37:21.438
cmmreqmin00tfr5lu4jjyfn6g	cmmqfin3f000wr5riqmcfcwsy	2	2024	2000	1846	0	3846	1700	PARTIAL	2026-03-15 07:02:45.12	2026-03-15 07:37:21.439
cmmreqmin00thr5ludfzclitd	cmmqfin3h0011r5ri60yvcljp	2	2024	2000	2410	0	4410	1700	PARTIAL	2026-03-15 07:02:45.12	2026-03-15 07:37:21.439
cmmreqmi400qpr5luucxbrrv6	cmmqfin34000cr5riujl5lkum	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.1	2026-03-15 07:37:21.44
cmmreqmi400qrr5lu30qgx26y	cmmqfin37000hr5ri6v7crew3	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.1	2026-03-15 07:37:21.425
cmmreqmi500qvr5lufiom3s58	cmmqfin3c000rr5riaz9ygvbu	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.101	2026-03-15 07:37:21.44
cmmreqmi700r7r5luwctz9hpi	cmmqfin3s001lr5ri9eb3mld8	9	2023	1700	0	800	2500	2500	PAID	2026-03-15 07:02:45.104	2026-03-15 07:37:21.441
cmmreqmia00rlr5lugiz0ezzq	cmmqfin37000hr5ri6v7crew3	12	2023	1700	0	3400	5100	0	PENDING	2026-03-15 07:02:45.106	2026-03-15 07:37:21.442
cmmreqmia00rnr5luq5hux3q4	cmmqfin39000mr5rifitry7zu	12	2023	1700	0	3400	5100	0	PENDING	2026-03-15 07:02:45.107	2026-03-15 07:37:21.442
cmmreqmib00rpr5luml4fnenz	cmmqfin3c000rr5riaz9ygvbu	12	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.107	2026-03-15 07:37:21.443
cmmreqmid00s1r5lu4jmkq04d	cmmqfin3s001lr5ri9eb3mld8	12	2023	1700	0	3400	5100	0	PENDING	2026-03-15 07:02:45.109	2026-03-15 07:37:21.443
cmmreqmid00s3r5lu657nezrd	cmmqfin3v001qr5rik05d5yuh	12	2023	1700	0	3400	5100	0	PENDING	2026-03-15 07:02:45.11	2026-03-15 07:37:21.443
cmmreqmid00s5r5luro39hwdx	cmmqfin3x001vr5rixugbviaq	12	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.11	2026-03-15 07:37:21.444
cmmreqmii00str5lui88fous7	cmmqfin3q001gr5riuek21iw1	1	2024	1700	532	0	2232	0	PENDING	2026-03-15 07:02:45.114	2026-03-15 07:37:21.444
cmmreqmii00svr5luc7bodzvi	cmmqfin3s001lr5ri9eb3mld8	1	2024	1700	422	-1700	422	6800	PAID	2026-03-15 07:02:45.115	2026-03-15 07:37:21.444
cmmreqmim00tbr5lupx3f2t3x	cmmqfin39000mr5rifitry7zu	2	2024	2000	727	0	2727	1700	PARTIAL	2026-03-15 07:02:45.119	2026-03-15 07:37:21.445
cmmreqmip00tpr5lu7o5991wp	cmmqfin3s001lr5ri9eb3mld8	2	2024	2000	2131	422	4553	0	PENDING	2026-03-15 07:02:45.122	2026-03-15 07:37:21.446
cmmreqmiq00tvr5lu9yn1z9eh	cmmqfin400020r5ri8p9t0kvk	2	2024	2000	1892	0	3892	1700	PARTIAL	2026-03-15 07:02:45.123	2026-03-15 07:37:21.446
cmmreqmir00txr5lujrsmoeps	cmmqfin2s0002r5rig5gyl78u	3	2024	2000	1584	0	3584	2000	PARTIAL	2026-03-15 07:02:45.123	2026-03-15 07:37:21.446
cmmreqmir00tzr5lujr6z46na	cmmqfin300007r5ri7hev5ck1	3	2024	2000	4377	5695	12072	0	PENDING	2026-03-15 07:02:45.124	2026-03-15 07:37:21.447
cmmreqmis00u5r5luh3jbsdu6	cmmqfin39000mr5rifitry7zu	3	2024	2000	1060	0	3060	2000	PARTIAL	2026-03-15 07:02:45.125	2026-03-15 07:37:21.447
cmmreqmit00u7r5lu2h0hzmc5	cmmqfin3c000rr5riaz9ygvbu	3	2024	2000	1896	0	3896	2000	PARTIAL	2026-03-15 07:02:45.125	2026-03-15 07:37:21.447
cmmreqmit00u9r5luxofklsem	cmmqfin3f000wr5riqmcfcwsy	3	2024	2000	1333	0	3333	2000	PARTIAL	2026-03-15 07:02:45.126	2026-03-15 07:37:21.447
cmmreqmiu00ubr5luhnawrv4n	cmmqfin3h0011r5ri60yvcljp	3	2024	2000	3702	-1597	4105	2000	PARTIAL	2026-03-15 07:02:45.126	2026-03-15 07:37:21.448
cmmreqmiu00udr5lusta7dcfr	cmmqfin3k0016r5ri43nzr1pi	3	2024	2000	2628	0	4628	2000	PARTIAL	2026-03-15 07:02:45.126	2026-03-15 07:37:21.448
cmmreqmiu00ufr5luohnzj2uk	cmmqfin3n001br5rinbkhyypl	3	2024	2000	1871	0	3871	2000	PARTIAL	2026-03-15 07:02:45.127	2026-03-15 07:37:21.449
cmmreqmiv00uhr5lutkf0hn8u	cmmqfin3q001gr5riuek21iw1	3	2024	2000	1011	0	3011	2000	PARTIAL	2026-03-15 07:02:45.127	2026-03-15 07:37:21.449
cmmreqmiv00ujr5lun8kfh0de	cmmqfin3s001lr5ri9eb3mld8	3	2024	2000	1789	4553	8342	0	PENDING	2026-03-15 07:02:45.127	2026-03-15 07:37:21.449
cmmreqmiw00upr5lu4clcz5wf	cmmqfin400020r5ri8p9t0kvk	3	2024	2000	2104	90	4194	2000	PARTIAL	2026-03-15 07:02:45.129	2026-03-15 07:37:21.45
cmmreqmiw00urr5lucvtaou7c	cmmqfin2s0002r5rig5gyl78u	4	2024	2000	2079	0	4079	2000	PARTIAL	2026-03-15 07:02:45.129	2026-03-15 07:37:21.45
cmmreqmix00utr5lue8tcnjek	cmmqfin300007r5ri7hev5ck1	4	2024	2000	4073	0	6073	4000	PARTIAL	2026-03-15 07:02:45.129	2026-03-15 07:37:21.451
cmmreqmix00uvr5luu9iyji5e	cmmqfin34000cr5riujl5lkum	4	2024	2000	951	0	2951	4000	PAID	2026-03-15 07:02:45.13	2026-03-15 07:37:21.451
cmmreqmiy00uxr5lu7mmrkokv	cmmqfin37000hr5ri6v7crew3	4	2024	2000	1381	0	3381	2000	PARTIAL	2026-03-15 07:02:45.13	2026-03-15 07:37:21.452
cmmreqmiy00uzr5lu476f1ws3	cmmqfin39000mr5rifitry7zu	4	2024	2000	960	0	2960	2000	PARTIAL	2026-03-15 07:02:45.131	2026-03-15 07:37:21.452
cmmreqmiy00v1r5lu0izlv13f	cmmqfin3c000rr5riaz9ygvbu	4	2024	2000	2032	0	4032	2000	PARTIAL	2026-03-15 07:02:45.131	2026-03-15 07:37:21.452
cmmreqmiz00v3r5lu42b9n6eg	cmmqfin3f000wr5riqmcfcwsy	4	2024	2000	1102	0	3102	2000	PARTIAL	2026-03-15 07:02:45.131	2026-03-15 07:37:21.453
cmmreqmiz00v5r5lu4aicy5t1	cmmqfin3h0011r5ri60yvcljp	4	2024	2000	2990	0	4990	2000	PARTIAL	2026-03-15 07:02:45.132	2026-03-15 07:37:21.453
cmmreqmj000v7r5luw7pu4x4h	cmmqfin3k0016r5ri43nzr1pi	4	2024	2000	2674	0	4674	2000	PARTIAL	2026-03-15 07:02:45.132	2026-03-15 07:37:21.453
cmmreqmj000v9r5lupl40w2i5	cmmqfin3n001br5rinbkhyypl	4	2024	2000	2343	0	4343	2000	PARTIAL	2026-03-15 07:02:45.133	2026-03-15 07:37:21.454
cmmreqmj100vbr5luc8nkxijg	cmmqfin3q001gr5riuek21iw1	4	2024	2000	1128	0	3128	2000	PARTIAL	2026-03-15 07:02:45.133	2026-03-15 07:37:21.454
cmmreqmj100vdr5lu4l7j2a05	cmmqfin3s001lr5ri9eb3mld8	4	2024	2000	913	0	2913	4000	PAID	2026-03-15 07:02:45.134	2026-03-15 07:37:21.455
cmmreqmj100vfr5luubgpkt5e	cmmqfin3v001qr5rik05d5yuh	4	2024	2000	2073	0	4073	2000	PARTIAL	2026-03-15 07:02:45.134	2026-03-15 07:37:21.455
cmmreqmj200vhr5lu1z0n0150	cmmqfin3x001vr5rixugbviaq	4	2024	2000	439	0	2439	2000	PARTIAL	2026-03-15 07:02:45.134	2026-03-15 07:37:21.455
cmmreqmj200vjr5lunou0sxlo	cmmqfin400020r5ri8p9t0kvk	4	2024	2000	2352	0	4352	2000	PARTIAL	2026-03-15 07:02:45.135	2026-03-15 07:37:21.456
cmmreqmj300vlr5luwlh4vyad	cmmqfin2s0002r5rig5gyl78u	5	2024	2000	1321	0	3321	2000	PARTIAL	2026-03-15 07:02:45.135	2026-03-15 07:37:21.456
cmmreqmj300vnr5lufx0kavdu	cmmqfin300007r5ri7hev5ck1	5	2024	2000	2955	0	4955	2000	PARTIAL	2026-03-15 07:02:45.135	2026-03-15 07:37:21.456
cmmreqmj300vpr5luj1tc0gvr	cmmqfin34000cr5riujl5lkum	5	2024	2000	1593	0	3593	2000	PARTIAL	2026-03-15 07:02:45.136	2026-03-15 07:37:21.457
cmmreqmj400vrr5lu64g2vhb4	cmmqfin37000hr5ri6v7crew3	5	2024	2000	1057	0	3057	2000	PARTIAL	2026-03-15 07:02:45.136	2026-03-15 07:37:21.457
cmmreqmj400vtr5lueqfgk1hk	cmmqfin39000mr5rifitry7zu	5	2024	2000	1342	0	3342	2000	PARTIAL	2026-03-15 07:02:45.137	2026-03-15 07:37:21.458
cmmreqmj500vvr5lu2nn3dwxz	cmmqfin3c000rr5riaz9ygvbu	5	2024	2000	1410	0	3410	2000	PARTIAL	2026-03-15 07:02:45.137	2026-03-15 07:37:21.458
cmmreqmj500vxr5lugsp1rx6v	cmmqfin3f000wr5riqmcfcwsy	5	2024	2000	1144	3102	6246	0	PENDING	2026-03-15 07:02:45.137	2026-03-15 07:37:21.458
cmmreqmj600w1r5lukvxn6g1t	cmmqfin3k0016r5ri43nzr1pi	5	2024	2000	2369	0	4369	2000	PARTIAL	2026-03-15 07:02:45.138	2026-03-15 07:37:21.459
cmmreqmj600w3r5luctdwxl0c	cmmqfin3n001br5rinbkhyypl	5	2024	2000	2084	0	4084	2000	PARTIAL	2026-03-15 07:02:45.138	2026-03-15 07:37:21.459
cmmreqmj600w5r5lu8hbwie64	cmmqfin3q001gr5riuek21iw1	5	2024	2000	1713	0	3713	2000	PARTIAL	2026-03-15 07:02:45.139	2026-03-15 07:37:21.46
cmmreqmj700w7r5lued9j36su	cmmqfin3s001lr5ri9eb3mld8	5	2024	2000	1758	0	3758	2000	PARTIAL	2026-03-15 07:02:45.139	2026-03-15 07:37:21.46
cmmreqmj800w9r5luzjktgn7i	cmmqfin3v001qr5rik05d5yuh	5	2024	2000	1504	73	3577	2000	PARTIAL	2026-03-15 07:02:45.141	2026-03-15 07:37:21.461
cmmreqmj900wbr5lufueq8nv2	cmmqfin3x001vr5rixugbviaq	5	2024	2000	215	0	2215	2000	PARTIAL	2026-03-15 07:02:45.141	2026-03-15 07:37:21.461
cmmreqmj900wdr5lu1rgkpf0y	cmmqfin400020r5ri8p9t0kvk	5	2024	2000	1024	0	3024	2000	PARTIAL	2026-03-15 07:02:45.141	2026-03-15 07:37:21.461
cmmreqmip00tlr5lu8100zyhn	cmmqfin3n001br5rinbkhyypl	2	2024	2000	1346	0	3346	3400	PAID	2026-03-15 07:02:45.121	2026-03-15 07:37:21.462
cmmreqmip00tnr5lut66e3yna	cmmqfin3q001gr5riuek21iw1	2	2024	2000	788	0	2788	1700	PARTIAL	2026-03-15 07:02:45.122	2026-03-15 07:37:21.445
cmmreqmiq00trr5lu62nkj397	cmmqfin3v001qr5rik05d5yuh	2	2024	2000	1856	2186	6042	0	PENDING	2026-03-15 07:02:45.122	2026-03-15 07:37:21.462
cmmreqmiq00ttr5luiadzr5wv	cmmqfin3x001vr5rixugbviaq	2	2024	2000	806	0	2806	1700	PARTIAL	2026-03-15 07:02:45.123	2026-03-15 07:37:21.463
cmmreqmis00u1r5lucwwklj4l	cmmqfin34000cr5riujl5lkum	3	2024	2000	1994	5100	9094	0	PENDING	2026-03-15 07:02:45.124	2026-03-15 07:37:21.463
cmmreqmis00u3r5luzamlg72n	cmmqfin37000hr5ri6v7crew3	3	2024	2000	1261	1390	4651	3400	PARTIAL	2026-03-15 07:02:45.124	2026-03-15 07:37:21.463
cmmreqmiv00ulr5lunwf4hzz6	cmmqfin3v001qr5rik05d5yuh	3	2024	2000	2827	0	4827	4186	PARTIAL	2026-03-15 07:02:45.128	2026-03-15 07:37:21.464
cmmreqmj500vzr5lu3ixnpbtl	cmmqfin3h0011r5ri60yvcljp	5	2024	2000	2373	398	4771	2000	PARTIAL	2026-03-15 07:02:45.138	2026-03-15 07:37:21.464
cmmreqmjb00wnr5lu0h45y4mk	cmmqfin39000mr5rifitry7zu	6	2024	2000	1095	0	3095	2000	PARTIAL	2026-03-15 07:02:45.143	2026-03-15 07:37:21.465
cmmreqmjb00wpr5luf3owbory	cmmqfin3c000rr5riaz9ygvbu	6	2024	2000	1093	0	3093	2000	PARTIAL	2026-03-15 07:02:45.144	2026-03-15 07:37:21.465
cmmreqmjb00wrr5lucbp6gpsz	cmmqfin3f000wr5riqmcfcwsy	6	2024	2000	1005	0	3005	4000	PAID	2026-03-15 07:02:45.144	2026-03-15 07:37:21.466
cmmreqmjc00wtr5luvxf2rr5d	cmmqfin3h0011r5ri60yvcljp	6	2024	2000	1612	0	3612	2000	PARTIAL	2026-03-15 07:02:45.144	2026-03-15 07:37:21.466
cmmreqmjc00wvr5luhn6dvayv	cmmqfin3k0016r5ri43nzr1pi	6	2024	2000	1778	0	3778	2000	PARTIAL	2026-03-15 07:02:45.145	2026-03-15 07:37:21.467
cmmreqmjc00wxr5lupyn0i7e8	cmmqfin3n001br5rinbkhyypl	6	2024	2000	1364	0	3364	2000	PARTIAL	2026-03-15 07:02:45.145	2026-03-15 07:37:21.467
cmmreqmjd00wzr5luef1ril66	cmmqfin3q001gr5riuek21iw1	6	2024	2000	1487	0	3487	2000	PARTIAL	2026-03-15 07:02:45.145	2026-03-15 07:37:21.467
cmmreqmjd00x1r5luvv8k81gz	cmmqfin3s001lr5ri9eb3mld8	6	2024	2000	880	0	2880	2000	PARTIAL	2026-03-15 07:02:45.146	2026-03-15 07:37:21.468
cmmreqmje00x3r5lusbj5u6rm	cmmqfin3v001qr5rik05d5yuh	6	2024	2000	1543	0	3543	2000	PARTIAL	2026-03-15 07:02:45.146	2026-03-15 07:37:21.468
cmmreqmje00x5r5lutwifhmno	cmmqfin3x001vr5rixugbviaq	6	2024	2000	588	0	2588	2000	PARTIAL	2026-03-15 07:02:45.146	2026-03-15 07:37:21.468
cmmreqmje00x7r5luwd4hkulb	cmmqfin400020r5ri8p9t0kvk	6	2024	2000	1153	0	3153	2000	PARTIAL	2026-03-15 07:02:45.147	2026-03-15 07:37:21.469
cmmreqmjf00x9r5lufaob8e77	cmmqfin2s0002r5rig5gyl78u	7	2024	2000	521	0	2521	2000	PARTIAL	2026-03-15 07:02:45.147	2026-03-15 07:37:21.469
cmmreqmjf00xdr5lu7uhonaj2	cmmqfin34000cr5riujl5lkum	7	2024	2000	456	0	2456	4000	PAID	2026-03-15 07:02:45.148	2026-03-15 07:37:21.469
cmmreqmjg00xfr5luj2fp9rbq	cmmqfin37000hr5ri6v7crew3	7	2024	2000	436	0	2436	2000	PARTIAL	2026-03-15 07:02:45.148	2026-03-15 07:37:21.47
cmmreqmjg00xhr5lupbdgbt8r	cmmqfin39000mr5rifitry7zu	7	2024	2000	369	0	2369	2000	PARTIAL	2026-03-15 07:02:45.148	2026-03-15 07:37:21.47
cmmreqmjg00xjr5lu1owx436e	cmmqfin3c000rr5riaz9ygvbu	7	2024	2000	473	0	2473	2000	PARTIAL	2026-03-15 07:02:45.149	2026-03-15 07:37:21.471
cmmreqmjh00xlr5luyaz750pg	cmmqfin3f000wr5riqmcfcwsy	7	2024	2000	341	0	2341	2000	PARTIAL	2026-03-15 07:02:45.149	2026-03-15 07:37:21.471
cmmreqmjh00xnr5lumtk5n9mz	cmmqfin3h0011r5ri60yvcljp	7	2024	2000	737	0	2737	2000	PARTIAL	2026-03-15 07:02:45.15	2026-03-15 07:37:21.472
cmmreqmji00xpr5lucqo9vrzs	cmmqfin3k0016r5ri43nzr1pi	7	2024	2000	782	0	2782	2000	PARTIAL	2026-03-15 07:02:45.15	2026-03-15 07:37:21.472
cmmreqmji00xrr5lu6107mu1t	cmmqfin3n001br5rinbkhyypl	7	2024	2000	684	0	2684	2000	PARTIAL	2026-03-15 07:02:45.15	2026-03-15 07:37:21.472
cmmreqmji00xtr5lu9kpe9jf9	cmmqfin3q001gr5riuek21iw1	7	2024	2000	618	0	2618	2000	PARTIAL	2026-03-15 07:02:45.151	2026-03-15 07:37:21.473
cmmreqmjj00xvr5luc20wdcb8	cmmqfin3s001lr5ri9eb3mld8	7	2024	2000	388	0	2388	2000	PARTIAL	2026-03-15 07:02:45.151	2026-03-15 07:37:21.473
cmmreqmjj00xxr5lure173jan	cmmqfin3v001qr5rik05d5yuh	7	2024	2000	644	0	2644	2000	PARTIAL	2026-03-15 07:02:45.152	2026-03-15 07:37:21.473
cmmreqmjj00xzr5lujjbk6tho	cmmqfin3x001vr5rixugbviaq	7	2024	2000	310	0	2310	2000	PARTIAL	2026-03-15 07:02:45.152	2026-03-15 07:37:21.474
cmmreqmjk00y1r5lum119vfzr	cmmqfin400020r5ri8p9t0kvk	7	2024	2000	570	0	2570	2000	PARTIAL	2026-03-15 07:02:45.153	2026-03-15 07:37:21.474
cmmreqmjl00y3r5lu8nz18w77	cmmqfin2s0002r5rig5gyl78u	8	2024	2000	521	0	2521	2000	PARTIAL	2026-03-15 07:02:45.153	2026-03-15 07:37:21.475
cmmreqmjl00y5r5lu39z4hnkt	cmmqfin300007r5ri7hev5ck1	8	2024	2000	1077	0	3077	2000	PARTIAL	2026-03-15 07:02:45.153	2026-03-15 07:37:21.475
cmmreqmjl00y7r5lugps5xlmd	cmmqfin34000cr5riujl5lkum	8	2024	2000	456	0	2456	0	PENDING	2026-03-15 07:02:45.154	2026-03-15 07:37:21.475
cmmreqmjm00ybr5lu6oxe9g13	cmmqfin39000mr5rifitry7zu	8	2024	2000	369	0	2369	0	PENDING	2026-03-15 07:02:45.155	2026-03-15 07:37:21.476
cmmreqmjn00yfr5lu9grm2fcz	cmmqfin3f000wr5riqmcfcwsy	8	2024	2000	341	0	2341	2000	PARTIAL	2026-03-15 07:02:45.155	2026-03-15 07:37:21.476
cmmreqmjn00yhr5lu8qux23m8	cmmqfin3h0011r5ri60yvcljp	8	2024	2000	737	0	2737	2000	PARTIAL	2026-03-15 07:02:45.156	2026-03-15 07:37:21.476
cmmreqmjo00yjr5lu2a2pukc3	cmmqfin3k0016r5ri43nzr1pi	8	2024	2000	782	0	2782	2000	PARTIAL	2026-03-15 07:02:45.156	2026-03-15 07:37:21.477
cmmreqmjo00ylr5lulvqncibf	cmmqfin3n001br5rinbkhyypl	8	2024	2000	684	0	2684	2000	PARTIAL	2026-03-15 07:02:45.157	2026-03-15 07:37:21.477
cmmreqmjo00ynr5luzuc5tlah	cmmqfin3q001gr5riuek21iw1	8	2024	2000	618	0	2618	0	PENDING	2026-03-15 07:02:45.157	2026-03-15 07:37:21.478
cmmreqmjp00yrr5lu6yc0ga7i	cmmqfin3v001qr5rik05d5yuh	8	2024	2000	644	0	2644	2000	PARTIAL	2026-03-15 07:02:45.158	2026-03-15 07:37:21.478
cmmreqmjp00ytr5luw2uk20tr	cmmqfin3x001vr5rixugbviaq	8	2024	2000	310	0	2310	2000	PARTIAL	2026-03-15 07:02:45.158	2026-03-15 07:37:21.478
cmmreqmjq00yvr5luz8vrax3x	cmmqfin400020r5ri8p9t0kvk	8	2024	2000	570	0	2570	0	PENDING	2026-03-15 07:02:45.158	2026-03-15 07:37:21.479
cmmreqmjr00yzr5luklmf2s0b	cmmqfin300007r5ri7hev5ck1	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.159	2026-03-15 07:37:21.479
cmmreqmjr00z1r5lusz8sdnsi	cmmqfin34000cr5riujl5lkum	9	2024	2000	0	4456	6456	0	PENDING	2026-03-15 07:02:45.159	2026-03-15 07:37:21.48
cmmreqmjs00z5r5lu44mluig4	cmmqfin39000mr5rifitry7zu	9	2024	2000	0	0	2000	4000	PAID	2026-03-15 07:02:45.16	2026-03-15 07:37:21.48
cmmreqmjs00z7r5luwxszdxpe	cmmqfin3c000rr5riaz9ygvbu	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.16	2026-03-15 07:37:21.48
cmmreqmjs00z9r5luy242sf02	cmmqfin3f000wr5riqmcfcwsy	9	2024	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.161	2026-03-15 07:37:21.481
cmmreqmja00whr5lugfbwz6cr	cmmqfin300007r5ri7hev5ck1	6	2024	2000	2615	0	4615	2000	PARTIAL	2026-03-15 07:02:45.142	2026-03-15 07:37:21.481
cmmreqmja00wlr5lu7obhuptb	cmmqfin37000hr5ri6v7crew3	6	2024	2000	946	0	2946	2000	PARTIAL	2026-03-15 07:02:45.143	2026-03-15 07:37:21.481
cmmreqmjm00y9r5lu2fa2c284	cmmqfin37000hr5ri6v7crew3	8	2024	2000	436	0	2436	2000	PARTIAL	2026-03-15 07:02:45.154	2026-03-15 07:37:21.482
cmmreqmjn00ydr5lu4rrjxf51	cmmqfin3c000rr5riaz9ygvbu	8	2024	2000	473	0	2473	2000	PARTIAL	2026-03-15 07:02:45.155	2026-03-15 07:37:21.482
cmmreqmjp00ypr5ludazvehnh	cmmqfin3s001lr5ri9eb3mld8	8	2024	2000	388	0	2388	2000	PARTIAL	2026-03-15 07:02:45.157	2026-03-15 07:37:21.483
cmmreqmjq00yxr5luubqju68j	cmmqfin2s0002r5rig5gyl78u	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.159	2026-03-15 07:37:21.483
cmmreqmjr00z3r5lurgerl2ym	cmmqfin37000hr5ri6v7crew3	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.16	2026-03-15 07:37:21.483
cmmreqmja00wjr5luncqziute	cmmqfin34000cr5riujl5lkum	6	2024	2000	529	3593	6122	0	PENDING	2026-03-15 07:02:45.143	2026-03-15 07:37:21.465
cmmreqmju00zhr5lu84r3382u	cmmqfin3q001gr5riuek21iw1	9	2024	2000	0	618	2618	2000	PARTIAL	2026-03-15 07:02:45.162	2026-03-15 07:37:21.484
cmmreqmju00zjr5lutulipxem	cmmqfin3s001lr5ri9eb3mld8	9	2024	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.163	2026-03-15 07:37:21.484
cmmreqmjv00znr5lu97os87h7	cmmqfin3x001vr5rixugbviaq	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.163	2026-03-15 07:37:21.485
cmmreqmjv00zpr5luijgk4tlx	cmmqfin400020r5ri8p9t0kvk	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.164	2026-03-15 07:37:21.485
cmmreqmjw00zrr5lum384l95a	cmmqfin2s0002r5rig5gyl78u	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.164	2026-03-15 07:37:21.486
cmmreqmjw00ztr5lu4bmerkya	cmmqfin300007r5ri7hev5ck1	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.165	2026-03-15 07:37:21.486
cmmreqmjx00zvr5lume0rmtjl	cmmqfin34000cr5riujl5lkum	10	2024	2000	0	0	2000	6000	PAID	2026-03-15 07:02:45.165	2026-03-15 07:37:21.487
cmmreqmjx00zxr5luadoeqggs	cmmqfin37000hr5ri6v7crew3	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.165	2026-03-15 07:37:21.487
cmmreqmjx00zzr5luqqnhj4zk	cmmqfin39000mr5rifitry7zu	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.166	2026-03-15 07:37:21.487
cmmreqmjy0101r5lufoa5litg	cmmqfin3c000rr5riaz9ygvbu	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.166	2026-03-15 07:37:21.488
cmmreqmjy0103r5luvem65vmi	cmmqfin3f000wr5riqmcfcwsy	10	2024	2000	0	2000	4000	2000	PARTIAL	2026-03-15 07:02:45.166	2026-03-15 07:37:21.488
cmmreqmjy0105r5lundv2ww2l	cmmqfin3h0011r5ri60yvcljp	10	2024	2000	0	-463	1537	2000	PAID	2026-03-15 07:02:45.167	2026-03-15 07:37:21.488
cmmreqmjz0107r5lu7kt1o36k	cmmqfin3k0016r5ri43nzr1pi	10	2024	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.167	2026-03-15 07:37:21.489
cmmreqmk0010dr5luc3dwsfi7	cmmqfin3s001lr5ri9eb3mld8	10	2024	2000	0	0	2000	4000	PAID	2026-03-15 07:02:45.169	2026-03-15 07:37:21.489
cmmreqmk0010fr5lusn5w28b5	cmmqfin3v001qr5rik05d5yuh	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.169	2026-03-15 07:37:21.49
cmmreqmk1010hr5lu8j8kmjwc	cmmqfin3x001vr5rixugbviaq	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.169	2026-03-15 07:37:21.49
cmmreqmk1010jr5lu0pfltq41	cmmqfin400020r5ri8p9t0kvk	10	2024	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.17	2026-03-15 07:37:21.49
cmmreqmk2010nr5lu0v5fa6n7	cmmqfin300007r5ri7hev5ck1	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.17	2026-03-15 07:37:21.491
cmmreqmk2010pr5luf0gbjmop	cmmqfin34000cr5riujl5lkum	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.171	2026-03-15 07:37:21.491
cmmreqmk3010rr5lunwjx20vq	cmmqfin37000hr5ri6v7crew3	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.171	2026-03-15 07:37:21.491
cmmreqmk3010tr5luxfl8erwo	cmmqfin39000mr5rifitry7zu	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.172	2026-03-15 07:37:21.492
cmmreqmk3010vr5lulkbygavc	cmmqfin3c000rr5riaz9ygvbu	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.172	2026-03-15 07:37:21.492
cmmreqmk4010xr5lujmdn0nha	cmmqfin3f000wr5riqmcfcwsy	11	2024	2000	0	2000	4000	2000	PARTIAL	2026-03-15 07:02:45.172	2026-03-15 07:37:21.492
cmmreqmk4010zr5lunhb8ngjk	cmmqfin3h0011r5ri60yvcljp	11	2024	2000	0	-463	1537	2000	PAID	2026-03-15 07:02:45.173	2026-03-15 07:37:21.493
cmmreqmk40111r5lukq1l5ebd	cmmqfin3k0016r5ri43nzr1pi	11	2024	2000	0	2000	4000	4000	PAID	2026-03-15 07:02:45.173	2026-03-15 07:37:21.493
cmmreqmk50113r5lugimdmfsq	cmmqfin3n001br5rinbkhyypl	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.173	2026-03-15 07:37:21.493
cmmreqmk50115r5luq3f2ufzq	cmmqfin3q001gr5riuek21iw1	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.174	2026-03-15 07:37:21.494
cmmreqmk60117r5luat0d2qou	cmmqfin3s001lr5ri9eb3mld8	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.174	2026-03-15 07:37:21.494
cmmreqmk60119r5lu7ojd39nq	cmmqfin3v001qr5rik05d5yuh	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.174	2026-03-15 07:37:21.494
cmmreqmk6011br5lubdjp5lf8	cmmqfin3x001vr5rixugbviaq	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.175	2026-03-15 07:37:21.495
cmmreqmk7011dr5luycc3y5rg	cmmqfin400020r5ri8p9t0kvk	11	2024	2000	0	2000	4000	2000	PARTIAL	2026-03-15 07:02:45.175	2026-03-15 07:37:21.495
cmmreqmk7011fr5luvpeyioer	cmmqfin2s0002r5rig5gyl78u	12	2024	2000	1618	0	3618	2000	PARTIAL	2026-03-15 07:02:45.176	2026-03-15 07:37:21.496
cmmreqmk7011hr5lutpfwliyc	cmmqfin300007r5ri7hev5ck1	12	2024	2000	1913	0	3913	2000	PARTIAL	2026-03-15 07:02:45.176	2026-03-15 07:37:21.496
cmmreqmk8011jr5luo41xr358	cmmqfin34000cr5riujl5lkum	12	2024	2000	922	2000	4922	0	PENDING	2026-03-15 07:02:45.176	2026-03-15 07:37:21.497
cmmreqmk9011nr5lu73gtuwlu	cmmqfin39000mr5rifitry7zu	12	2024	2000	312	0	2312	2000	PARTIAL	2026-03-15 07:02:45.177	2026-03-15 07:37:21.497
cmmreqmk9011pr5lujd0m964j	cmmqfin3c000rr5riaz9ygvbu	12	2024	2000	858	0	2858	2000	PARTIAL	2026-03-15 07:02:45.178	2026-03-15 07:37:21.497
cmmreqmka011rr5lui1e3gsra	cmmqfin3f000wr5riqmcfcwsy	12	2024	2000	1139	2000	5139	0	PENDING	2026-03-15 07:02:45.178	2026-03-15 07:37:21.498
cmmreqmka011vr5lu2ue7zayb	cmmqfin3k0016r5ri43nzr1pi	12	2024	2000	1510	0	3510	2000	PARTIAL	2026-03-15 07:02:45.179	2026-03-15 07:37:21.498
cmmreqmkb011xr5lub1ci482q	cmmqfin3n001br5rinbkhyypl	12	2024	2000	521	2000	4521	0	PENDING	2026-03-15 07:02:45.179	2026-03-15 07:37:21.499
cmmreqmkc0123r5luj4urbm3a	cmmqfin3v001qr5rik05d5yuh	12	2024	2000	1108	-6000	-2892	2000	PAID	2026-03-15 07:02:45.181	2026-03-15 07:37:21.499
cmmreqmkd0125r5luy82kzyrf	cmmqfin3x001vr5rixugbviaq	12	2024	2000	556	0	2556	2000	PARTIAL	2026-03-15 07:02:45.181	2026-03-15 07:37:21.499
cmmreqmjt00zdr5lul1dggpcx	cmmqfin3k0016r5ri43nzr1pi	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.162	2026-03-15 07:37:21.5
cmmreqmjt00zfr5luk6vep4bo	cmmqfin3n001br5rinbkhyypl	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.162	2026-03-15 07:37:21.484
cmmreqmjv00zlr5lup2vhpejc	cmmqfin3v001qr5rik05d5yuh	9	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.163	2026-03-15 07:37:21.5
cmmreqmk0010br5luj9hzm86u	cmmqfin3q001gr5riuek21iw1	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.168	2026-03-15 07:37:21.501
cmmreqmk2010lr5lurjsqe8x4	cmmqfin2s0002r5rig5gyl78u	11	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.17	2026-03-15 07:37:21.501
cmmreqmk8011lr5lu16kv2euc	cmmqfin37000hr5ri6v7crew3	12	2024	2000	777	0	2777	2000	PARTIAL	2026-03-15 07:02:45.177	2026-03-15 07:37:21.501
cmmreqmka011tr5ludaiz5lwr	cmmqfin3h0011r5ri60yvcljp	12	2024	2000	1509	-3140	369	2000	PAID	2026-03-15 07:02:45.178	2026-03-15 07:37:21.502
cmmreqmkb011zr5ludfpwcxxq	cmmqfin3q001gr5riuek21iw1	12	2024	2000	404	2000	4404	0	PENDING	2026-03-15 07:02:45.18	2026-03-15 07:37:21.502
cmmreqmkc0121r5lu1pfr212z	cmmqfin3s001lr5ri9eb3mld8	12	2024	2000	494	0	2494	2000	PARTIAL	2026-03-15 07:02:45.18	2026-03-15 07:37:21.502
cmmreqmke0129r5lujr8rr672	cmmqfin2s0002r5rig5gyl78u	1	2025	2000	923	0	2923	2000	PARTIAL	2026-03-15 07:02:45.182	2026-03-15 07:37:21.503
cmmreqmke012br5lurbji3qs0	cmmqfin300007r5ri7hev5ck1	1	2025	2000	2231	0	4231	2000	PARTIAL	2026-03-15 07:02:45.182	2026-03-15 07:37:21.503
cmmreqmke012dr5lub6dm90xd	cmmqfin34000cr5riujl5lkum	1	2025	2000	1998	4922	8920	0	PENDING	2026-03-15 07:02:45.183	2026-03-15 07:37:21.504
cmmreqmkf012hr5lu70ar2u8x	cmmqfin39000mr5rifitry7zu	1	2025	2000	1125	312	3437	2000	PARTIAL	2026-03-15 07:02:45.184	2026-03-15 07:37:21.504
cmmreqmkf012jr5luxhe6wc22	cmmqfin3c000rr5riaz9ygvbu	1	2025	2000	827	0	2827	2000	PARTIAL	2026-03-15 07:02:45.184	2026-03-15 07:37:21.505
cmmreqmkg012lr5luzu5etvf1	cmmqfin3f000wr5riqmcfcwsy	1	2025	2000	1472	0	3472	2000	PARTIAL	2026-03-15 07:02:45.184	2026-03-15 07:37:21.505
cmmreqmkg012nr5lu43o33n3k	cmmqfin3h0011r5ri60yvcljp	1	2025	2000	1731	-2380	1351	0	PENDING	2026-03-15 07:02:45.185	2026-03-15 07:37:21.506
cmmreqmkh012rr5lu6lh41cu3	cmmqfin3n001br5rinbkhyypl	1	2025	2000	1011	0	3011	2000	PARTIAL	2026-03-15 07:02:45.185	2026-03-15 07:37:21.506
cmmreqmkh012tr5luibc3lixz	cmmqfin3q001gr5riuek21iw1	1	2025	2000	934	0	2934	2000	PARTIAL	2026-03-15 07:02:45.186	2026-03-15 07:37:21.506
cmmreqmki012vr5lud50qju2z	cmmqfin3s001lr5ri9eb3mld8	1	2025	2000	684	0	2684	2000	PARTIAL	2026-03-15 07:02:45.186	2026-03-15 07:37:21.507
cmmreqmki012xr5lur55plvlm	cmmqfin3v001qr5rik05d5yuh	1	2025	2000	1676	-2892	784	2000	PAID	2026-03-15 07:02:45.186	2026-03-15 07:37:21.507
cmmreqmki012zr5lucqnpqj0b	cmmqfin3x001vr5rixugbviaq	1	2025	2000	690	0	2690	2000	PARTIAL	2026-03-15 07:02:45.187	2026-03-15 07:37:21.507
cmmreqmkj0131r5lu0g7lmzx4	cmmqfin400020r5ri8p9t0kvk	1	2025	2000	1231	0	3231	2000	PARTIAL	2026-03-15 07:02:45.187	2026-03-15 07:37:21.508
cmmreqmkj0135r5luzdfo1b5o	cmmqfin300007r5ri7hev5ck1	2	2025	2000	2276	0	4276	4000	PARTIAL	2026-03-15 07:02:45.188	2026-03-15 07:37:21.508
cmmreqmkk0137r5luruzs64o4	cmmqfin34000cr5riujl5lkum	2	2025	2000	1533	0	3533	6000	PAID	2026-03-15 07:02:45.188	2026-03-15 07:37:21.508
cmmreqmkk0139r5lun4b45luj	cmmqfin37000hr5ri6v7crew3	2	2025	2000	913	0	2913	2000	PARTIAL	2026-03-15 07:02:45.189	2026-03-15 07:37:21.509
cmmreqmkl013br5luk13uz27m	cmmqfin39000mr5rifitry7zu	2	2025	2000	763	0	2763	2000	PARTIAL	2026-03-15 07:02:45.189	2026-03-15 07:37:21.509
cmmreqmkl013dr5lu0pd6zu25	cmmqfin3c000rr5riaz9ygvbu	2	2025	2000	1173	0	3173	2000	PARTIAL	2026-03-15 07:02:45.19	2026-03-15 07:37:21.51
cmmreqmkm013fr5luk45alzv4	cmmqfin3f000wr5riqmcfcwsy	2	2025	2000	877	0	2877	2000	PARTIAL	2026-03-15 07:02:45.19	2026-03-15 07:37:21.51
cmmreqmkm013hr5luc1tzrcrc	cmmqfin3h0011r5ri60yvcljp	2	2025	2000	1675	0	3675	2000	PARTIAL	2026-03-15 07:02:45.191	2026-03-15 07:37:21.51
cmmreqmkn013jr5luxvap37fp	cmmqfin3k0016r5ri43nzr1pi	2	2025	2000	1688	0	3688	2000	PARTIAL	2026-03-15 07:02:45.191	2026-03-15 07:37:21.511
cmmreqmkn013lr5luxnmw6w95	cmmqfin3n001br5rinbkhyypl	2	2025	2000	1156	3011	6167	0	PENDING	2026-03-15 07:02:45.192	2026-03-15 07:37:21.511
cmmreqmko013pr5lum8pyctk2	cmmqfin3s001lr5ri9eb3mld8	2	2025	2000	707	0	2707	2000	PARTIAL	2026-03-15 07:02:45.192	2026-03-15 07:37:21.512
cmmreqmko013rr5luyir45of8	cmmqfin3v001qr5rik05d5yuh	2	2025	2000	1548	784	4332	2000	PARTIAL	2026-03-15 07:02:45.193	2026-03-15 07:37:21.512
cmmreqmkp013tr5lu3e5taq9x	cmmqfin3x001vr5rixugbviaq	2	2025	2000	393	0	2393	2000	PARTIAL	2026-03-15 07:02:45.193	2026-03-15 07:37:21.512
cmmreqmkp013vr5lul8n6ztyp	cmmqfin400020r5ri8p9t0kvk	2	2025	2000	1219	0	3219	2000	PARTIAL	2026-03-15 07:02:45.193	2026-03-15 07:37:21.513
cmmreqmkp013xr5lutie29ale	cmmqfin2s0002r5rig5gyl78u	3	2025	2000	1029	3081	6110	0	PENDING	2026-03-15 07:02:45.194	2026-03-15 07:37:21.513
cmmreqmkq0141r5lue7r37o2m	cmmqfin34000cr5riujl5lkum	3	2025	2000	1829	3533	7362	0	PENDING	2026-03-15 07:02:45.195	2026-03-15 07:37:21.513
cmmreqmkr0145r5lun5n3hp9i	cmmqfin39000mr5rifitry7zu	3	2025	2000	1666	0	3666	2000	PARTIAL	2026-03-15 07:02:45.195	2026-03-15 07:37:21.514
cmmreqmkr0147r5luzdffh6ti	cmmqfin3c000rr5riaz9ygvbu	3	2025	2000	1540	0	3540	2000	PARTIAL	2026-03-15 07:02:45.196	2026-03-15 07:37:21.514
cmmreqmkr0149r5lu6delsu6t	cmmqfin3f000wr5riqmcfcwsy	3	2025	2000	862	0	2862	2000	PARTIAL	2026-03-15 07:02:45.196	2026-03-15 07:37:21.514
cmmreqmks014br5lu73jse6t6	cmmqfin3h0011r5ri60yvcljp	3	2025	2000	3540	0	5540	2000	PARTIAL	2026-03-15 07:02:45.196	2026-03-15 07:37:21.515
cmmreqmks014dr5luvgw1xgxt	cmmqfin3k0016r5ri43nzr1pi	3	2025	2000	2849	0	4849	2000	PARTIAL	2026-03-15 07:02:45.197	2026-03-15 07:37:21.515
cmmreqmkt014fr5lucf89ef2d	cmmqfin3n001br5rinbkhyypl	3	2025	2000	1979	0	3979	4000	PAID	2026-03-15 07:02:45.197	2026-03-15 07:37:21.516
cmmreqmkt014hr5luw0i5sduw	cmmqfin3q001gr5riuek21iw1	3	2025	2000	891	-3748	-857	2000	PAID	2026-03-15 07:02:45.197	2026-03-15 07:37:21.516
cmmreqmkt014jr5lug6darums	cmmqfin3s001lr5ri9eb3mld8	3	2025	2000	1093	0	3093	2000	PARTIAL	2026-03-15 07:02:45.198	2026-03-15 07:37:21.516
cmmreqmku014lr5luziz7tn0h	cmmqfin3v001qr5rik05d5yuh	3	2025	2000	2207	0	4207	2000	PARTIAL	2026-03-15 07:02:45.198	2026-03-15 07:37:21.517
cmmreqmku014nr5lucg9p43js	cmmqfin3x001vr5rixugbviaq	3	2025	2000	1012	0	3012	2000	PARTIAL	2026-03-15 07:02:45.199	2026-03-15 07:37:21.517
cmmreqmkv014pr5lu2nxtm18y	cmmqfin400020r5ri8p9t0kvk	3	2025	2000	1966	0	3966	2000	PARTIAL	2026-03-15 07:02:45.199	2026-03-15 07:37:21.517
cmmreqmkv014tr5luumaogjx5	cmmqfin2s0002r5rig5gyl78u	4	2025	2000	1590	0	3590	4000	PAID	2026-03-15 07:02:45.2	2026-03-15 07:37:21.518
cmmreqmkw014vr5lubpl6nynp	cmmqfin300007r5ri7hev5ck1	4	2025	2000	3626	0	5626	2000	PARTIAL	2026-03-15 07:02:45.2	2026-03-15 07:37:21.518
cmmreqml8014xr5lurmvw5jc1	cmmqfin34000cr5riujl5lkum	4	2025	2000	1191	0	3191	4000	PAID	2026-03-15 07:02:45.213	2026-03-15 07:37:21.519
cmmreqml9014zr5lu3fc47y3o	cmmqfin37000hr5ri6v7crew3	4	2025	2000	2092	0	4092	2000	PARTIAL	2026-03-15 07:02:45.213	2026-03-15 07:37:21.519
cmmreqmla0151r5ludltse5e2	cmmqfin39000mr5rifitry7zu	4	2025	2000	1669	-334	3335	2000	PARTIAL	2026-03-15 07:02:45.214	2026-03-15 07:37:21.519
cmmreqmkd0127r5lu5ni81qxh	cmmqfin400020r5ri8p9t0kvk	12	2024	2000	772	0	2772	2000	PARTIAL	2026-03-15 07:02:45.181	2026-03-15 07:37:21.52
cmmreqmkq013zr5lus6hyw2uk	cmmqfin300007r5ri7hev5ck1	3	2025	2000	3637	0	5637	2000	PARTIAL	2026-03-15 07:02:45.194	2026-03-15 07:37:21.503
cmmreqmkf012fr5luvzeabmti	cmmqfin37000hr5ri6v7crew3	1	2025	2000	934	0	2934	2000	PARTIAL	2026-03-15 07:02:45.183	2026-03-15 07:37:21.52
cmmreqmkh012pr5luwqqo8j8m	cmmqfin3k0016r5ri43nzr1pi	1	2025	2000	1713	0	3713	2000	PARTIAL	2026-03-15 07:02:45.185	2026-03-15 07:37:21.52
cmmreqmko013nr5luxx6fylq6	cmmqfin3q001gr5riuek21iw1	2	2025	2000	609	0	2609	2000	PARTIAL	2026-03-15 07:02:45.192	2026-03-15 07:37:21.521
cmmreqmkq0143r5lu8xpg8o8v	cmmqfin37000hr5ri6v7crew3	3	2025	2000	1575	0	3575	2000	PARTIAL	2026-03-15 07:02:45.195	2026-03-15 07:37:21.521
cmmreqmlc0159r5lu92qpu70n	cmmqfin3k0016r5ri43nzr1pi	4	2025	2000	3023	0	5023	2000	PARTIAL	2026-03-15 07:02:45.216	2026-03-15 07:37:21.522
cmmreqmld015br5lubkcwnbyh	cmmqfin3n001br5rinbkhyypl	4	2025	2000	1424	0	3424	4000	PAID	2026-03-15 07:02:45.217	2026-03-15 07:37:21.522
cmmreqmld015dr5lui1jj6ddb	cmmqfin3q001gr5riuek21iw1	4	2025	2000	977	-857	2120	2000	PARTIAL	2026-03-15 07:02:45.217	2026-03-15 07:37:21.523
cmmreqmld015fr5lu1d4dibcz	cmmqfin3s001lr5ri9eb3mld8	4	2025	2000	1265	0	3265	2000	PARTIAL	2026-03-15 07:02:45.218	2026-03-15 07:37:21.523
cmmreqmle015hr5lu157gaa1h	cmmqfin3v001qr5rik05d5yuh	4	2025	2000	2882	4207	9089	0	PENDING	2026-03-15 07:02:45.219	2026-03-15 07:37:21.523
cmmreqmlf015lr5luz1pze4j2	cmmqfin400020r5ri8p9t0kvk	4	2025	2000	1494	0	3494	2000	PARTIAL	2026-03-15 07:02:45.22	2026-03-15 07:37:21.524
cmmreqmlg015nr5luu25nh9ri	cmmqfin2s0002r5rig5gyl78u	5	2025	2000	1622	0	3622	2000	PARTIAL	2026-03-15 07:02:45.22	2026-03-15 07:37:21.524
cmmreqmlg015pr5luja1i2ov8	cmmqfin300007r5ri7hev5ck1	5	2025	2000	3679	0	5679	2000	PARTIAL	2026-03-15 07:02:45.221	2026-03-15 07:37:21.524
cmmreqmli015rr5lut1rgl5jd	cmmqfin34000cr5riujl5lkum	5	2025	2000	1714	3191	6905	0	PENDING	2026-03-15 07:02:45.222	2026-03-15 07:37:21.525
cmmreqmlk015xr5luhanw1uhv	cmmqfin3c000rr5riaz9ygvbu	5	2025	2000	1310	0	3310	2000	PARTIAL	2026-03-15 07:02:45.225	2026-03-15 07:37:21.525
cmmreqmll015zr5lubey1os14	cmmqfin3f000wr5riqmcfcwsy	5	2025	2000	1058	2935	5993	0	PENDING	2026-03-15 07:02:45.226	2026-03-15 07:37:21.525
cmmreqmlm0163r5lubvghql45	cmmqfin3k0016r5ri43nzr1pi	5	2025	2000	2281	0	4281	2000	PARTIAL	2026-03-15 07:02:45.227	2026-03-15 07:37:21.526
cmmreqmln0165r5luy3i168ns	cmmqfin3n001br5rinbkhyypl	5	2025	2000	1928	3424	7352	0	PENDING	2026-03-15 07:02:45.227	2026-03-15 07:37:21.526
cmmreqmlo016br5luuqoxvy8d	cmmqfin3v001qr5rik05d5yuh	5	2025	2000	2882	0	4882	4000	PARTIAL	2026-03-15 07:02:45.229	2026-03-15 07:37:21.527
cmmreqmlp016dr5lu7om7m0cr	cmmqfin3x001vr5rixugbviaq	5	2025	2000	280	0	2280	2000	PARTIAL	2026-03-15 07:02:45.229	2026-03-15 07:37:21.527
cmmreqmlp016fr5lug995yz55	cmmqfin400020r5ri8p9t0kvk	5	2025	2000	1748	0	3748	2000	PARTIAL	2026-03-15 07:02:45.23	2026-03-15 07:37:21.527
cmmreqmlq016hr5lu3iahb3mv	cmmqfin2s0002r5rig5gyl78u	6	2025	2000	1709	0	3709	2000	PARTIAL	2026-03-15 07:02:45.23	2026-03-15 07:37:21.528
cmmreqmlq016jr5ludgdpr5dl	cmmqfin300007r5ri7hev5ck1	6	2025	2000	2725	0	4725	2000	PARTIAL	2026-03-15 07:02:45.231	2026-03-15 07:37:21.528
cmmreqmlr016lr5lumliks26c	cmmqfin34000cr5riujl5lkum	6	2025	2000	1696	6905	10601	0	PENDING	2026-03-15 07:02:45.231	2026-03-15 07:37:21.528
cmmreqmls016pr5luedf0m427	cmmqfin39000mr5rifitry7zu	6	2025	2000	1380	335	3715	2000	PARTIAL	2026-03-15 07:02:45.232	2026-03-15 07:37:21.529
cmmreqmls016rr5lukv73glu4	cmmqfin3c000rr5riaz9ygvbu	6	2025	2000	1023	0	3023	2000	PARTIAL	2026-03-15 07:02:45.233	2026-03-15 07:37:21.529
cmmreqmlt016tr5lu27w8oe1y	cmmqfin3f000wr5riqmcfcwsy	6	2025	2000	577	0	2577	2000	PARTIAL	2026-03-15 07:02:45.233	2026-03-15 07:37:21.53
cmmreqmlu016vr5lu5klp775s	cmmqfin3h0011r5ri60yvcljp	6	2025	2000	1064	0	3064	0	PENDING	2026-03-15 07:02:45.234	2026-03-15 07:37:21.53
cmmreqmlv016zr5lu94c7at5c	cmmqfin3n001br5rinbkhyypl	6	2025	2000	1355	0	3355	4000	PAID	2026-03-15 07:02:45.235	2026-03-15 07:37:21.53
cmmreqmlv0171r5lunjnrmkmf	cmmqfin3q001gr5riuek21iw1	6	2025	2000	979	0	2979	2000	PARTIAL	2026-03-15 07:02:45.236	2026-03-15 07:37:21.531
cmmreqmlw0173r5lu0cm1ywm1	cmmqfin3s001lr5ri9eb3mld8	6	2025	2000	1242	0	3242	2000	PARTIAL	2026-03-15 07:02:45.236	2026-03-15 07:37:21.531
cmmreqmlw0175r5luya1k63xe	cmmqfin3v001qr5rik05d5yuh	6	2025	2000	2019	4882	8901	0	PENDING	2026-03-15 07:02:45.237	2026-03-15 07:37:21.531
cmmreqmlx0179r5lu7afo3jij	cmmqfin400020r5ri8p9t0kvk	6	2025	2000	1409	0	3409	2000	PARTIAL	2026-03-15 07:02:45.237	2026-03-15 07:37:21.532
cmmreqmlx017br5lu8mzt2smr	cmmqfin2s0002r5rig5gyl78u	7	2025	2000	771	0	2771	2000	PARTIAL	2026-03-15 07:02:45.238	2026-03-15 07:37:21.532
cmmreqmly017dr5luaic35fa7	cmmqfin300007r5ri7hev5ck1	7	2025	2000	1279	0	3279	2000	PARTIAL	2026-03-15 07:02:45.238	2026-03-15 07:37:21.532
cmmreqmly017fr5luxhjjfdqu	cmmqfin34000cr5riujl5lkum	7	2025	2000	878	0	2878	4000	PAID	2026-03-15 07:02:45.239	2026-03-15 07:37:21.533
cmmreqmlz017hr5lua3w0jzah	cmmqfin37000hr5ri6v7crew3	7	2025	2000	456	0	2456	2000	PARTIAL	2026-03-15 07:02:45.239	2026-03-15 07:37:21.533
cmmreqmlz017jr5lu00t4th6m	cmmqfin39000mr5rifitry7zu	7	2025	2000	524	0	2524	2000	PARTIAL	2026-03-15 07:02:45.24	2026-03-15 07:37:21.534
cmmreqmlz017lr5lu16sij1g9	cmmqfin3c000rr5riaz9ygvbu	7	2025	2000	328	0	2328	2000	PARTIAL	2026-03-15 07:02:45.24	2026-03-15 07:37:21.534
cmmreqmm0017nr5luf63hss1n	cmmqfin3f000wr5riqmcfcwsy	7	2025	2000	199	2577	4776	0	PENDING	2026-03-15 07:02:45.24	2026-03-15 07:37:21.534
cmmreqmm1017rr5lu2dwt45s2	cmmqfin3k0016r5ri43nzr1pi	7	2025	2000	992	0	2992	2000	PARTIAL	2026-03-15 07:02:45.242	2026-03-15 07:37:21.535
cmmreqmm2017tr5luo478txmk	cmmqfin3n001br5rinbkhyypl	7	2025	2000	730	0	2730	2000	PARTIAL	2026-03-15 07:02:45.242	2026-03-15 07:37:21.535
cmmreqmm2017vr5luv889ojvy	cmmqfin3q001gr5riuek21iw1	7	2025	2000	398	0	2398	2000	PARTIAL	2026-03-15 07:02:45.243	2026-03-15 07:37:21.536
cmmreqmm3017xr5lui0valb73	cmmqfin3s001lr5ri9eb3mld8	7	2025	2000	337	0	2337	2000	PARTIAL	2026-03-15 07:02:45.243	2026-03-15 07:37:21.536
cmmreqmlb0155r5lu2mkf3wt1	cmmqfin3f000wr5riqmcfcwsy	4	2025	2000	935	0	2935	2000	PARTIAL	2026-03-15 07:02:45.215	2026-03-15 07:37:21.536
cmmreqmlb0157r5luz94w7zp5	cmmqfin3h0011r5ri60yvcljp	4	2025	2000	2959	0	4959	2000	PARTIAL	2026-03-15 07:02:45.216	2026-03-15 07:37:21.522
cmmreqmlf015jr5lubhccf0s2	cmmqfin3x001vr5rixugbviaq	4	2025	2000	959	0	2959	2000	PARTIAL	2026-03-15 07:02:45.219	2026-03-15 07:37:21.536
cmmreqmlj015tr5lus6a5ez0c	cmmqfin37000hr5ri6v7crew3	5	2025	2000	3469	4092	9561	0	PENDING	2026-03-15 07:02:45.223	2026-03-15 07:37:21.537
cmmreqmlk015vr5luu2zcr5d8	cmmqfin39000mr5rifitry7zu	5	2025	2000	1168	335	3503	2000	PARTIAL	2026-03-15 07:02:45.224	2026-03-15 07:37:21.537
cmmreqmlm0161r5lu1d0j8p61	cmmqfin3h0011r5ri60yvcljp	5	2025	2000	1324	0	3324	2000	PARTIAL	2026-03-15 07:02:45.226	2026-03-15 07:37:21.538
cmmreqmlo0169r5lug84jvugr	cmmqfin3s001lr5ri9eb3mld8	5	2025	2000	1480	0	3480	2000	PARTIAL	2026-03-15 07:02:45.228	2026-03-15 07:37:21.538
cmmreqmlr016nr5lu4ob2szk4	cmmqfin37000hr5ri6v7crew3	6	2025	2000	1128	0	3128	4000	PAID	2026-03-15 07:02:45.232	2026-03-15 07:37:21.538
cmmreqmlu016xr5lu4sweqaon	cmmqfin3k0016r5ri43nzr1pi	6	2025	2000	1891	0	3891	2000	PARTIAL	2026-03-15 07:02:45.235	2026-03-15 07:37:21.539
cmmreqmlx0177r5lu3exromcq	cmmqfin3x001vr5rixugbviaq	6	2025	2000	775	0	2775	2000	PARTIAL	2026-03-15 07:02:45.237	2026-03-15 07:37:21.539
cmmreqmm1017pr5luh9vpuu43	cmmqfin3h0011r5ri60yvcljp	7	2025	2000	614	0	2614	2000	PARTIAL	2026-03-15 07:02:45.241	2026-03-15 07:37:21.539
cmmreqmm40185r5lu40c9kwjm	cmmqfin2s0002r5rig5gyl78u	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.244	2026-03-15 07:37:21.54
cmmreqmm40187r5luymmsmc56	cmmqfin300007r5ri7hev5ck1	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.245	2026-03-15 07:37:21.54
cmmreqmm50189r5lumhyq813j	cmmqfin34000cr5riujl5lkum	8	2025	2000	0	2878	4878	0	PENDING	2026-03-15 07:02:45.245	2026-03-15 07:37:21.541
cmmreqmm5018dr5lucyy2oui3	cmmqfin39000mr5rifitry7zu	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.246	2026-03-15 07:37:21.541
cmmreqmm6018fr5lu871gzb7g	cmmqfin3c000rr5riaz9ygvbu	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.246	2026-03-15 07:37:21.542
cmmreqmm6018hr5lugsajscxl	cmmqfin3f000wr5riqmcfcwsy	8	2025	2000	0	4776	6776	0	PENDING	2026-03-15 07:02:45.246	2026-03-15 07:37:21.542
cmmreqmm7018lr5luow0tyhk1	cmmqfin3k0016r5ri43nzr1pi	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.247	2026-03-15 07:37:21.542
cmmreqmm7018nr5luwg1taueo	cmmqfin3n001br5rinbkhyypl	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.248	2026-03-15 07:37:21.543
cmmreqmm8018pr5lup5mi4g6v	cmmqfin3q001gr5riuek21iw1	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.248	2026-03-15 07:37:21.543
cmmreqmm8018rr5luo8is1cww	cmmqfin3s001lr5ri9eb3mld8	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.249	2026-03-15 07:37:21.545
cmmreqmm9018tr5lu5c8pcpbf	cmmqfin3v001qr5rik05d5yuh	8	2025	2000	0	-174	1826	2000	PAID	2026-03-15 07:02:45.249	2026-03-15 07:37:21.545
cmmreqmm9018vr5lufysuu99u	cmmqfin3x001vr5rixugbviaq	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.25	2026-03-15 07:37:21.546
cmmreqmma018zr5lu2f2jygvg	cmmqfin2s0002r5rig5gyl78u	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.25	2026-03-15 07:37:21.546
cmmreqmma0191r5luhcfuihkx	cmmqfin300007r5ri7hev5ck1	9	2025	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.251	2026-03-15 07:37:21.546
cmmreqmmb0195r5lur1upyfcw	cmmqfin37000hr5ri6v7crew3	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.252	2026-03-15 07:37:21.547
cmmreqmmc0197r5luesxnhu0s	cmmqfin39000mr5rifitry7zu	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.252	2026-03-15 07:37:21.547
cmmreqmmc0199r5lucoept0kf	cmmqfin3c000rr5riaz9ygvbu	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.253	2026-03-15 07:37:21.548
cmmreqmmd019br5lu14d2pcje	cmmqfin3f000wr5riqmcfcwsy	9	2025	2000	0	-2000	0	6000	PAID	2026-03-15 07:02:45.253	2026-03-15 07:37:21.548
cmmreqmmd019dr5luijbpsny3	cmmqfin3h0011r5ri60yvcljp	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.254	2026-03-15 07:37:21.549
cmmreqmme019fr5lusxdbrxgn	cmmqfin3k0016r5ri43nzr1pi	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.254	2026-03-15 07:37:21.549
cmmreqmme019hr5luihzp8azi	cmmqfin3n001br5rinbkhyypl	9	2025	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.255	2026-03-15 07:37:21.549
cmmreqmmf019lr5lubxivklp1	cmmqfin3s001lr5ri9eb3mld8	9	2025	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.256	2026-03-15 07:37:21.55
cmmreqmmh019rr5lumtsr3f1u	cmmqfin400020r5ri8p9t0kvk	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.257	2026-03-15 07:37:21.55
cmmreqmmh019tr5luw6qcu4jk	cmmqfin2s0002r5rig5gyl78u	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.258	2026-03-15 07:37:21.551
cmmreqmmi019vr5luvdheuo73	cmmqfin300007r5ri7hev5ck1	10	2025	2000	0	2000	4000	4000	PAID	2026-03-15 07:02:45.258	2026-03-15 07:37:21.551
cmmreqmmi019xr5luedld378m	cmmqfin34000cr5riujl5lkum	10	2025	2000	0	0	2000	0	PENDING	2026-03-15 07:02:45.259	2026-03-15 07:37:21.552
cmmreqmmj01a1r5ludarvvhia	cmmqfin39000mr5rifitry7zu	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.26	2026-03-15 07:37:21.552
cmmreqmmk01a3r5luqn0rezmy	cmmqfin3c000rr5riaz9ygvbu	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.26	2026-03-15 07:37:21.552
cmmreqmmk01a5r5lurplcdldv	cmmqfin3f000wr5riqmcfcwsy	10	2025	2000	0	-2000	0	2000	PAID	2026-03-15 07:02:45.261	2026-03-15 07:37:21.552
cmmreqmml01a7r5lusqcufv3i	cmmqfin3h0011r5ri60yvcljp	10	2025	2000	0	-3100	-1100	2000	PAID	2026-03-15 07:02:45.261	2026-03-15 07:37:21.553
cmmreqmml01a9r5lu85f5q7ke	cmmqfin3k0016r5ri43nzr1pi	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.262	2026-03-15 07:37:21.554
cmmreqmmm01abr5lup93ztnlr	cmmqfin3n001br5rinbkhyypl	10	2025	2000	0	2000	4000	4000	PAID	2026-03-15 07:02:45.262	2026-03-15 07:37:21.554
cmmreqmmm01adr5lu83shtsyb	cmmqfin3q001gr5riuek21iw1	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.263	2026-03-15 07:37:21.554
cmmreqmmn01afr5lu3e1gpi4p	cmmqfin3s001lr5ri9eb3mld8	10	2025	2000	0	2000	4000	4000	PAID	2026-03-15 07:02:45.263	2026-03-15 07:37:21.554
cmmreqmmn01ahr5lulq1jd1ez	cmmqfin3v001qr5rik05d5yuh	10	2025	2000	0	1826	3826	4000	PAID	2026-03-15 07:02:45.264	2026-03-15 07:37:21.555
cmmreqmmo01ajr5lufn2cwioj	cmmqfin3x001vr5rixugbviaq	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.264	2026-03-15 07:37:21.555
cmmreqmmo01alr5luf3dx39zx	cmmqfin400020r5ri8p9t0kvk	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.264	2026-03-15 07:37:21.555
cmmreqmmo01anr5luimwiv9f8	cmmqfin2s0002r5rig5gyl78u	11	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.265	2026-03-15 07:37:21.556
cmmreqmmp01apr5lu4gknb08v	cmmqfin300007r5ri7hev5ck1	11	2025	2000	0	0	2000	4000	PAID	2026-03-15 07:02:45.265	2026-03-15 07:37:21.556
cmmreqmmp01arr5luff9jla4q	cmmqfin34000cr5riujl5lkum	11	2025	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.266	2026-03-15 07:37:21.556
cmmreqmm30181r5lubuv4t88j	cmmqfin3x001vr5rixugbviaq	7	2025	2000	341	0	2341	2000	PARTIAL	2026-03-15 07:02:45.244	2026-03-15 07:37:21.557
cmmreqmm40183r5lunqm0jrxz	cmmqfin400020r5ri8p9t0kvk	7	2025	2000	640	0	2640	2000	PARTIAL	2026-03-15 07:02:45.244	2026-03-15 07:37:21.54
cmmreqmm5018br5lucy3b1p5b	cmmqfin37000hr5ri6v7crew3	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.245	2026-03-15 07:37:21.557
cmmreqmm6018jr5luiwq6v0fz	cmmqfin3h0011r5ri60yvcljp	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.247	2026-03-15 07:37:21.557
cmmreqmmb0193r5luvtqvd7kr	cmmqfin34000cr5riujl5lkum	9	2025	2000	0	0	2000	4000	PAID	2026-03-15 07:02:45.251	2026-03-15 07:37:21.558
cmmreqmmf019jr5ludil093u3	cmmqfin3q001gr5riuek21iw1	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.255	2026-03-15 07:37:21.558
cmmreqmmg019nr5lu6s6mvwte	cmmqfin3v001qr5rik05d5yuh	9	2025	2000	0	1826	3826	0	PENDING	2026-03-15 07:02:45.256	2026-03-15 07:37:21.558
cmmreqmmg019pr5lu4mo6b60h	cmmqfin3x001vr5rixugbviaq	9	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.257	2026-03-15 07:37:21.558
cmmreqmmj019zr5lu7vd9ti1h	cmmqfin37000hr5ri6v7crew3	10	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.259	2026-03-15 07:37:21.559
cmmreqmmq01atr5lu0r41jv18	cmmqfin37000hr5ri6v7crew3	11	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.266	2026-03-15 07:37:21.559
cmmreqmnr01exr5lunqkgtfsv	cmmqfin37000hr5ri6v7crew3	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.304	2026-03-15 07:37:21.56
cmmreqmnt01f1r5lue5zkzppv	cmmqfin39000mr5rifitry7zu	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.306	2026-03-15 07:37:21.56
cmmreqmnv01f5r5luf51e2qsh	cmmqfin3c000rr5riaz9ygvbu	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.308	2026-03-15 07:37:21.56
cmmreqmnx01f9r5lukoc2xfba	cmmqfin3f000wr5riqmcfcwsy	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.31	2026-03-15 07:37:21.561
cmmreqmnz01fdr5lujm6d5ip9	cmmqfin3h0011r5ri60yvcljp	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.311	2026-03-15 07:37:21.561
cmmreqmo201fhr5lu12kxv5eo	cmmqfin3s001lr5ri9eb3mld8	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.314	2026-03-15 07:37:21.561
cmmreqmo401flr5luninp26yt	cmmqfin3v001qr5rik05d5yuh	1	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.316	2026-03-15 07:37:21.562
cmmreqmmr01axr5lu7t3p1z4x	cmmqfin3c000rr5riaz9ygvbu	11	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.267	2026-03-15 07:37:21.562
cmmreqmmr01azr5luvzpsvvqt	cmmqfin3f000wr5riqmcfcwsy	11	2025	2000	0	-2000	0	2000	PAID	2026-03-15 07:02:45.268	2026-03-15 07:37:21.562
cmmreqmms01b1r5lugnaemrul	cmmqfin3h0011r5ri60yvcljp	11	2025	2000	0	-1100	900	2000	PAID	2026-03-15 07:02:45.268	2026-03-15 07:37:21.562
cmmreqmms01b3r5luvugghs5t	cmmqfin3k0016r5ri43nzr1pi	11	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.269	2026-03-15 07:37:21.563
cmmreqmmt01b5r5lubyrv5q8d	cmmqfin3n001br5rinbkhyypl	11	2025	2000	0	0	2000	4000	PAID	2026-03-15 07:02:45.269	2026-03-15 07:37:21.563
cmmreqmmt01b7r5lu4afhv5fh	cmmqfin3q001gr5riuek21iw1	11	2025	2000	0	-1375	625	2000	PAID	2026-03-15 07:02:45.27	2026-03-15 07:37:21.563
cmmreqmmv01bbr5lujhpzdumj	cmmqfin3v001qr5rik05d5yuh	11	2025	2000	0	-174	1826	4000	PAID	2026-03-15 07:02:45.271	2026-03-15 07:37:21.564
cmmreqmmv01bdr5lumlw4mkb3	cmmqfin3x001vr5rixugbviaq	11	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.272	2026-03-15 07:37:21.564
cmmreqmmw01bfr5luyov531mr	cmmqfin400020r5ri8p9t0kvk	11	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.272	2026-03-15 07:37:21.564
cmmreqmmx01bjr5lu9ftswhpx	cmmqfin300007r5ri7hev5ck1	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.273	2026-03-16 03:48:31.521
cmmreqmmx01blr5lus3x76416	cmmqfin34000cr5riujl5lkum	12	2025	2000	0	4000	6000	0	PENDING	2026-03-15 07:02:45.274	2026-03-16 03:48:31.523
cmmreqmmy01bnr5lura7zcr69	cmmqfin37000hr5ri6v7crew3	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.274	2026-03-16 03:48:31.525
cmmreqmmy01brr5lugzknsd8g	cmmqfin3c000rr5riaz9ygvbu	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.275	2026-03-16 03:48:31.528
cmmreqmmz01btr5lu10ha9590	cmmqfin3f000wr5riqmcfcwsy	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.275	2026-03-16 03:48:31.529
cmmreqmmz01bvr5luaxy9xghp	cmmqfin3h0011r5ri60yvcljp	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.276	2026-03-16 03:48:31.53
cmmreqmn001bxr5luizts1try	cmmqfin3k0016r5ri43nzr1pi	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.276	2026-03-16 03:48:31.531
cmmreqmn001bzr5lu8j69ro40	cmmqfin3n001br5rinbkhyypl	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.276	2026-03-16 03:48:31.533
cmmreqmn101c1r5lurgb90r53	cmmqfin3q001gr5riuek21iw1	12	2025	2000	0	625	2625	0	PENDING	2026-03-15 07:02:45.277	2026-03-16 03:48:31.534
cmmreqmn101c3r5lur7zv85y8	cmmqfin3s001lr5ri9eb3mld8	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.277	2026-03-16 03:48:31.535
cmmreqmn201c7r5luqpubn6ui	cmmqfin3x001vr5rixugbviaq	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.278	2026-03-16 03:48:31.537
cmmreqmn201c9r5lupgfkifo1	cmmqfin400020r5ri8p9t0kvk	12	2025	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.279	2026-03-16 03:48:31.538
cmmreqmn301cbr5lujmvvhmx1	cmmqfin2s0002r5rig5gyl78u	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.279	2026-03-16 03:48:31.54
cmmreqmn501clr5luxqcwliu4	cmmqfin3c000rr5riaz9ygvbu	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.281	2026-03-16 03:48:31.544
cmmreqmn501cnr5lus77j0bjj	cmmqfin3f000wr5riqmcfcwsy	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.282	2026-03-16 03:48:31.545
cmmreqmn601cpr5luxd3imyyg	cmmqfin3h0011r5ri60yvcljp	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.282	2026-03-16 03:48:31.546
cmmreqmn601crr5lu0fmsb9gz	cmmqfin3k0016r5ri43nzr1pi	1	2026	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.282	2026-03-16 03:48:31.547
cmmreqmn601ctr5luwdwvcwjv	cmmqfin3n001br5rinbkhyypl	1	2026	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.283	2026-03-16 03:48:31.548
cmmreqmn701cvr5lu3jxi2364	cmmqfin3q001gr5riuek21iw1	1	2026	2000	0	0	2000	2625	PAID	2026-03-15 07:02:45.283	2026-03-16 03:48:31.549
cmmreqmn701cxr5lu7zvmtojf	cmmqfin3s001lr5ri9eb3mld8	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.284	2026-03-16 03:48:31.55
cmmreqmn801d3r5lupn3x8hro	cmmqfin400020r5ri8p9t0kvk	1	2026	2000	0	2000	4000	2000	PARTIAL	2026-03-15 07:02:45.285	2026-03-16 03:48:31.553
cmmrdgxy70001r5c3d65t5nk2	cmmqfin2s0002r5rig5gyl78u	2	2026	2000	1204	0	3204	2000	PARTIAL	2026-03-15 06:27:13.759	2026-03-16 03:48:31.554
cmmreqmn401cjr5luqlfh7w1u	cmmqfin39000mr5rifitry7zu	1	2026	2000	0	2000	4000	2000	PARTIAL	2026-03-15 07:02:45.281	2026-03-16 03:48:31.543
cmmreqmmw01bhr5lue9nid3cs	cmmqfin2s0002r5rig5gyl78u	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.273	2026-03-16 03:48:31.516
cmmreqmn301cdr5luv37z9bmq	cmmqfin300007r5ri7hev5ck1	1	2026	2000	0	2000	4000	0	PENDING	2026-03-15 07:02:45.28	2026-03-16 03:48:31.541
cmmreqmn401cfr5lumi460x7l	cmmqfin34000cr5riujl5lkum	1	2026	2000	0	0	2000	6000	PAID	2026-03-15 07:02:45.28	2026-03-16 03:48:31.541
cmmreqmmq01avr5lu9f2zp7di	cmmqfin39000mr5rifitry7zu	11	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.267	2026-03-15 07:37:21.572
cmmreqmnl01etr5luioe0jvzi	cmmqfin34000cr5riujl5lkum	1	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.297	2026-03-15 07:37:21.559
cmmreqmmy01bpr5lu9ssbqfo8	cmmqfin39000mr5rifitry7zu	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.274	2026-03-16 03:48:31.526
cmmreqmn201c5r5lu9dvkj1w0	cmmqfin3v001qr5rik05d5yuh	12	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.278	2026-03-16 03:48:31.536
cmmreqmn401chr5lud7mhegwy	cmmqfin37000hr5ri6v7crew3	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.28	2026-03-16 03:48:31.542
cmmreqmn801czr5lunbqpspl3	cmmqfin3v001qr5rik05d5yuh	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.284	2026-03-16 03:48:31.551
cmmreqmn801d1r5luzjdqmcsg	cmmqfin3x001vr5rixugbviaq	1	2026	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.284	2026-03-16 03:48:31.552
cmmqica0i0001r5l8bp98e6k8	cmmqfin2s0002r5rig5gyl78u	3	2026	2000	2114	0	4114	0	PENDING	2026-03-14 15:55:48.018	2026-03-16 05:46:02.025
cmmreqmo801ftr5lu6qqp0h2p	cmmqfin400020r5ri8p9t0kvk	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.32	2026-03-15 07:37:21.575
cmmreqmoa01fxr5lug56voabo	cmmqfin300007r5ri7hev5ck1	2	2021	2000	0	0	2000	5100	PAID	2026-03-15 07:02:45.322	2026-03-15 07:37:21.575
cmmreqmob01g1r5luq7uhqwkl	cmmqfin34000cr5riujl5lkum	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.324	2026-03-15 07:37:21.575
cmmreqmod01g5r5lumpqeb7e4	cmmqfin39000mr5rifitry7zu	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.325	2026-03-15 07:37:21.576
cmmreqmof01g9r5lukca1d876	cmmqfin3c000rr5riaz9ygvbu	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.327	2026-03-15 07:37:21.576
cmmreqmog01gdr5lu5ar5t2a5	cmmqfin3f000wr5riqmcfcwsy	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.329	2026-03-15 07:37:21.576
cmmreqmoi01ghr5luof34seie	cmmqfin3h0011r5ri60yvcljp	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.33	2026-03-15 07:37:21.577
cmmreqmoj01glr5lu4esk22c8	cmmqfin3s001lr5ri9eb3mld8	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.332	2026-03-15 07:37:21.577
cmmreqmol01gpr5lut67zr1a9	cmmqfin3v001qr5rik05d5yuh	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.334	2026-03-15 07:37:21.578
cmmreqmoo01gtr5lu9jpwejm5	cmmqfin3x001vr5rixugbviaq	2	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.336	2026-03-15 07:37:21.578
cmmreqmoq01gxr5lum9pqoknx	cmmqfin300007r5ri7hev5ck1	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.338	2026-03-15 07:37:21.578
cmmreqmos01h1r5lu8jx4ozkw	cmmqfin37000hr5ri6v7crew3	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.34	2026-03-15 07:37:21.579
cmmreqmou01h5r5luhuwupkjk	cmmqfin39000mr5rifitry7zu	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.342	2026-03-15 07:37:21.579
cmmreqmov01h9r5lunp7d605e	cmmqfin3c000rr5riaz9ygvbu	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.344	2026-03-15 07:37:21.58
cmmreqmox01hdr5luyvy08njl	cmmqfin3f000wr5riqmcfcwsy	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.345	2026-03-15 07:37:21.58
cmmreqmoz01hhr5lu4ixx0msd	cmmqfin3h0011r5ri60yvcljp	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.347	2026-03-15 07:37:21.58
cmmreqmp101hlr5lu1mzj7wsz	cmmqfin3k0016r5ri43nzr1pi	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.349	2026-03-15 07:37:21.581
cmmreqmp301hpr5luv0q9lsf0	cmmqfin3n001br5rinbkhyypl	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.351	2026-03-15 07:37:21.581
cmmreqmp501htr5luwkt301ni	cmmqfin3s001lr5ri9eb3mld8	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.353	2026-03-15 07:37:21.582
cmmreqmp701hxr5lu54bqgpw1	cmmqfin3v001qr5rik05d5yuh	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.355	2026-03-15 07:37:21.582
cmmreqmp901i1r5luvek4i1t3	cmmqfin3x001vr5rixugbviaq	3	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.358	2026-03-15 07:37:21.583
cmmreqmpb01i5r5luejx675x0	cmmqfin400020r5ri8p9t0kvk	3	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.36	2026-03-15 07:37:21.583
cmmreqmpe01i9r5luofw2i728	cmmqfin34000cr5riujl5lkum	4	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.362	2026-03-15 07:37:21.583
cmmreqmpg01idr5luuj84b7pw	cmmqfin37000hr5ri6v7crew3	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.364	2026-03-15 07:37:21.584
cmmreqmpi01ihr5lub0w32wx9	cmmqfin39000mr5rifitry7zu	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.367	2026-03-15 07:37:21.584
cmmreqmpk01ilr5lukwd8wc3t	cmmqfin3c000rr5riaz9ygvbu	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.369	2026-03-15 07:37:21.585
cmmreqmpm01ipr5luh9ucsc61	cmmqfin3f000wr5riqmcfcwsy	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.371	2026-03-15 07:37:21.585
cmmreqmpo01itr5luvvmo2q54	cmmqfin3h0011r5ri60yvcljp	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.373	2026-03-15 07:37:21.585
cmmreqmpq01ixr5lu0d7oqgtx	cmmqfin3k0016r5ri43nzr1pi	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.375	2026-03-15 07:37:21.586
cmmreqmps01j1r5luihpci5v2	cmmqfin3n001br5rinbkhyypl	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.377	2026-03-15 07:37:21.586
cmmreqmpu01j5r5lui2qjt6y7	cmmqfin3s001lr5ri9eb3mld8	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.379	2026-03-15 07:37:21.587
cmmreqmpw01j9r5luuanun87a	cmmqfin3v001qr5rik05d5yuh	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.381	2026-03-15 07:37:21.587
cmmreqmpz01jdr5lup073r6f7	cmmqfin3x001vr5rixugbviaq	4	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.383	2026-03-15 07:37:21.587
cmmreqmqh01k3r5luxsrq9oo3	cmmqfin3q001gr5riuek21iw1	5	2021	0	0	0	0	1700	PAID	2026-03-15 07:02:45.401	2026-03-15 07:37:21.588
cmmreqmra01l1r5lubciey20q	cmmqfin34000cr5riujl5lkum	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.43	2026-03-15 07:37:21.588
cmmreqmo601fpr5lu014yih7u	cmmqfin3x001vr5rixugbviaq	1	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.318	2026-03-15 07:37:21.574
cmmreqmrc01l5r5lua6nv43zi	cmmqfin37000hr5ri6v7crew3	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.433	2026-03-15 07:37:21.589
cmmreqmrf01l9r5lu0y9brqa5	cmmqfin39000mr5rifitry7zu	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.435	2026-03-15 07:37:21.589
cmmreqmrh01ldr5luqaj05d69	cmmqfin3c000rr5riaz9ygvbu	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.437	2026-03-15 07:37:21.589
cmmreqmrj01lhr5luxn387xbj	cmmqfin3f000wr5riqmcfcwsy	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.44	2026-03-15 07:37:21.59
cmmreqmrl01llr5luab3ewntt	cmmqfin3h0011r5ri60yvcljp	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.442	2026-03-15 07:37:21.59
cmmreqmrp01lpr5lufd276hn7	cmmqfin3k0016r5ri43nzr1pi	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.445	2026-03-15 07:37:21.591
cmmreqmrr01ltr5luxwxpcajw	cmmqfin3n001br5rinbkhyypl	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.447	2026-03-15 07:37:21.591
cmmreqmrt01lxr5luzxfxc0a7	cmmqfin3s001lr5ri9eb3mld8	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.449	2026-03-15 07:37:21.592
cmmreqmrv01m1r5luftdl55wy	cmmqfin3v001qr5rik05d5yuh	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.451	2026-03-15 07:37:21.592
cmmreqmrz01m5r5lusch0caf8	cmmqfin3x001vr5rixugbviaq	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.455	2026-03-15 07:37:21.592
cmmreqms101m9r5lu9ldeqcvy	cmmqfin400020r5ri8p9t0kvk	6	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.458	2026-03-15 07:37:21.593
cmmreqms301mdr5lueopgk6dj	cmmqfin34000cr5riujl5lkum	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.459	2026-03-15 07:37:21.593
cmmreqms501mhr5lu0nqul44l	cmmqfin37000hr5ri6v7crew3	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.461	2026-03-15 07:37:21.593
cmmreqmq101jhr5lumx8r8852	cmmqfin2s0002r5rig5gyl78u	5	2021	0	0	0	0	1700	PAID	2026-03-15 07:02:45.385	2026-03-15 07:37:21.594
cmmreqms801mpr5lu0stv90gq	cmmqfin3f000wr5riqmcfcwsy	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.465	2026-03-15 07:37:21.594
cmmreqmsb01mtr5lumn00cp9f	cmmqfin3h0011r5ri60yvcljp	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.467	2026-03-15 07:37:21.595
cmmreqmsd01mxr5lunk6b1jlz	cmmqfin3k0016r5ri43nzr1pi	7	2021	2000	0	0	2000	1200	PARTIAL	2026-03-15 07:02:45.469	2026-03-15 07:37:21.595
cmmreqmsf01n1r5lu280c2dpa	cmmqfin3n001br5rinbkhyypl	7	2021	2000	0	0	2000	1200	PARTIAL	2026-03-15 07:02:45.471	2026-03-15 07:37:21.596
cmmreqmsh01n5r5luy362soj4	cmmqfin3s001lr5ri9eb3mld8	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.473	2026-03-15 07:37:21.596
cmmreqmsj01n9r5lumfh1x1dt	cmmqfin3v001qr5rik05d5yuh	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.475	2026-03-15 07:37:21.596
cmmreqmsl01ndr5luyzqr9ws0	cmmqfin3x001vr5rixugbviaq	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.477	2026-03-15 07:37:21.597
cmmreqmsn01nhr5lufivai3vv	cmmqfin400020r5ri8p9t0kvk	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.479	2026-03-15 07:37:21.597
cmmreqmsp01nlr5lu4mmblkif	cmmqfin300007r5ri7hev5ck1	8	2021	2000	0	0	2000	5100	PAID	2026-03-15 07:02:45.481	2026-03-15 07:37:21.598
cmmreqmsr01npr5lu4zl78sit	cmmqfin37000hr5ri6v7crew3	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.483	2026-03-15 07:37:21.598
cmmreqmst01ntr5lug9m61pkk	cmmqfin39000mr5rifitry7zu	8	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.486	2026-03-15 07:37:21.599
cmmreqmsv01nxr5luhhxaeku9	cmmqfin3c000rr5riaz9ygvbu	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.488	2026-03-15 07:37:21.599
cmmreqmsx01o1r5lutcrsrmv2	cmmqfin3f000wr5riqmcfcwsy	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.49	2026-03-15 07:37:21.599
cmmreqmt001o5r5lux14ktk92	cmmqfin3h0011r5ri60yvcljp	8	2021	2000	0	0	2000	1163	PARTIAL	2026-03-15 07:02:45.492	2026-03-15 07:37:21.6
cmmreqmt201o9r5lucgpwxyy8	cmmqfin3k0016r5ri43nzr1pi	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.495	2026-03-15 07:37:21.6
cmmreqmt401odr5luwjeovzxi	cmmqfin3n001br5rinbkhyypl	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.497	2026-03-15 07:37:21.601
cmmreqmt601ohr5lup9mjfh0d	cmmqfin3s001lr5ri9eb3mld8	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.499	2026-03-15 07:37:21.601
cmmreqmt901olr5luxzoatobw	cmmqfin3v001qr5rik05d5yuh	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.501	2026-03-15 07:37:21.601
cmmreqmtb01opr5lus4uv86e7	cmmqfin3x001vr5rixugbviaq	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.503	2026-03-15 07:37:21.602
cmmreqmtd01otr5lu23a1v0w9	cmmqfin400020r5ri8p9t0kvk	8	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.506	2026-03-15 07:37:21.602
cmmreqmtf01oxr5lul988khml	cmmqfin39000mr5rifitry7zu	10	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.508	2026-03-15 07:37:21.602
cmmreqmti01p1r5lu8t1t70al	cmmqfin3c000rr5riaz9ygvbu	10	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.51	2026-03-15 07:37:21.602
cmmreqmtk01p5r5lus52camo7	cmmqfin3h0011r5ri60yvcljp	10	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.512	2026-03-15 07:37:21.603
cmmreqmtm01p9r5luazz9s9ub	cmmqfin3s001lr5ri9eb3mld8	10	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.514	2026-03-15 07:37:21.603
cmmreqmto01pdr5ludnns45sa	cmmqfin3x001vr5rixugbviaq	10	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.516	2026-03-15 07:37:21.604
cmmreqmtq01phr5luclkqm3x4	cmmqfin300007r5ri7hev5ck1	11	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.519	2026-03-15 07:37:21.604
cmmreqmts01plr5lujjivcvtc	cmmqfin34000cr5riujl5lkum	11	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.521	2026-03-15 07:37:21.604
cmmreqmtu01ppr5luq3r3e03s	cmmqfin37000hr5ri6v7crew3	11	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.523	2026-03-15 07:37:21.605
cmmreqmty01ptr5lukixlis17	cmmqfin39000mr5rifitry7zu	11	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.526	2026-03-15 07:37:21.605
cmmreqmu001pxr5luyhrihkv9	cmmqfin3c000rr5riaz9ygvbu	11	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.529	2026-03-15 07:37:21.605
cmmreqmu201q1r5lulyy7rk1m	cmmqfin3f000wr5riqmcfcwsy	11	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.531	2026-03-15 07:37:21.606
cmmreqmu401q5r5luhg90fdne	cmmqfin3h0011r5ri60yvcljp	11	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.533	2026-03-15 07:37:21.606
cmmreqmu701q9r5lu8b9zejej	cmmqfin3s001lr5ri9eb3mld8	11	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.535	2026-03-15 07:37:21.607
cmmreqmu901qdr5lur3m8xmxa	cmmqfin3x001vr5rixugbviaq	11	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.537	2026-03-15 07:37:21.607
cmmreqmub01qhr5lug9jlsu9g	cmmqfin400020r5ri8p9t0kvk	11	2021	2000	0	0	2000	5100	PAID	2026-03-15 07:02:45.54	2026-03-15 07:37:21.607
cmmreqmue01qlr5lu7a0okrah	cmmqfin300007r5ri7hev5ck1	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.543	2026-03-15 07:37:21.608
cmmreqmug01qpr5luospb2w8p	cmmqfin34000cr5riujl5lkum	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.545	2026-03-15 07:37:21.608
cmmreqmui01qtr5lum9tos4ve	cmmqfin37000hr5ri6v7crew3	12	2021	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.547	2026-03-15 07:37:21.609
cmmreqmuk01qxr5lu9r8uj8ys	cmmqfin39000mr5rifitry7zu	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.549	2026-03-15 07:37:21.609
cmmreqmun01r1r5luwc3qmaqt	cmmqfin3c000rr5riaz9ygvbu	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.551	2026-03-15 07:37:21.609
cmmreqmup01r5r5luu46nuof5	cmmqfin3f000wr5riqmcfcwsy	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.554	2026-03-15 07:37:21.61
cmmreqmur01r9r5luyaczltkw	cmmqfin3h0011r5ri60yvcljp	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.556	2026-03-15 07:37:21.61
cmmreqmut01rdr5lux0v8znnm	cmmqfin3s001lr5ri9eb3mld8	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.558	2026-03-15 07:37:21.611
cmmreqmuv01rhr5lupcpyrvax	cmmqfin3x001vr5rixugbviaq	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.559	2026-03-15 07:37:21.611
cmmreqmuw01rlr5lukum1o4rt	cmmqfin400020r5ri8p9t0kvk	12	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.561	2026-03-15 07:37:21.611
cmmreqmuy01rpr5luzangg9o9	cmmqfin300007r5ri7hev5ck1	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.563	2026-03-15 07:37:21.612
cmmreqmv001rtr5luyyzyqj45	cmmqfin34000cr5riujl5lkum	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.565	2026-03-15 07:37:21.612
cmmreqmv201rxr5luwac7csew	cmmqfin37000hr5ri6v7crew3	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.567	2026-03-15 07:37:21.613
cmmreqmv401s1r5luvdp87gn0	cmmqfin39000mr5rifitry7zu	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.569	2026-03-15 07:37:21.613
cmmreqms601mlr5luglw2bg3i	cmmqfin3c000rr5riaz9ygvbu	7	2021	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.463	2026-03-15 07:37:21.594
cmmreqmv901s9r5luecrddr6h	cmmqfin3h0011r5ri60yvcljp	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.573	2026-03-15 07:37:21.614
cmmreqmvb01sdr5luskit30dr	cmmqfin3s001lr5ri9eb3mld8	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.575	2026-03-15 07:37:21.614
cmmreqmvd01shr5lumaq1f8yh	cmmqfin3x001vr5rixugbviaq	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.578	2026-03-15 07:37:21.615
cmmreqmvf01slr5lu4hk1i7jz	cmmqfin400020r5ri8p9t0kvk	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.58	2026-03-15 07:37:21.615
cmmreqmvh01spr5lusoodnrfk	cmmqfin300007r5ri7hev5ck1	2	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.582	2026-03-15 07:37:21.616
cmmreqmvk01str5lujz77ma2k	cmmqfin34000cr5riujl5lkum	2	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.584	2026-03-15 07:37:21.616
cmmreqmvm01sxr5lusch6y35a	cmmqfin3f000wr5riqmcfcwsy	2	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.587	2026-03-15 07:37:21.617
cmmreqmvo01t1r5lughlwv2xj	cmmqfin3h0011r5ri60yvcljp	2	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.589	2026-03-15 07:37:21.617
cmmreqmvq01t5r5luhnnc8q3n	cmmqfin3v001qr5rik05d5yuh	2	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.591	2026-03-15 07:37:21.617
cmmreqmvt01t9r5lucahja23z	cmmqfin3x001vr5rixugbviaq	2	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.593	2026-03-15 07:37:21.618
cmmreqmvv01tdr5lucd2jpsjb	cmmqfin400020r5ri8p9t0kvk	2	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.595	2026-03-15 07:37:21.618
cmmreqmvx01thr5lu0wdde90m	cmmqfin300007r5ri7hev5ck1	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.598	2026-03-15 07:37:21.619
cmmreqmvz01tlr5lu6nc486sq	cmmqfin34000cr5riujl5lkum	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.6	2026-03-15 07:37:21.619
cmmreqmw101tpr5lukf949sz9	cmmqfin37000hr5ri6v7crew3	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.602	2026-03-15 07:37:21.62
cmmreqmw301ttr5luykf31xus	cmmqfin39000mr5rifitry7zu	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.604	2026-03-15 07:37:21.62
cmmreqmw501txr5luik02yrdx	cmmqfin3c000rr5riaz9ygvbu	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.606	2026-03-15 07:37:21.62
cmmreqmw801u1r5lu13qr5h09	cmmqfin3f000wr5riqmcfcwsy	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.608	2026-03-15 07:37:21.621
cmmreqmwa01u5r5lu14z7k24b	cmmqfin3h0011r5ri60yvcljp	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.61	2026-03-15 07:37:21.621
cmmreqmwc01u9r5lu48cazra0	cmmqfin3k0016r5ri43nzr1pi	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.612	2026-03-15 07:37:21.621
cmmreqmwe01udr5lukwfuz7xy	cmmqfin3n001br5rinbkhyypl	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.614	2026-03-15 07:37:21.622
cmmreqmwg01uhr5lun0x1wf1i	cmmqfin3s001lr5ri9eb3mld8	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.616	2026-03-15 07:37:21.622
cmmreqmwi01ulr5lumefek3ri	cmmqfin3v001qr5rik05d5yuh	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.619	2026-03-15 07:37:21.623
cmmreqmwk01upr5luplgwuhmw	cmmqfin3x001vr5rixugbviaq	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.621	2026-03-15 07:37:21.623
cmmreqmwm01utr5luieseidfu	cmmqfin400020r5ri8p9t0kvk	3	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.623	2026-03-15 07:37:21.624
cmmreqmwo01uxr5luudkn7vhf	cmmqfin300007r5ri7hev5ck1	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.625	2026-03-15 07:37:21.624
cmmreqmwr01v1r5lu131hr8xe	cmmqfin34000cr5riujl5lkum	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.627	2026-03-15 07:37:21.624
cmmreqmws01v5r5luhmft83ey	cmmqfin37000hr5ri6v7crew3	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.629	2026-03-15 07:37:21.625
cmmreqmwu01v9r5lut8v31y2l	cmmqfin39000mr5rifitry7zu	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.631	2026-03-15 07:37:21.625
cmmreqmww01vdr5lujn5vaa9u	cmmqfin3c000rr5riaz9ygvbu	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.633	2026-03-15 07:37:21.626
cmmreqmwy01vhr5lus6f5tfsv	cmmqfin3f000wr5riqmcfcwsy	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.635	2026-03-15 07:37:21.626
cmmreqmx001vlr5luj5331px3	cmmqfin3h0011r5ri60yvcljp	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.637	2026-03-15 07:37:21.626
cmmreqmx201vpr5lu0ynupti1	cmmqfin3k0016r5ri43nzr1pi	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.639	2026-03-15 07:37:21.627
cmmreqmx501vtr5luh4j099w0	cmmqfin3n001br5rinbkhyypl	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.641	2026-03-15 07:37:21.627
cmmreqmx701vxr5lu0z4oo4qz	cmmqfin3s001lr5ri9eb3mld8	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.644	2026-03-15 07:37:21.628
cmmreqmxa01w1r5luktbgjihk	cmmqfin3v001qr5rik05d5yuh	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.646	2026-03-15 07:37:21.628
cmmreqmxc01w5r5luy54a9yuc	cmmqfin3x001vr5rixugbviaq	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.648	2026-03-15 07:37:21.629
cmmreqmxe01w9r5luzkz0bnz0	cmmqfin400020r5ri8p9t0kvk	4	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.65	2026-03-15 07:37:21.629
cmmreqmxg01wdr5lueud98o0p	cmmqfin300007r5ri7hev5ck1	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.653	2026-03-15 07:37:21.629
cmmreqmxi01whr5lullysfxwi	cmmqfin34000cr5riujl5lkum	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.655	2026-03-15 07:37:21.63
cmmreqmxk01wlr5lujvrqc9v2	cmmqfin37000hr5ri6v7crew3	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.657	2026-03-15 07:37:21.63
cmmreqmxm01wpr5lu8rxgoh6v	cmmqfin39000mr5rifitry7zu	5	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.659	2026-03-15 07:37:21.631
cmmreqmxp01wtr5luke8mxs11	cmmqfin3c000rr5riaz9ygvbu	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.661	2026-03-15 07:37:21.631
cmmreqmxr01wxr5lulqzziqfh	cmmqfin3f000wr5riqmcfcwsy	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.663	2026-03-15 07:37:21.631
cmmreqmxt01x1r5luqndx9u9v	cmmqfin3h0011r5ri60yvcljp	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.665	2026-03-15 07:37:21.632
cmmreqmxv01x5r5lugodlmvg3	cmmqfin3k0016r5ri43nzr1pi	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.667	2026-03-15 07:37:21.632
cmmreqmxx01x9r5lumswc13rp	cmmqfin3n001br5rinbkhyypl	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.669	2026-03-15 07:37:21.633
cmmreqmxz01xdr5lu33q94p61	cmmqfin3s001lr5ri9eb3mld8	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.671	2026-03-15 07:37:21.633
cmmreqmy101xhr5luu6b0mcxj	cmmqfin3v001qr5rik05d5yuh	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.673	2026-03-15 07:37:21.633
cmmreqmy301xlr5luvjta7gt8	cmmqfin3x001vr5rixugbviaq	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.676	2026-03-15 07:37:21.634
cmmreqmv601s5r5luc4gqi5yi	cmmqfin3f000wr5riqmcfcwsy	1	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.571	2026-03-15 07:37:21.614
cmmreqmy801xtr5luznrf6gq4	cmmqfin300007r5ri7hev5ck1	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.68	2026-03-15 07:37:21.635
cmmreqmya01xxr5lujin9p0i3	cmmqfin34000cr5riujl5lkum	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.682	2026-03-15 07:37:21.635
cmmreqmyc01y1r5luvucsrh1o	cmmqfin37000hr5ri6v7crew3	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.684	2026-03-15 07:37:21.636
cmmreqmyf01y5r5lu4ah8046g	cmmqfin39000mr5rifitry7zu	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.687	2026-03-15 07:37:21.636
cmmreqmyh01y9r5luve7oc9tn	cmmqfin3c000rr5riaz9ygvbu	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.69	2026-03-15 07:37:21.636
cmmreqmyj01ydr5lud5da7qz9	cmmqfin3f000wr5riqmcfcwsy	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.692	2026-03-15 07:37:21.637
cmmreqmym01yhr5luxz9t7dzs	cmmqfin3h0011r5ri60yvcljp	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.695	2026-03-15 07:37:21.637
cmmreqmyo01ylr5lut5mx0nww	cmmqfin3k0016r5ri43nzr1pi	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.697	2026-03-15 07:37:21.638
cmmreqmyr01ypr5lug1pq6k91	cmmqfin3n001br5rinbkhyypl	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.699	2026-03-15 07:37:21.638
cmmreqmyt01ytr5luta34wuoq	cmmqfin3s001lr5ri9eb3mld8	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.701	2026-03-15 07:37:21.638
cmmreqmyv01yxr5lur7y3s6dd	cmmqfin3v001qr5rik05d5yuh	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.703	2026-03-15 07:37:21.639
cmmreqmyx01z1r5luaio585x8	cmmqfin3x001vr5rixugbviaq	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.705	2026-03-15 07:37:21.639
cmmreqmyz01z5r5luf0cviscc	cmmqfin400020r5ri8p9t0kvk	6	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.707	2026-03-15 07:37:21.64
cmmreqmz001z9r5lun4vtvxam	cmmqfin2s0002r5rig5gyl78u	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.709	2026-03-15 07:37:21.64
cmmreqmz301zdr5luy00ch842	cmmqfin300007r5ri7hev5ck1	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.711	2026-03-15 07:37:21.641
cmmreqmz501zhr5lun6ay3vpu	cmmqfin37000hr5ri6v7crew3	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.713	2026-03-15 07:37:21.641
cmmreqmz601zlr5lukspwpplv	cmmqfin3c000rr5riaz9ygvbu	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.715	2026-03-15 07:37:21.641
cmmreqmz901zpr5lurhr2wtlg	cmmqfin3f000wr5riqmcfcwsy	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.717	2026-03-15 07:37:21.642
cmmreqmzb01ztr5lurpsu3bep	cmmqfin3h0011r5ri60yvcljp	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.72	2026-03-15 07:37:21.642
cmmreqmzd01zxr5lumbci09ak	cmmqfin3k0016r5ri43nzr1pi	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.722	2026-03-15 07:37:21.643
cmmreqmzf0201r5lutwhxnih3	cmmqfin3n001br5rinbkhyypl	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.724	2026-03-15 07:37:21.643
cmmreqmzh0205r5luzk9j8bu1	cmmqfin3s001lr5ri9eb3mld8	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.726	2026-03-15 07:37:21.643
cmmreqmzj0209r5lu49n9c3ae	cmmqfin3v001qr5rik05d5yuh	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.728	2026-03-15 07:37:21.644
cmmreqmzl020dr5luevz5h7p1	cmmqfin3x001vr5rixugbviaq	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.73	2026-03-15 07:37:21.644
cmmreqmzn020hr5lun3sypkct	cmmqfin400020r5ri8p9t0kvk	7	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.731	2026-03-15 07:37:21.644
cmmreqmzp020lr5lu911rwyum	cmmqfin2s0002r5rig5gyl78u	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.734	2026-03-15 07:37:21.645
cmmreqmzr020pr5lun30i3j9u	cmmqfin300007r5ri7hev5ck1	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.736	2026-03-15 07:37:21.645
cmmreqmzt020tr5lun3lsar8a	cmmqfin37000hr5ri6v7crew3	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.737	2026-03-15 07:37:21.646
cmmreqmzv020xr5lu42wdqlms	cmmqfin39000mr5rifitry7zu	8	2022	2000	0	0	2000	3790	PAID	2026-03-15 07:02:45.739	2026-03-15 07:37:21.646
cmmreqmzx0211r5luxr6380fk	cmmqfin3c000rr5riaz9ygvbu	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.741	2026-03-15 07:37:21.647
cmmreqmzz0215r5ludwbb37tm	cmmqfin3f000wr5riqmcfcwsy	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.743	2026-03-15 07:37:21.647
cmmreqn010219r5lu9ahrtm9u	cmmqfin3h0011r5ri60yvcljp	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.745	2026-03-15 07:37:21.648
cmmreqn04021dr5lu9jzsijgx	cmmqfin3k0016r5ri43nzr1pi	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.748	2026-03-15 07:37:21.648
cmmreqn06021hr5luyt23z0yx	cmmqfin3n001br5rinbkhyypl	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.751	2026-03-15 07:37:21.648
cmmreqn08021lr5luzdqbm1gj	cmmqfin3s001lr5ri9eb3mld8	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.753	2026-03-15 07:37:21.649
cmmreqn0b021pr5luanmf975n	cmmqfin3v001qr5rik05d5yuh	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.755	2026-03-15 07:37:21.649
cmmreqn0d021tr5lumg00iijh	cmmqfin3x001vr5rixugbviaq	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.757	2026-03-15 07:37:21.649
cmmreqn0f021xr5lu59w07tqe	cmmqfin400020r5ri8p9t0kvk	8	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.759	2026-03-15 07:37:21.65
cmmreqn0h0221r5luwytetk9a	cmmqfin2s0002r5rig5gyl78u	10	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.761	2026-03-15 07:37:21.65
cmmreqn0j0225r5lu2edmh2ek	cmmqfin3h0011r5ri60yvcljp	10	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.763	2026-03-15 07:37:21.65
cmmreqn0l0229r5luonspgldi	cmmqfin3n001br5rinbkhyypl	10	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.765	2026-03-15 07:37:21.651
cmmreqn0n022dr5luqkkwwfga	cmmqfin3s001lr5ri9eb3mld8	10	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.767	2026-03-15 07:37:21.651
cmmreqn0p022hr5lu3rbcurvd	cmmqfin3x001vr5rixugbviaq	10	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.769	2026-03-15 07:37:21.651
cmmreqn0r022lr5luyoy76f2i	cmmqfin2s0002r5rig5gyl78u	11	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.771	2026-03-15 07:37:21.651
cmmreqn0t022pr5lu3fa874ii	cmmqfin300007r5ri7hev5ck1	11	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.773	2026-03-15 07:37:21.652
cmmreqn0v022tr5lu90fk3llk	cmmqfin37000hr5ri6v7crew3	11	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.775	2026-03-15 07:37:21.652
cmmreqn0x022xr5lu7tajv2c6	cmmqfin3c000rr5riaz9ygvbu	11	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.777	2026-03-15 07:37:21.653
cmmreqn0y0231r5lu11kemksh	cmmqfin3f000wr5riqmcfcwsy	11	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.779	2026-03-15 07:37:21.653
cmmreqn100235r5lucnwx4669	cmmqfin3h0011r5ri60yvcljp	11	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.781	2026-03-15 07:37:21.653
cmmreqmy501xpr5luz1nsw0np	cmmqfin400020r5ri8p9t0kvk	5	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.678	2026-03-15 07:37:21.634
cmmreqn15023dr5luq3felfvd	cmmqfin3n001br5rinbkhyypl	11	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.785	2026-03-15 07:37:21.654
cmmreqn16023hr5luqtltdgk1	cmmqfin3s001lr5ri9eb3mld8	11	2022	2000	0	0	2000	3789	PAID	2026-03-15 07:02:45.787	2026-03-15 07:37:21.654
cmmreqn18023lr5lux2yth2yn	cmmqfin3v001qr5rik05d5yuh	11	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.789	2026-03-15 07:37:21.654
cmmreqn1b023pr5luouc53b65	cmmqfin3x001vr5rixugbviaq	11	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.791	2026-03-15 07:37:21.655
cmmreqn1d023tr5luekhcqbi9	cmmqfin400020r5ri8p9t0kvk	11	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.793	2026-03-15 07:37:21.655
cmmreqn1f023xr5luh9u9c3ty	cmmqfin2s0002r5rig5gyl78u	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.795	2026-03-15 07:37:21.655
cmmreqn1h0241r5luu9i3lkxg	cmmqfin300007r5ri7hev5ck1	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.797	2026-03-15 07:37:21.656
cmmreqn1j0245r5lufjcaf86x	cmmqfin34000cr5riujl5lkum	12	2022	2000	0	0	2000	5100	PAID	2026-03-15 07:02:45.799	2026-03-15 07:37:21.656
cmmreqn1l0249r5lu0uzcotcy	cmmqfin39000mr5rifitry7zu	12	2022	2000	0	0	2000	5269	PAID	2026-03-15 07:02:45.802	2026-03-15 07:37:21.657
cmmreqn1n024dr5luqeke1vg5	cmmqfin3c000rr5riaz9ygvbu	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.804	2026-03-15 07:37:21.657
cmmreqn1p024hr5ludyr8b5a2	cmmqfin3h0011r5ri60yvcljp	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.806	2026-03-15 07:37:21.658
cmmreqn1r024lr5lutpewqgft	cmmqfin3k0016r5ri43nzr1pi	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.808	2026-03-15 07:37:21.658
cmmreqn1t024pr5lu573nr4bn	cmmqfin3n001br5rinbkhyypl	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.809	2026-03-15 07:37:21.658
cmmreqn1v024tr5luzwrw94nu	cmmqfin3s001lr5ri9eb3mld8	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.811	2026-03-15 07:37:21.659
cmmreqn1w024xr5lumooq40ur	cmmqfin3x001vr5rixugbviaq	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.813	2026-03-15 07:37:21.659
cmmreqn1y0251r5luuabwcvsn	cmmqfin400020r5ri8p9t0kvk	12	2022	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.815	2026-03-15 07:37:21.659
cmmreqn200255r5ludl6rcdks	cmmqfin2s0002r5rig5gyl78u	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.816	2026-03-15 07:37:21.66
cmmreqn220259r5lu04u0hrzc	cmmqfin34000cr5riujl5lkum	1	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.818	2026-03-15 07:37:21.66
cmmreqn24025dr5lu3dsr2wpn	cmmqfin3c000rr5riaz9ygvbu	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.82	2026-03-15 07:37:21.66
cmmreqn25025hr5lu9wfki9dt	cmmqfin3f000wr5riqmcfcwsy	1	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.822	2026-03-15 07:37:21.661
cmmreqn27025lr5lum1ru85i9	cmmqfin3h0011r5ri60yvcljp	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.824	2026-03-15 07:37:21.661
cmmreqn29025pr5luz1mer9z3	cmmqfin3k0016r5ri43nzr1pi	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.825	2026-03-15 07:37:21.661
cmmreqn2b025tr5luvyvcwrvu	cmmqfin3n001br5rinbkhyypl	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.827	2026-03-15 07:37:21.661
cmmreqn2c025xr5luqz69pivn	cmmqfin3s001lr5ri9eb3mld8	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.829	2026-03-15 07:37:21.662
cmmreqn2e0261r5lunx0uaahh	cmmqfin3x001vr5rixugbviaq	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.831	2026-03-15 07:37:21.662
cmmreqn2g0265r5lu2nuv040y	cmmqfin400020r5ri8p9t0kvk	1	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.832	2026-03-15 07:37:21.663
cmmreqn2i0269r5luceovmd2h	cmmqfin2s0002r5rig5gyl78u	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.834	2026-03-15 07:37:21.663
cmmreqn2j026dr5lugrmnxob7	cmmqfin300007r5ri7hev5ck1	2	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.836	2026-03-15 07:37:21.663
cmmreqn2l026hr5luroar70tz	cmmqfin34000cr5riujl5lkum	2	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.838	2026-03-15 07:37:21.664
cmmreqn2n026lr5luap1mlhrs	cmmqfin37000hr5ri6v7crew3	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.839	2026-03-15 07:37:21.664
cmmreqn2p026pr5lu8ydu1cxr	cmmqfin39000mr5rifitry7zu	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.841	2026-03-15 07:37:21.664
cmmreqn2q026tr5lunw4gocao	cmmqfin3c000rr5riaz9ygvbu	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.843	2026-03-15 07:37:21.665
cmmreqn2s026xr5lux4ub1qs6	cmmqfin3h0011r5ri60yvcljp	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.845	2026-03-15 07:37:21.665
cmmreqn2u0271r5lu0ijemerk	cmmqfin3k0016r5ri43nzr1pi	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.847	2026-03-15 07:37:21.665
cmmreqn2w0275r5lur8ufzv0n	cmmqfin3s001lr5ri9eb3mld8	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.849	2026-03-15 07:37:21.666
cmmreqn2y0279r5luetp1jt7e	cmmqfin3x001vr5rixugbviaq	2	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.851	2026-03-15 07:37:21.666
cmmreqn30027dr5luokknnqu8	cmmqfin2s0002r5rig5gyl78u	3	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.852	2026-03-15 07:37:21.666
cmmreqn31027hr5lup2qk63nw	cmmqfin300007r5ri7hev5ck1	3	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.854	2026-03-15 07:37:21.667
cmmreqn33027lr5luqykly4bw	cmmqfin37000hr5ri6v7crew3	3	2023	2000	0	0	2000	5100	PAID	2026-03-15 07:02:45.855	2026-03-15 07:37:21.667
cmmreqn35027pr5lunisyst9l	cmmqfin39000mr5rifitry7zu	3	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.858	2026-03-15 07:37:21.668
cmmreqn37027tr5luh3e6mup2	cmmqfin3c000rr5riaz9ygvbu	3	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.859	2026-03-15 07:37:21.668
cmmreqn39027xr5lulq4hnbfb	cmmqfin3f000wr5riqmcfcwsy	3	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.861	2026-03-15 07:37:21.668
cmmreqn3a0281r5lu48bchumg	cmmqfin3h0011r5ri60yvcljp	3	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.863	2026-03-15 07:37:21.669
cmmreqn3c0285r5lutreiikhu	cmmqfin3k0016r5ri43nzr1pi	3	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.865	2026-03-15 07:37:21.669
cmmreqn3e0289r5lue2a7m5r4	cmmqfin3n001br5rinbkhyypl	3	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.866	2026-03-15 07:37:21.669
cmmreqn3g028dr5lu93zis8k4	cmmqfin3s001lr5ri9eb3mld8	3	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.868	2026-03-15 07:37:21.67
cmmreqn3h028hr5luid4qt9w0	cmmqfin3x001vr5rixugbviaq	3	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.87	2026-03-15 07:37:21.67
cmmreqn3j028lr5luqxcqtnf1	cmmqfin400020r5ri8p9t0kvk	3	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.871	2026-03-15 07:37:21.67
cmmreqn3l028pr5lua3vmzoy9	cmmqfin2s0002r5rig5gyl78u	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.873	2026-03-15 07:37:21.671
cmmreqn120239r5luptdb3yyq	cmmqfin3k0016r5ri43nzr1pi	11	2022	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.783	2026-03-15 07:37:21.654
cmmreqn3t0299r5luq4uoikmq	cmmqfin3h0011r5ri60yvcljp	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.882	2026-03-15 07:37:21.673
cmmreqn3v029dr5lu7rrxfusw	cmmqfin3k0016r5ri43nzr1pi	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.883	2026-03-15 07:37:21.673
cmmreqn3w029hr5lu4yt3g93o	cmmqfin3n001br5rinbkhyypl	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.885	2026-03-15 07:37:21.674
cmmreqn3y029lr5lurlt2itdg	cmmqfin3s001lr5ri9eb3mld8	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.887	2026-03-15 07:37:21.674
cmmreqn44029xr5luq9k8dhnx	cmmqfin400020r5ri8p9t0kvk	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.892	2026-03-15 07:37:21.675
cmmreqn4k02alr5luq0d10yga	cmmqfin2s0002r5rig5gyl78u	6	2023	2000	0	0	2000	1150	PARTIAL	2026-03-15 07:02:45.908	2026-03-15 07:37:21.676
cmmreqn4m02apr5lu5hp0twtz	cmmqfin300007r5ri7hev5ck1	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.91	2026-03-15 07:37:21.676
cmmreqn4n02atr5lud12dsaz4	cmmqfin37000hr5ri6v7crew3	6	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.912	2026-03-15 07:37:21.677
cmmreqn4p02axr5lucc962n36	cmmqfin39000mr5rifitry7zu	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.914	2026-03-15 07:37:21.677
cmmreqn4r02b1r5ludqe7aly6	cmmqfin3c000rr5riaz9ygvbu	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.915	2026-03-15 07:37:21.677
cmmreqn4t02b5r5luepmo9p6i	cmmqfin3f000wr5riqmcfcwsy	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.917	2026-03-15 07:37:21.678
cmmreqn4u02b9r5lu8twwfozp	cmmqfin3h0011r5ri60yvcljp	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.919	2026-03-15 07:37:21.678
cmmreqn4w02bdr5luqrndy5j4	cmmqfin3k0016r5ri43nzr1pi	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.92	2026-03-15 07:37:21.679
cmmreqn4y02bhr5luofb0sv8d	cmmqfin3s001lr5ri9eb3mld8	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.923	2026-03-15 07:37:21.679
cmmreqn5002blr5lu1lf9r1fy	cmmqfin3v001qr5rik05d5yuh	6	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.925	2026-03-15 07:37:21.679
cmmreqn5202bpr5lummwd0e3i	cmmqfin3x001vr5rixugbviaq	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.927	2026-03-15 07:37:21.68
cmmreqn5402btr5lup6xq2lv4	cmmqfin400020r5ri8p9t0kvk	6	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.928	2026-03-15 07:37:21.68
cmmreqn6w02ebr5lu3vw2zqn9	cmmqfin2s0002r5rig5gyl78u	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.993	2026-03-15 07:37:21.681
cmmreqn6y02efr5luxofscbkb	cmmqfin37000hr5ri6v7crew3	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.994	2026-03-15 07:37:21.681
cmmreqn6z02ejr5lu79korkn2	cmmqfin39000mr5rifitry7zu	10	2023	2000	0	0	2000	5138	PAID	2026-03-15 07:02:45.996	2026-03-15 07:37:21.681
cmmreqn7102enr5ludsgdqu0i	cmmqfin3c000rr5riaz9ygvbu	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.998	2026-03-15 07:37:21.682
cmmreqn7402err5luk4mqecpr	cmmqfin3f000wr5riqmcfcwsy	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:46	2026-03-15 07:37:21.682
cmmreqn7602evr5lumjl6haz0	cmmqfin3h0011r5ri60yvcljp	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:46.002	2026-03-15 07:37:21.683
cmmreqn7802ezr5luqjpx7aj3	cmmqfin3s001lr5ri9eb3mld8	10	2023	2000	0	0	2000	2500	PAID	2026-03-15 07:02:46.004	2026-03-15 07:37:21.683
cmmreqn7902f3r5luu1oywk5y	cmmqfin3v001qr5rik05d5yuh	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:46.006	2026-03-15 07:37:21.683
cmmreqn7b02f7r5lufv7log16	cmmqfin3x001vr5rixugbviaq	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:46.008	2026-03-15 07:37:21.684
cmmreqn7d02fbr5lumccjf5gm	cmmqfin400020r5ri8p9t0kvk	10	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:46.009	2026-03-15 07:37:21.684
cmmreqmhh00nrr5luohthtug5	cmmqfin3n001br5rinbkhyypl	5	2023	1700	0	101	1801	1700	PARTIAL	2026-03-15 07:02:45.077	2026-03-15 07:37:21.685
cmmreqmhu00pbr5lut2o9yy91	cmmqfin3h0011r5ri60yvcljp	7	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.091	2026-03-15 07:37:21.685
cmmreqmi300qnr5luikhnrxqe	cmmqfin300007r5ri7hev5ck1	9	2023	1700	0	0	1700	1700	PAID	2026-03-15 07:02:45.1	2026-03-15 07:37:21.686
cmmreqmib00rrr5lu7ziosooa	cmmqfin3f000wr5riqmcfcwsy	12	2023	1700	0	0	1700	3400	PAID	2026-03-15 07:02:45.108	2026-03-15 07:37:21.686
cmmreqmio00tjr5luf29sgghp	cmmqfin3k0016r5ri43nzr1pi	2	2024	2000	2555	0	4555	1700	PARTIAL	2026-03-15 07:02:45.12	2026-03-15 07:37:21.686
cmmreqmiw00unr5lujar92ufk	cmmqfin3x001vr5rixugbviaq	3	2024	2000	908	0	2908	2000	PARTIAL	2026-03-15 07:02:45.128	2026-03-15 07:37:21.687
cmmreqmj900wfr5luk3ybss0c	cmmqfin2s0002r5rig5gyl78u	6	2024	2000	998	0	2998	2000	PARTIAL	2026-03-15 07:02:45.142	2026-03-15 07:37:21.687
cmmreqmjf00xbr5lug7fjbgpf	cmmqfin300007r5ri7hev5ck1	7	2024	2000	1077	0	3077	2000	PARTIAL	2026-03-15 07:02:45.147	2026-03-15 07:37:21.687
cmmreqn3n028tr5lurxq3ohr6	cmmqfin300007r5ri7hev5ck1	4	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.875	2026-03-15 07:37:21.671
cmmreqn3o028xr5lu31yilk5r	cmmqfin34000cr5riujl5lkum	4	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.877	2026-03-15 07:37:21.672
cmmreqn3q0291r5luxpai6bs6	cmmqfin3c000rr5riaz9ygvbu	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.878	2026-03-15 07:37:21.672
cmmreqn3r0295r5lursu2kgnz	cmmqfin3f000wr5riqmcfcwsy	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.88	2026-03-15 07:37:21.672
cmmreqn40029pr5lu1gracp09	cmmqfin3v001qr5rik05d5yuh	4	2023	2000	0	0	2000	3400	PAID	2026-03-15 07:02:45.888	2026-03-15 07:37:21.675
cmmreqn42029tr5lu6jcgzei1	cmmqfin3x001vr5rixugbviaq	4	2023	2000	0	0	2000	1700	PARTIAL	2026-03-15 07:02:45.89	2026-03-15 07:37:21.675
cmmreqmjt00zbr5lum4ne2lvw	cmmqfin3h0011r5ri60yvcljp	9	2024	2000	0	-2463	-463	2000	PAID	2026-03-15 07:02:45.161	2026-03-15 07:37:21.688
cmmreqmjz0109r5lu28k9ge3j	cmmqfin3n001br5rinbkhyypl	10	2024	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.168	2026-03-15 07:37:21.688
cmmreqmkj0133r5lu99kkkp7j	cmmqfin2s0002r5rig5gyl78u	2	2025	2000	1081	0	3081	2000	PARTIAL	2026-03-15 07:02:45.187	2026-03-15 07:37:21.688
cmmreqmla0153r5lutsv8knef	cmmqfin3c000rr5riaz9ygvbu	4	2025	2000	1501	0	3501	2000	PARTIAL	2026-03-15 07:02:45.214	2026-03-15 07:37:21.689
cmmreqmln0167r5luiphgl6gq	cmmqfin3q001gr5riuek21iw1	5	2025	2000	949	0	2949	2000	PARTIAL	2026-03-15 07:02:45.228	2026-03-15 07:37:21.689
cmmreqmm3017zr5lutwb4j9hh	cmmqfin3v001qr5rik05d5yuh	7	2025	2000	925	0	2925	4000	PAID	2026-03-15 07:02:45.243	2026-03-15 07:37:21.69
cmmreqmma018xr5lu2yrlqyvd	cmmqfin400020r5ri8p9t0kvk	8	2025	2000	0	0	2000	2000	PAID	2026-03-15 07:02:45.25	2026-03-15 07:37:21.69
cmmreqmmu01b9r5lu457x7n62	cmmqfin3s001lr5ri9eb3mld8	11	2025	2000	0	0	2000	4000	PAID	2026-03-15 07:02:45.27	2026-03-15 07:37:21.691
\.


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Payment" (id, "billId", amount, "paymentDate", "paymentMethod", "transactionRef", notes) FROM stdin;
cmmsrbt0w0001r5l8o8p3lbym	cmmrdgxyx000hr5c3tfvpgj2y	7603	2026-02-28 00:00:00	CASH	\N	\N
cmmrfz45r00sdr5kkii31yxys	cmmreqmnl01etr5luioe0jvzi	3400	2026-03-15 07:37:20.848	CASH	\N	\N
cmmrfz45t00sfr5kksjpkdaqp	cmmreqmnr01exr5lunqkgtfsv	1700	2026-03-15 07:37:20.849	CASH	\N	\N
cmmrfz45u00shr5kkhokv5kn9	cmmreqmnt01f1r5lue5zkzppv	1700	2026-03-15 07:37:20.85	CASH	\N	\N
cmmrfz45u00sjr5kk8ugxh1mj	cmmreqmnv01f5r5luf51e2qsh	1700	2026-03-15 07:37:20.851	CASH	\N	\N
cmmrfz45v00slr5kkltp11zoy	cmmreqmnx01f9r5lukoc2xfba	1700	2026-03-15 07:37:20.851	CASH	\N	\N
cmmrfz45w00snr5kkiqrabm90	cmmreqmnz01fdr5lujm6d5ip9	1700	2026-03-15 07:37:20.852	CASH	\N	\N
cmmrfz45w00spr5kk5inmqqqt	cmmreqmo201fhr5lu12kxv5eo	1700	2026-03-15 07:37:20.853	CASH	\N	\N
cmmrfz45x00srr5kk4rl9nbfc	cmmreqmo401flr5luninp26yt	3400	2026-03-15 07:37:20.854	CASH	\N	\N
cmmrfz45y00str5kkwgm3uapo	cmmreqmo601fpr5lu014yih7u	1700	2026-03-15 07:37:20.854	CASH	\N	\N
cmmrfz45y00svr5kk2s7ckel7	cmmreqmo801ftr5lu6qqp0h2p	1700	2026-03-15 07:37:20.855	CASH	\N	Pending 1700 (December)
cmmrfz45z00sxr5kkjbba79qm	cmmreqmoa01fxr5lug56voabo	5100	2026-03-15 07:37:20.856	CASH	\N	\N
cmmrfz46000szr5kkdrl6cqvf	cmmreqmob01g1r5luq7uhqwkl	1700	2026-03-15 07:37:20.856	CASH	\N	\N
cmmrfz46000t1r5kk6qylumuq	cmmreqmod01g5r5lumpqeb7e4	1700	2026-03-15 07:37:20.857	CASH	\N	\N
cmmrfz46200t3r5kkj0fto70v	cmmreqmof01g9r5lukca1d876	1700	2026-03-15 07:37:20.859	CASH	\N	\N
cmmrfz46300t5r5kkxs2yhoeb	cmmreqmog01gdr5lu5ar5t2a5	1700	2026-03-15 07:37:20.859	CASH	\N	\N
cmmrfz46400t7r5kkl5qojjag	cmmreqmoi01ghr5luof34seie	1700	2026-03-15 07:37:20.86	CASH	\N	\N
cmmrfz46400t9r5kkqai5myx3	cmmreqmoj01glr5lu4esk22c8	1700	2026-03-15 07:37:20.861	CASH	\N	Paid to sameer account
cmmrfz46500tbr5kk9hzipc9h	cmmreqmol01gpr5lut67zr1a9	1700	2026-03-15 07:37:20.862	CASH	\N	Paid to sameer account
cmmrfz46600tdr5kk4tq1ebew	cmmreqmoo01gtr5lu9jpwejm5	1700	2026-03-15 07:37:20.862	CASH	\N	\N
cmmrfz46700tfr5kkj2kel4a9	cmmreqmoq01gxr5lum9pqoknx	1700	2026-03-15 07:37:20.863	CASH	\N	\N
cmmrfz46700thr5kkqynglbjy	cmmreqmos01h1r5lu8jx4ozkw	1700	2026-03-15 07:37:20.864	CASH	\N	\N
cmmrfz46800tjr5kkecugyur2	cmmreqmou01h5r5luhuwupkjk	1700	2026-03-15 07:37:20.864	CASH	\N	\N
cmmrfz46800tlr5kk1gttvgpl	cmmreqmov01h9r5lunp7d605e	1700	2026-03-15 07:37:20.865	CASH	\N	\N
cmmrfz46900tnr5kkpxsguomj	cmmreqmox01hdr5luyvy08njl	1700	2026-03-15 07:37:20.865	CASH	\N	\N
cmmrfz46900tpr5kkijo3kyg4	cmmreqmoz01hhr5lu4ixx0msd	1700	2026-03-15 07:37:20.866	CASH	\N	\N
cmmrfz46a00trr5kkrfre9ij2	cmmreqmp101hlr5lu1mzj7wsz	1700	2026-03-15 07:37:20.866	CASH	\N	Cash
cmmrfz46a00ttr5kk9czpt038	cmmreqmp301hpr5luv0q9lsf0	1700	2026-03-15 07:37:20.867	CASH	\N	Cash
cmmrfz46b00tvr5kk7ekti2ih	cmmreqmp501htr5luwkt301ni	1700	2026-03-15 07:37:20.867	CASH	\N	\N
cmmrfz46b00txr5kkwkoaw5ql	cmmreqmp701hxr5lu54bqgpw1	1700	2026-03-15 07:37:20.868	CASH	\N	\N
cmmrfz46c00tzr5kkcneunxrz	cmmreqmp901i1r5luvek4i1t3	1700	2026-03-15 07:37:20.868	CASH	\N	\N
cmmrfz46d00u1r5kk923rvy4b	cmmreqmpb01i5r5luejx675x0	3400	2026-03-15 07:37:20.869	CASH	\N	pending 5100
cmmrfz46d00u3r5kkmxktqayt	cmmreqmpe01i9r5luofw2i728	3400	2026-03-15 07:37:20.869	CASH	\N	\N
cmmrfz46e00u5r5kkfwwqssfl	cmmreqmpg01idr5luuj84b7pw	1700	2026-03-15 07:37:20.87	CASH	\N	\N
cmmrfz46e00u7r5kkgyjhz2ra	cmmreqmpi01ihr5lub0w32wx9	1700	2026-03-15 07:37:20.871	CASH	\N	\N
cmmrfz46f00u9r5kkx0fqic29	cmmreqmpk01ilr5lukwd8wc3t	1700	2026-03-15 07:37:20.871	CASH	\N	\N
cmmrfz46f00ubr5kkyfsl5bpz	cmmreqmpm01ipr5luh9ucsc61	1700	2026-03-15 07:37:20.872	CASH	\N	\N
cmmrfz46g00udr5kk0gmby2v7	cmmreqmpo01itr5luvvmo2q54	1700	2026-03-15 07:37:20.872	CASH	\N	\N
cmmrfz46g00ufr5kkcg9540dg	cmmreqmpq01ixr5lu0d7oqgtx	1700	2026-03-15 07:37:20.873	CASH	\N	\N
cmmrfz46h00uhr5kkm5ihmgtv	cmmreqmps01j1r5luihpci5v2	1700	2026-03-15 07:37:20.873	CASH	\N	\N
cmmrfz46h00ujr5kk5vy56b6c	cmmreqmpu01j5r5lui2qjt6y7	1700	2026-03-15 07:37:20.874	CASH	\N	\N
cmmrfz46i00ulr5kkmglll12k	cmmreqmpw01j9r5luuanun87a	1700	2026-03-15 07:37:20.874	CASH	\N	\N
cmmrfz46i00unr5kklftz48fn	cmmreqmpz01jdr5lup073r6f7	1700	2026-03-15 07:37:20.875	CASH	\N	\N
cmmrfz46j00upr5kk8pr7tmcj	cmmreqmq101jhr5lumx8r8852	1700	2026-03-15 07:37:20.875	CASH	\N	816.0
cmmrfz46k00urr5kkqek2cxxw	cmmreqmh600mjr5luxuhoitfc	1700	2026-03-15 07:37:20.876	CASH	\N	360.0
cmmrfz46k00utr5kkbe02pfgo	cmmreqmh800mlr5lud4i5dlnw	1700	2026-03-15 07:37:20.877	CASH	\N	540.0
cmmrfz46l00uvr5kkz1f6svf6	cmmreqmh800mnr5luetyz7fgb	1700	2026-03-15 07:37:20.877	CASH	\N	376.0
cmmrfz46l00uxr5kkg8bx5gcu	cmmreqmh900mpr5luxieirs7d	1700	2026-03-15 07:37:20.878	CASH	\N	562.0
cmmrfz46m00uzr5kksy3zg0ie	cmmreqmh900mrr5luxyrijh32	1700	2026-03-15 07:37:20.878	CASH	\N	869.0
cmmrfz46m00v1r5kkvpoixybz	cmmreqmha00mtr5lujfdxdoh8	1700	2026-03-15 07:37:20.879	CASH	\N	288.0
cmmrfz46n00v3r5kkqzpf97qa	cmmreqmha00mvr5luy38ch1po	1700	2026-03-15 07:37:20.879	CASH	\N	989.0
cmmrfz46n00v5r5kk71m1zlgh	cmmreqmhb00mxr5lub0vp7l2y	1700	2026-03-15 07:37:20.88	CASH	\N	953.0
cmmrfz46o00v7r5kknurxvbjk	cmmreqmhb00mzr5luhe3uclcr	1700	2026-03-15 07:37:20.88	CASH	\N	954.0
cmmrfz46o00v9r5kkwudww8ys	cmmreqmqh01k3r5luxsrq9oo3	1700	2026-03-15 07:37:20.881	CASH	\N	490.0
cmmrfz46p00vbr5kked6v4cmf	cmmreqmhb00n1r5luitqiax0c	1700	2026-03-15 07:37:20.881	CASH	\N	226.0
cmmrfz46p00vdr5kknh5jkwi9	cmmreqmhc00n3r5lu8mcilngb	1700	2026-03-15 07:37:20.882	CASH	\N	\N
cmmrfz46q00vfr5kkggu6o2bi	cmmreqmhc00n5r5luik0e2u66	1700	2026-03-15 07:37:20.882	CASH	\N	567.0
cmmrfz46q00vhr5kk84my9l6z	cmmreqmhd00n7r5luz4ang63p	1700	2026-03-15 07:37:20.883	CASH	\N	362.0
cmmrfz46r00vjr5kkk5vp3dx6	cmmreqmh600mjr5luxuhoitfc	3760	2026-03-15 07:37:20.883	CASH	\N	\N
cmmrfz46r00vlr5kky0cpxdmy	cmmreqmh800mlr5lud4i5dlnw	2240	2026-03-15 07:37:20.884	CASH	\N	\N
cmmrfz46s00vnr5kk3yxj8lg8	cmmreqmh800mnr5luetyz7fgb	2076	2026-03-15 07:37:20.884	CASH	\N	\N
cmmrfz46s00vpr5kkw5dfglyk	cmmreqmh900mpr5luxieirs7d	2262	2026-03-15 07:37:20.885	CASH	\N	\N
cmmrfz46t00vrr5kk9qjewsf6	cmmreqmh900mrr5luxyrijh32	2569	2026-03-15 07:37:20.885	CASH	\N	\N
cmmrfz46t00vtr5kkanyk7esi	cmmreqmha00mtr5lujfdxdoh8	1988	2026-03-15 07:37:20.886	CASH	\N	\N
cmmrfz46u00vvr5kkcrcgy5co	cmmreqmha00mvr5luy38ch1po	2689	2026-03-15 07:37:20.886	CASH	\N	\N
cmmrfz46u00vxr5kkzzbubaqb	cmmreqmhb00mxr5lub0vp7l2y	2653	2026-03-15 07:37:20.887	CASH	\N	\N
cmmrfz46v00vzr5kkhlr9l5vh	cmmreqmhb00mzr5luhe3uclcr	2654	2026-03-15 07:37:20.887	CASH	\N	\N
cmmrfz46v00w1r5kko2m6xywr	cmmreqmhb00n1r5luitqiax0c	1700	2026-03-15 07:37:20.888	CASH	\N	\N
cmmrfz46w00w3r5kkhy5d3sx8	cmmreqmhc00n3r5lu8mcilngb	1700	2026-03-15 07:37:20.888	CASH	\N	\N
cmmrfz46w00w5r5kkcjg42jz8	cmmreqmhc00n5r5luik0e2u66	2267	2026-03-15 07:37:20.889	CASH	\N	\N
cmmrfz46x00w7r5kkv5xl0ao5	cmmreqmhd00n7r5luz4ang63p	5462	2026-03-15 07:37:20.889	CASH	\N	pending 3400
cmmrfz46x00w9r5kkeqstpxri	cmmreqmra01l1r5lubciey20q	1700	2026-03-15 07:37:20.89	CASH	\N	\N
cmmrfz46y00wbr5kkjv3ogcsa	cmmreqmrc01l5r5lua6nv43zi	1700	2026-03-15 07:37:20.89	CASH	\N	\N
cmmrfz46z00wdr5kkq5qwc7c5	cmmreqmrf01l9r5lu0y9brqa5	1700	2026-03-15 07:37:20.891	CASH	\N	\N
cmmrfz46z00wfr5kk33ntnuum	cmmreqmrh01ldr5luqaj05d69	1700	2026-03-15 07:37:20.892	CASH	\N	\N
cmmrfz47000whr5kkhmandho2	cmmreqmrj01lhr5luxn387xbj	1700	2026-03-15 07:37:20.892	CASH	\N	\N
cmmrfz47100wjr5kkpy3ap7rq	cmmreqmrl01llr5luab3ewntt	1700	2026-03-15 07:37:20.893	CASH	\N	\N
cmmrfz47100wlr5kkhdmcyfak	cmmreqmrp01lpr5lufd276hn7	1700	2026-03-15 07:37:20.894	CASH	\N	\N
cmmrfz47200wnr5kk7jf46w1i	cmmreqmrr01ltr5luxwxpcajw	1700	2026-03-15 07:37:20.894	CASH	\N	\N
cmmrfz47200wpr5kkptu2v0eu	cmmreqmrt01lxr5luzxfxc0a7	1700	2026-03-15 07:37:20.895	CASH	\N	Pending 226 water bill
cmmrfz47300wrr5kkj3p2l91s	cmmreqmrv01m1r5luftdl55wy	1700	2026-03-15 07:37:20.895	CASH	\N	\N
cmmrfz47300wtr5kkg98diq2i	cmmreqmrz01m5r5lusch0caf8	1700	2026-03-15 07:37:20.896	CASH	\N	\N
cmmrfz47400wvr5kk88vwj02a	cmmreqms101m9r5lu9ldeqcvy	1700	2026-03-15 07:37:20.896	CASH	\N	\N
cmmrfz47400wxr5kk1l4uzmky	cmmreqms301mdr5lueopgk6dj	1700	2026-03-15 07:37:20.897	CASH	\N	\N
cmmrfz47500wzr5kk9yxbo12b	cmmreqms501mhr5lu0nqul44l	1700	2026-03-15 07:37:20.898	CASH	\N	\N
cmmrfz47600x1r5kkvjmfuewm	cmmreqms601mlr5luglw2bg3i	1700	2026-03-15 07:37:20.898	CASH	\N	\N
cmmrfz47700x3r5kkvcyi6v75	cmmreqms801mpr5lu0stv90gq	1700	2026-03-15 07:37:20.899	CASH	\N	\N
cmmrfz47700x5r5kkb77p7xz0	cmmreqmsb01mtr5lumn00cp9f	1700	2026-03-15 07:37:20.9	CASH	\N	\N
cmmrfz47800x7r5kk3xg0vvzk	cmmreqmsd01mxr5lunk6b1jlz	1200	2026-03-15 07:37:20.9	CASH	\N	\N
cmmrfz47800x9r5kkla4sfxzq	cmmreqmsf01n1r5lu280c2dpa	1200	2026-03-15 07:37:20.901	CASH	\N	\N
cmmrfz47900xbr5kkuurj11i5	cmmreqmsh01n5r5luy362soj4	1700	2026-03-15 07:37:20.901	CASH	\N	\N
cmmrfz47900xdr5kkccznl1zo	cmmreqmsj01n9r5lumfh1x1dt	1700	2026-03-15 07:37:20.902	CASH	\N	\N
cmmrfz47a00xfr5kk09xbf4je	cmmreqmsl01ndr5luyzqr9ws0	1700	2026-03-15 07:37:20.902	CASH	\N	\N
cmmrfz47a00xhr5kk6vk1p7k7	cmmreqmsn01nhr5lufivai3vv	1700	2026-03-15 07:37:20.903	CASH	\N	\N
cmmrfz47b00xjr5kkrds97s4z	cmmreqmsp01nlr5lu4mmblkif	5100	2026-03-15 07:37:20.903	CASH	\N	\N
cmmrfz47b00xlr5kkangd4fdo	cmmreqmsr01npr5lu4zl78sit	1700	2026-03-15 07:37:20.904	CASH	\N	\N
cmmrfz47c00xnr5kk8yod1o9a	cmmreqmst01ntr5lug9m61pkk	3400	2026-03-15 07:37:20.904	CASH	\N	\N
cmmrfz47c00xpr5kk30vg4c8k	cmmreqmsv01nxr5luhhxaeku9	1700	2026-03-15 07:37:20.905	CASH	\N	\N
cmmrfz47d00xrr5kke0yc7csm	cmmreqmsx01o1r5lutcrsrmv2	1700	2026-03-15 07:37:20.905	CASH	\N	\N
cmmrfz47d00xtr5kkbdui76b0	cmmreqmt001o5r5lux14ktk92	1163	2026-03-15 07:37:20.906	CASH	\N	\N
cmmrfz47e00xvr5kkgjuoaosg	cmmreqmt201o9r5lucgpwxyy8	1700	2026-03-15 07:37:20.906	CASH	\N	\N
cmmrfz47e00xxr5kkwik9phy1	cmmreqmt401odr5luwjeovzxi	1700	2026-03-15 07:37:20.907	CASH	\N	\N
cmmrfz47f00xzr5kkvgql7bgv	cmmreqmt601ohr5lup9mjfh0d	1700	2026-03-15 07:37:20.907	CASH	\N	\N
cmmrfz47f00y1r5kkuaiiodky	cmmreqmt901olr5luxzoatobw	1700	2026-03-15 07:37:20.908	CASH	\N	\N
cmmrfz47g00y3r5kkk0ku7hxp	cmmreqmtb01opr5lus4uv86e7	1700	2026-03-15 07:37:20.908	CASH	\N	\N
cmmrfz47g00y5r5kkxnhlafop	cmmreqmtd01otr5lu23a1v0w9	1700	2026-03-15 07:37:20.909	CASH	\N	\N
cmmrfz47h00y7r5kke5scnpbn	cmmreqmtf01oxr5lul988khml	1700	2026-03-15 07:37:20.909	CASH	\N	\N
cmmrfz47h00y9r5kkwrjnhnrt	cmmreqmti01p1r5lu8t1t70al	1700	2026-03-15 07:37:20.91	CASH	\N	\N
cmmrfz47i00ybr5kksbp3beza	cmmreqmtk01p5r5lus52camo7	1700	2026-03-15 07:37:20.91	CASH	\N	\N
cmmrfz47i00ydr5kkbemhdirg	cmmreqmtm01p9r5luazz9s9ub	1700	2026-03-15 07:37:20.911	CASH	\N	\N
cmmrfz47j00yfr5kkmtxkae8z	cmmreqmto01pdr5ludnns45sa	1700	2026-03-15 07:37:20.911	CASH	\N	\N
cmmrfz47j00yhr5kkc9sqjayi	cmmreqmtq01phr5luclkqm3x4	3400	2026-03-15 07:37:20.912	CASH	\N	\N
cmmrfz47k00yjr5kkp0isjrhn	cmmreqmts01plr5lujjivcvtc	3400	2026-03-15 07:37:20.912	CASH	\N	\N
cmmrfz47k00ylr5kk6rz9gasw	cmmreqmtu01ppr5luq3r3e03s	1700	2026-03-15 07:37:20.913	CASH	\N	1700 is balance
cmmrfz47l00ynr5kk8klvvvzl	cmmreqmty01ptr5lukixlis17	1700	2026-03-15 07:37:20.914	CASH	\N	\N
cmmrfz47m00ypr5kk9lyd3avo	cmmreqmu001pxr5luyhrihkv9	1700	2026-03-15 07:37:20.915	CASH	\N	\N
cmmrfz47n00yrr5kkdcne35wy	cmmreqmu201q1r5lulyy7rk1m	3400	2026-03-15 07:37:20.915	CASH	\N	\N
cmmrfz47n00ytr5kk2kum58y1	cmmreqmu401q5r5luhg90fdne	1700	2026-03-15 07:37:20.916	CASH	\N	\N
cmmrfz47o00yvr5kkdgmkyrpa	cmmreqmu701q9r5lu8b9zejej	1700	2026-03-15 07:37:20.916	CASH	\N	\N
cmmrfz47o00yxr5kkv2gja0i2	cmmreqmu901qdr5lur3m8xmxa	1700	2026-03-15 07:37:20.917	CASH	\N	\N
cmmrfz47p00yzr5kk19jdy7cy	cmmreqmub01qhr5lug9jlsu9g	5100	2026-03-15 07:37:20.917	CASH	\N	\N
cmmrfz47p00z1r5kkhkikodvx	cmmreqmue01qlr5lu7a0okrah	1700	2026-03-15 07:37:20.918	CASH	\N	\N
cmmrfz47q00z3r5kkuzyt6wiw	cmmreqmug01qpr5luospb2w8p	1700	2026-03-15 07:37:20.918	CASH	\N	\N
cmmrfz47r00z5r5kkscf3dnw4	cmmreqmui01qtr5lum9tos4ve	3400	2026-03-15 07:37:20.919	CASH	\N	\N
cmmrfz47r00z7r5kk2s0jem41	cmmreqmuk01qxr5lu9r8uj8ys	1700	2026-03-15 07:37:20.92	CASH	\N	\N
cmmrfz47s00z9r5kkiny5ca84	cmmreqmun01r1r5luwc3qmaqt	1700	2026-03-15 07:37:20.92	CASH	\N	\N
cmmrfz47s00zbr5kkwcud8njq	cmmreqmup01r5r5luu46nuof5	1700	2026-03-15 07:37:20.921	CASH	\N	\N
cmmrfz47t00zdr5kkp37gvx7b	cmmreqmur01r9r5luyaczltkw	1700	2026-03-15 07:37:20.921	CASH	\N	\N
cmmrfz47t00zfr5kk5qcv2syp	cmmreqmut01rdr5lux0v8znnm	1700	2026-03-15 07:37:20.922	CASH	\N	\N
cmmrfz47u00zhr5kkn45g2pmo	cmmreqmuv01rhr5lupcpyrvax	1700	2026-03-15 07:37:20.922	CASH	\N	\N
cmmrfz47u00zjr5kkv1fwsehr	cmmreqmuw01rlr5lukum1o4rt	1700	2026-03-15 07:37:20.923	CASH	\N	\N
cmmrfz47v00zlr5kk2mr95kui	cmmreqmuy01rpr5luzangg9o9	1700	2026-03-15 07:37:20.923	CASH	\N	\N
cmmrfz47v00znr5kkzfsjwf09	cmmreqmv001rtr5luyyzyqj45	1700	2026-03-15 07:37:20.924	CASH	\N	\N
cmmrfz47w00zpr5kk48ewl0od	cmmreqmv201rxr5luwac7csew	1700	2026-03-15 07:37:20.924	CASH	\N	\N
cmmrfz47x00zrr5kkyv8xfpwc	cmmreqmv401s1r5luvdp87gn0	1700	2026-03-15 07:37:20.925	CASH	\N	\N
cmmrfz47x00ztr5kkfhzl11yi	cmmreqmv601s5r5luc4gqi5yi	1700	2026-03-15 07:37:20.926	CASH	\N	\N
cmmrfz47y00zvr5kkqesdn7h0	cmmreqmv901s9r5luecrddr6h	1700	2026-03-15 07:37:20.926	CASH	\N	\N
cmmrfz47z00zxr5kk9aewveuw	cmmreqmvb01sdr5luskit30dr	1700	2026-03-15 07:37:20.927	CASH	\N	\N
cmmrfz47z00zzr5kko0iov793	cmmreqmvd01shr5lumaq1f8yh	1700	2026-03-15 07:37:20.928	CASH	\N	\N
cmmrfz4800101r5kkaf41s8gx	cmmreqmvf01slr5lu4hk1i7jz	1700	2026-03-15 07:37:20.928	CASH	\N	\N
cmmrfz4800103r5kk0wxuois7	cmmreqmvh01spr5lusoodnrfk	1700	2026-03-15 07:37:20.929	CASH	\N	\N
cmmrfz4810105r5kk3bl8xl0n	cmmreqmvk01str5lujz77ma2k	1700	2026-03-15 07:37:20.929	CASH	\N	\N
cmmrfz4810107r5kklxwfdqe7	cmmreqmvm01sxr5lusch6y35a	1700	2026-03-15 07:37:20.93	CASH	\N	\N
cmmrfz4820109r5kkk8r0gwjv	cmmreqmvo01t1r5lughlwv2xj	1700	2026-03-15 07:37:20.93	CASH	\N	\N
cmmrfz482010br5kkwxy33flz	cmmreqmvq01t5r5luhnnc8q3n	3400	2026-03-15 07:37:20.931	CASH	\N	\N
cmmrfz483010dr5kk0vtkxqdw	cmmreqmvt01t9r5lucahja23z	1700	2026-03-15 07:37:20.931	CASH	\N	\N
cmmrfz483010fr5kkdy0stq6b	cmmreqmvv01tdr5lucd2jpsjb	1700	2026-03-15 07:37:20.932	CASH	\N	\N
cmmrfz484010hr5kkf5xhr8lg	cmmreqmvx01thr5lu0wdde90m	1700	2026-03-15 07:37:20.932	CASH	\N	\N
cmmrfz484010jr5kkr5b60k4c	cmmreqmvz01tlr5lu6nc486sq	1700	2026-03-15 07:37:20.933	CASH	\N	\N
cmmrfz485010lr5kkbuenddjh	cmmreqmw101tpr5lukf949sz9	1700	2026-03-15 07:37:20.933	CASH	\N	\N
cmmrfz485010nr5kkujpvdexy	cmmreqmw301ttr5luykf31xus	1700	2026-03-15 07:37:20.934	CASH	\N	\N
cmmrfz486010pr5kksvershbp	cmmreqmw501txr5luik02yrdx	1700	2026-03-15 07:37:20.935	CASH	\N	\N
cmmrfz487010rr5kktqddsl9v	cmmreqmw801u1r5lu13qr5h09	1700	2026-03-15 07:37:20.935	CASH	\N	\N
cmmrfz488010tr5kk5dn9mwo0	cmmreqmwa01u5r5lu14z7k24b	1700	2026-03-15 07:37:20.936	CASH	\N	\N
cmmrfz488010vr5kk3f4qw8q8	cmmreqmwc01u9r5lu48cazra0	1700	2026-03-15 07:37:20.937	CASH	\N	\N
cmmrfz489010xr5kk1e0azfcu	cmmreqmwe01udr5lukwfuz7xy	1700	2026-03-15 07:37:20.937	CASH	\N	\N
cmmrfz489010zr5kke5di4uz1	cmmreqmwg01uhr5lun0x1wf1i	1700	2026-03-15 07:37:20.938	CASH	\N	\N
cmmrfz48a0111r5kkn2lqj636	cmmreqmwi01ulr5lumefek3ri	1700	2026-03-15 07:37:20.938	CASH	\N	\N
cmmrfz48a0113r5kkc70af69u	cmmreqmwk01upr5luplgwuhmw	1700	2026-03-15 07:37:20.939	CASH	\N	\N
cmmrfz48b0115r5kkwidteopn	cmmreqmwm01utr5luieseidfu	1700	2026-03-15 07:37:20.939	CASH	\N	\N
cmmrfz48c0117r5kki2fc92v9	cmmreqmwo01uxr5luudkn7vhf	1700	2026-03-15 07:37:20.94	CASH	\N	\N
cmmrfz48c0119r5kkyut6girk	cmmreqmwr01v1r5lu131hr8xe	1700	2026-03-15 07:37:20.941	CASH	\N	\N
cmmrfz48d011br5kkpwj97g5n	cmmreqmws01v5r5luhmft83ey	1700	2026-03-15 07:37:20.941	CASH	\N	\N
cmmrfz48d011dr5kkxp52ndm8	cmmreqmwu01v9r5lut8v31y2l	1700	2026-03-15 07:37:20.942	CASH	\N	\N
cmmrfz48e011fr5kk420k1lpb	cmmreqmww01vdr5lujn5vaa9u	1700	2026-03-15 07:37:20.942	CASH	\N	\N
cmmrfz48e011hr5kk2bnr1dss	cmmreqmwy01vhr5lus6f5tfsv	1700	2026-03-15 07:37:20.943	CASH	\N	\N
cmmrfz48f011jr5kkf1u7ubqb	cmmreqmx001vlr5luj5331px3	1700	2026-03-15 07:37:20.943	CASH	\N	\N
cmmrfz48f011lr5kkwfltl86t	cmmreqmx201vpr5lu0ynupti1	1700	2026-03-15 07:37:20.944	CASH	\N	\N
cmmrfz48g011nr5kkdiggieat	cmmreqmx501vtr5luh4j099w0	1700	2026-03-15 07:37:20.944	CASH	\N	\N
cmmrfz48g011pr5kknwtl1za3	cmmreqmx701vxr5lu0z4oo4qz	1700	2026-03-15 07:37:20.945	CASH	\N	\N
cmmrfz48h011rr5kkxgfli782	cmmreqmxa01w1r5luktbgjihk	1700	2026-03-15 07:37:20.945	CASH	\N	\N
cmmrfz48h011tr5kkwmut5ah2	cmmreqmxc01w5r5luy54a9yuc	1700	2026-03-15 07:37:20.946	CASH	\N	\N
cmmrfz48i011vr5kk537fhgiy	cmmreqmxe01w9r5luzkz0bnz0	1700	2026-03-15 07:37:20.946	CASH	\N	\N
cmmrfz48j011xr5kka45vd55a	cmmreqmxg01wdr5lueud98o0p	1700	2026-03-15 07:37:20.947	CASH	\N	\N
cmmrfz48j011zr5kkrms6zy7g	cmmreqmxi01whr5lullysfxwi	1700	2026-03-15 07:37:20.948	CASH	\N	\N
cmmrfz48k0121r5kk6bezvkvb	cmmreqmxk01wlr5lujvrqc9v2	1700	2026-03-15 07:37:20.949	CASH	\N	\N
cmmrfz48l0123r5kkrvco8886	cmmreqmxm01wpr5lu8rxgoh6v	3400	2026-03-15 07:37:20.95	CASH	\N	\N
cmmrfz48m0125r5kk0xa5id3b	cmmreqmxp01wtr5luke8mxs11	1700	2026-03-15 07:37:20.95	CASH	\N	\N
cmmrfz48n0127r5kkjgcligvq	cmmreqmxr01wxr5lulqzziqfh	1700	2026-03-15 07:37:20.951	CASH	\N	\N
cmmrfz48o0129r5kkdiwcfe23	cmmreqmxt01x1r5luqndx9u9v	1700	2026-03-15 07:37:20.952	CASH	\N	\N
cmmrfz48o012br5kkdz009mbi	cmmreqmxv01x5r5lugodlmvg3	1700	2026-03-15 07:37:20.953	CASH	\N	\N
cmmrfz48p012dr5kkgvkqesi8	cmmreqmxx01x9r5lumswc13rp	1700	2026-03-15 07:37:20.954	CASH	\N	\N
cmmrfz48q012fr5kk8zdww3u8	cmmreqmxz01xdr5lu33q94p61	1700	2026-03-15 07:37:20.954	CASH	\N	\N
cmmrfz48q012hr5kkbsh3w5at	cmmreqmy101xhr5luu6b0mcxj	1700	2026-03-15 07:37:20.955	CASH	\N	\N
cmmrfz48r012jr5kkta07kdnw	cmmreqmy301xlr5luvjta7gt8	1700	2026-03-15 07:37:20.956	CASH	\N	\N
cmmrfz48s012lr5kkumgbwsto	cmmreqmy501xpr5luz1nsw0np	1700	2026-03-15 07:37:20.956	CASH	\N	\N
cmmrfz48t012nr5kkn6axf35r	cmmreqmy801xtr5luznrf6gq4	1700	2026-03-15 07:37:20.957	CASH	\N	\N
cmmrfz48t012pr5kkjknv46fg	cmmreqmya01xxr5lujin9p0i3	1700	2026-03-15 07:37:20.958	CASH	\N	\N
cmmrfz48u012rr5kkdo9yg0gc	cmmreqmyc01y1r5luvucsrh1o	1700	2026-03-15 07:37:20.959	CASH	\N	\N
cmmrfz48v012tr5kk07ot68ui	cmmreqmyf01y5r5lu4ah8046g	1700	2026-03-15 07:37:20.96	CASH	\N	\N
cmmrfz48w012vr5kkljt42lqd	cmmreqmyh01y9r5luve7oc9tn	1700	2026-03-15 07:37:20.96	CASH	\N	\N
cmmrfz48x012xr5kk2kzb3e6b	cmmreqmyj01ydr5lud5da7qz9	1700	2026-03-15 07:37:20.961	CASH	\N	\N
cmmrfz48x012zr5kk7196pm8q	cmmreqmym01yhr5luxz9t7dzs	1700	2026-03-15 07:37:20.962	CASH	\N	\N
cmmrfz48y0131r5kkopgs09r3	cmmreqmyo01ylr5lut5mx0nww	1700	2026-03-15 07:37:20.963	CASH	\N	\N
cmmrfz48z0133r5kklk9zs9l2	cmmreqmyr01ypr5lug1pq6k91	1700	2026-03-15 07:37:20.963	CASH	\N	\N
cmmrfz4900135r5kkjxux77dy	cmmreqmyt01ytr5luta34wuoq	1700	2026-03-15 07:37:20.964	CASH	\N	\N
cmmrfz4900137r5kknkt7jpo5	cmmreqmyv01yxr5lur7y3s6dd	1700	2026-03-15 07:37:20.965	CASH	\N	\N
cmmrfz4910139r5kk84soyyfu	cmmreqmyx01z1r5luaio585x8	1700	2026-03-15 07:37:20.966	CASH	\N	\N
cmmrfz492013br5kk0ti9p2va	cmmreqmyz01z5r5luf0cviscc	1700	2026-03-15 07:37:20.967	CASH	\N	\N
cmmrfz493013dr5kkq0smhuhl	cmmreqmz001z9r5lun4vtvxam	1700	2026-03-15 07:37:20.967	CASH	\N	\N
cmmrfz494013fr5kkgp0p71po	cmmreqmz301zdr5luy00ch842	1700	2026-03-15 07:37:20.968	CASH	\N	\N
cmmrfz494013hr5kkewc2d8yh	cmmreqmz501zhr5lun6ay3vpu	1700	2026-03-15 07:37:20.969	CASH	\N	\N
cmmrfz495013jr5kkb0orptyn	cmmreqmz601zlr5lukspwpplv	1700	2026-03-15 07:37:20.97	CASH	\N	\N
cmmrfz496013lr5kks5fu4n69	cmmreqmz901zpr5lurhr2wtlg	1700	2026-03-15 07:37:20.97	CASH	\N	\N
cmmrfz496013nr5kkxzk951r7	cmmreqmzb01ztr5lurpsu3bep	1700	2026-03-15 07:37:20.971	CASH	\N	\N
cmmrfz497013pr5kkh2xw4d2v	cmmreqmzd01zxr5lumbci09ak	1700	2026-03-15 07:37:20.972	CASH	\N	\N
cmmrfz498013rr5kk1r3knsvy	cmmreqmzf0201r5lutwhxnih3	1700	2026-03-15 07:37:20.973	CASH	\N	\N
cmmrfz499013tr5kkvdtbe12t	cmmreqmzh0205r5luzk9j8bu1	1700	2026-03-15 07:37:20.973	CASH	\N	\N
cmmrfz49a013vr5kk343wa6n0	cmmreqmzj0209r5lu49n9c3ae	1700	2026-03-15 07:37:20.974	CASH	\N	\N
cmmrfz49a013xr5kk3gjyjda5	cmmreqmzl020dr5luevz5h7p1	1700	2026-03-15 07:37:20.975	CASH	\N	\N
cmmrfz49b013zr5kko9wqgt2a	cmmreqmzn020hr5lun3sypkct	1700	2026-03-15 07:37:20.976	CASH	\N	\N
cmmrfz49c0141r5kk8r78dp41	cmmreqmzp020lr5lu911rwyum	1700	2026-03-15 07:37:20.977	CASH	\N	\N
cmmrfz49d0143r5kkh5zscb7d	cmmreqmzr020pr5lun30i3j9u	1700	2026-03-15 07:37:20.977	CASH	\N	\N
cmmrfz49e0145r5kkqjftc1bo	cmmreqmzt020tr5lun3lsar8a	1700	2026-03-15 07:37:20.978	CASH	\N	\N
cmmrfz49e0147r5kkerublykm	cmmreqmzv020xr5lu42wdqlms	3790	2026-03-15 07:37:20.979	CASH	\N	pending 169
cmmrfz49f0149r5kksj43pt5z	cmmreqmzx0211r5luxr6380fk	1700	2026-03-15 07:37:20.98	CASH	\N	\N
cmmrfz49g014br5kk026xjros	cmmreqmzz0215r5ludwbb37tm	1700	2026-03-15 07:37:20.98	CASH	\N	\N
cmmrfz49h014dr5kkjtu9uthz	cmmreqn010219r5lu9ahrtm9u	1700	2026-03-15 07:37:20.981	CASH	\N	\N
cmmrfz49h014fr5kka1ty1hsj	cmmreqn04021dr5lu9jzsijgx	1700	2026-03-15 07:37:20.982	CASH	\N	\N
cmmrfz49i014hr5kkuk30vkv7	cmmreqn06021hr5luyt23z0yx	1700	2026-03-15 07:37:20.983	CASH	\N	\N
cmmrfz49j014jr5kk2rzfkvea	cmmreqn08021lr5luzdqbm1gj	1700	2026-03-15 07:37:20.983	CASH	\N	Pending 2089
cmmrfz49k014lr5kkib95g3i1	cmmreqn0b021pr5luanmf975n	1700	2026-03-15 07:37:20.984	CASH	\N	\N
cmmrfz49k014nr5kks5ki39f5	cmmreqn0d021tr5lumg00iijh	1700	2026-03-15 07:37:20.985	CASH	\N	\N
cmmrfz49l014pr5kkfu23fxh8	cmmreqn0f021xr5lu59w07tqe	1700	2026-03-15 07:37:20.986	CASH	\N	\N
cmmrfz49m014rr5kkd0feefrf	cmmreqn0h0221r5luwytetk9a	1700	2026-03-15 07:37:20.986	CASH	\N	\N
cmmrfz49n014tr5kkrp6s5p99	cmmreqn0j0225r5lu2edmh2ek	1700	2026-03-15 07:37:20.987	CASH	\N	\N
cmmrfz49o014vr5kk2x3ay7br	cmmreqn0l0229r5luonspgldi	1700	2026-03-15 07:37:20.988	CASH	\N	\N
cmmrfz49o014xr5kkxx0d82sl	cmmreqn0n022dr5luqkkwwfga	1700	2026-03-15 07:37:20.989	CASH	\N	Pending 2089
cmmrfz49p014zr5kkp6m05e3f	cmmreqn0p022hr5lu3rbcurvd	1700	2026-03-15 07:37:20.989	CASH	\N	\N
cmmrfz49q0151r5kk1nbl5ytz	cmmreqn0r022lr5luyoy76f2i	1700	2026-03-15 07:37:20.99	CASH	\N	\N
cmmrfz49q0153r5kk5ftu1fh1	cmmreqn0t022pr5lu3fa874ii	3400	2026-03-15 07:37:20.991	CASH	\N	\N
cmmrfz49r0155r5kkbxz90vqj	cmmreqn0v022tr5lu90fk3llk	3400	2026-03-15 07:37:20.992	CASH	\N	\N
cmmrfz49s0157r5kkv9mkhnbz	cmmreqn0x022xr5lu7tajv2c6	3400	2026-03-15 07:37:20.992	CASH	\N	\N
cmmrfz49t0159r5kkxjntfgyf	cmmreqn0y0231r5lu11kemksh	3400	2026-03-15 07:37:20.993	CASH	\N	\N
cmmrfz49t015br5kkcdlpa4x3	cmmreqn100235r5lucnwx4669	1700	2026-03-15 07:37:20.994	CASH	\N	\N
cmmrfz49u015dr5kk342z6fzw	cmmreqn120239r5luptdb3yyq	3400	2026-03-15 07:37:20.995	CASH	\N	\N
cmmrfz49v015fr5kkqu7l3z43	cmmreqn15023dr5luq3felfvd	1700	2026-03-15 07:37:20.996	CASH	\N	\N
cmmrfz49w015hr5kk6czxenqd	cmmreqn16023hr5luqtltdgk1	3789	2026-03-15 07:37:20.996	CASH	\N	\N
cmmrfz49x015jr5kkhyei4gq1	cmmreqn18023lr5lux2yth2yn	3400	2026-03-15 07:37:20.997	CASH	\N	\N
cmmrfz49y015lr5kkdidllgpe	cmmreqn1b023pr5luouc53b65	1700	2026-03-15 07:37:20.998	CASH	\N	\N
cmmrfz49z015nr5kkrlf2rfzp	cmmreqn1d023tr5luekhcqbi9	3400	2026-03-15 07:37:20.999	CASH	\N	\N
cmmrfz49z015pr5kklrolesm9	cmmreqn1f023xr5luh9u9c3ty	1700	2026-03-15 07:37:21	CASH	\N	\N
cmmrfz4a0015rr5kkzh2cvkqo	cmmreqn1h0241r5luu9i3lkxg	1700	2026-03-15 07:37:21.001	CASH	\N	\N
cmmrfz4a1015tr5kk75zu6ocb	cmmreqn1j0245r5lufjcaf86x	5100	2026-03-15 07:37:21.002	CASH	\N	\N
cmmrfz4a2015vr5kkzpbqlfrf	cmmreqn1l0249r5lu0uzcotcy	5269	2026-03-15 07:37:21.002	CASH	\N	\N
cmmrfz4a3015xr5kkcq5gtoqn	cmmreqn1n024dr5luqeke1vg5	1700	2026-03-15 07:37:21.004	CASH	\N	\N
cmmrfz4a4015zr5kkxc0u873x	cmmreqn1p024hr5ludyr8b5a2	1700	2026-03-15 07:37:21.004	CASH	\N	\N
cmmrfz4a50161r5kky1h869g0	cmmreqn1r024lr5lutpewqgft	1700	2026-03-15 07:37:21.005	CASH	\N	\N
cmmrfz4a50163r5kklq2zlsks	cmmreqn1t024pr5lu573nr4bn	1700	2026-03-15 07:37:21.006	CASH	\N	\N
cmmrfz4a60165r5kk0vhf2k7r	cmmreqn1v024tr5luzwrw94nu	1700	2026-03-15 07:37:21.007	CASH	\N	\N
cmmrfz4a70167r5kkrrkk59iw	cmmreqn1w024xr5lumooq40ur	1700	2026-03-15 07:37:21.007	CASH	\N	\N
cmmrfz4a80169r5kk22dpvv7z	cmmreqn1y0251r5luuabwcvsn	1700	2026-03-15 07:37:21.008	CASH	\N	\N
cmmrfz4a8016br5kkthxt51ie	cmmreqn200255r5ludl6rcdks	1700	2026-03-15 07:37:21.009	CASH	\N	\N
cmmrfz4a9016dr5kkgpctlaes	cmmreqn220259r5lu04u0hrzc	3400	2026-03-15 07:37:21.01	CASH	\N	\N
cmmrfz4aa016fr5kk8zqxzdee	cmmreqn24025dr5lu3dsr2wpn	1700	2026-03-15 07:37:21.01	CASH	\N	\N
cmmrfz4aa016hr5kknjnzt0uz	cmmreqn25025hr5lu9wfki9dt	3400	2026-03-15 07:37:21.011	CASH	\N	\N
cmmrfz4ab016jr5kkagy8rtxi	cmmreqn27025lr5lum1ru85i9	1700	2026-03-15 07:37:21.012	CASH	\N	\N
cmmrfz4ac016lr5kkqorak3sd	cmmreqn29025pr5luz1mer9z3	1700	2026-03-15 07:37:21.012	CASH	\N	\N
cmmrfz4ad016nr5kkfobwae3l	cmmreqn2b025tr5luvyvcwrvu	1700	2026-03-15 07:37:21.013	CASH	\N	\N
cmmrfz4ae016pr5kkwqcacywd	cmmreqn2c025xr5luqz69pivn	1700	2026-03-15 07:37:21.014	CASH	\N	\N
cmmrfz4ae016rr5kku37uae0z	cmmreqn2e0261r5lunx0uaahh	1700	2026-03-15 07:37:21.015	CASH	\N	\N
cmmrfz4af016tr5kkjw2g6au5	cmmreqn2g0265r5lu2nuv040y	1700	2026-03-15 07:37:21.015	CASH	\N	\N
cmmrfz4ag016vr5kkb2ecvr4h	cmmreqn2i0269r5luceovmd2h	1700	2026-03-15 07:37:21.016	CASH	\N	\N
cmmrfz4ag016xr5kkcjscksj4	cmmreqn2j026dr5lugrmnxob7	3400	2026-03-15 07:37:21.017	CASH	\N	\N
cmmrfz4ah016zr5kk28fx5k4v	cmmreqn2l026hr5luroar70tz	3400	2026-03-15 07:37:21.018	CASH	\N	\N
cmmrfz4ai0171r5kkawf9jf20	cmmreqn2n026lr5luap1mlhrs	1700	2026-03-15 07:37:21.018	CASH	\N	\N
cmmrfz4aj0173r5kk6sw5dbpr	cmmreqn2p026pr5lu8ydu1cxr	1700	2026-03-15 07:37:21.019	CASH	\N	Jan amount still pending
cmmrfz4aj0175r5kklvcr689v	cmmreqn2q026tr5lunw4gocao	1700	2026-03-15 07:37:21.019	CASH	\N	\N
cmmrfz4ak0177r5kkqwi004f6	cmmreqn2s026xr5lux4ub1qs6	1700	2026-03-15 07:37:21.02	CASH	\N	\N
cmmrfz4al0179r5kky09ce35u	cmmreqn2u0271r5lu0ijemerk	1700	2026-03-15 07:37:21.021	CASH	\N	\N
cmmrfz4al017br5kk81ncoll3	cmmreqn2w0275r5lur8ufzv0n	1700	2026-03-15 07:37:21.022	CASH	\N	\N
cmmrfz4am017dr5kk2f0mln7v	cmmreqn2y0279r5luetp1jt7e	1700	2026-03-15 07:37:21.022	CASH	\N	\N
cmmrfz4an017fr5kkc54n84mv	cmmreqn30027dr5luokknnqu8	1700	2026-03-15 07:37:21.023	CASH	\N	\N
cmmrfz4an017hr5kkqpws090x	cmmreqn31027hr5lup2qk63nw	1700	2026-03-15 07:37:21.024	CASH	\N	\N
cmmrfz4ao017jr5kkqt9032h3	cmmreqn33027lr5luqykly4bw	5100	2026-03-15 07:37:21.025	CASH	\N	\N
cmmrfz4ap017lr5kk8ek4ud6g	cmmreqn35027pr5lunisyst9l	3400	2026-03-15 07:37:21.025	CASH	\N	\N
cmmrfz4aq017nr5kkfwiz8mn8	cmmreqn37027tr5luh3e6mup2	1700	2026-03-15 07:37:21.026	CASH	\N	\N
cmmrfz4aq017pr5kkzfvpsvyr	cmmreqn39027xr5lulq4hnbfb	3400	2026-03-15 07:37:21.027	CASH	\N	\N
cmmrfz4ar017rr5kkgxh02iru	cmmreqn3a0281r5lu48bchumg	1700	2026-03-15 07:37:21.027	CASH	\N	\N
cmmrfz4as017tr5kkeva0nram	cmmreqn3c0285r5lutreiikhu	1700	2026-03-15 07:37:21.028	CASH	\N	Water bill pending
cmmrfz4as017vr5kkj3toja3d	cmmreqn3e0289r5lue2a7m5r4	3400	2026-03-15 07:37:21.029	CASH	\N	\N
cmmrfz4at017xr5kko86ctx7r	cmmreqn3g028dr5lu93zis8k4	1700	2026-03-15 07:37:21.03	CASH	\N	\N
cmmrfz4au017zr5kkz68o7cgm	cmmreqn3h028hr5luid4qt9w0	1700	2026-03-15 07:37:21.03	CASH	\N	\N
cmmrfz4au0181r5kk57bmouvn	cmmreqn3j028lr5luqxcqtnf1	3400	2026-03-15 07:37:21.031	CASH	\N	\N
cmmrfz4av0183r5kkqovxr2su	cmmreqn3l028pr5lua3vmzoy9	1700	2026-03-15 07:37:21.032	CASH	\N	\N
cmmrfz4aw0185r5kku4w09m9r	cmmreqn3n028tr5lurxq3ohr6	3400	2026-03-15 07:37:21.032	CASH	\N	1092 water bill
cmmrfz4ax0187r5kk4nb7gt2b	cmmreqn3o028xr5lu31yilk5r	3400	2026-03-15 07:37:21.033	CASH	\N	\N
cmmrfz4ax0189r5kkwrcb8qeu	cmmreqn3q0291r5luxpai6bs6	1700	2026-03-15 07:37:21.034	CASH	\N	\N
cmmrfz4ay018br5kkjwjpb8z8	cmmreqn3r0295r5lursu2kgnz	1700	2026-03-15 07:37:21.034	CASH	\N	\N
cmmrfz4az018dr5kk82udokec	cmmreqn3t0299r5luq4uoikmq	1700	2026-03-15 07:37:21.035	CASH	\N	\N
cmmrfz4b0018fr5kkck87jg1m	cmmreqn3v029dr5lu7rrxfusw	1700	2026-03-15 07:37:21.036	CASH	\N	Water bill pending
cmmrfz4b1018hr5kkl7ddwnbv	cmmreqn3w029hr5lu4yt3g93o	1700	2026-03-15 07:37:21.037	CASH	\N	\N
cmmrfz4b1018jr5kklzahgnte	cmmreqn3y029lr5lurlt2itdg	1700	2026-03-15 07:37:21.038	CASH	\N	\N
cmmrfz4b2018lr5kkvfjr2zlq	cmmreqn40029pr5lu1gracp09	3400	2026-03-15 07:37:21.039	CASH	\N	216 water bill pending
cmmrfz4b3018nr5kkwzlt9gfm	cmmreqn42029tr5lu6jcgzei1	1700	2026-03-15 07:37:21.039	CASH	\N	\N
cmmrfz4b5018pr5kkh4fcu07l	cmmreqn44029xr5luq9k8dhnx	1700	2026-03-15 07:37:21.041	CASH	\N	\N
cmmrfz4b6018rr5kkdcm7hbnk	cmmreqmhd00n9r5luki37wig4	1700	2026-03-15 07:37:21.042	CASH	\N	\N
cmmrfz4b7018tr5kki6eybdb1	cmmreqmhd00nbr5ludo94eerw	1700	2026-03-15 07:37:21.043	CASH	\N	\N
cmmrfz4b8018vr5kkbbdx8ei4	cmmreqmhf00nhr5luakd36lic	3400	2026-03-15 07:37:21.044	CASH	\N	490  water bill is pending
cmmrfz4b8018xr5kkkzzcb43r	cmmreqmhf00njr5luskel3ed9	1700	2026-03-15 07:37:21.045	CASH	\N	1115 water bill pedning
cmmrfz4b9018zr5kkwfzugi5q	cmmreqmhg00nlr5luldd5we7l	1700	2026-03-15 07:37:21.045	CASH	\N	\N
cmmrfz4ba0191r5kkiqut7ddr	cmmreqmhg00nnr5luykeraeaz	1700	2026-03-15 07:37:21.046	CASH	\N	\N
cmmrfz4bb0193r5kkokmiorxl	cmmreqmhg00npr5luohophshj	1700	2026-03-15 07:37:21.047	CASH	\N	\N
cmmrfz4bb0195r5kk5tds6tjo	cmmreqmhh00nrr5luohthtug5	1700	2026-03-15 07:37:21.048	CASH	\N	101 bill is pending
cmmrfz4bc0197r5kkbtqlmpev	cmmreqmhj00nzr5lu0h2v55pa	1700	2026-03-15 07:37:21.049	CASH	\N	\N
cmmrfz4bd0199r5kkoos5tm45	cmmreqmhj00o1r5lu91sudxg4	1700	2026-03-15 07:37:21.049	CASH	\N	61 pending
cmmrfz4bd019br5kkkupt43ep	cmmreqn4k02alr5luq0d10yga	1150	2026-03-15 07:37:21.05	CASH	\N	Remaning amount paid for maintainence
cmmrfz4be019dr5kktvrvnif5	cmmreqn4m02apr5lu5hp0twtz	1700	2026-03-15 07:37:21.051	CASH	\N	\N
cmmrfz4bf019fr5kk84m7zyva	cmmreqn4n02atr5lud12dsaz4	3400	2026-03-15 07:37:21.051	CASH	\N	\N
cmmrfz4bg019hr5kkmognxxet	cmmreqn4p02axr5lucc962n36	1700	2026-03-15 07:37:21.052	CASH	\N	\N
cmmrfz4bg019jr5kk8uabmsdi	cmmreqn4r02b1r5ludqe7aly6	1700	2026-03-15 07:37:21.053	CASH	\N	\N
cmmrfz4bh019lr5kkngxgev0h	cmmreqn4t02b5r5luepmo9p6i	1700	2026-03-15 07:37:21.053	CASH	\N	\N
cmmrfz4bi019nr5kknxx8xicp	cmmreqn4u02b9r5lu8twwfozp	1700	2026-03-15 07:37:21.054	CASH	\N	\N
cmmrfz4bi019pr5kk4l7qcsaw	cmmreqn4w02bdr5luqrndy5j4	1700	2026-03-15 07:37:21.055	CASH	\N	\N
cmmrfz4bj019rr5kkvbyetdq7	cmmreqn4y02bhr5luofb0sv8d	1700	2026-03-15 07:37:21.055	CASH	\N	water bill cleared
cmmrfz4bj019tr5kkhozrfxom	cmmreqn5002blr5lu1lf9r1fy	3400	2026-03-15 07:37:21.056	CASH	\N	3389 We need to adjust in next month maintainence
cmmrfz4bk019vr5kk2kfe9iqf	cmmreqn5202bpr5lummwd0e3i	1700	2026-03-15 07:37:21.056	CASH	\N	\N
cmmrfz4bl019xr5kkkuw8zo9u	cmmreqn5402btr5lup6xq2lv4	1700	2026-03-15 07:37:21.057	CASH	\N	\N
cmmrfz4bl019zr5kki0wmv0ci	cmmreqmhk00o3r5lu50rlkofr	1700	2026-03-15 07:37:21.058	CASH	\N	\N
cmmrfz4bm01a1r5kkw9o5qjdl	cmmreqmhn00odr5luk90urdnh	1700	2026-03-15 07:37:21.058	CASH	\N	\N
cmmrfz4bn01a3r5kkg6t8d38j	cmmreqmho00ohr5lundhuf6op	1700	2026-03-15 07:37:21.059	CASH	\N	\N
cmmrfz4bn01a5r5kkv0xzv4mf	cmmreqmhq00opr5luq1hgcfeb	2500	2026-03-15 07:37:21.06	CASH	\N	\N
cmmrfz4bo01a7r5kk7qw3dbmx	cmmreqmhr00otr5luk1wp9xb0	1700	2026-03-15 07:37:21.061	CASH	\N	\N
cmmrfz4bp01a9r5kkon1uhahi	cmmreqmhr00oxr5luo7jyx5tt	1700	2026-03-15 07:37:21.062	CASH	\N	\N
cmmrfz4bq01abr5kkqfewkn97	cmmreqmhs00ozr5luk25aquva	1700	2026-03-15 07:37:21.062	CASH	\N	\N
cmmrfz4br01adr5kkgl8kk0d7	cmmreqmhs00p1r5lu4s312bdc	5100	2026-03-15 07:37:21.063	CASH	\N	\N
cmmrfz4bs01afr5kkd7qyqlcu	cmmreqmht00p3r5lur3crsvn4	1700	2026-03-15 07:37:21.064	CASH	\N	\N
cmmrfz4bs01ahr5kkmupo3k36	cmmreqmht00p5r5lu6edroll1	1700	2026-03-15 07:37:21.065	CASH	\N	38 pending for water bill
cmmrfz4bt01ajr5kks89eftnf	cmmreqmht00p7r5luxhsuisc0	1700	2026-03-15 07:37:21.066	CASH	\N	\N
cmmrfz4bu01alr5kkf0pl488j	cmmreqmhu00p9r5luhpo49rv5	1700	2026-03-15 07:37:21.066	CASH	\N	\N
cmmrfz4bu01anr5kkq1fwz1yy	cmmreqmhu00pbr5lut2o9yy91	1700	2026-03-15 07:37:21.067	CASH	\N	\N
cmmrfz4bv01apr5kk3300r9cr	cmmreqmhv00pdr5lu0jr7umsr	1700	2026-03-15 07:37:21.068	CASH	\N	\N
cmmrfz4bw01arr5kkl35kj9y3	cmmreqmhv00pfr5lujdagpf8m	3400	2026-03-15 07:37:21.068	CASH	\N	need to pay 3
cmmrfz4bw01atr5kk5hw4t7yg	cmmreqmhw00pjr5lu1xs3m71a	1700	2026-03-15 07:37:21.069	CASH	\N	Paid 3500
cmmrfz4bx01avr5kk1s6tt73y	cmmreqmhw00plr5luahxqd60a	1700	2026-03-15 07:37:21.07	CASH	\N	664 We need to adjust in next month maintainence
cmmrfz4by01axr5kk0g6tov22	cmmreqmhw00pnr5luk1lzpmq6	1700	2026-03-15 07:37:21.07	CASH	\N	\N
cmmrfz4bz01azr5kknp3e5ove	cmmreqmhx00prr5luxdluwa9j	1700	2026-03-15 07:37:21.071	CASH	\N	\N
cmmrfz4c001b1r5kkqc7r8b66	cmmreqmhx00ptr5luswcz1rj6	1700	2026-03-15 07:37:21.072	CASH	\N	\N
cmmrfz4c001b3r5kk8vhymf0c	cmmreqmhy00pvr5lux241htby	1700	2026-03-15 07:37:21.073	CASH	\N	\N
cmmrfz4c101b5r5kkahemur32	cmmreqmhy00pxr5lu2j6yhrrn	1700	2026-03-15 07:37:21.073	CASH	\N	\N
cmmrfz4c101b7r5kkrebtw9le	cmmreqmhz00q1r5lu35obrfdw	1700	2026-03-15 07:37:21.074	CASH	\N	\N
cmmrfz4c201b9r5kkg0js5jem	cmmreqmhz00q3r5lu9a8mv0jm	1700	2026-03-15 07:37:21.075	CASH	\N	\N
cmmrfz4c301bbr5kkvkn5cat7	cmmreqmi000q5r5luwc5uux33	1700	2026-03-15 07:37:21.075	CASH	\N	\N
cmmrfz4c301bdr5kkzk331pu9	cmmreqmi000q7r5luftiznndu	1700	2026-03-15 07:37:21.076	CASH	\N	\N
cmmrfz4c401bfr5kkq8p39y0k	cmmreqmi100q9r5luj06k87i1	1700	2026-03-15 07:37:21.077	CASH	\N	Currency notes
cmmrfz4c501bhr5kkg0xzrx2u	cmmreqmi200qfr5lu3ihpqigc	1036	2026-03-15 07:37:21.077	CASH	\N	\N
cmmrfz4c501bjr5kk37fu2pg2	cmmreqmi200qhr5lug64hcq17	1700	2026-03-15 07:37:21.078	CASH	\N	\N
cmmrfz4c601blr5kkd649gmzx	cmmreqmi200qjr5luz1centsw	1700	2026-03-15 07:37:21.078	CASH	\N	\N
cmmrfz4c701bnr5kki39so2z2	cmmreqmi300qlr5lump6j03qs	1700	2026-03-15 07:37:21.079	CASH	\N	\N
cmmrfz4c701bpr5kkmx68nper	cmmreqmi300qnr5luikhnrxqe	1700	2026-03-15 07:37:21.08	CASH	\N	\N
cmmrfz4c801brr5kk0vw2w83q	cmmreqmi400qpr5luucxbrrv6	1700	2026-03-15 07:37:21.08	CASH	\N	\N
cmmrfz4c901btr5kkwc2gpuxn	cmmreqmi400qrr5lu30qgx26y	1700	2026-03-15 07:37:21.081	CASH	\N	\N
cmmrfz4c901bvr5kkzyrlr80p	cmmreqmi500qvr5lufiom3s58	1700	2026-03-15 07:37:21.082	CASH	\N	\N
cmmrfz4ca01bxr5kkj4tvo49i	cmmreqmi500qxr5lum7l47gum	1700	2026-03-15 07:37:21.082	CASH	\N	\N
cmmrfz4cb01bzr5kk6l6b7kq8	cmmreqmi600qzr5lu427ak2ml	1700	2026-03-15 07:37:21.083	CASH	\N	\N
cmmrfz4cb01c1r5kkzwzhdz0w	cmmreqmi600r1r5luhock8ucg	1700	2026-03-15 07:37:21.084	CASH	\N	\N
cmmrfz4cc01c3r5kkkqa7541y	cmmreqmi600r3r5lutb6bwjnd	1700	2026-03-15 07:37:21.084	CASH	\N	\N
cmmrfz4cd01c5r5kkuvzybow3	cmmreqmi700r7r5luwctz9hpi	2500	2026-03-15 07:37:21.085	CASH	\N	3300-2500
cmmrfz4cd01c7r5kkjfrsogkn	cmmreqmi700r9r5lu7xrxq97h	1700	2026-03-15 07:37:21.086	CASH	\N	\N
cmmrfz4ce01c9r5kkyuwxy8d7	cmmreqmi800rbr5lu1hv20did	1700	2026-03-15 07:37:21.086	CASH	\N	\N
cmmrfz4cf01cbr5kk9xj8ilot	cmmreqmi800rdr5lub44j7vuv	1700	2026-03-15 07:37:21.087	CASH	\N	\N
cmmrfz4cg01cdr5kkoftpgdba	cmmreqn6w02ebr5lu3vw2zqn9	1700	2026-03-15 07:37:21.088	CASH	\N	\N
cmmrfz4cg01cfr5kk85gyb63l	cmmreqn6y02efr5luxofscbkb	1700	2026-03-15 07:37:21.089	CASH	\N	\N
cmmrfz4ch01chr5kkprk8121o	cmmreqn6z02ejr5lu79korkn2	5138	2026-03-15 07:37:21.089	CASH	\N	\N
cmmrfz4ci01cjr5kkvhgwc0xb	cmmreqn7102enr5ludsgdqu0i	1700	2026-03-15 07:37:21.09	CASH	\N	\N
cmmrfz4ci01clr5kk73ggu71g	cmmreqn7402err5luk4mqecpr	1700	2026-03-15 07:37:21.091	CASH	\N	\N
cmmrfz4cj01cnr5kk3923rygu	cmmreqn7602evr5lumjl6haz0	1700	2026-03-15 07:37:21.091	CASH	\N	\N
cmmrfz4cj01cpr5kk1i3e0pa6	cmmreqn7802ezr5luqjpx7aj3	2500	2026-03-15 07:37:21.092	CASH	\N	\N
cmmrfz4ck01crr5kkeacqwmy1	cmmreqn7902f3r5luu1oywk5y	1700	2026-03-15 07:37:21.093	CASH	\N	\N
cmmrfz4cl01ctr5kkrzbl3ebe	cmmreqn7b02f7r5lufv7log16	1700	2026-03-15 07:37:21.093	CASH	\N	\N
cmmrfz4cm01cvr5kklbm359ua	cmmreqn7d02fbr5lumccjf5gm	1700	2026-03-15 07:37:21.094	CASH	\N	\N
cmmrfz4cn01cxr5kkr7b8h80k	cmmreqmi900rfr5lugx8su8ch	1700	2026-03-15 07:37:21.095	CASH	\N	\N
cmmrfz4cn01czr5kk6kkichyh	cmmreqmi900rhr5lubjyaik8c	3400	2026-03-15 07:37:21.096	CASH	\N	\N
cmmrfz4co01d1r5kkjil0hjts	cmmreqmib00rpr5luml4fnenz	1700	2026-03-15 07:37:21.096	CASH	\N	\N
cmmrfz4cp01d3r5kkmc62dgi1	cmmreqmib00rrr5lu7ziosooa	3400	2026-03-15 07:37:21.097	CASH	\N	\N
cmmrfz4cp01d5r5kkhn1n9kuv	cmmreqmic00rtr5luhj7qbkmf	1700	2026-03-15 07:37:21.098	CASH	\N	\N
cmmrfz4cq01d7r5kkj2wd3ewk	cmmreqmic00rvr5lumbx5atpy	5100	2026-03-15 07:37:21.099	CASH	\N	\N
cmmrfz4cr01d9r5kk003jqa54	cmmreqmic00rxr5luor2njy77	3400	2026-03-15 07:37:21.099	CASH	\N	\N
cmmrfz4cs01dbr5kkelrtdcga	cmmreqmid00s5r5luro39hwdx	1700	2026-03-15 07:37:21.1	CASH	\N	\N
cmmrfz4cs01ddr5kk4wyq48mv	cmmreqmie00s7r5lu9s87pfy5	3400	2026-03-15 07:37:21.101	CASH	\N	\N
cmmrfz4ct01dfr5kkogsr0lzb	cmmreqmie00s9r5lu5q1w1l4d	1700	2026-03-15 07:37:21.102	CASH	\N	\N
cmmrfz4cu01dhr5kko08ht3hy	cmmreqmie00sbr5luf6f0wwxx	1700	2026-03-15 07:37:21.102	CASH	\N	\N
cmmrfz4cv01djr5kkj1zo7p0d	cmmreqmif00sdr5luxdaif8w8	6800	2026-03-15 07:37:21.103	CASH	\N	\N
cmmrfz4cv01dlr5kk4dlfko76	cmmreqmif00sfr5ludlcpjodi	5100	2026-03-15 07:37:21.104	CASH	\N	\N
cmmrfz4cw01dnr5kk755jh4e1	cmmreqmif00shr5luwh8d1au9	5100	2026-03-15 07:37:21.105	CASH	\N	\N
cmmrfz4cx01dpr5kkcmso7fhz	cmmreqmig00sjr5luiiwuzfnn	1700	2026-03-15 07:37:21.106	CASH	\N	\N
cmmrfz4cy01drr5kku1zrbq3z	cmmreqmig00slr5lud1pq50qq	1700	2026-03-15 07:37:21.106	CASH	\N	\N
cmmrfz4cz01dtr5kk7e94qrhb	cmmreqmih00snr5lucubqbki7	1700	2026-03-15 07:37:21.107	CASH	\N	\N
cmmrfz4d001dvr5kkx4buhisu	cmmreqmih00spr5lu73htpsoo	1700	2026-03-15 07:37:21.108	CASH	\N	\N
cmmrfz4d001dxr5kkbhct4reh	cmmreqmii00svr5luc7bodzvi	6800	2026-03-15 07:37:21.109	CASH	\N	we need to give 1700. will adjust in next month
cmmrfz4d101dzr5kk26xji4sn	cmmreqmij00sxr5lu7c8yggyb	5100	2026-03-15 07:37:21.11	CASH	\N	\N
cmmrfz4d201e1r5kk0qap8ptf	cmmreqmik00szr5lubtbb687x	1700	2026-03-15 07:37:21.111	CASH	\N	\N
cmmrfz4d301e3r5kksdiv2lbs	cmmreqmik00t1r5lu5jlj5jb3	1700	2026-03-15 07:37:21.111	CASH	\N	\N
cmmrfz4d301e5r5kk5f1ap11w	cmmreqmil00t3r5lu1t1c5zkh	1700	2026-03-15 07:37:21.112	CASH	\N	\N
cmmrfz4d401e7r5kkhi45dpxk	cmmreqmil00t5r5lukmzeo30i	1700	2026-03-15 07:37:21.113	CASH	\N	\N
cmmrfz4d501e9r5kkb9aiufkm	cmmreqmim00t7r5lu01naro83	1700	2026-03-15 07:37:21.114	CASH	\N	\N
cmmrfz4d601ebr5kk0g5fzv49	cmmreqmim00tbr5lupx3f2t3x	1700	2026-03-15 07:37:21.114	CASH	\N	\N
cmmrfz4d601edr5kkcklxet53	cmmreqmin00tdr5lu0yxxrh67	1700	2026-03-15 07:37:21.115	CASH	\N	\N
cmmrfz4d701efr5kkw74lgj14	cmmreqmin00tfr5lu4jjyfn6g	1700	2026-03-15 07:37:21.116	CASH	\N	\N
cmmrfz4d801ehr5kknlgivxv4	cmmreqmin00thr5ludfzclitd	1700	2026-03-15 07:37:21.116	CASH	\N	1597 we need to pay
cmmrfz4d901ejr5kk0mod27rg	cmmreqmio00tjr5luf29sgghp	1700	2026-03-15 07:37:21.117	CASH	\N	\N
cmmrfz4da01elr5kksxrlnd4k	cmmreqmip00tlr5lu8100zyhn	3400	2026-03-15 07:37:21.118	CASH	\N	\N
cmmrfz4da01enr5kkmsjn6ro9	cmmreqmip00tnr5lut66e3yna	1700	2026-03-15 07:37:21.119	CASH	\N	\N
cmmrfz4db01epr5kkum2o5k3i	cmmreqmiq00ttr5luiadzr5wv	1700	2026-03-15 07:37:21.119	CASH	\N	\N
cmmrfz4dc01err5kkj9498hxj	cmmreqmiq00tvr5lu9yn1z9eh	1700	2026-03-15 07:37:21.12	CASH	\N	\N
cmmrfz4dd01etr5kkhdlazjcp	cmmreqmir00txr5lujrsmoeps	2000	2026-03-15 07:37:21.121	CASH	\N	\N
cmmrfz4dd01evr5kknvpkpup7	cmmreqmis00u3r5luzamlg72n	3400	2026-03-15 07:37:21.122	CASH	\N	1390 they need to pay
cmmrfz4de01exr5kkie49abbw	cmmreqmis00u5r5luh3jbsdu6	2000	2026-03-15 07:37:21.123	CASH	\N	\N
cmmrfz4df01ezr5kk9tk3notg	cmmreqmit00u7r5lu2h0hzmc5	2000	2026-03-15 07:37:21.123	CASH	\N	\N
cmmrfz4dg01f1r5kkcgnh0hje	cmmreqmit00u9r5luxofklsem	2000	2026-03-15 07:37:21.124	CASH	\N	\N
cmmrfz4dg01f3r5kkjvnvli4p	cmmreqmiu00ubr5luhnawrv4n	2000	2026-03-15 07:37:21.125	CASH	\N	1597 we need to pay
cmmrfz4dh01f5r5kkmtk5u0kp	cmmreqmiu00udr5lusta7dcfr	2000	2026-03-15 07:37:21.126	CASH	\N	\N
cmmrfz4di01f7r5kk2p2dyp4q	cmmreqmiu00ufr5luohnzj2uk	2000	2026-03-15 07:37:21.126	CASH	\N	\N
cmmrfz4dj01f9r5kkyou3b6bj	cmmreqmiv00uhr5lutkf0hn8u	2000	2026-03-15 07:37:21.127	CASH	\N	\N
cmmrfz4dj01fbr5kk2uqz9c3i	cmmreqmiv00ulr5lunwf4hzz6	4186	2026-03-15 07:37:21.128	CASH	\N	\N
cmmrfz4dk01fdr5kkotaynq3j	cmmreqmiw00unr5lujar92ufk	2000	2026-03-15 07:37:21.129	CASH	\N	\N
cmmrfz4dl01ffr5kkjvd4fvrc	cmmreqmiw00upr5lu4clcz5wf	2000	2026-03-15 07:37:21.129	CASH	\N	\N
cmmrfz4dl01fhr5kk6ylz6fyq	cmmreqmiw00urr5lucvtaou7c	2000	2026-03-15 07:37:21.13	CASH	\N	\N
cmmrfz4dm01fjr5kk9xwc0rn1	cmmreqmix00utr5lue8tcnjek	4000	2026-03-15 07:37:21.131	CASH	\N	\N
cmmrfz4dn01flr5kk8kwhnq6x	cmmreqmix00uvr5luu9iyji5e	4000	2026-03-15 07:37:21.131	CASH	\N	\N
cmmrfz4dn01fnr5kky4x6qplf	cmmreqmiy00uxr5lu7mmrkokv	2000	2026-03-15 07:37:21.132	CASH	\N	\N
cmmrfz4do01fpr5kksq2s72fc	cmmreqmiy00uzr5lu476f1ws3	2000	2026-03-15 07:37:21.132	CASH	\N	\N
cmmrfz4do01frr5kkbeot2frv	cmmreqmiy00v1r5lu0izlv13f	2000	2026-03-15 07:37:21.133	CASH	\N	\N
cmmrfz4dp01ftr5kk0qy21orp	cmmreqmiz00v3r5lu42b9n6eg	2000	2026-03-15 07:37:21.133	CASH	\N	\N
cmmrfz4dp01fvr5kk6ac12c60	cmmreqmiz00v5r5lu4aicy5t1	2000	2026-03-15 07:37:21.134	CASH	\N	\N
cmmrfz4dq01fxr5kkq1prcazm	cmmreqmj000v7r5luw7pu4x4h	2000	2026-03-15 07:37:21.134	CASH	\N	\N
cmmrfz4dq01fzr5kkj9liapm3	cmmreqmj000v9r5lupl40w2i5	2000	2026-03-15 07:37:21.135	CASH	\N	\N
cmmrfz4dr01g1r5kkojdt3giq	cmmreqmj100vbr5luc8nkxijg	2000	2026-03-15 07:37:21.136	CASH	\N	\N
cmmrfz4ds01g3r5kk2kko91mz	cmmreqmj100vdr5lu4l7j2a05	4000	2026-03-15 07:37:21.136	CASH	\N	\N
cmmrfz4ds01g5r5kkeb0jb0ii	cmmreqmj100vfr5luubgpkt5e	2000	2026-03-15 07:37:21.137	CASH	\N	\N
cmmrfz4dt01g7r5kkqdg4szp9	cmmreqmj200vhr5lu1z0n0150	2000	2026-03-15 07:37:21.138	CASH	\N	\N
cmmrfz4du01g9r5kky33opx42	cmmreqmj200vjr5lunou0sxlo	2000	2026-03-15 07:37:21.138	CASH	\N	\N
cmmrfz4du01gbr5kk632znrd2	cmmreqmj300vlr5luwlh4vyad	2000	2026-03-15 07:37:21.139	CASH	\N	\N
cmmrfz4dv01gdr5kk0at2foce	cmmreqmj300vnr5lufx0kavdu	2000	2026-03-15 07:37:21.14	CASH	\N	\N
cmmrfz4dw01gfr5kk74dizgjf	cmmreqmj300vpr5luj1tc0gvr	2000	2026-03-15 07:37:21.14	CASH	\N	\N
cmmrfz4dx01ghr5kkvp9wmkg2	cmmreqmj400vrr5lu64g2vhb4	2000	2026-03-15 07:37:21.141	CASH	\N	\N
cmmrfz4dx01gjr5kk96y7ci4b	cmmreqmj400vtr5lueqfgk1hk	2000	2026-03-15 07:37:21.142	CASH	\N	\N
cmmrfz4dy01glr5kku1igggao	cmmreqmj500vvr5lu2nn3dwxz	2000	2026-03-15 07:37:21.143	CASH	\N	\N
cmmrfz4dz01gnr5kk4qywtawn	cmmreqmj500vzr5lu3ixnpbtl	2000	2026-03-15 07:37:21.144	CASH	\N	\N
cmmrfz4e001gpr5kktspghl9c	cmmreqmj600w1r5lukvxn6g1t	2000	2026-03-15 07:37:21.144	CASH	\N	\N
cmmrfz4e001grr5kkw7nh9opl	cmmreqmj600w3r5luctdwxl0c	2000	2026-03-15 07:37:21.145	CASH	\N	\N
cmmrfz4e101gtr5kkptlj28m1	cmmreqmj600w5r5lu8hbwie64	2000	2026-03-15 07:37:21.146	CASH	\N	\N
cmmrfz4e201gvr5kkgy4aeqsz	cmmreqmj700w7r5lued9j36su	2000	2026-03-15 07:37:21.147	CASH	\N	\N
cmmrfz4e301gxr5kk61pces2y	cmmreqmj800w9r5luzjktgn7i	2000	2026-03-15 07:37:21.148	CASH	\N	Water bill 73 rupees pending
cmmrfz4e401gzr5kk1cfpqihk	cmmreqmj900wbr5lufueq8nv2	2000	2026-03-15 07:37:21.148	CASH	\N	\N
cmmrfz4e501h1r5kkww1k6rdp	cmmreqmj900wdr5lu1rgkpf0y	2000	2026-03-15 07:37:21.149	CASH	\N	\N
cmmrfz4e501h3r5kkb0oi8hzz	cmmreqmj900wfr5luk3ybss0c	2000	2026-03-15 07:37:21.15	CASH	\N	\N
cmmrfz4e601h5r5kkbt7i0zs6	cmmreqmja00whr5lugfbwz6cr	2000	2026-03-15 07:37:21.151	CASH	\N	\N
cmmrfz4e701h7r5kkdbcdm3cl	cmmreqmja00wlr5lu7obhuptb	2000	2026-03-15 07:37:21.151	CASH	\N	\N
cmmrfz4e801h9r5kkyhynkc8p	cmmreqmjb00wnr5lu0h45y4mk	2000	2026-03-15 07:37:21.152	CASH	\N	\N
cmmrfz4e801hbr5kk5gjglyt0	cmmreqmjb00wpr5luf3owbory	2000	2026-03-15 07:37:21.153	CASH	\N	\N
cmmrfz4e901hdr5kklu8g6b8q	cmmreqmjb00wrr5lucbp6gpsz	4000	2026-03-15 07:37:21.154	CASH	\N	\N
cmmrfz4ea01hfr5kkxn7jz63j	cmmreqmjc00wtr5luvxf2rr5d	2000	2026-03-15 07:37:21.155	CASH	\N	\N
cmmrfz4eb01hhr5kk9t2xrdc2	cmmreqmjc00wvr5luhn6dvayv	2000	2026-03-15 07:37:21.155	CASH	\N	\N
cmmrfz4ec01hjr5kkaizr9t5v	cmmreqmjc00wxr5lupyn0i7e8	2000	2026-03-15 07:37:21.156	CASH	\N	\N
cmmrfz4ed01hlr5kk7ufbpcs4	cmmreqmjd00wzr5luef1ril66	2000	2026-03-15 07:37:21.157	CASH	\N	\N
cmmrfz4ed01hnr5kkeubogo3m	cmmreqmjd00x1r5luvv8k81gz	2000	2026-03-15 07:37:21.158	CASH	\N	\N
cmmrfz4ee01hpr5kk0de4g6l7	cmmreqmje00x3r5lusbj5u6rm	2000	2026-03-15 07:37:21.159	CASH	\N	\N
cmmrfz4ef01hrr5kkj4qjm4u1	cmmreqmje00x5r5lutwifhmno	2000	2026-03-15 07:37:21.16	CASH	\N	\N
cmmrfz4eg01htr5kkqu9mfvzi	cmmreqmje00x7r5luwd4hkulb	2000	2026-03-15 07:37:21.16	CASH	\N	\N
cmmrfz4eg01hvr5kkmpfts6ug	cmmreqmjf00x9r5lufaob8e77	2000	2026-03-15 07:37:21.161	CASH	\N	\N
cmmrfz4eh01hxr5kkfqw9sij8	cmmreqmjf00xbr5lug7fjbgpf	2000	2026-03-15 07:37:21.162	CASH	\N	\N
cmmrfz4ei01hzr5kkdp5qh3e9	cmmreqmjf00xdr5lu7uhonaj2	4000	2026-03-15 07:37:21.163	CASH	\N	\N
cmmrfz4ej01i1r5kkzl16vxoj	cmmreqmjg00xfr5luj2fp9rbq	2000	2026-03-15 07:37:21.164	CASH	\N	\N
cmmrfz4ek01i3r5kk5f6x9jhr	cmmreqmjg00xhr5lupbdgbt8r	2000	2026-03-15 07:37:21.164	CASH	\N	\N
cmmrfz4el01i5r5kkffwfi1cj	cmmreqmjg00xjr5lu1owx436e	2000	2026-03-15 07:37:21.165	CASH	\N	\N
cmmrfz4em01i7r5kkj7e2l6qp	cmmreqmjh00xlr5luyaz750pg	2000	2026-03-15 07:37:21.166	CASH	\N	\N
cmmrfz4em01i9r5kkid1nwh8t	cmmreqmjh00xnr5lumtk5n9mz	2000	2026-03-15 07:37:21.167	CASH	\N	\N
cmmrfz4en01ibr5kk9gg4yxv5	cmmreqmji00xpr5lucqo9vrzs	2000	2026-03-15 07:37:21.168	CASH	\N	\N
cmmrfz4eo01idr5kkqfadpdw8	cmmreqmji00xrr5lu6107mu1t	2000	2026-03-15 07:37:21.169	CASH	\N	\N
cmmrfz4ep01ifr5kkj59wasi0	cmmreqmji00xtr5lu9kpe9jf9	2000	2026-03-15 07:37:21.169	CASH	\N	\N
cmmrfz4ep01ihr5kkstbsdgc6	cmmreqmjj00xvr5luc20wdcb8	2000	2026-03-15 07:37:21.17	CASH	\N	\N
cmmrfz4eq01ijr5kkuy8a1wja	cmmreqmjj00xxr5lure173jan	2000	2026-03-15 07:37:21.171	CASH	\N	\N
cmmrfz4er01ilr5kkw4ir5paf	cmmreqmjj00xzr5lujjbk6tho	2000	2026-03-15 07:37:21.172	CASH	\N	\N
cmmrfz4es01inr5kkcs7vxllp	cmmreqmjk00y1r5lum119vfzr	2000	2026-03-15 07:37:21.172	CASH	\N	\N
cmmrfz4et01ipr5kkzhrscx9s	cmmreqmjl00y3r5lu8nz18w77	2000	2026-03-15 07:37:21.173	CASH	\N	\N
cmmrfz4et01irr5kktsuya0sq	cmmreqmjl00y5r5lu39z4hnkt	2000	2026-03-15 07:37:21.174	CASH	\N	\N
cmmrfz4eu01itr5kkse3ij4zg	cmmreqmjm00y9r5lu2fa2c284	2000	2026-03-15 07:37:21.175	CASH	\N	\N
cmmrfz4ev01ivr5kkqo9og0x3	cmmreqmjn00ydr5lu4rrjxf51	2000	2026-03-15 07:37:21.175	CASH	\N	\N
cmmrfz4ev01ixr5kk1wctl1hf	cmmreqmjn00yfr5lu9grm2fcz	2000	2026-03-15 07:37:21.176	CASH	\N	\N
cmmrfz4ew01izr5kk4shygsgt	cmmreqmjn00yhr5lu8qux23m8	2000	2026-03-15 07:37:21.177	CASH	\N	\N
cmmrfz4ex01j1r5kkylto1c6k	cmmreqmjo00yjr5lu2a2pukc3	2000	2026-03-15 07:37:21.177	CASH	\N	\N
cmmrfz4ex01j3r5kkfm6v4ueh	cmmreqmjo00ylr5lulvqncibf	2000	2026-03-15 07:37:21.178	CASH	\N	\N
cmmrfz4ey01j5r5kk653chy9i	cmmreqmjp00ypr5ludazvehnh	2000	2026-03-15 07:37:21.179	CASH	\N	\N
cmmrfz4ez01j7r5kkr5end0bb	cmmreqmjp00yrr5lu6yc0ga7i	2000	2026-03-15 07:37:21.179	CASH	\N	\N
cmmrfz4f001j9r5kke66wvl5t	cmmreqmjp00ytr5luw2uk20tr	2000	2026-03-15 07:37:21.18	CASH	\N	\N
cmmrfz4f101jbr5kkw60uerx0	cmmreqmjq00yxr5luubqju68j	2000	2026-03-15 07:37:21.181	CASH	\N	\N
cmmrfz4f101jdr5kke6y5mzep	cmmreqmjr00yzr5luklmf2s0b	2000	2026-03-15 07:37:21.182	CASH	\N	\N
cmmrfz4f201jfr5kkqcly3qj9	cmmreqmjr00z3r5lurgerl2ym	2000	2026-03-15 07:37:21.183	CASH	\N	\N
cmmrfz4f301jhr5kky1kkwq12	cmmreqmjs00z5r5lu44mluig4	4000	2026-03-15 07:37:21.183	CASH	\N	\N
cmmrfz4f401jjr5kkuqswrdbq	cmmreqmjs00z7r5luwxszdxpe	2000	2026-03-15 07:37:21.184	CASH	\N	\N
cmmrfz4f401jlr5kkhwd36onx	cmmreqmjt00zbr5lum4ne2lvw	2000	2026-03-15 07:37:21.185	CASH	\N	\N
cmmrfz4f501jnr5kky5r9oos3	cmmreqmjt00zdr5lul1dggpcx	2000	2026-03-15 07:37:21.186	CASH	\N	\N
cmmrfz4f601jpr5kkph857e1a	cmmreqmjt00zfr5luk6vep4bo	2000	2026-03-15 07:37:21.186	CASH	\N	\N
cmmrfz4f701jrr5kk3osfi3ts	cmmreqmju00zhr5lu84r3382u	2000	2026-03-15 07:37:21.187	CASH	\N	\N
cmmrfz4f701jtr5kk4ca7m1k5	cmmreqmjv00zlr5lup2vhpejc	2000	2026-03-15 07:37:21.188	CASH	\N	\N
cmmrfz4f801jvr5kkd2dfb32k	cmmreqmjv00znr5lu97os87h7	2000	2026-03-15 07:37:21.189	CASH	\N	\N
cmmrfz4f901jxr5kkrglu60x2	cmmreqmjv00zpr5luijgk4tlx	2000	2026-03-15 07:37:21.19	CASH	\N	\N
cmmrfz4fa01jzr5kko4tbhek5	cmmreqmjw00zrr5lum384l95a	2000	2026-03-15 07:37:21.19	CASH	\N	\N
cmmrfz4fb01k1r5kkjnu1ktf1	cmmreqmjw00ztr5lu4bmerkya	2000	2026-03-15 07:37:21.191	CASH	\N	\N
cmmrfz4fb01k3r5kkjbiv5i0i	cmmreqmjx00zvr5lume0rmtjl	6000	2026-03-15 07:37:21.192	CASH	\N	\N
cmmrfz4fc01k5r5kkf7pnkij6	cmmreqmjx00zxr5luadoeqggs	2000	2026-03-15 07:37:21.193	CASH	\N	\N
cmmrfz4fd01k7r5kkyp3lvzdi	cmmreqmjx00zzr5luqqnhj4zk	2000	2026-03-15 07:37:21.193	CASH	\N	\N
cmmrfz4fd01k9r5kky09ldowf	cmmreqmjy0101r5lufoa5litg	2000	2026-03-15 07:37:21.194	CASH	\N	\N
cmmrfz4fe01kbr5kkhay7xufj	cmmreqmjy0103r5luvem65vmi	2000	2026-03-15 07:37:21.194	CASH	\N	2000 is pending
cmmrfz4ff01kdr5kkg8lxs39b	cmmreqmjy0105r5lundv2ww2l	2000	2026-03-15 07:37:21.195	CASH	\N	\N
cmmrfz4fg01kfr5kki52g3an5	cmmreqmjz0109r5lu28k9ge3j	2000	2026-03-15 07:37:21.196	CASH	\N	\N
cmmrfz4fg01khr5kkp7qff895	cmmreqmk0010br5luj9hzm86u	2000	2026-03-15 07:37:21.197	CASH	\N	\N
cmmrfz4fh01kjr5kkbx6tax3g	cmmreqmk0010dr5luc3dwsfi7	4000	2026-03-15 07:37:21.198	CASH	\N	\N
cmmrfz4fi01klr5kkcujmiqgv	cmmreqmk0010fr5lusn5w28b5	2000	2026-03-15 07:37:21.198	CASH	\N	\N
cmmrfz4fj01knr5kkaw4d1c4g	cmmreqmk1010hr5lu8j8kmjwc	2000	2026-03-15 07:37:21.199	CASH	\N	\N
cmmrfz4fj01kpr5kksobjc8tx	cmmreqmk2010lr5lurjsqe8x4	2000	2026-03-15 07:37:21.2	CASH	\N	\N
cmmrfz4fk01krr5kk60l9f31a	cmmreqmk2010nr5lu0v5fa6n7	2000	2026-03-15 07:37:21.201	CASH	\N	\N
cmmrfz4fl01ktr5kkn6jq96je	cmmreqmk2010pr5luf0gbjmop	2000	2026-03-15 07:37:21.201	CASH	\N	\N
cmmrfz4fl01kvr5kkc8njbre5	cmmreqmk3010rr5lunwjx20vq	2000	2026-03-15 07:37:21.202	CASH	\N	\N
cmmrfz4fm01kxr5kkb3ksaso7	cmmreqmk3010tr5luxfl8erwo	2000	2026-03-15 07:37:21.203	CASH	\N	\N
cmmrfz4fn01kzr5kkb9frjsdx	cmmreqmk3010vr5lulkbygavc	2000	2026-03-15 07:37:21.204	CASH	\N	\N
cmmrfz4fo01l1r5kkxznhpb09	cmmreqmk4010xr5lujmdn0nha	2000	2026-03-15 07:37:21.204	CASH	\N	\N
cmmrfz4fs01l3r5kkwhvat8gl	cmmreqmk4010zr5lunhb8ngjk	2000	2026-03-15 07:37:21.208	CASH	\N	\N
cmmrfz4ft01l5r5kkzfsd3elr	cmmreqmk40111r5lukq1l5ebd	4000	2026-03-15 07:37:21.209	CASH	\N	\N
cmmrfz4ft01l7r5kkhgz0w19y	cmmreqmk50113r5lugimdmfsq	2000	2026-03-15 07:37:21.21	CASH	\N	\N
cmmrfz4fu01l9r5kktt2ju7j3	cmmreqmk50115r5luq3f2ufzq	2000	2026-03-15 07:37:21.21	CASH	\N	\N
cmmrfz4fv01lbr5kkk9kr5etz	cmmreqmk60117r5luat0d2qou	2000	2026-03-15 07:37:21.211	CASH	\N	\N
cmmrfz4fw01ldr5kk3946vfj4	cmmreqmk60119r5lu7ojd39nq	2000	2026-03-15 07:37:21.212	CASH	\N	\N
cmmrfz4fw01lfr5kkzyuggu8m	cmmreqmk6011br5lubdjp5lf8	2000	2026-03-15 07:37:21.213	CASH	\N	\N
cmmrfz4fx01lhr5kk29mphnti	cmmreqmk7011dr5luycc3y5rg	2000	2026-03-15 07:37:21.213	CASH	\N	\N
cmmrfz4fy01ljr5kkyavg0jg4	cmmreqmk7011fr5luvpeyioer	2000	2026-03-15 07:37:21.214	CASH	\N	\N
cmmrfz4fy01llr5kk465737wy	cmmreqmk7011hr5lutpfwliyc	2000	2026-03-15 07:37:21.215	CASH	\N	\N
cmmrfz4fz01lnr5kk5rd4cd5b	cmmreqmk8011lr5lu16kv2euc	2000	2026-03-15 07:37:21.215	CASH	\N	\N
cmmrfz4g001lpr5kkbicmt6ff	cmmreqmk9011nr5lu73gtuwlu	2000	2026-03-15 07:37:21.216	CASH	\N	\N
cmmrfz4g001lrr5kkpwy90g5t	cmmreqmk9011pr5lujd0m964j	2000	2026-03-15 07:37:21.217	CASH	\N	\N
cmmrfz4g101ltr5kkfkyzhzgi	cmmreqmka011tr5ludaiz5lwr	2000	2026-03-15 07:37:21.217	CASH	\N	\N
cmmrfz4g201lvr5kk8voa8dhg	cmmreqmka011vr5lu2ue7zayb	2000	2026-03-15 07:37:21.218	CASH	\N	\N
cmmrfz4g201lxr5kkjdf0z7c9	cmmreqmkc0121r5lu1pfr212z	2000	2026-03-15 07:37:21.219	CASH	\N	\N
cmmrfz4g301lzr5kkz52fnpwc	cmmreqmkc0123r5luj4urbm3a	2000	2026-03-15 07:37:21.219	CASH	\N	paid 4000 extra
cmmrfz4g301m1r5kk373gdb4p	cmmreqmkd0125r5luy82kzyrf	2000	2026-03-15 07:37:21.22	CASH	\N	\N
cmmrfz4g401m3r5kkch1pgp8k	cmmreqmkd0127r5lu5ni81qxh	2000	2026-03-15 07:37:21.221	CASH	\N	\N
cmmrfz4g501m5r5kky8oohvts	cmmreqmke0129r5lujr8rr672	2000	2026-03-15 07:37:21.222	CASH	\N	Water bill paid
cmmrfz4g601m7r5kkmy9b2jf7	cmmreqmke012br5lurbji3qs0	2000	2026-03-15 07:37:21.222	CASH	\N	Water bill paid
cmmrfz4g601m9r5kkvh2wbkde	cmmreqmkf012fr5luvzeabmti	2000	2026-03-15 07:37:21.223	CASH	\N	Water bill paid
cmmrfz4g701mbr5kk0cntgni3	cmmreqmkf012hr5lu70ar2u8x	2000	2026-03-15 07:37:21.224	CASH	\N	last month water bill 312
cmmrfz4g801mdr5kk2ac2vzg6	cmmreqmkf012jr5luxhe6wc22	2000	2026-03-15 07:37:21.224	CASH	\N	Water bill paid
cmmrfz4g801mfr5kkb68dnpq9	cmmreqmkg012lr5luzu5etvf1	2000	2026-03-15 07:37:21.225	CASH	\N	Water bill paid
cmmrfz4g901mhr5kkk8dejbgt	cmmreqmkh012pr5luwqqo8j8m	2000	2026-03-15 07:37:21.225	CASH	\N	Water bill paid
cmmrfz4ga01mjr5kk73spoike	cmmreqmkh012rr5lu6lh41cu3	2000	2026-03-15 07:37:21.226	CASH	\N	Water bill paid
cmmrfz4ga01mlr5kkih9aclcf	cmmreqmkh012tr5luibc3lixz	2000	2026-03-15 07:37:21.227	CASH	\N	Water bill paid
cmmrfz4gb01mnr5kkydkyvrhn	cmmreqmki012vr5lud50qju2z	2000	2026-03-15 07:37:21.227	CASH	\N	Water bill paid
cmmrfz4gb01mpr5kklwo0ghwr	cmmreqmki012xr5lur55plvlm	2000	2026-03-15 07:37:21.228	CASH	\N	paid 4000 extra \nremaining 2892
cmmrfz4gc01mrr5kkunzu24cu	cmmreqmki012zr5lucqnpqj0b	2000	2026-03-15 07:37:21.229	CASH	\N	Water bill paid
cmmrfz4gd01mtr5kk2w5hw1aq	cmmreqmkj0131r5lu0g7lmzx4	2000	2026-03-15 07:37:21.229	CASH	\N	Water bill paid
cmmrfz4ge01mvr5kkn2vbwd52	cmmreqmkj0133r5lu99kkkp7j	2000	2026-03-15 07:37:21.23	CASH	\N	Water bill paid
cmmrfz4ge01mxr5kk5mxrdsm8	cmmreqmkj0135r5luzdfo1b5o	4000	2026-03-15 07:37:21.231	CASH	\N	Water bill paid
cmmrfz4gf01mzr5kkl1ly9tsh	cmmreqmkk0137r5luruzs64o4	6000	2026-03-15 07:37:21.231	CASH	\N	Water bill paid
cmmrfz4gf01n1r5kkkeeo0lri	cmmreqmkk0139r5lun4b45luj	2000	2026-03-15 07:37:21.232	CASH	\N	Water bill paid
cmmrfz4gg01n3r5kkpp72aabk	cmmreqmkl013br5luk13uz27m	2000	2026-03-15 07:37:21.233	CASH	\N	Water bill paid
cmmrfz4gh01n5r5kk446vd431	cmmreqmkl013dr5lu0pd6zu25	2000	2026-03-15 07:37:21.233	CASH	\N	Water bill paid
cmmrfz4gh01n7r5kk69duk4vv	cmmreqmkm013fr5luk45alzv4	2000	2026-03-15 07:37:21.234	CASH	\N	Water bill paid
cmmrfz4gi01n9r5kkyhlz2tmh	cmmreqmkm013hr5luc1tzrcrc	2000	2026-03-15 07:37:21.235	CASH	\N	Water bill paid
cmmrfz4gj01nbr5kkhmt38980	cmmreqmkn013jr5luxvap37fp	2000	2026-03-15 07:37:21.235	CASH	\N	Water bill paid
cmmrfz4gj01ndr5kk7et8u3cr	cmmreqmko013nr5luxx6fylq6	2000	2026-03-15 07:37:21.236	CASH	\N	Water bill paid
cmmrfz4gk01nfr5kkofoaskpk	cmmreqmko013pr5lum8pyctk2	2000	2026-03-15 07:37:21.237	CASH	\N	Water bill paid
cmmrfz4gl01nhr5kkk4ny7qb7	cmmreqmko013rr5luyir45of8	2000	2026-03-15 07:37:21.237	CASH	\N	784 water bill pending
cmmrfz4gm01njr5kkyozhvuy1	cmmreqmkp013tr5lu3e5taq9x	2000	2026-03-15 07:37:21.238	CASH	\N	Water bill paid
cmmrfz4gm01nlr5kkfdf4tok4	cmmreqmkp013vr5lul8n6ztyp	2000	2026-03-15 07:37:21.239	CASH	\N	Water bill paid
cmmrfz4gn01nnr5kkwka3dbzk	cmmreqmkq013zr5lus6hyw2uk	2000	2026-03-15 07:37:21.24	CASH	\N	water bill paid
cmmrfz4go01npr5kkiii7f191	cmmreqmkq0143r5lu8xpg8o8v	2000	2026-03-15 07:37:21.24	CASH	\N	water bill paid
cmmrfz4gp01nrr5kkn2h4h2ei	cmmreqmkr0145r5lun5n3hp9i	2000	2026-03-15 07:37:21.241	CASH	\N	water bill paid
cmmrfz4gp01ntr5kkwpok9o7g	cmmreqmkr0147r5luzdffh6ti	2000	2026-03-15 07:37:21.242	CASH	\N	water bill paid
cmmrfz4gq01nvr5kk7infxxtl	cmmreqmkr0149r5lu6delsu6t	2000	2026-03-15 07:37:21.243	CASH	\N	water bill paid
cmmrfz4gs01nxr5kkn67l5py8	cmmreqmks014br5lu73jse6t6	2000	2026-03-15 07:37:21.244	CASH	\N	water bill paid
cmmrfz4gt01nzr5kkju7cgi83	cmmreqmks014dr5luvgw1xgxt	2000	2026-03-15 07:37:21.245	CASH	\N	water bill paid
cmmrfz4gt01o1r5kkmsfkrkp3	cmmreqmkt014fr5lucf89ef2d	4000	2026-03-15 07:37:21.246	CASH	\N	water bill paid
cmmrfz4gu01o3r5kk5klafpdj	cmmreqmkt014hr5luw0i5sduw	2000	2026-03-15 07:37:21.247	CASH	\N	water bill paid
cmmrfz4gv01o5r5kknayeaq6v	cmmreqmkt014jr5lug6darums	2000	2026-03-15 07:37:21.247	CASH	\N	water bill paid
cmmrfz4gw01o7r5kkf70gypv7	cmmreqmku014lr5luziz7tn0h	2000	2026-03-15 07:37:21.248	CASH	\N	water bill paid
cmmrfz4gw01o9r5kktxzimlti	cmmreqmku014nr5lucg9p43js	2000	2026-03-15 07:37:21.249	CASH	\N	water bill paid
cmmrfz4gx01obr5kkgollhwce	cmmreqmkv014pr5lu2nxtm18y	2000	2026-03-15 07:37:21.25	CASH	\N	water bill paid
cmmrfz4gy01odr5kkcvoxw6p5	cmmreqmkv014tr5luumaogjx5	4000	2026-03-15 07:37:21.25	CASH	\N	water bill paid
cmmrfz4gy01ofr5kkm1wgqhlt	cmmreqmkw014vr5lubpl6nynp	2000	2026-03-15 07:37:21.251	CASH	\N	water bill paid
cmmrfz4gz01ohr5kk8wzx6in8	cmmreqml8014xr5lurmvw5jc1	4000	2026-03-15 07:37:21.252	CASH	\N	water bill paid
cmmrfz4h001ojr5kkef5e3nk6	cmmreqml9014zr5lu3fc47y3o	2000	2026-03-15 07:37:21.252	CASH	\N	water bill paid
cmmrfz4h001olr5kk5nhf9105	cmmreqmla0151r5ludltse5e2	2000	2026-03-15 07:37:21.253	CASH	\N	water bill paid and Extra amount paid 334
cmmrfz4h101onr5kk31zkipm6	cmmreqmla0153r5lutsv8knef	2000	2026-03-15 07:37:21.253	CASH	\N	water bill paid
cmmrfz4h201opr5kk5ab2orda	cmmreqmlb0155r5lu2mkf3wt1	2000	2026-03-15 07:37:21.255	CASH	\N	water bill paid
cmmrfz4h301orr5kktq1002w0	cmmreqmlb0157r5luz94w7zp5	2000	2026-03-15 07:37:21.255	CASH	\N	water bill paid
cmmrfz4h401otr5kkcgekrntq	cmmreqmlc0159r5lu92qpu70n	2000	2026-03-15 07:37:21.257	CASH	\N	water bill paid
cmmrfz4h501ovr5kk7hxql169	cmmreqmld015br5lubkcwnbyh	4000	2026-03-15 07:37:21.257	CASH	\N	water bill paid
cmmrfz4h601oxr5kkjd9ounw8	cmmreqmld015dr5lui1jj6ddb	2000	2026-03-15 07:37:21.258	CASH	\N	water bill paid
cmmrfz4h601ozr5kklmsifb8j	cmmreqmld015fr5lu1d4dibcz	2000	2026-03-15 07:37:21.259	CASH	\N	water bill paid
cmmrfz4h701p1r5kkz3rtm3tw	cmmreqmlf015jr5lubhccf0s2	2000	2026-03-15 07:37:21.26	CASH	\N	water bill paid
cmmrfz4h801p3r5kk7e098ua6	cmmreqmlf015lr5luz1pze4j2	2000	2026-03-15 07:37:21.26	CASH	\N	water bill paid
cmmrfz4h801p5r5kkdz4qjfqx	cmmreqmlg015nr5luu25nh9ri	2000	2026-03-15 07:37:21.261	CASH	\N	Water bill paid
cmmrfz4h901p7r5kkc6pyzsy9	cmmreqmlg015pr5luja1i2ov8	2000	2026-03-15 07:37:21.262	CASH	\N	Water bill paid
cmmrfz4hb01p9r5kkdq0p9azq	cmmreqmlk015vr5luu2zcr5d8	2000	2026-03-15 07:37:21.263	CASH	\N	335 water bill is pending
cmmrfz4hb01pbr5kko1f5eiwg	cmmreqmlk015xr5luhanw1uhv	2000	2026-03-15 07:37:21.264	CASH	\N	water bill paid
cmmrfz4hc01pdr5kk0v18c2s7	cmmreqmlm0161r5lu1d0j8p61	2000	2026-03-15 07:37:21.265	CASH	\N	water bill paid
cmmrfz4hd01pfr5kky5i4709b	cmmreqmlm0163r5lubvghql45	2000	2026-03-15 07:37:21.265	CASH	\N	water bill paid
cmmrfz4he01phr5kk496i3pjg	cmmreqmln0167r5luiphgl6gq	2000	2026-03-15 07:37:21.266	CASH	\N	water bill paid
cmmrfz4he01pjr5kk6zpvu2k7	cmmreqmlo0169r5lug84jvugr	2000	2026-03-15 07:37:21.267	CASH	\N	water bill paid
cmmrfz4hf01plr5kkd7kalyf3	cmmreqmlo016br5luuqoxvy8d	4000	2026-03-15 07:37:21.268	CASH	\N	water bill paid
cmmrfz4hg01pnr5kkjo3dob3m	cmmreqmlp016dr5lu7om7m0cr	2000	2026-03-15 07:37:21.268	CASH	\N	water bill paid
cmmrfz4hg01ppr5kksip0gnva	cmmreqmlp016fr5lug995yz55	2000	2026-03-15 07:37:21.269	CASH	\N	water bill paid
cmmrfz4hh01prr5kkzcyyhg0w	cmmreqmlq016hr5lu3iahb3mv	2000	2026-03-15 07:37:21.269	CASH	\N	Water bill paid
cmmrfz4hi01ptr5kknhh4kyey	cmmreqmlq016jr5ludgdpr5dl	2000	2026-03-15 07:37:21.27	CASH	\N	Water bill paid
cmmrfz4hj01pvr5kk1dpzgpyp	cmmreqmlr016nr5lu4ob2szk4	4000	2026-03-15 07:37:21.271	CASH	\N	Water bill paid
cmmrfz4hj01pxr5kkzx7xrl3m	cmmreqmls016pr5luedf0m427	2000	2026-03-15 07:37:21.272	CASH	\N	335 water bill is pending
cmmrfz4hk01pzr5kksuwwhc5e	cmmreqmls016rr5lukv73glu4	2000	2026-03-15 07:37:21.273	CASH	\N	water bill paid
cmmrfz4hl01q1r5kkrdhoici9	cmmreqmlt016tr5lu27w8oe1y	2000	2026-03-15 07:37:21.273	CASH	\N	water bill paid
cmmrfz4hm01q3r5kkgps1v7c2	cmmreqmlu016xr5lu4sweqaon	2000	2026-03-15 07:37:21.274	CASH	\N	water bill paid
cmmrfz4hm01q5r5kkgej7lna4	cmmreqmlv016zr5lu94c7at5c	4000	2026-03-15 07:37:21.275	CASH	\N	water bill paid
cmmrfz4hn01q7r5kk47p9yllv	cmmreqmlv0171r5lunjnrmkmf	2000	2026-03-15 07:37:21.275	CASH	\N	water bill paid
cmmrfz4ho01q9r5kk7xnu97wx	cmmreqmlw0173r5lu0cm1ywm1	2000	2026-03-15 07:37:21.276	CASH	\N	water bill paid
cmmrfz4ho01qbr5kkoin8ig67	cmmreqmlx0177r5lu3exromcq	2000	2026-03-15 07:37:21.277	CASH	\N	water bill paid
cmmrfz4hp01qdr5kk78n9lwoo	cmmreqmlx0179r5lu7afo3jij	2000	2026-03-15 07:37:21.277	CASH	\N	water bill paid
cmmrfz4hp01qfr5kktjn2br2o	cmmreqmlx017br5lu8mzt2smr	2000	2026-03-15 07:37:21.278	CASH	\N	Water bill paid
cmmrfz4hq01qhr5kkz5pw9dkw	cmmreqmly017dr5luaic35fa7	2000	2026-03-15 07:37:21.279	CASH	\N	Water bill paid
cmmrfz4hr01qjr5kko1zj6uxu	cmmreqmly017fr5luxhjjfdqu	4000	2026-03-15 07:37:21.28	CASH	\N	Water bill paid
cmmrfz4hs01qlr5kkb5lk8m85	cmmreqmlz017hr5lua3w0jzah	2000	2026-03-15 07:37:21.28	CASH	\N	Water bill paid
cmmrfz4hs01qnr5kk8xi0gq6q	cmmreqmlz017jr5lu00t4th6m	2000	2026-03-15 07:37:21.281	CASH	\N	Water bill paid
cmmrfz4ht01qpr5kk3phgm47v	cmmreqmlz017lr5lu16sij1g9	2000	2026-03-15 07:37:21.281	CASH	\N	water bill paid
cmmrfz4hu01qrr5kkwtfjdoz8	cmmreqmm1017pr5luh9vpuu43	2000	2026-03-15 07:37:21.282	CASH	\N	water bill paid
cmmrfz4hu01qtr5kk5ubbss90	cmmreqmm1017rr5lu2dwt45s2	2000	2026-03-15 07:37:21.283	CASH	\N	water bill paid
cmmrfz4hv01qvr5kkj75kc7kl	cmmreqmm2017tr5luo478txmk	2000	2026-03-15 07:37:21.284	CASH	\N	water bill paid
cmmrfz4hw01qxr5kktv5xt7bu	cmmreqmm2017vr5luv889ojvy	2000	2026-03-15 07:37:21.284	CASH	\N	water bill paid
cmmrfz4hx01qzr5kkj7bqy5ev	cmmreqmm3017xr5lui0valb73	2000	2026-03-15 07:37:21.285	CASH	\N	water bill paid
cmmrfz4hx01r1r5kkysehlkzu	cmmreqmm3017zr5lutwb4j9hh	4000	2026-03-15 07:37:21.286	CASH	\N	water bill paid
cmmrfz4hy01r3r5kk4pfw28zu	cmmreqmm30181r5lubuv4t88j	2000	2026-03-15 07:37:21.287	CASH	\N	water bill paid
cmmrfz4hz01r5r5kk5it378u8	cmmreqmm40183r5lunqm0jrxz	2000	2026-03-15 07:37:21.287	CASH	\N	water bill paid
cmmrfz4i001r7r5kkzw8bn8il	cmmreqmm40185r5lu40c9kwjm	2000	2026-03-15 07:37:21.288	CASH	\N	Water bill paid
cmmrfz4i101r9r5kkfmp3kmeb	cmmreqmm40187r5luymmsmc56	2000	2026-03-15 07:37:21.289	CASH	\N	Water bill paid
cmmrfz4i201rbr5kk25p6vaf6	cmmreqmm5018br5lucy3b1p5b	2000	2026-03-15 07:37:21.29	CASH	\N	Water bill paid
cmmrfz4i301rdr5kkqud4frc0	cmmreqmm5018dr5lucyy2oui3	2000	2026-03-15 07:37:21.291	CASH	\N	Water bill paid
cmmrfz4i301rfr5kkhspim90m	cmmreqmm6018fr5lu871gzb7g	2000	2026-03-15 07:37:21.292	CASH	\N	water bill paid
cmmrfz4i401rhr5kk06h1mhjp	cmmreqmm6018jr5luiwq6v0fz	2000	2026-03-15 07:37:21.293	CASH	\N	water bill paid
cmmrfz4i501rjr5kkowzy9tlm	cmmreqmm7018lr5luow0tyhk1	2000	2026-03-15 07:37:21.293	CASH	\N	water bill paid
cmmrfz4i501rlr5kk4pi9thna	cmmreqmm7018nr5luwg1taueo	2000	2026-03-15 07:37:21.294	CASH	\N	water bill paid
cmmrfz4i601rnr5kkilts0zza	cmmreqmm8018pr5lup5mi4g6v	2000	2026-03-15 07:37:21.294	CASH	\N	water bill paid
cmmrfz4i701rpr5kk26744sc8	cmmreqmm8018rr5luo8is1cww	2000	2026-03-15 07:37:21.295	CASH	\N	water bill paid
cmmrfz4i801rrr5kk66ht4tae	cmmreqmm9018tr5lu5c8pcpbf	2000	2026-03-15 07:37:21.296	CASH	\N	water bill paid, 174 extra amount is there
cmmrfz4i801rtr5kk98rf8eah	cmmreqmm9018vr5lufysuu99u	2000	2026-03-15 07:37:21.297	CASH	\N	water bill paid
cmmrfz4i901rvr5kku7uxx13l	cmmreqmma018xr5lu2yrlqyvd	2000	2026-03-15 07:37:21.298	CASH	\N	water bill paid
cmmrfz4ia01rxr5kknobx6xns	cmmreqmma018zr5lu2f2jygvg	2000	2026-03-15 07:37:21.298	CASH	\N	\N
cmmrfz4ib01rzr5kky8y5bwz5	cmmreqmmb0193r5luvtqvd7kr	4000	2026-03-15 07:37:21.299	CASH	\N	\N
cmmrfz4ib01s1r5kkkzin9hlk	cmmreqmmb0195r5lur1upyfcw	2000	2026-03-15 07:37:21.3	CASH	\N	\N
cmmrfz4ic01s3r5kka9osru9h	cmmreqmmc0197r5luesxnhu0s	2000	2026-03-15 07:37:21.3	CASH	\N	\N
cmmrfz4id01s5r5kkcqvpgb8c	cmmreqmmc0199r5lucoept0kf	2000	2026-03-15 07:37:21.301	CASH	\N	\N
cmmrfz4id01s7r5kkg0rqv9v7	cmmreqmmd019br5lu14d2pcje	6000	2026-03-15 07:37:21.302	CASH	\N	\N
cmmrfz4ie01s9r5kkguvk0w2h	cmmreqmmd019dr5luijbpsny3	2000	2026-03-15 07:37:21.303	CASH	\N	3100 we need to give to them.
cmmrfz4if01sbr5kkc1qapt3j	cmmreqmme019fr5lusxdbrxgn	2000	2026-03-15 07:37:21.303	CASH	\N	\N
cmmrfz4if01sdr5kk6b1yn5r1	cmmreqmmf019jr5ludil093u3	2000	2026-03-15 07:37:21.304	CASH	\N	\N
cmmrfz4ih01sfr5kkk2jkwttd	cmmreqmmg019pr5lu4mo6b60h	2000	2026-03-15 07:37:21.305	CASH	\N	\N
cmmrfz4ih01shr5kkjkrvys3e	cmmreqmmh019rr5lumtsr3f1u	2000	2026-03-15 07:37:21.306	CASH	\N	\N
cmmrfz4ii01sjr5kktq1thj4t	cmmreqmmh019tr5luw6qcu4jk	2000	2026-03-15 07:37:21.307	CASH	\N	\N
cmmrfz4ij01slr5kkapw2q0qr	cmmreqmmi019vr5luvdheuo73	4000	2026-03-15 07:37:21.308	CASH	\N	\N
cmmrfz4ik01snr5kk89br4pdc	cmmreqmmj019zr5lu7vd9ti1h	2000	2026-03-15 07:37:21.308	CASH	\N	\N
cmmrfz4il01spr5kk0lmisg97	cmmreqmmj01a1r5ludarvvhia	2000	2026-03-15 07:37:21.309	CASH	\N	\N
cmmrfz4il01srr5kkfs7jp1uc	cmmreqmmk01a3r5luqn0rezmy	2000	2026-03-15 07:37:21.31	CASH	\N	\N
cmmrfz4im01str5kkf5wlpkms	cmmreqmmk01a5r5lurplcdldv	2000	2026-03-15 07:37:21.311	CASH	\N	\N
cmmrfz4in01svr5kk8mik82oh	cmmreqmml01a7r5lusqcufv3i	2000	2026-03-15 07:37:21.311	CASH	\N	1100 we need to give
cmmrfz4in01sxr5kk52e28set	cmmreqmml01a9r5lu85f5q7ke	2000	2026-03-15 07:37:21.312	CASH	\N	\N
cmmrfz4ip01szr5kkkp7d47z1	cmmreqmmm01abr5lup93ztnlr	4000	2026-03-15 07:37:21.313	CASH	\N	\N
cmmrfz4ip01t1r5kkncmsfp5r	cmmreqmmm01adr5lu83shtsyb	2000	2026-03-15 07:37:21.314	CASH	\N	\N
cmmrfz4iq01t3r5kkklgwytjn	cmmreqmmn01afr5lu3e1gpi4p	4000	2026-03-15 07:37:21.315	CASH	\N	\N
cmmrfz4ir01t5r5kkt5s50k5o	cmmreqmmn01ahr5lulq1jd1ez	4000	2026-03-15 07:37:21.315	CASH	\N	174 we need to give.
cmmrfz4is01t7r5kkap9be7kh	cmmreqmmo01ajr5lufn2cwioj	2000	2026-03-15 07:37:21.316	CASH	\N	\N
cmmrfz4is01t9r5kkxcix9dtk	cmmreqmmo01alr5luf3dx39zx	2000	2026-03-15 07:37:21.317	CASH	\N	\N
cmmrfz4it01tbr5kk08js6j5n	cmmreqmmo01anr5luimwiv9f8	2000	2026-03-15 07:37:21.318	CASH	\N	\N
cmmrfz4iu01tdr5kkcw9ico0z	cmmreqmmp01apr5lu4gknb08v	4000	2026-03-15 07:37:21.318	CASH	\N	\N
cmmrfz4iv01tfr5kk9w85l8rq	cmmreqmmq01atr5lu0r41jv18	2000	2026-03-15 07:37:21.319	CASH	\N	\N
cmmrfz4iv01thr5kk4f5tb5yq	cmmreqmmq01avr5lu9f2zp7di	2000	2026-03-15 07:37:21.32	CASH	\N	\N
cmmrfz4iw01tjr5kkl070a8dn	cmmreqmmr01axr5lu7t3p1z4x	2000	2026-03-15 07:37:21.32	CASH	\N	\N
cmmrfz4ix01tlr5kkymrqmmiw	cmmreqmmr01azr5luvzpsvvqt	2000	2026-03-15 07:37:21.321	CASH	\N	\N
cmmrfz4iy01tnr5kkwpr0pj0n	cmmreqmms01b1r5lugnaemrul	2000	2026-03-15 07:37:21.322	CASH	\N	1100 we need to give
cmmrfz4iy01tpr5kk31g5cr5p	cmmreqmms01b3r5luvugghs5t	2000	2026-03-15 07:37:21.323	CASH	\N	\N
cmmrfz4iz01trr5kk0t3netd3	cmmreqmmt01b5r5lubyrv5q8d	4000	2026-03-15 07:37:21.324	CASH	\N	\N
cmmrfz4j001ttr5kkvvne59fk	cmmreqmmt01b7r5lu4afhv5fh	2000	2026-03-15 07:37:21.324	CASH	\N	1375 we need to give
cmmrfz4j101tvr5kkmjklmm51	cmmreqmmu01b9r5lu457x7n62	4000	2026-03-15 07:37:21.325	CASH	\N	\N
cmmrfz4j101txr5kkfgmqc2lc	cmmreqmmv01bbr5lujhpzdumj	4000	2026-03-15 07:37:21.326	CASH	\N	174 we need to give.
cmmrfz4j201tzr5kkcl2x4zk6	cmmreqmmv01bdr5lumlw4mkb3	2000	2026-03-15 07:37:21.327	CASH	\N	\N
cmmrfz4j301u1r5kk8yidjq3h	cmmreqmmw01bfr5luyov531mr	2000	2026-03-15 07:37:21.327	CASH	\N	\N
cmmrfz4j401u3r5kka0pw25ad	cmmreqmmw01bhr5lue9nid3cs	2000	2026-03-15 07:37:21.328	CASH	\N	\N
cmmrfz4j501u5r5kkzx8juodb	cmmreqmmx01bjr5lu9ftswhpx	2000	2026-03-15 07:37:21.329	CASH	\N	\N
cmmrfz4j501u7r5kkchi8t1jq	cmmreqmmy01bnr5lura7zcr69	2000	2026-03-15 07:37:21.33	CASH	\N	\N
cmmrfz4j601u9r5kk08zmxyz1	cmmreqmmy01bpr5lu9ssbqfo8	2000	2026-03-15 07:37:21.331	CASH	\N	\N
cmmrfz4j701ubr5kkpqj0z8no	cmmreqmmy01brr5lugzknsd8g	2000	2026-03-15 07:37:21.331	CASH	\N	\N
cmmrfz4j801udr5kkbpb7aunp	cmmreqmmz01btr5lu10ha9590	2000	2026-03-15 07:37:21.332	CASH	\N	\N
cmmrfz4j801ufr5kkjg53oivv	cmmreqmmz01bvr5luaxy9xghp	2000	2026-03-15 07:37:21.333	CASH	\N	\N
cmmrfz4j901uhr5kksosdm8zd	cmmreqmn001bxr5luizts1try	2000	2026-03-15 07:37:21.334	CASH	\N	\N
cmmrfz4ja01ujr5kkeazcjr7z	cmmreqmn001bzr5lu8j69ro40	2000	2026-03-15 07:37:21.334	CASH	\N	\N
cmmrfz4jb01ulr5kk4n9x5gxx	cmmreqmn101c3r5lur7zv85y8	2000	2026-03-15 07:37:21.335	CASH	\N	\N
cmmrfz4jb01unr5kk7jimdg0y	cmmreqmn201c5r5lu9dvkj1w0	2000	2026-03-15 07:37:21.336	CASH	\N	\N
cmmrfz4jc01upr5kksdgpap86	cmmreqmn201c7r5luqpubn6ui	2000	2026-03-15 07:37:21.336	CASH	\N	\N
cmmrfz4jd01urr5kksh4m3tvt	cmmreqmn301cbr5lujmvvhmx1	2000	2026-03-15 07:37:21.337	CASH	\N	\N
cmmrfz4je01utr5kkym8t6ved	cmmreqmn401cfr5lumi460x7l	6000	2026-03-15 07:37:21.338	CASH	\N	\N
cmmrfz4je01uvr5kk8eigslq7	cmmreqmn401chr5lud7mhegwy	2000	2026-03-15 07:37:21.339	CASH	\N	\N
cmmrfz4jf01uxr5kkj2ddzau6	cmmreqmn401cjr5luqlfh7w1u	2000	2026-03-15 07:37:21.339	CASH	\N	\N
cmmrfz4jg01uzr5kkb4i5y22z	cmmreqmn501clr5luxqcwliu4	2000	2026-03-15 07:37:21.34	CASH	\N	\N
cmmrfz4jg01v1r5kk36nrvq38	cmmreqmn501cnr5lus77j0bjj	2000	2026-03-15 07:37:21.341	CASH	\N	\N
cmmrfz4jh01v3r5kk8zzd5zjm	cmmreqmn601cpr5luxd3imyyg	2000	2026-03-15 07:37:21.342	CASH	\N	\N
cmmrfz4ji01v5r5kkogzwcpfz	cmmreqmn701cvr5lu3jxi2364	2625	2026-03-15 07:37:21.342	CASH	\N	\N
cmmrfz4jj01v7r5kkxhmklhnp	cmmreqmn701cxr5lu7zvmtojf	2000	2026-03-15 07:37:21.343	CASH	\N	\N
cmmrfz4jj01v9r5kkl694h94s	cmmreqmn801czr5lunbqpspl3	2000	2026-03-15 07:37:21.344	CASH	\N	\N
cmmrfz4jk01vbr5kkehymlhuj	cmmreqmn801d1r5luzjdqmcsg	2000	2026-03-15 07:37:21.344	CASH	\N	\N
cmmrfz4jl01vdr5kk0wpy03ph	cmmreqmn801d3r5lupn3x8hro	2000	2026-03-15 07:37:21.345	CASH	\N	2000 pending
cmmrfz4jm01vfr5kk96iup5dj	cmmrdgxy70001r5c3d65t5nk2	2000	2026-03-15 07:37:21.346	CASH	\N	\N
cmmrfz4jm01vhr5kk1tc7mh3z	cmmrdgxyc0003r5c3z0y7a5cd	2000	2026-03-15 07:37:21.347	CASH	\N	2000 pending
cmmrfz4jn01vjr5kkbran2b83	cmmrdgxyf0005r5c3gbuz6oag	2000	2026-03-15 07:37:21.348	CASH	\N	\N
cmmrfz4jo01vlr5kk9v91q2ef	cmmrdgxyj0007r5c3anonx7rw	2000	2026-03-15 07:37:21.348	CASH	\N	\N
cmmrfz4jp01vnr5kkrxnedf1r	cmmrdgxym0009r5c36icwkik3	2000	2026-03-15 07:37:21.349	CASH	\N	\N
cmmrfz4jp01vpr5kk95zlbhgo	cmmrdgxyp000br5c3yrl8h0qp	2000	2026-03-15 07:37:21.35	CASH	\N	\N
cmmrfz4jq01vrr5kkz3ilnjh4	cmmrdgxys000dr5c3ng9kx5ev	2000	2026-03-15 07:37:21.35	CASH	\N	\N
cmmrfz4jr01vtr5kkv2i9n6gz	cmmrdgxyu000fr5c3z3a1cl3e	2000	2026-03-15 07:37:21.351	CASH	\N	\N
cmmrfz4jr01vvr5kkfhfmd880	cmmrdgxz1000jr5c3j8nqxt0l	4000	2026-03-15 07:37:21.352	CASH	\N	\N
cmmrfz4js01vxr5kk5gjqajiu	cmmrdgxz4000lr5c38o35cqkf	2000	2026-03-15 07:37:21.352	CASH	\N	\N
cmmrfz4js01vzr5kkhdsxxuqh	cmmrdgxza000nr5c3klf8fuot	2000	2026-03-15 07:37:21.353	CASH	\N	\N
cmmrfz4jt01w1r5kk1r7wprl1	cmmrdgxzc000pr5c3u31ht8y2	2000	2026-03-15 07:37:21.354	CASH	\N	\N
cmmrfz4ju01w3r5kktbj7ugdz	cmmrdgxzf000rr5c3773x0pca	2000	2026-03-15 07:37:21.355	CASH	\N	\N
cmmrfz4jv01w5r5kk0wk7kgkh	cmmrdgxzh000tr5c3tdwjmmfq	4000	2026-03-15 07:37:21.355	CASH	\N	\N
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, name, email, phone, password, role, "createdAt", "updatedAt", "isOwnerTenant") FROM stdin;
cmmqfin2i0000r5riksj20y54	PSA Admin	admin@psa.com	7093991333	$2a$10$N5NgkjmkU6zBaQJcO16LBOq6qxJwdIecpjvBZx2D.3LJ2g480hZDS	ADMIN	2026-03-14 14:36:46.026	2026-03-14 14:36:46.026	f
cmmqfin2v0003r5rid4lrhpg3	Resident 101	flat101@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.04	2026-03-14 14:36:46.04	f
cmmqfin310008r5rizm9dia5q	Resident 102	flat102@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.046	2026-03-14 14:36:46.046	f
cmmqfin35000dr5rizrtqlucc	Resident 103	flat103@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.05	2026-03-14 14:36:46.05	f
cmmqfin38000ir5ri6m0kii1w	Resident 201	flat201@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.052	2026-03-14 14:36:46.052	f
cmmqfin3a000nr5rifmdtmn4l	Resident 202	flat202@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.054	2026-03-14 14:36:46.054	f
cmmqfin3d000sr5rihf8qwecl	Resident 203	flat203@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.058	2026-03-14 14:36:46.058	f
cmmqfin3g000xr5ribkvvqrk0	Resident 301	flat301@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.06	2026-03-14 14:36:46.06	f
cmmqfin3i0012r5rijo82cm7a	Resident 302	flat302@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.063	2026-03-14 14:36:46.063	f
cmmqfin3l0017r5ri167ce1oj	Resident 303	flat303@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.066	2026-03-14 14:36:46.066	f
cmmqfin3o001cr5ri5bpkv24a	Resident 401	flat401@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.069	2026-03-14 14:36:46.069	f
cmmqfin3q001hr5riwxj65axe	Resident 402	flat402@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.071	2026-03-14 14:36:46.071	f
cmmqfin3t001mr5ri6l8aibpi	Resident 403	flat403@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.074	2026-03-14 14:36:46.074	f
cmmqfin3w001rr5ripkpb80vj	Resident 501	flat501@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.077	2026-03-14 14:36:46.077	f
cmmqfin410021r5riqey329rg	Resident 503	flat503@psa.com	\N	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.081	2026-03-14 14:36:46.081	f
cmmrcnslh0001r59e6swro422	Owner Flat 101	owner101@psa.com	9000000101	$2a$10$CdHdIJdsQZnsH0I4iziyW.p84SO7.JkMxFQf7twOo0h6DWrRFFL6G	OWNER	2026-03-15 06:04:33.798	2026-03-15 06:04:33.798	f
cmmqfin3y001wr5rivfau0fn4	Resident 502	flat502@psa.com	7795737658	$2a$10$6UIcWrgsTXnqjQoX6F.bVuxhjn6YsAXT/J20o61gFW2oKMlEZOTlS	TENANT	2026-03-14 14:36:46.079	2026-03-16 04:18:52.137	f
\.


--
-- Data for Name: WaterMeterReading; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."WaterMeterReading" (id, "flatId", month, year, "previousReading", "currentReading", "litersConsumed", "pricePerLiter", "waterAmount", "readingDate") FROM stdin;
cmmre15mv0003r5p54rl9xjo5	cmmqfin300007r5ri7hev5ck1	4	2021	18138	18837	6990	0.088	360	2026-03-15 06:42:56.839
cmmre15mw0005r5p5cn9jx890	cmmqfin34000cr5riujl5lkum	4	2021	15612	16659	10470	0.088	540	2026-03-15 06:42:56.841
cmmre15mx0007r5p5noboq157	cmmqfin37000hr5ri6v7crew3	4	2021	10752	11482	7300	0.088	376	2026-03-15 06:42:56.842
cmmre15my0009r5p58tu0gg3y	cmmqfin39000mr5rifitry7zu	4	2021	18330	19419	10890	0.088	562	2026-03-15 06:42:56.843
cmmre15n0000br5p5lastho8w	cmmqfin3c000rr5riaz9ygvbu	4	2021	27366	29052	16860	0.088	869	2026-03-15 06:42:56.844
cmmre15n1000dr5p5oknzwkhe	cmmqfin3f000wr5riqmcfcwsy	4	2021	19993	20552	5590	0.088	288	2026-03-15 06:42:56.846
cmmre15n3000fr5p5xc6dwu6w	cmmqfin3h0011r5ri60yvcljp	4	2021	32439	34357	19180	0.088	989	2026-03-15 06:42:56.847
cmmre15n4000hr5p5a6sz67n3	cmmqfin3k0016r5ri43nzr1pi	4	2021	12639	14486	18470	0.088	953	2026-03-15 06:42:56.848
cmmre15n5000jr5p5wj8392sv	cmmqfin3n001br5rinbkhyypl	4	2021	32869	34719	18500	0.088	954	2026-03-15 06:42:56.849
cmmre15n6000lr5p5vqcydoya	cmmqfin3q001gr5riuek21iw1	4	2021	14551	15502	9510	0.088	490	2026-03-15 06:42:56.85
cmmre15n7000nr5p5e8mfgh6j	cmmqfin3s001lr5ri9eb3mld8	4	2021	10956	11395	4390	0.088	226	2026-03-15 06:42:56.851
cmmre15n8000pr5p5cs386tgw	cmmqfin3v001qr5rik05d5yuh	4	2021	20115	20115	0	0.088	0	2026-03-15 06:42:56.852
cmmre15na000tr5p5o6z8lee4	cmmqfin400020r5ri8p9t0kvk	4	2021	19575	20276	7010	0.088	362	2026-03-15 06:42:56.854
cmmre15nb000vr5p53jx4670d	cmmqfin2s0002r5rig5gyl78u	3	2022	49244	50482	12380	0.088	771	2026-03-15 06:42:56.855
cmmre15nc000xr5p50t7r0lm7	cmmqfin300007r5ri7hev5ck1	3	2022	40335	43345	30100	0.088	1874	2026-03-15 06:42:56.856
cmmre15nd000zr5p52ghovall	cmmqfin34000cr5riujl5lkum	3	2022	37667	38315	6480	0.088	404	2026-03-15 06:42:56.857
cmmre15nd0011r5p59ar96jzf	cmmqfin37000hr5ri6v7crew3	3	2022	19628	20741	11130	0.088	693	2026-03-15 06:42:56.858
cmmre15ne0013r5p5l35e0cw5	cmmqfin39000mr5rifitry7zu	3	2022	37200	38900	17000	0.088	1059	2026-03-15 06:42:56.859
cmmre15nf0015r5p5g7exht1p	cmmqfin3c000rr5riaz9ygvbu	3	2022	49912	52178	22660	0.088	1411	2026-03-15 06:42:56.86
cmmre15ng0017r5p5zer6d6op	cmmqfin3f000wr5riqmcfcwsy	3	2022	28272	28824	5520	0.088	344	2026-03-15 06:42:56.861
cmmre15ni0019r5p5jd225wy1	cmmqfin3h0011r5ri60yvcljp	3	2022	56136	58503	23670	0.088	1474	2026-03-15 06:42:56.862
cmmre15nj001br5p52qpugkwg	cmmqfin3k0016r5ri43nzr1pi	3	2022	30690	32104	14140	0.088	880	2026-03-15 06:42:56.863
cmmre15nk001dr5p5iekaej6i	cmmqfin3n001br5rinbkhyypl	3	2022	69673	72539	28660	0.088	1785	2026-03-15 06:42:56.864
cmmre15nk001fr5p53yz2q4pa	cmmqfin3q001gr5riuek21iw1	3	2022	29523	31143	16200	0.088	1009	2026-03-15 06:42:56.865
cmmre15nl001hr5p534hvxgw8	cmmqfin3s001lr5ri9eb3mld8	3	2022	30712	32231	15190	0.088	946	2026-03-15 06:42:56.866
cmmre15nm001jr5p5lidi0079	cmmqfin3v001qr5rik05d5yuh	3	2022	27869	29148	12790	0.088	796	2026-03-15 06:42:56.867
cmmre15nn001lr5p53rkbzz2f	cmmqfin3x001vr5rixugbviaq	3	2022	15894	16573	6790	0.088	423	2026-03-15 06:42:56.867
cmmre15no001nr5p53ht07yi3	cmmqfin400020r5ri8p9t0kvk	3	2022	36691	38209	15180	0.088	945	2026-03-15 06:42:56.869
cmmre15np001pr5p5fanr72vm	cmmqfin2s0002r5rig5gyl78u	4	2022	50482	50918	4360	0.088	433	2026-03-15 06:42:56.87
cmmre15nr001rr5p5px3qgmg1	cmmqfin300007r5ri7hev5ck1	4	2022	43345	45696	23510	0.088	2335	2026-03-15 06:42:56.871
cmmre15ns001tr5p52c0l207b	cmmqfin34000cr5riujl5lkum	4	2022	38315	39061	7460	0.088	741	2026-03-15 06:42:56.872
cmmre15nt001vr5p57kfzy8yd	cmmqfin37000hr5ri6v7crew3	4	2022	20741	21545	8040	0.088	798	2026-03-15 06:42:56.873
cmmre15nt001xr5p5a1l34ajv	cmmqfin39000mr5rifitry7zu	4	2022	38900	40898	19980	0.088	1984	2026-03-15 06:42:56.874
cmmre15nu001zr5p54l6xubpg	cmmqfin3c000rr5riaz9ygvbu	4	2022	52178	54510	23320	0.088	2316	2026-03-15 06:42:56.875
cmmre15nv0021r5p5s8liqo2g	cmmqfin3f000wr5riqmcfcwsy	4	2022	28824	29835	10110	0.088	1004	2026-03-15 06:42:56.875
cmmre15nw0023r5p5iuwo9xj6	cmmqfin3h0011r5ri60yvcljp	4	2022	58503	61250	27470	0.088	2728	2026-03-15 06:42:56.876
cmmre15nx0025r5p5r1ta78hg	cmmqfin3k0016r5ri43nzr1pi	4	2022	32104	34330	22260	0.088	2211	2026-03-15 06:42:56.877
cmmre15ny0027r5p5e3c32qa3	cmmqfin3n001br5rinbkhyypl	4	2022	72539	73593	10540	0.088	1047	2026-03-15 06:42:56.878
cmmre15nz0029r5p5cqt5zuu1	cmmqfin3q001gr5riuek21iw1	4	2022	31143	32432	12890	0.088	1280	2026-03-15 06:42:56.879
cmmre15o0002br5p5yj269rr1	cmmqfin3s001lr5ri9eb3mld8	4	2022	32231	33849	16180	0.088	1607	2026-03-15 06:42:56.88
cmmre15o1002dr5p574d1me51	cmmqfin3v001qr5rik05d5yuh	4	2022	29148	30609	14610	0.088	1451	2026-03-15 06:42:56.881
cmmre15o2002fr5p5ti5lrc96	cmmqfin3x001vr5rixugbviaq	4	2022	16573	17354	7810	0.088	776	2026-03-15 06:42:56.882
cmmre15o2002hr5p52x6iflpt	cmmqfin400020r5ri8p9t0kvk	4	2022	38209	39940	17310	0.088	1719	2026-03-15 06:42:56.883
cmmre15o3002jr5p5f3xjj8o4	cmmqfin2s0002r5rig5gyl78u	5	2022	50918	52528	16100	0.088	1135	2026-03-15 06:42:56.884
cmmre15o4002lr5p5ukun1via	cmmqfin300007r5ri7hev5ck1	5	2022	45696	48922	32260	0.088	2275	2026-03-15 06:42:56.884
cmmre15o5002nr5p5ezfvj0a1	cmmqfin34000cr5riujl5lkum	5	2022	39061	40496	14350	0.088	1012	2026-03-15 06:42:56.885
cmmre15o7002rr5p5305a3tnl	cmmqfin39000mr5rifitry7zu	5	2022	40898	42379	14810	0.088	1044	2026-03-15 06:42:56.888
cmmre15o8002tr5p554ienryx	cmmqfin3c000rr5riaz9ygvbu	5	2022	54510	56951	24410	0.088	1721	2026-03-15 06:42:56.889
cmmre15o9002vr5p5yjel5b0x	cmmqfin3f000wr5riqmcfcwsy	5	2022	29835	30142	3070	0.088	217	2026-03-15 06:42:56.889
cmmre15oa002xr5p5ibofi9lm	cmmqfin3h0011r5ri60yvcljp	5	2022	61250	63942	26920	0.088	1898	2026-03-15 06:42:56.89
cmmre15ob002zr5p5s0sxhi2t	cmmqfin3k0016r5ri43nzr1pi	5	2022	34330	36088	17580	0.088	1240	2026-03-15 06:42:56.891
cmmre15ob0031r5p5d39klpwy	cmmqfin3n001br5rinbkhyypl	5	2022	73593	74348	7550	0.088	532	2026-03-15 06:42:56.892
cmmre15oc0033r5p5atjqsmjn	cmmqfin3q001gr5riuek21iw1	5	2022	32432	33646	12140	0.088	856	2026-03-15 06:42:56.893
cmmre15od0035r5p5una9fbbw	cmmqfin3s001lr5ri9eb3mld8	5	2022	33849	35373	15240	0.088	1075	2026-03-15 06:42:56.893
cmmre15oe0037r5p51pcqfs7m	cmmqfin3v001qr5rik05d5yuh	5	2022	30609	32904	22950	0.088	1618	2026-03-15 06:42:56.894
cmmre15oh003br5p5ky2vymu6	cmmqfin400020r5ri8p9t0kvk	5	2022	39940	41921	19810	0.088	1397	2026-03-15 06:42:56.897
cmmre15oi003dr5p55e2x3yyj	cmmqfin2s0002r5rig5gyl78u	6	2022	52528	55154	26260	0.088	658	2026-03-15 06:42:56.898
cmmre15oj003fr5p5131oopyz	cmmqfin300007r5ri7hev5ck1	6	2022	48922	54010	50880	0.088	1275	2026-03-15 06:42:56.899
cmmre15oj003hr5p5jz521h7l	cmmqfin34000cr5riujl5lkum	6	2022	40496	42911	24150	0.088	605	2026-03-15 06:42:56.9
cmmre15ok003jr5p5ncaw8xq3	cmmqfin37000hr5ri6v7crew3	6	2022	22789	23616	8270	0.088	207	2026-03-15 06:42:56.901
cmmre15ol003lr5p5on61137f	cmmqfin39000mr5rifitry7zu	6	2022	42379	44609	22300	0.088	559	2026-03-15 06:42:56.902
cmmre15om003nr5p5i6k8r27a	cmmqfin3c000rr5riaz9ygvbu	6	2022	56951	59546	25950	0.088	650	2026-03-15 06:42:56.903
cmmre15on003pr5p554l6j8aw	cmmqfin3f000wr5riqmcfcwsy	6	2022	30142	31104	9620	0.088	241	2026-03-15 06:42:56.904
cmmre15oo003rr5p5lj916i2v	cmmqfin3h0011r5ri60yvcljp	6	2022	63942	68956	50140	0.088	1256	2026-03-15 06:42:56.905
cmmre15op003tr5p5762ethuh	cmmqfin3k0016r5ri43nzr1pi	6	2022	36088	36258	1700	0.088	43	2026-03-15 06:42:56.906
cmmre15oq003vr5p5768eaxvn	cmmqfin3n001br5rinbkhyypl	6	2022	74348	75711	13630	0.088	342	2026-03-15 06:42:56.906
cmmre15or003xr5p5zo2h5e8e	cmmqfin3q001gr5riuek21iw1	6	2022	33646	35324	16780	0.088	420	2026-03-15 06:42:56.907
cmmre15ot0041r5p54u14rjts	cmmqfin3v001qr5rik05d5yuh	6	2022	32904	36634	37300	0.088	935	2026-03-15 06:42:56.909
cmmre15ot0043r5p5wbwurkel	cmmqfin3x001vr5rixugbviaq	6	2022	18536	19500	9640	0.088	242	2026-03-15 06:42:56.91
cmmre15ou0045r5p537avn16m	cmmqfin400020r5ri8p9t0kvk	6	2022	41921	44135	22140	0.088	555	2026-03-15 06:42:56.911
cmmre15ov0047r5p533n7nxit	cmmqfin2s0002r5rig5gyl78u	2	2023	71102	73275	21730	0.088	865	2026-03-15 06:42:56.912
cmmre15ow0049r5p5hsr5ihwo	cmmqfin300007r5ri7hev5ck1	2	2023	74915	78411	34960	0.088	1391	2026-03-15 06:42:56.913
cmmre15ox004br5p5flft114c	cmmqfin34000cr5riujl5lkum	2	2023	51670	53378	17080	0.088	680	2026-03-15 06:42:56.914
cmmre15oy004dr5p5hzrlqwcw	cmmqfin37000hr5ri6v7crew3	2	2023	29500	29500	0	0.088	0	2026-03-15 06:42:56.915
cmmre15oz004fr5p5xj752gm9	cmmqfin39000mr5rifitry7zu	2	2023	56662	59240	25780	0.088	1026	2026-03-15 06:42:56.916
cmmre15p0004hr5p5r3airuxo	cmmqfin3c000rr5riaz9ygvbu	2	2023	72582	74909	23270	0.088	926	2026-03-15 06:42:56.916
cmmre15p1004jr5p5yvvo3wy8	cmmqfin3f000wr5riqmcfcwsy	2	2023	35555	36521	9660	0.088	384	2026-03-15 06:42:56.917
cmmre15p1004lr5p5vj89yvml	cmmqfin3h0011r5ri60yvcljp	2	2023	87386	89480	20940	0.088	833	2026-03-15 06:42:56.918
cmmre15p2004nr5p58rc63oyw	cmmqfin3k0016r5ri43nzr1pi	2	2023	49035	51713	26780	0.088	1066	2026-03-15 06:42:56.919
cmmre15p3004pr5p5nlahl2n0	cmmqfin3n001br5rinbkhyypl	2	2023	81976	82671	6950	0.088	277	2026-03-15 06:42:56.92
cmmre15p4004rr5p53skiust9	cmmqfin3q001gr5riuek21iw1	2	2023	44227	46366	21390	0.088	851	2026-03-15 06:42:56.921
cmmre15p9004tr5p5wwosys53	cmmqfin3s001lr5ri9eb3mld8	2	2023	46101	47681	15800	0.088	629	2026-03-15 06:42:56.926
cmmre15pa004vr5p5roeesij5	cmmqfin3v001qr5rik05d5yuh	2	2023	50382	52731	23490	0.088	935	2026-03-15 06:42:56.927
cmmre15pc004xr5p5rzg0fjy7	cmmqfin3x001vr5rixugbviaq	2	2023	26402	27540	11380	0.088	453	2026-03-15 06:42:56.928
cmmre15pd004zr5p50kw0ogku	cmmqfin400020r5ri8p9t0kvk	2	2023	53737	55978	22410	0.088	892	2026-03-15 06:42:56.93
cmmre15pf0051r5p5ijtxt1pq	cmmqfin2s0002r5rig5gyl78u	3	2023	73275	75321	20460	0.088	601	2026-03-15 06:42:56.932
cmmre15pg0053r5p5gcru79uw	cmmqfin300007r5ri7hev5ck1	3	2023	78411	82129	37180	0.088	1092	2026-03-15 06:42:56.933
cmmre15ph0055r5p5yz1r27d0	cmmqfin34000cr5riujl5lkum	3	2023	53378	55251	18730	0.088	550	2026-03-15 06:42:56.934
cmmre15pi0057r5p5ii63lhuv	cmmqfin37000hr5ri6v7crew3	3	2023	29500	29689	1890	0.088	56	2026-03-15 06:42:56.935
cmmre15pj0059r5p5sq4kjqc8	cmmqfin39000mr5rifitry7zu	3	2023	59240	61744	25040	0.088	735	2026-03-15 06:42:56.935
cmmre15pk005br5p51pdxuyu8	cmmqfin3c000rr5riaz9ygvbu	3	2023	74909	77149	22400	0.088	658	2026-03-15 06:42:56.936
cmmre15pl005dr5p5o3fngldz	cmmqfin3f000wr5riqmcfcwsy	3	2023	36521	37186	6650	0.088	195	2026-03-15 06:42:56.938
cmmre15po005fr5p5hasznrag	cmmqfin3h0011r5ri60yvcljp	3	2023	89480	91647	21670	0.088	636	2026-03-15 06:42:56.941
cmmre15pp005hr5p54pxlrh11	cmmqfin3k0016r5ri43nzr1pi	3	2023	51713	54319	26060	0.088	765	2026-03-15 06:42:56.942
cmmre15pq005jr5p54oau17vc	cmmqfin3n001br5rinbkhyypl	3	2023	82671	85193	25220	0.088	741	2026-03-15 06:42:56.943
cmmre15pr005lr5p5g3t7kgpo	cmmqfin3q001gr5riuek21iw1	3	2023	46366	48543	21770	0.088	639	2026-03-15 06:42:56.944
cmmre15ps005nr5p56ghmelra	cmmqfin3s001lr5ri9eb3mld8	3	2023	47681	49102	14210	0.088	417	2026-03-15 06:42:56.945
cmmre15pu005pr5p5iqwz0yyl	cmmqfin3v001qr5rik05d5yuh	3	2023	52731	55390	26590	0.088	781	2026-03-15 06:42:56.947
cmmre15pw005rr5p5xih167ek	cmmqfin3x001vr5rixugbviaq	3	2023	27540	28458	9180	0.088	270	2026-03-15 06:42:56.948
cmmre15pw005tr5p5jr8mm73d	cmmqfin400020r5ri8p9t0kvk	3	2023	55978	57710	17320	0.088	509	2026-03-15 06:42:56.949
cmmre15px005vr5p5zh6gl306	cmmqfin2s0002r5rig5gyl78u	4	2023	75321	77120	17990	0.088	1217	2026-03-15 06:42:56.95
cmmre15pz005zr5p5iirvan1i	cmmqfin34000cr5riujl5lkum	4	2023	55251	56945	16940	0.088	1146	2026-03-15 06:42:56.951
cmmre15q00061r5p5vhryj0q2	cmmqfin37000hr5ri6v7crew3	4	2023	29689	29913	2240	0.088	152	2026-03-15 06:42:56.952
cmmre15q10063r5p56928p4rc	cmmqfin39000mr5rifitry7zu	4	2023	61744	63746	20020	0.088	1355	2026-03-15 06:42:56.953
cmmre15q20065r5p59ujtshn5	cmmqfin3c000rr5riaz9ygvbu	4	2023	77149	78797	16480	0.088	1115	2026-03-15 06:42:56.954
cmmre15q30067r5p56t5l103e	cmmqfin3f000wr5riqmcfcwsy	4	2023	37186	38066	8800	0.088	596	2026-03-15 06:42:56.955
cmmre15q40069r5p5du0a86yw	cmmqfin3h0011r5ri60yvcljp	4	2023	91647	93414	17670	0.088	1196	2026-03-15 06:42:56.956
cmmre15q5006br5p5dnszilwn	cmmqfin3k0016r5ri43nzr1pi	4	2023	54319	56645	23260	0.088	1574	2026-03-15 06:42:56.957
cmmre15q5006dr5p5y553hzt4	cmmqfin3n001br5rinbkhyypl	4	2023	85193	87559	23660	0.088	1601	2026-03-15 06:42:56.958
cmmre15q6006fr5p5kef22s37	cmmqfin3q001gr5riuek21iw1	4	2023	48543	50360	18170	0.088	1230	2026-03-15 06:42:56.959
cmmre15q8006jr5p5kjmiebaj	cmmqfin3v001qr5rik05d5yuh	4	2023	55390	57567	21770	0.088	1473	2026-03-15 06:42:56.96
cmmre15q9006lr5p5nognklf0	cmmqfin3x001vr5rixugbviaq	4	2023	28458	29359	9010	0.088	610	2026-03-15 06:42:56.961
cmmre15q9006nr5p5cynxz7oj	cmmqfin400020r5ri8p9t0kvk	4	2023	57710	59469	17590	0.088	1190	2026-03-15 06:42:56.962
cmmre15qa006pr5p5aom40rb7	cmmqfin2s0002r5rig5gyl78u	6	2023	81089	82165	10760	0.088	662	2026-03-15 06:42:56.963
cmmre15qc006rr5p5hxr258w1	cmmqfin300007r5ri7hev5ck1	6	2023	90797	93589	27920	0.088	1717	2026-03-15 06:42:56.964
cmmre15qd006tr5p5y00o8pi1	cmmqfin34000cr5riujl5lkum	6	2023	58684	59914	12300	0.088	756	2026-03-15 06:42:56.966
cmmre15qf006vr5p53thm9je1	cmmqfin37000hr5ri6v7crew3	6	2023	30298	30918	6200	0.088	381	2026-03-15 06:42:56.967
cmmre15qf006xr5p5ple7657j	cmmqfin39000mr5rifitry7zu	6	2023	65886	67086	12000	0.088	738	2026-03-15 06:42:56.968
cmmre15qg006zr5p57xxa1l99	cmmqfin3c000rr5riaz9ygvbu	6	2023	81883	82983	11000	0.088	677	2026-03-15 06:42:56.969
cmmre15qh0071r5p51i8ebkkl	cmmqfin3f000wr5riqmcfcwsy	6	2023	38971	39911	9400	0.088	578	2026-03-15 06:42:56.969
cmmre15qi0073r5p50nwd6k2u	cmmqfin3h0011r5ri60yvcljp	6	2023	95812	97488	16760	0.088	1031	2026-03-15 06:42:56.97
cmmre15qi0075r5p50wco8qju	cmmqfin3k0016r5ri43nzr1pi	6	2023	60058	61495	14370	0.088	884	2026-03-15 06:42:56.971
cmmre15qk0079r5p5e7xiyzqp	cmmqfin3q001gr5riuek21iw1	6	2023	52294	53296	10020	0.088	616	2026-03-15 06:42:56.973
cmmre15ql007br5p58glrvwr6	cmmqfin3s001lr5ri9eb3mld8	6	2023	53516	54770	12540	0.088	771	2026-03-15 06:42:56.973
cmmre15qm007dr5p52cl8jpkk	cmmqfin3v001qr5rik05d5yuh	6	2023	61769	63435	16660	0.088	1025	2026-03-15 06:42:56.974
cmmre15qm007fr5p5spdkn1f1	cmmqfin3x001vr5rixugbviaq	6	2023	30082	30818	7360	0.088	453	2026-03-15 06:42:56.975
cmmre15qn007hr5p5umwuf2u3	cmmqfin400020r5ri8p9t0kvk	6	2023	61873	63274	14010	0.088	862	2026-03-15 06:42:56.976
cmmre15qo007jr5p5igivqsk4	cmmqfin2s0002r5rig5gyl78u	1	2024	96172	97035	8630	0.088	540	2026-03-15 06:42:56.977
cmmre15qq007lr5p5j5i0oat1	cmmqfin300007r5ri7hev5ck1	1	2024	118492	120149	16570	0.088	1036	2026-03-15 06:42:56.978
cmmre15qs007nr5p5s3b7jru5	cmmqfin34000cr5riujl5lkum	1	2024	72206	73688	14820	0.088	927	2026-03-15 06:42:56.981
cmmre15qu007pr5p5z37defsm	cmmqfin37000hr5ri6v7crew3	1	2024	39205	39213	80	0.088	5	2026-03-15 06:42:56.983
cmmre15qv007rr5p56ay6074e	cmmqfin39000mr5rifitry7zu	1	2024	80932	81759	8270	0.088	517	2026-03-15 06:42:56.984
cmmre15qw007tr5p5frw8dr15	cmmqfin3c000rr5riaz9ygvbu	1	2024	96627	97588	9610	0.088	601	2026-03-15 06:42:56.985
cmmre15qx007vr5p5qhkzbz2x	cmmqfin3f000wr5riqmcfcwsy	1	2024	45912	46799	8870	0.088	555	2026-03-15 06:42:56.986
cmmre15qy007xr5p55dr217bs	cmmqfin3h0011r5ri60yvcljp	1	2024	111431	112512	10810	0.088	676	2026-03-15 06:42:56.987
cmmre15r0007zr5p5j887ix55	cmmqfin3k0016r5ri43nzr1pi	1	2024	77591	78829	12380	0.088	774	2026-03-15 06:42:56.988
cmmre15r10081r5p5h6wm5r71	cmmqfin3n001br5rinbkhyypl	1	2024	103776	104744	9680	0.088	605	2026-03-15 06:42:56.989
cmmre15r20083r5p5k8n52emy	cmmqfin3q001gr5riuek21iw1	1	2024	65339	66189	8500	0.088	532	2026-03-15 06:42:56.99
cmmre15r30085r5p5ojtzhtt6	cmmqfin3s001lr5ri9eb3mld8	1	2024	65620	66295	6750	0.088	422	2026-03-15 06:42:56.991
cmmre15r30087r5p501sshfxq	cmmqfin3v001qr5rik05d5yuh	1	2024	77340	78117	7770	0.088	486	2026-03-15 06:42:56.992
cmmre15r50089r5p5dfzogfgp	cmmqfin3x001vr5rixugbviaq	1	2024	36218	36609	3910	0.088	245	2026-03-15 06:42:56.994
cmmre15r6008br5p5adh990ex	cmmqfin400020r5ri8p9t0kvk	1	2024	77086	78151	10650	0.088	666	2026-03-15 06:42:56.995
cmmre15r8008fr5p5yz6ik3n0	cmmqfin300007r5ri7hev5ck1	2	2024	1201.49	1241.56	400.7	0.088	3695	2026-03-15 06:42:56.997
cmmre15r9008hr5p5ffqunpsn	cmmqfin34000cr5riujl5lkum	2	2024	736.88	770.49	336.1	0.088	3100	2026-03-15 06:42:56.998
cmmre15ra008jr5p58496pc62	cmmqfin37000hr5ri6v7crew3	2	2024	392.13	403.9	117.7	0.088	1085	2026-03-15 06:42:56.998
cmmre15rb008lr5p5nfwx07zw	cmmqfin39000mr5rifitry7zu	2	2024	817.59	825.47	78.8	0.088	727	2026-03-15 06:42:56.999
cmmre15rc008nr5p5s7wyo75u	cmmqfin3c000rr5riaz9ygvbu	2	2024	975.88	993.75	178.7	0.088	1648	2026-03-15 06:42:57
cmmre15rc008pr5p5j5kkrs2y	cmmqfin3f000wr5riqmcfcwsy	2	2024	467.99	488.01	200.2	0.088	1846	2026-03-15 06:42:57.001
cmmre15re008rr5p5967a4pgm	cmmqfin3h0011r5ri60yvcljp	2	2024	1125.12	1151.25	261.3	0.088	2410	2026-03-15 06:42:57.002
cmmre15re008tr5p5likqssen	cmmqfin3k0016r5ri43nzr1pi	2	2024	788.29	815.99	277	0.088	2555	2026-03-15 06:42:57.003
cmmre15rf008vr5p5uxmrvlls	cmmqfin3n001br5rinbkhyypl	2	2024	1047.44	1062.03	145.9	0.088	1346	2026-03-15 06:42:57.004
cmmre15rg008xr5p52qu0645r	cmmqfin3q001gr5riuek21iw1	2	2024	661.89	670.43	85.4	0.088	788	2026-03-15 06:42:57.005
cmmre15rh008zr5p5iiyeznij	cmmqfin3s001lr5ri9eb3mld8	2	2024	662.95	686.06	231.1	0.088	2131	2026-03-15 06:42:57.006
cmmre15ri0091r5p558tzvd6o	cmmqfin3v001qr5rik05d5yuh	2	2024	781.17	801.29	201.2	0.088	1856	2026-03-15 06:42:57.007
cmmre15rj0093r5p5s8krv9h3	cmmqfin3x001vr5rixugbviaq	2	2024	366.09	374.83	87.4	0.088	806	2026-03-15 06:42:57.008
cmmre15s000a1r5p55g9htwb4	cmmqfin2s0002r5rig5gyl78u	3	2024	99442	100836	13940	0.088	1584	2026-03-15 06:42:57.025
cmmre15r7008dr5p5iwpsl4z9	cmmqfin2s0002r5rig5gyl78u	2	2024	970.35	994.42	240.7	0.088	2220	2026-03-15 06:42:56.996
cmmre15s200a3r5p5e7hoix6v	cmmqfin300007r5ri7hev5ck1	3	2024	124156	128008	38520	0.088	4377	2026-03-15 06:42:57.026
cmmre15s300a5r5p5f2dhmttj	cmmqfin34000cr5riujl5lkum	3	2024	77049	78804	17550	0.088	1994	2026-03-15 06:42:57.027
cmmre15s400a7r5p5mf3ftnez	cmmqfin37000hr5ri6v7crew3	3	2024	40390	41500	11100	0.088	1261	2026-03-15 06:42:57.028
cmmre15s400a9r5p5olu8tibe	cmmqfin39000mr5rifitry7zu	3	2024	82547	83480	9330	0.088	1060	2026-03-15 06:42:57.029
cmmre15s500abr5p5t3mahu93	cmmqfin3c000rr5riaz9ygvbu	3	2024	99375	101044	16690	0.088	1896	2026-03-15 06:42:57.03
cmmre15s600adr5p5mrb4qff1	cmmqfin3f000wr5riqmcfcwsy	3	2024	48801	49974	11730	0.088	1333	2026-03-15 06:42:57.031
cmmre15s800afr5p5i045o4zy	cmmqfin3h0011r5ri60yvcljp	3	2024	115125	118383	32580	0.088	3702	2026-03-15 06:42:57.032
cmmre15s900ahr5p57ia4braq	cmmqfin3k0016r5ri43nzr1pi	3	2024	81599	83912	23130	0.088	2628	2026-03-15 06:42:57.033
cmmre15sb00alr5p5o35z61u7	cmmqfin3q001gr5riuek21iw1	3	2024	67043	67933	8900	0.088	1011	2026-03-15 06:42:57.035
cmmre15sc00anr5p5jp7nhlbp	cmmqfin3s001lr5ri9eb3mld8	3	2024	68606	70180	15740	0.088	1789	2026-03-15 06:42:57.036
cmmre15sd00apr5p5r6uu0tms	cmmqfin3v001qr5rik05d5yuh	3	2024	80129	82617	24880	0.088	2827	2026-03-15 06:42:57.037
cmmre15se00arr5p53vjcqinv	cmmqfin3x001vr5rixugbviaq	3	2024	37483	38282	7990	0.088	908	2026-03-15 06:42:57.039
cmmre15sf00atr5p5oq1v6hh1	cmmqfin400020r5ri8p9t0kvk	3	2024	80203	82055	18520	0.088	2104	2026-03-15 06:42:57.04
cmmre15sh00avr5p56ck6yzej	cmmqfin2s0002r5rig5gyl78u	4	2024	100836	102720	18840	0.088	2079	2026-03-15 06:42:57.041
cmmre15sh00axr5p5ov2z8dmn	cmmqfin300007r5ri7hev5ck1	4	2024	128008	131699	36910	0.088	4073	2026-03-15 06:42:57.042
cmmre15sj00azr5p56vypa2jj	cmmqfin34000cr5riujl5lkum	4	2024	78804	79666	8620	0.088	951	2026-03-15 06:42:57.043
cmmre15sk00b1r5p55g2v6i10	cmmqfin37000hr5ri6v7crew3	4	2024	41500	42751	12510	0.088	1381	2026-03-15 06:42:57.044
cmmre15sk00b3r5p54suhn9nv	cmmqfin39000mr5rifitry7zu	4	2024	83480	84350	8700	0.088	960	2026-03-15 06:42:57.045
cmmre15sl00b5r5p5dyxzl8g6	cmmqfin3c000rr5riaz9ygvbu	4	2024	101044	102885	18410	0.088	2032	2026-03-15 06:42:57.046
cmmre15sn00b7r5p5kxtyqut0	cmmqfin3f000wr5riqmcfcwsy	4	2024	49974	50973	9990	0.088	1102	2026-03-15 06:42:57.047
cmmre15sp00bbr5p5nl3tihlk	cmmqfin3k0016r5ri43nzr1pi	4	2024	83912	86335	24230	0.088	2674	2026-03-15 06:42:57.05
cmmre15sq00bdr5p5tt1phb94	cmmqfin3n001br5rinbkhyypl	4	2024	107850	109973	21230	0.088	2343	2026-03-15 06:42:57.051
cmmre15sr00bfr5p5hoe2rqwo	cmmqfin3q001gr5riuek21iw1	4	2024	67933	68955	10220	0.088	1128	2026-03-15 06:42:57.052
cmmre15ss00bhr5p59gsc9gic	cmmqfin3s001lr5ri9eb3mld8	4	2024	70180	71007	8270	0.088	913	2026-03-15 06:42:57.052
cmmre15st00bjr5p549rb6jiw	cmmqfin3v001qr5rik05d5yuh	4	2024	82617	84495	18780	0.088	2073	2026-03-15 06:42:57.053
cmmre15su00blr5p5gghce93y	cmmqfin3x001vr5rixugbviaq	4	2024	38282	38680	3980	0.088	439	2026-03-15 06:42:57.054
cmmre15sv00bnr5p5t3dbfbtd	cmmqfin400020r5ri8p9t0kvk	4	2024	82055	84186	21310	0.088	2352	2026-03-15 06:42:57.055
cmmre15sw00bpr5p5laiu5hz0	cmmqfin2s0002r5rig5gyl78u	5	2024	102720	104262	15420	0.088	1321	2026-03-15 06:42:57.056
cmmre15sw00brr5p5zykedcvf	cmmqfin300007r5ri7hev5ck1	5	2024	131699	135148	34490	0.088	2955	2026-03-15 06:42:57.057
cmmre15sy00btr5p57soeyjh6	cmmqfin34000cr5riujl5lkum	5	2024	79666	81525	18590	0.088	1593	2026-03-15 06:42:57.058
cmmre15sy00bvr5p5svjprsm9	cmmqfin37000hr5ri6v7crew3	5	2024	42751	43985	12340	0.088	1057	2026-03-15 06:42:57.059
cmmre15sz00bxr5p5ikk9p70e	cmmqfin39000mr5rifitry7zu	5	2024	84350	85916	15660	0.088	1342	2026-03-15 06:42:57.06
cmmre15t000bzr5p5qt23dv1t	cmmqfin3c000rr5riaz9ygvbu	5	2024	102885	104531	16460	0.088	1410	2026-03-15 06:42:57.061
cmmre15t100c1r5p5y3f3jakl	cmmqfin3f000wr5riqmcfcwsy	5	2024	50973	52308	13350	0.088	1144	2026-03-15 06:42:57.062
cmmre15t200c3r5p5v8pg2940	cmmqfin3h0011r5ri60yvcljp	5	2024	121092	123862	27700	0.088	2373	2026-03-15 06:42:57.062
cmmre15t300c5r5p52uf77ch3	cmmqfin3k0016r5ri43nzr1pi	5	2024	86335	89100	27650	0.088	2369	2026-03-15 06:42:57.063
cmmre15t400c7r5p5cji2pkzs	cmmqfin3n001br5rinbkhyypl	5	2024	109973	112405	24320	0.088	2084	2026-03-15 06:42:57.064
cmmre15t500c9r5p52gju6n2j	cmmqfin3q001gr5riuek21iw1	5	2024	68955	70955	20000	0.088	1713	2026-03-15 06:42:57.065
cmmre15t600cbr5p5vznzwczd	cmmqfin3s001lr5ri9eb3mld8	5	2024	71007	73059	20520	0.088	1758	2026-03-15 06:42:57.066
cmmre15t700cdr5p5z86v9j2e	cmmqfin3v001qr5rik05d5yuh	5	2024	84495	86251	17560	0.088	1504	2026-03-15 06:42:57.067
cmmre15t800cfr5p5dnifi6q5	cmmqfin3x001vr5rixugbviaq	5	2024	38680	38931	2510	0.088	215	2026-03-15 06:42:57.068
cmmre15t800chr5p5xjuk5net	cmmqfin400020r5ri8p9t0kvk	5	2024	84186	85381	11950	0.088	1024	2026-03-15 06:42:57.069
cmmre15t900cjr5p5fvsun88q	cmmqfin2s0002r5rig5gyl78u	6	2024	104262	105650	13880	0.088	998	2026-03-15 06:42:57.07
cmmre15ta00clr5p5mqujuxwp	cmmqfin300007r5ri7hev5ck1	6	2024	135148	138784	36360	0.088	2615	2026-03-15 06:42:57.071
cmmre15tb00cnr5p5n7a97wjb	cmmqfin34000cr5riujl5lkum	6	2024	81525	82260	7350	0.088	529	2026-03-15 06:42:57.072
cmmre15tc00cpr5p5386ebeb0	cmmqfin37000hr5ri6v7crew3	6	2024	43985	45300	13150	0.088	946	2026-03-15 06:42:57.072
cmmre15td00crr5p5ek5vzbsu	cmmqfin39000mr5rifitry7zu	6	2024	85916	87438	15220	0.088	1095	2026-03-15 06:42:57.073
cmmre15te00ctr5p5y1dd5nn0	cmmqfin3c000rr5riaz9ygvbu	6	2024	104531	106051	15200	0.088	1093	2026-03-15 06:42:57.074
cmmre15tf00cvr5p5k2g9d20w	cmmqfin3f000wr5riqmcfcwsy	6	2024	52308	53705	13970	0.088	1005	2026-03-15 06:42:57.075
cmmre15tg00cxr5p5jwwohkc3	cmmqfin3h0011r5ri60yvcljp	6	2024	123862	126103	22410	0.088	1612	2026-03-15 06:42:57.076
cmmre15th00czr5p5qe1ugntj	cmmqfin3k0016r5ri43nzr1pi	6	2024	89100	91572	24720	0.088	1778	2026-03-15 06:42:57.077
cmmre15th00d1r5p5kbmd38zz	cmmqfin3n001br5rinbkhyypl	6	2024	112405	114302	18970	0.088	1364	2026-03-15 06:42:57.078
cmmre15ti00d3r5p50vvzh6z5	cmmqfin3q001gr5riuek21iw1	6	2024	70955	73022	20670	0.088	1487	2026-03-15 06:42:57.079
cmmre15tj00d5r5p5mhftninw	cmmqfin3s001lr5ri9eb3mld8	6	2024	73059	74283	12240	0.088	880	2026-03-15 06:42:57.08
cmmre15tl00d9r5p59uafhfh6	cmmqfin3x001vr5rixugbviaq	6	2024	38931	39749	8180	0.088	588	2026-03-15 06:42:57.081
cmmre15tm00dbr5p59l91qrtk	cmmqfin400020r5ri8p9t0kvk	6	2024	85381	86984	16030	0.088	1153	2026-03-15 06:42:57.082
cmmre15tn00ddr5p52npmdb9i	cmmqfin2s0002r5rig5gyl78u	7	2024	105650	107225	15750	0.088	521	2026-03-15 06:42:57.083
cmmre15tn00dfr5p5nn009bid	cmmqfin300007r5ri7hev5ck1	7	2024	138784	142042	32580	0.088	1077	2026-03-15 06:42:57.084
cmmre15to00dhr5p59qrgme4w	cmmqfin34000cr5riujl5lkum	7	2024	82260	83641	13810	0.088	456	2026-03-15 06:42:57.084
cmmre15tp00djr5p59oo06mh2	cmmqfin37000hr5ri6v7crew3	7	2024	45300	46618	13180	0.088	436	2026-03-15 06:42:57.085
cmmre15tq00dlr5p5u4tef9ov	cmmqfin39000mr5rifitry7zu	7	2024	87438	88555	11170	0.088	369	2026-03-15 06:42:57.086
cmmre15tq00dnr5p5ray9hrjw	cmmqfin3c000rr5riaz9ygvbu	7	2024	106051	107482	14310	0.088	473	2026-03-15 06:42:57.087
cmmre15tr00dpr5p5tjbmw2ds	cmmqfin3f000wr5riqmcfcwsy	7	2024	53705	54738	10330	0.088	341	2026-03-15 06:42:57.088
cmmre15tt00dtr5p5ea6lie17	cmmqfin3k0016r5ri43nzr1pi	7	2024	91572	93939	23670	0.088	782	2026-03-15 06:42:57.09
cmmre15tu00dvr5p59qipscj5	cmmqfin3n001br5rinbkhyypl	7	2024	114302	116370	20680	0.088	684	2026-03-15 06:42:57.091
cmmre15tv00dxr5p53ne55rd7	cmmqfin3q001gr5riuek21iw1	7	2024	73022	74891	18690	0.088	618	2026-03-15 06:42:57.091
cmmre15tw00dzr5p527gqq32y	cmmqfin3s001lr5ri9eb3mld8	7	2024	74283	75458	11750	0.088	388	2026-03-15 06:42:57.092
cmmre15tw00e1r5p5fg90bk4o	cmmqfin3v001qr5rik05d5yuh	7	2024	88396	90343	19470	0.088	644	2026-03-15 06:42:57.093
cmmre15tx00e3r5p5jetvxaa2	cmmqfin3x001vr5rixugbviaq	7	2024	39749	40688	9390	0.088	310	2026-03-15 06:42:57.094
cmmre15ty00e5r5p5u4x5tkbc	cmmqfin400020r5ri8p9t0kvk	7	2024	86984	88709	17250	0.088	570	2026-03-15 06:42:57.094
cmmre15tz00e7r5p58cd0829n	cmmqfin2s0002r5rig5gyl78u	1	2025	113483	114790	13070	0.088	1618	2026-03-15 06:42:57.095
cmmre15tz00e9r5p586rcgpih	cmmqfin300007r5ri7hev5ck1	1	2025	158593	160138	15450	0.088	1913	2026-03-15 06:42:57.096
cmmre15u000ebr5p57mdn6fx8	cmmqfin34000cr5riujl5lkum	1	2025	92410	93155	7450	0.088	922	2026-03-15 06:42:57.097
cmmre15u100edr5p57kxey0ah	cmmqfin37000hr5ri6v7crew3	1	2025	53020	53648	6280	0.088	777	2026-03-15 06:42:57.098
cmmre15u200efr5p5mpy362ss	cmmqfin39000mr5rifitry7zu	1	2025	94377	94629	2520	0.088	312	2026-03-15 06:42:57.098
cmmre15u400ejr5p5dhkff030	cmmqfin3f000wr5riqmcfcwsy	1	2025	62270	63190	9200	0.088	1139	2026-03-15 06:42:57.1
cmmre15u400elr5p5b4lk4ueu	cmmqfin3h0011r5ri60yvcljp	1	2025	137893	139112	12190	0.088	1509	2026-03-15 06:42:57.101
cmmre15u500enr5p5k2vz3bak	cmmqfin3k0016r5ri43nzr1pi	1	2025	105351	106571	12200	0.088	1510	2026-03-15 06:42:57.102
cmmre15u600epr5p57emp774y	cmmqfin3n001br5rinbkhyypl	1	2025	124567	124988	4210	0.088	521	2026-03-15 06:42:57.102
cmmre15u700err5p546er1gix	cmmqfin3q001gr5riuek21iw1	1	2025	79502	79828	3260	0.088	404	2026-03-15 06:42:57.103
cmmre15u800etr5p5jawqyf4s	cmmqfin3s001lr5ri9eb3mld8	1	2025	80304	80703	3990	0.088	494	2026-03-15 06:42:57.104
cmmre15u900evr5p5u1lbaaxs	cmmqfin3v001qr5rik05d5yuh	1	2025	98919	99814	8950	0.088	1108	2026-03-15 06:42:57.105
cmmre15u900exr5p5z7bfsaog	cmmqfin3x001vr5rixugbviaq	1	2025	45412	45861	4490	0.088	556	2026-03-15 06:42:57.106
cmmre15ua00ezr5p57kvxdp3n	cmmqfin400020r5ri8p9t0kvk	1	2025	95530	96154	6240	0.088	772	2026-03-15 06:42:57.107
cmmre15ub00f1r5p5y3fe1t0y	cmmqfin2s0002r5rig5gyl78u	2	2025	114790	116181	13910	0.088	923	2026-03-15 06:42:57.107
cmmre15uc00f3r5p5etyinrzb	cmmqfin300007r5ri7hev5ck1	2	2025	160138	163500	33620	0.088	2231	2026-03-15 06:42:57.108
cmmre15uc00f5r5p57ozvtki8	cmmqfin34000cr5riujl5lkum	2	2025	93155	96166	30110	0.088	1998	2026-03-15 06:42:57.109
cmmre15ud00f7r5p54v0zu9a3	cmmqfin37000hr5ri6v7crew3	2	2025	53648	55055	14070	0.088	934	2026-03-15 06:42:57.11
cmmre15ue00f9r5p55f2gkb80	cmmqfin39000mr5rifitry7zu	2	2025	94629	96324	16950	0.088	1125	2026-03-15 06:42:57.11
cmmre15uf00fbr5p5ac79himb	cmmqfin3c000rr5riaz9ygvbu	2	2025	114195	115442	12470	0.088	827	2026-03-15 06:42:57.111
cmmre15ug00fdr5p5eyuvvz5x	cmmqfin3f000wr5riqmcfcwsy	2	2025	63190	65408	22180	0.088	1472	2026-03-15 06:42:57.112
cmmre15ug00ffr5p5mrk8fdq6	cmmqfin3h0011r5ri60yvcljp	2	2025	139112	141721	26090	0.088	1731	2026-03-15 06:42:57.113
cmmre15uh00fhr5p583nsl94d	cmmqfin3k0016r5ri43nzr1pi	2	2025	106571	109153	25820	0.088	1713	2026-03-15 06:42:57.114
cmmre15ui00fjr5p58lpaald6	cmmqfin3n001br5rinbkhyypl	2	2025	124988	126511	15230	0.088	1011	2026-03-15 06:42:57.115
cmmre15uj00flr5p5r2qb6itp	cmmqfin3q001gr5riuek21iw1	2	2025	79828	81236	14080	0.088	934	2026-03-15 06:42:57.115
cmmre15uk00fnr5p5z0p7uww5	cmmqfin3s001lr5ri9eb3mld8	2	2025	80703	81734	10310	0.088	684	2026-03-15 06:42:57.116
cmmre15uk00fpr5p5dwwq6i9j	cmmqfin3v001qr5rik05d5yuh	2	2025	99814	102340	25260	0.088	1676	2026-03-15 06:42:57.117
cmmre15ul00frr5p5uegavhlf	cmmqfin3x001vr5rixugbviaq	2	2025	45861	46901	10400	0.088	690	2026-03-15 06:42:57.118
cmmre15um00ftr5p59urx4k5m	cmmqfin400020r5ri8p9t0kvk	2	2025	96154	98009	18550	0.088	1231	2026-03-15 06:42:57.118
cmmre15un00fvr5p5drd1hipf	cmmqfin2s0002r5rig5gyl78u	3	2025	116181	117765	15840	0.088	1081	2026-03-15 06:42:57.119
cmmre15uo00fxr5p579ikucja	cmmqfin300007r5ri7hev5ck1	3	2025	163500	166834	33340	0.088	2276	2026-03-15 06:42:57.12
cmmre15uo00fzr5p5mfpir23u	cmmqfin34000cr5riujl5lkum	3	2025	96166	98411	22450	0.088	1533	2026-03-15 06:42:57.121
cmmre15up00g1r5p50rzdj7a3	cmmqfin37000hr5ri6v7crew3	3	2025	55055	56392	13370	0.088	913	2026-03-15 06:42:57.122
cmmre15uq00g3r5p5f8g9bva4	cmmqfin39000mr5rifitry7zu	3	2025	96324	97442	11180	0.088	763	2026-03-15 06:42:57.122
cmmre15ur00g5r5p5n3bhw0wp	cmmqfin3c000rr5riaz9ygvbu	3	2025	115442	117161	17190	0.088	1173	2026-03-15 06:42:57.123
cmmre15ur00g7r5p5zj3mvqma	cmmqfin3f000wr5riqmcfcwsy	3	2025	65408	66692	12840	0.088	877	2026-03-15 06:42:57.124
cmmre15us00g9r5p5uozxdact	cmmqfin3h0011r5ri60yvcljp	3	2025	141721	144174	24530	0.088	1675	2026-03-15 06:42:57.125
cmmre15ut00gbr5p5jnor4o6y	cmmqfin3k0016r5ri43nzr1pi	3	2025	109153	111626	24730	0.088	1688	2026-03-15 06:42:57.125
cmmre15uu00gdr5p5v6pw0qf4	cmmqfin3n001br5rinbkhyypl	3	2025	126511	128205	16940	0.088	1156	2026-03-15 06:42:57.126
cmmre15uv00ghr5p5yd2m8z72	cmmqfin3s001lr5ri9eb3mld8	3	2025	81734	82769	10350	0.088	707	2026-03-15 06:42:57.128
cmmre15uw00gjr5p59twmvpl2	cmmqfin3v001qr5rik05d5yuh	3	2025	102340	104608	22680	0.088	1548	2026-03-15 06:42:57.128
cmmre15ux00glr5p5m378e5hc	cmmqfin3x001vr5rixugbviaq	3	2025	46901	47477	5760	0.088	393	2026-03-15 06:42:57.129
cmmre15uy00gnr5p5v7ygvyaz	cmmqfin400020r5ri8p9t0kvk	3	2025	98009	99794	17850	0.088	1219	2026-03-15 06:42:57.13
cmmre15uy00gpr5p5b5ggi107	cmmqfin2s0002r5rig5gyl78u	4	2025	117765	118512	7470	0.088	1029	2026-03-15 06:42:57.131
cmmre15uz00grr5p52yn603dp	cmmqfin300007r5ri7hev5ck1	4	2025	166834	169475	26410	0.088	3637	2026-03-15 06:42:57.132
cmmre15v000gtr5p517ouc3va	cmmqfin34000cr5riujl5lkum	4	2025	98411	99739	13280	0.088	1829	2026-03-15 06:42:57.132
cmmre15v000gvr5p5qk86zhl2	cmmqfin37000hr5ri6v7crew3	4	2025	56392	57536	11440	0.088	1575	2026-03-15 06:42:57.133
cmmre15v100gxr5p57loqn95v	cmmqfin39000mr5rifitry7zu	4	2025	97442	98652	12100	0.088	1666	2026-03-15 06:42:57.134
cmmre15mp0001r5p5717whu9j	cmmqfin2s0002r5rig5gyl78u	4	2021	26779	28361	15820	0.088	816	2026-03-15 06:42:56.834
cmmre15n9000rr5p5ldmwkjou	cmmqfin3x001vr5rixugbviaq	4	2021	9831	10931	11000	0.088	567	2026-03-15 06:42:56.853
cmmre15o6002pr5p53dot3o53	cmmqfin37000hr5ri6v7crew3	5	2022	21545	22789	12440	0.088	877	2026-03-15 06:42:56.886
cmmre15of0039r5p51ff4l16k	cmmqfin3x001vr5rixugbviaq	5	2022	17354	18536	11820	0.088	834	2026-03-15 06:42:56.895
cmmre15os003zr5p5emccbpih	cmmqfin3s001lr5ri9eb3mld8	6	2022	35373	37211	18380	0.088	461	2026-03-15 06:42:56.908
cmmre15py005xr5p5v64jzj4g	cmmqfin300007r5ri7hev5ck1	4	2023	82129	85389	32600	0.088	2206	2026-03-15 06:42:56.951
cmmre15q7006hr5p5rwtuuesd	cmmqfin3s001lr5ri9eb3mld8	4	2023	49102	50682	15800	0.088	1069	2026-03-15 06:42:56.959
cmmre15qj0077r5p58xtedo75	cmmqfin3n001br5rinbkhyypl	6	2023	90744	91729	9850	0.088	606	2026-03-15 06:42:56.972
cmmre15rk0095r5p59ujqch5g	cmmqfin400020r5ri8p9t0kvk	2	2024	781.51	802.03	205.2	0.088	1892	2026-03-15 06:42:57.009
cmmre15sa00ajr5p5lhvhmd3v	cmmqfin3n001br5rinbkhyypl	3	2024	106203	107850	16470	0.088	1871	2026-03-15 06:42:57.034
cmmre15so00b9r5p5zszckx4v	cmmqfin3h0011r5ri60yvcljp	4	2024	118383	121092	27090	0.088	2990	2026-03-15 06:42:57.049
cmmre15tk00d7r5p5r2gk376o	cmmqfin3v001qr5rik05d5yuh	6	2024	86251	88396	21450	0.088	1543	2026-03-15 06:42:57.081
cmmre15ts00drr5p5ggmcyzmq	cmmqfin3h0011r5ri60yvcljp	7	2024	126103	128332	22290	0.088	737	2026-03-15 06:42:57.089
cmmre15u300ehr5p5813zkbye	cmmqfin3c000rr5riaz9ygvbu	1	2025	113502	114195	6930	0.088	858	2026-03-15 06:42:57.099
cmmre15uu00gfr5p5ctnku40h	cmmqfin3q001gr5riuek21iw1	3	2025	81236	82128	8920	0.088	609	2026-03-15 06:42:57.127
cmmre15v200gzr5p54khzh8cw	cmmqfin3c000rr5riaz9ygvbu	4	2025	117161	118279	11180	0.088	1540	2026-03-15 06:42:57.134
cmmre15v300h1r5p5o765rt2g	cmmqfin3f000wr5riqmcfcwsy	4	2025	66692	67318	6260	0.088	862	2026-03-15 06:42:57.135
cmmre15v300h3r5p547ul0el9	cmmqfin3h0011r5ri60yvcljp	4	2025	144174	146745	25710	0.088	3540	2026-03-15 06:42:57.136
cmmre15v400h5r5p5fah938so	cmmqfin3k0016r5ri43nzr1pi	4	2025	111626	113695	20690	0.088	2849	2026-03-15 06:42:57.137
cmmre15v500h7r5p5m7dx894h	cmmqfin3n001br5rinbkhyypl	4	2025	128205	129642	14370	0.088	1979	2026-03-15 06:42:57.137
cmmre15v600h9r5p52ciljxrg	cmmqfin3q001gr5riuek21iw1	4	2025	82128	82775	6470	0.088	891	2026-03-15 06:42:57.138
cmmre15v600hbr5p53alxd5xb	cmmqfin3s001lr5ri9eb3mld8	4	2025	82769	83563	7940	0.088	1093	2026-03-15 06:42:57.139
cmmre15v700hdr5p5a9lm5lrd	cmmqfin3v001qr5rik05d5yuh	4	2025	104608	106211	16030	0.088	2207	2026-03-15 06:42:57.14
cmmre15v800hfr5p5iyi5f950	cmmqfin3x001vr5rixugbviaq	4	2025	47477	48212	7350	0.088	1012	2026-03-15 06:42:57.14
cmmre15v900hhr5p5jzo7wgtf	cmmqfin400020r5ri8p9t0kvk	4	2025	99794	101222	14280	0.088	1966	2026-03-15 06:42:57.141
cmmre15v900hjr5p5ryqzlvsp	cmmqfin2s0002r5rig5gyl78u	5	2025	118512	119968	14560	0.088	1590	2026-03-15 06:42:57.142
cmmre15va00hlr5p5bdgl7juw	cmmqfin300007r5ri7hev5ck1	5	2025	169475	172794	33190	0.088	3626	2026-03-15 06:42:57.142
cmmre15vb00hnr5p561lptz5l	cmmqfin34000cr5riujl5lkum	5	2025	99739	100829	10900	0.088	1191	2026-03-15 06:42:57.143
cmmre15vb00hpr5p5h9xrf7nc	cmmqfin37000hr5ri6v7crew3	5	2025	57536	59451	19150	0.088	2092	2026-03-15 06:42:57.144
cmmre15vc00hrr5p5n0ikdq4f	cmmqfin39000mr5rifitry7zu	5	2025	98652	100180	15280	0.088	1669	2026-03-15 06:42:57.145
cmmre15vd00htr5p5bxlqzhn6	cmmqfin3c000rr5riaz9ygvbu	5	2025	118279	119653	13740	0.088	1501	2026-03-15 06:42:57.145
cmmre15ve00hvr5p5cxu9f47k	cmmqfin3f000wr5riqmcfcwsy	5	2025	67318	68174	8560	0.088	935	2026-03-15 06:42:57.147
cmmre15vf00hxr5p5ykzyoji8	cmmqfin3h0011r5ri60yvcljp	5	2025	146745	149454	27090	0.088	2959	2026-03-15 06:42:57.147
cmmre15vg00hzr5p5viktsnlu	cmmqfin3k0016r5ri43nzr1pi	5	2025	113695	116462	27670	0.088	3023	2026-03-15 06:42:57.148
cmmre15vg00i1r5p5hvroge1e	cmmqfin3n001br5rinbkhyypl	5	2025	129642	130946	13040	0.088	1424	2026-03-15 06:42:57.149
cmmre15vh00i3r5p517zdt6iz	cmmqfin3q001gr5riuek21iw1	5	2025	82775	83669	8940	0.088	977	2026-03-15 06:42:57.15
cmmre15vi00i5r5p56dwpaq2h	cmmqfin3s001lr5ri9eb3mld8	5	2025	83563	84721	11580	0.088	1265	2026-03-15 06:42:57.15
cmmre15vi00i7r5p5yk6x6rqf	cmmqfin3v001qr5rik05d5yuh	5	2025	106211	108849	26380	0.088	2882	2026-03-15 06:42:57.151
cmmre15vj00i9r5p5bktjz671	cmmqfin3x001vr5rixugbviaq	5	2025	48212	49090	8780	0.088	959	2026-03-15 06:42:57.152
cmmre15vk00ibr5p52agrkjet	cmmqfin400020r5ri8p9t0kvk	5	2025	101222	102590	13680	0.088	1494	2026-03-15 06:42:57.152
cmmre15vl00idr5p53qmz8h8k	cmmqfin2s0002r5rig5gyl78u	6	2025	119968	122084	21160	0.088	1622	2026-03-15 06:42:57.153
cmmre15vm00ifr5p5l8fr57ud	cmmqfin300007r5ri7hev5ck1	6	2025	172794	177594	48000	0.088	3679	2026-03-15 06:42:57.154
cmmre15vm00ihr5p5ro2l6dvw	cmmqfin34000cr5riujl5lkum	6	2025	100829	103066	22370	0.088	1714	2026-03-15 06:42:57.155
cmmre15vn00ijr5p52lccxelo	cmmqfin37000hr5ri6v7crew3	6	2025	59451	63978	45270	0.088	3469	2026-03-15 06:42:57.156
cmmre15vo00ilr5p5900ycjx2	cmmqfin39000mr5rifitry7zu	6	2025	100180	101704	15240	0.088	1168	2026-03-15 06:42:57.156
cmmre15vp00inr5p5gwn03j1m	cmmqfin3c000rr5riaz9ygvbu	6	2025	119653	121363	17100	0.088	1310	2026-03-15 06:42:57.157
cmmre15vp00ipr5p5zxys0lsw	cmmqfin3f000wr5riqmcfcwsy	6	2025	68174	69555	13810	0.088	1058	2026-03-15 06:42:57.158
cmmre15vq00irr5p5yigi3dz8	cmmqfin3h0011r5ri60yvcljp	6	2025	149454	151182	17280	0.088	1324	2026-03-15 06:42:57.158
cmmre15vr00itr5p55gmn9vxj	cmmqfin3k0016r5ri43nzr1pi	6	2025	116462	119438	29760	0.088	2281	2026-03-15 06:42:57.159
cmmre15vr00ivr5p5nk0nvgyx	cmmqfin3n001br5rinbkhyypl	6	2025	130946	133462	25160	0.088	1928	2026-03-15 06:42:57.16
cmmre15vs00ixr5p56uduw0oj	cmmqfin3q001gr5riuek21iw1	6	2025	83669	84907	12380	0.088	949	2026-03-15 06:42:57.161
cmmre15vt00izr5p56icgty7p	cmmqfin3s001lr5ri9eb3mld8	6	2025	84721	86652	19310	0.088	1480	2026-03-15 06:42:57.161
cmmre15vu00j1r5p572vmgdau	cmmqfin3v001qr5rik05d5yuh	6	2025	108849	112610	37610	0.088	2882	2026-03-15 06:42:57.162
cmmre15vu00j3r5p5g86bxpgf	cmmqfin3x001vr5rixugbviaq	6	2025	49090	49455	3650	0.088	280	2026-03-15 06:42:57.163
cmmre15vv00j5r5p5p5xta8gr	cmmqfin400020r5ri8p9t0kvk	6	2025	102590	104871	22810	0.088	1748	2026-03-15 06:42:57.164
cmmreqmgi00j7r5lupcfkgbb3	cmmqfin2s0002r5rig5gyl78u	7	2025	122084	123979	18950	0.088	1709	2026-03-15 07:02:45.042
cmmreqmgj00j9r5lurtrd4ij6	cmmqfin300007r5ri7hev5ck1	7	2025	177594	180616	30220	0.088	2725	2026-03-15 07:02:45.043
cmmreqmgj00jbr5lue726akqd	cmmqfin34000cr5riujl5lkum	7	2025	103066	104947	18810	0.088	1696	2026-03-15 07:02:45.043
cmmreqmgj00jdr5lu3l0bgqsw	cmmqfin37000hr5ri6v7crew3	7	2025	63978	65229	12510	0.088	1128	2026-03-15 07:02:45.044
cmmreqmgk00jfr5lub49r9jbc	cmmqfin39000mr5rifitry7zu	7	2025	101704	103234	15300	0.088	1380	2026-03-15 07:02:45.044
cmmreqmgk00jhr5lu5ew5a8jm	cmmqfin3c000rr5riaz9ygvbu	7	2025	121363	122498	11350	0.088	1023	2026-03-15 07:02:45.045
cmmreqmgl00jjr5luudp9jdwd	cmmqfin3f000wr5riqmcfcwsy	7	2025	69555	70195	6400	0.088	577	2026-03-15 07:02:45.045
cmmreqmgl00jlr5lucwtvkxrl	cmmqfin3h0011r5ri60yvcljp	7	2025	151182	152362	11800	0.088	1064	2026-03-15 07:02:45.046
cmmreqmgl00jnr5lupii2iqny	cmmqfin3k0016r5ri43nzr1pi	7	2025	119438	121535	20970	0.088	1891	2026-03-15 07:02:45.046
cmmreqmgm00jpr5luflv9q7dy	cmmqfin3n001br5rinbkhyypl	7	2025	133462	134965	15030	0.088	1355	2026-03-15 07:02:45.046
cmmreqmgm00jrr5lupdqv2ywd	cmmqfin3q001gr5riuek21iw1	7	2025	84907	85993	10860	0.088	979	2026-03-15 07:02:45.047
cmmreqmgn00jtr5lupz9m2fni	cmmqfin3s001lr5ri9eb3mld8	7	2025	86652	88029	13770	0.088	1242	2026-03-15 07:02:45.047
cmmreqmgn00jvr5lu1chaxj09	cmmqfin3v001qr5rik05d5yuh	7	2025	112610	114849	22390	0.088	2019	2026-03-15 07:02:45.048
cmmreqmgn00jxr5lujboobw0a	cmmqfin3x001vr5rixugbviaq	7	2025	49455	50315	8600	0.088	775	2026-03-15 07:02:45.048
cmmreqmgo00jzr5luvzqce9yf	cmmqfin400020r5ri8p9t0kvk	7	2025	104871	106434	15630	0.088	1409	2026-03-15 07:02:45.048
cmmreqmgo00k1r5lurfi53ay5	cmmqfin2s0002r5rig5gyl78u	8	2025	123979	126276	22970	0.088	771	2026-03-15 07:02:45.049
cmmreqmgp00k3r5lun43bp6ad	cmmqfin300007r5ri7hev5ck1	8	2025	180616	184426	38100	0.088	1279	2026-03-15 07:02:45.05
cmmreqmgq00k5r5luk0s54e08	cmmqfin34000cr5riujl5lkum	8	2025	104947	107562	26150	0.088	878	2026-03-15 07:02:45.05
cmmreqmgq00k7r5lurec4stoc	cmmqfin37000hr5ri6v7crew3	8	2025	65229	66587	13580	0.088	456	2026-03-15 07:02:45.051
cmmreqmgq00k9r5lusiuswfi7	cmmqfin39000mr5rifitry7zu	8	2025	103234	104796	15620	0.088	524	2026-03-15 07:02:45.051
cmmreqmgr00kbr5lug3esqvqo	cmmqfin3c000rr5riaz9ygvbu	8	2025	122498	123475	9770	0.088	328	2026-03-15 07:02:45.051
cmmreqmgr00kdr5luz4ompobl	cmmqfin3f000wr5riqmcfcwsy	8	2025	70195	70789	5940	0.088	199	2026-03-15 07:02:45.052
cmmreqmgs00kfr5lukn0f9kr0	cmmqfin3h0011r5ri60yvcljp	8	2025	152362	154192	18300	0.088	614	2026-03-15 07:02:45.052
cmmreqmgs00khr5luie0gqhz6	cmmqfin3k0016r5ri43nzr1pi	8	2025	121535	124489	29540	0.088	992	2026-03-15 07:02:45.052
cmmreqmgs00kjr5lusuy1gjoj	cmmqfin3n001br5rinbkhyypl	8	2025	134965	137141	21760	0.088	730	2026-03-15 07:02:45.053
cmmreqmgt00klr5lu218j0tqb	cmmqfin3q001gr5riuek21iw1	8	2025	85993	87179	11860	0.088	398	2026-03-15 07:02:45.053
cmmreqmgt00knr5lugc0dtwnc	cmmqfin3s001lr5ri9eb3mld8	8	2025	88029	89032	10030	0.088	337	2026-03-15 07:02:45.053
cmmreqmgt00kpr5luf34cnyfp	cmmqfin3v001qr5rik05d5yuh	8	2025	114849	117605	27560	0.088	925	2026-03-15 07:02:45.054
cmmreqmgu00krr5lufi7obxon	cmmqfin3x001vr5rixugbviaq	8	2025	50315	51330	10150	0.088	341	2026-03-15 07:02:45.054
cmmreqmgu00ktr5lu9dz6981r	cmmqfin400020r5ri8p9t0kvk	8	2025	106434	108340	19060	0.088	640	2026-03-15 07:02:45.055
cmmreqmgu00kvr5lul8ptzb5u	cmmqfin2s0002r5rig5gyl78u	1	2026	137460	139112	16520	0.088	1204	2026-03-15 07:02:45.055
cmmreqmgv00kxr5lu1jryhoc0	cmmqfin300007r5ri7hev5ck1	1	2026	201355	204122	27670	0.088	2016	2026-03-15 07:02:45.055
cmmreqmgv00kzr5lupe0cwfwe	cmmqfin34000cr5riujl5lkum	1	2026	116546	117939	13930	0.088	1015	2026-03-15 07:02:45.056
cmmreqmgw00l1r5luwahcuu5a	cmmqfin37000hr5ri6v7crew3	1	2026	73491	73939	4480	0.088	326	2026-03-15 07:02:45.056
cmmreqmgw00l3r5lu3o8c8g5u	cmmqfin39000mr5rifitry7zu	1	2026	111495	112934	14390	0.088	1049	2026-03-15 07:02:45.056
cmmreqmgw00l5r5lupn927ofl	cmmqfin3c000rr5riaz9ygvbu	1	2026	127316	128158	8420	0.088	614	2026-03-15 07:02:45.057
cmmreqmgx00l7r5lu28o7j32z	cmmqfin3f000wr5riqmcfcwsy	1	2026	73105	73564	4590	0.088	334	2026-03-15 07:02:45.057
cmmreqmgx00l9r5luuffzl1dt	cmmqfin3h0011r5ri60yvcljp	1	2026	166919	169051	21320	0.088	1554	2026-03-15 07:02:45.057
cmmreqmgx00lbr5luzihw4dc8	cmmqfin3k0016r5ri43nzr1pi	1	2026	136403	138603	22000	0.088	1603	2026-03-15 07:02:45.058
cmmreqmgy00ldr5lu2f52zwa5	cmmqfin3n001br5rinbkhyypl	1	2026	143888	144910	10220	0.088	745	2026-03-15 07:02:45.058
cmmreqmgy00lfr5lu1n9qf393	cmmqfin3q001gr5riuek21iw1	1	2026	94223	95061	8380	0.088	611	2026-03-15 07:02:45.058
cmmreqmgy00lhr5lugx41jvg7	cmmqfin3s001lr5ri9eb3mld8	1	2026	94410	95172	7620	0.088	555	2026-03-15 07:02:45.059
cmmreqmgz00ljr5luedjh33hi	cmmqfin3v001qr5rik05d5yuh	1	2026	128147	129480	13330	0.088	971	2026-03-15 07:02:45.059
cmmreqmgz00llr5lu3fif1o8h	cmmqfin3x001vr5rixugbviaq	1	2026	55193	55942	7490	0.088	546	2026-03-15 07:02:45.06
cmmreqmh000lnr5lusefs8rym	cmmqfin400020r5ri8p9t0kvk	1	2026	116316	117733	14170	0.088	1033	2026-03-15 07:02:45.06
cmmreqmh000lpr5lufuqlkgpy	cmmqfin2s0002r5rig5gyl78u	2	2026	139112	141519	24070	0.088	2114	2026-03-15 07:02:45.06
cmmreqmh100lrr5luy3hzqre7	cmmqfin300007r5ri7hev5ck1	2	2026	204122	207474	33520	0.088	2944	2026-03-15 07:02:45.061
cmmreqmh100ltr5lu0c3z6nm9	cmmqfin34000cr5riujl5lkum	2	2026	117939	120669	27300	0.088	2398	2026-03-15 07:02:45.062
cmmreqmh100lvr5luwusgauq0	cmmqfin37000hr5ri6v7crew3	2	2026	73939	73946	70	0.088	6	2026-03-15 07:02:45.062
cmmreqmh200lxr5lucnrbi9vd	cmmqfin39000mr5rifitry7zu	2	2026	112934	114538	16040	0.088	1409	2026-03-15 07:02:45.062
cmmreqmh200lzr5lu94fr5zrb	cmmqfin3c000rr5riaz9ygvbu	2	2026	128158	129097	9390	0.088	825	2026-03-15 07:02:45.063
cmmreqmh200m1r5lu1u5whtvr	cmmqfin3f000wr5riqmcfcwsy	2	2026	73564	74176	6120	0.088	537	2026-03-15 07:02:45.063
cmmreqmh300m3r5lu2005mswp	cmmqfin3h0011r5ri60yvcljp	2	2026	169051	171820	27690	0.088	2432	2026-03-15 07:02:45.063
cmmreqmh300m5r5lulz9ttnm9	cmmqfin3k0016r5ri43nzr1pi	2	2026	138603	141537	29340	0.088	2577	2026-03-15 07:02:45.064
cmmreqmh400m7r5luca3wngcw	cmmqfin3n001br5rinbkhyypl	2	2026	144910	146314	14040	0.088	1233	2026-03-15 07:02:45.064
cmmreqmh400m9r5lu3i1hxr15	cmmqfin3q001gr5riuek21iw1	2	2026	95061	96680	16190	0.088	1422	2026-03-15 07:02:45.065
cmmreqmh500mbr5luaf2p8lr6	cmmqfin3s001lr5ri9eb3mld8	2	2026	95172	96834	16620	0.088	1460	2026-03-15 07:02:45.065
cmmreqmh500mdr5luoyr6cpr7	cmmqfin3v001qr5rik05d5yuh	2	2026	129480	131280	18000	0.088	1581	2026-03-15 07:02:45.065
cmmreqmh500mfr5ludtyt3uin	cmmqfin3x001vr5rixugbviaq	2	2026	55942	56670	7280	0.088	639	2026-03-15 07:02:45.066
cmmreqmh600mhr5luaq5fgri8	cmmqfin400020r5ri8p9t0kvk	2	2026	117733	119749	20160	0.088	1770	2026-03-15 07:02:45.066
\.


--
-- Data for Name: WaterPurchase; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."WaterPurchase" (id, "apartmentId", month, year, "srNo", "capacityLiters", "tokenNo", "bookedOn", "deliveredOn", "amountPaid", "vehicleNo", "createdAt") FROM stdin;
cmmx9i6dc0001r5ameiuzgxgv	psa-main	3	2026	1	10000		2026-03-01 00:00:00	2026-03-02 00:00:00	1100		2026-03-19 09:22:49.919
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
6d2d12c5-94bb-4e9d-9513-a210418b64bc	316760aa573014c02839f7d032c5636ea7e238387c9f911931fd2e2b50ee95b9	2026-03-14 20:06:43.967523+05:30	20260314143643_init	\N	\N	2026-03-14 20:06:43.94634+05:30	1
6372f9ac-7abc-400f-b294-082c71c13ec8	af29892365c1e9d3487bf5bfdc74d0bdb46ade68338a3e77c767eb0decff1216	2026-03-14 21:17:34.91748+05:30	20260314154734_add_water_purchase	\N	\N	2026-03-14 21:17:34.910884+05:30	1
584d3c78-dd7f-4e17-a0fe-89baca545efa	8e26322d90e66fa1fb29b0ac2b2b1e638ac097b27d62ec412eb63fcd3afac9eb	2026-03-15 11:32:21.135069+05:30	20260315060221_make_token_vehicle_optional	\N	\N	2026-03-15 11:32:21.134038+05:30	1
43895f43-9792-444f-8d6d-763c3430ef28	86d89227d564cb2e408873322cec9d0208301126f3e53cad9a5b27cc9d046899	2026-03-15 12:08:05.50164+05:30	20260315063805_add_contributions_owner_tenant	\N	\N	2026-03-15 12:08:05.493814+05:30	1
\.


--
-- Name: Apartment Apartment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Apartment"
    ADD CONSTRAINT "Apartment_pkey" PRIMARY KEY (id);


--
-- Name: Expense Expense_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_pkey" PRIMARY KEY (id);


--
-- Name: FlatContribution FlatContribution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatContribution"
    ADD CONSTRAINT "FlatContribution_pkey" PRIMARY KEY (id);


--
-- Name: FlatOwnership FlatOwnership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatOwnership"
    ADD CONSTRAINT "FlatOwnership_pkey" PRIMARY KEY (id);


--
-- Name: FlatTenancy FlatTenancy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatTenancy"
    ADD CONSTRAINT "FlatTenancy_pkey" PRIMARY KEY (id);


--
-- Name: Flat Flat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Flat"
    ADD CONSTRAINT "Flat_pkey" PRIMARY KEY (id);


--
-- Name: MaintenanceRequest MaintenanceRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MaintenanceRequest"
    ADD CONSTRAINT "MaintenanceRequest_pkey" PRIMARY KEY (id);


--
-- Name: MonthlyBill MonthlyBill_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MonthlyBill"
    ADD CONSTRAINT "MonthlyBill_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: WaterMeterReading WaterMeterReading_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WaterMeterReading"
    ADD CONSTRAINT "WaterMeterReading_pkey" PRIMARY KEY (id);


--
-- Name: WaterPurchase WaterPurchase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WaterPurchase"
    ADD CONSTRAINT "WaterPurchase_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Flat_flatNumber_apartmentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Flat_flatNumber_apartmentId_key" ON public."Flat" USING btree ("flatNumber", "apartmentId");


--
-- Name: MonthlyBill_flatId_month_year_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "MonthlyBill_flatId_month_year_key" ON public."MonthlyBill" USING btree ("flatId", month, year);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: WaterMeterReading_flatId_month_year_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WaterMeterReading_flatId_month_year_key" ON public."WaterMeterReading" USING btree ("flatId", month, year);


--
-- Name: Expense Expense_apartmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES public."Apartment"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FlatContribution FlatContribution_flatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatContribution"
    ADD CONSTRAINT "FlatContribution_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES public."Flat"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FlatContribution FlatContribution_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatContribution"
    ADD CONSTRAINT "FlatContribution_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FlatOwnership FlatOwnership_flatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatOwnership"
    ADD CONSTRAINT "FlatOwnership_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES public."Flat"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FlatOwnership FlatOwnership_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatOwnership"
    ADD CONSTRAINT "FlatOwnership_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FlatTenancy FlatTenancy_flatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatTenancy"
    ADD CONSTRAINT "FlatTenancy_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES public."Flat"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FlatTenancy FlatTenancy_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FlatTenancy"
    ADD CONSTRAINT "FlatTenancy_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Flat Flat_apartmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Flat"
    ADD CONSTRAINT "Flat_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES public."Apartment"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MaintenanceRequest MaintenanceRequest_flatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MaintenanceRequest"
    ADD CONSTRAINT "MaintenanceRequest_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES public."Flat"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MaintenanceRequest MaintenanceRequest_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MaintenanceRequest"
    ADD CONSTRAINT "MaintenanceRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MonthlyBill MonthlyBill_flatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MonthlyBill"
    ADD CONSTRAINT "MonthlyBill_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES public."Flat"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Payment Payment_billId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_billId_fkey" FOREIGN KEY ("billId") REFERENCES public."MonthlyBill"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WaterMeterReading WaterMeterReading_flatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WaterMeterReading"
    ADD CONSTRAINT "WaterMeterReading_flatId_fkey" FOREIGN KEY ("flatId") REFERENCES public."Flat"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WaterPurchase WaterPurchase_apartmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WaterPurchase"
    ADD CONSTRAINT "WaterPurchase_apartmentId_fkey" FOREIGN KEY ("apartmentId") REFERENCES public."Apartment"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

