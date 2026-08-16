# CorporatePoolingApp — Software Requirements Specification (SRS)
### Version 3.1 | August 2026 | Tech Stack: Flutter + Supabase (PostgreSQL & PostGIS)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Overview & Architecture](#2-system-overview--architecture)
3. [User Roles & Authentication](#3-user-roles--authentication)
4. [Core Feature: Offer a Ride (Driver)](#4-core-feature-offer-a-ride-driver)
5. [Core Feature: Find a Ride (Rider)](#5-core-feature-find-a-ride-rider)

*(Note: The Super Admin Application specification is maintained in a separate document: `SuperAdmin_SRS_Document.md`).*

---

## 1. Introduction

### 1.1 Product Name
**CorporatePoolingApp** (incorporating the *Karma Ride* peer-to-peer economy model).

### 1.2 Purpose
CorporatePoolingApp is a specialized peer-to-peer corporate carpooling and bike-pooling platform built specifically for Indian corporate hubs and tech parks. It matches office commuters who share overlapping travel corridors and physical office clusters (Same Building / Tech Park). 

Unlike commercial taxi aggregators (Uber, Ola, Rapido), CorporatePoolingApp operates as a **closed/semi-closed cost-sharing community**. The driver is already commuting to work, and the rider shares the empty seats.

### 1.3 Core Philosophy & Architectural Pillars
- **Karma Economy (No Direct Cash/Petrol Liability):** Rides are funded through "Karma Coins". Drivers earn coins by providing rides; coins can be shared across family members or redeemed for employer-sponsored petrol cards / green incentives.
- **Tech Park & Building ID Clustering:** Overcomes the "Company Isolation Trap". While verification is done via corporate email, matching allows cross-company pooling if commuters share the same physical office building or tech park.
- **Multi-Modal Vehicles (Bike & Car):** Designed for Indian road realities with explicit 2-wheeler (Bike/Scooter: 1 passenger + spare helmet requirement) and 4-wheeler support.
- **Hardware-Agnostic 4-Level Boarding Verification:** Replaces missing NFC chips on budget Indian smartphones with Bluetooth Low Energy (BLE) auto-handshake, dynamic "Daily Karma Word" screen touch, dynamic QR codes, and fallback PIN.
- **Data Privacy & Legal Compliance (DPDP Act 2023):** Commutes are classified as personal time. Live SOS broadcasts route strictly to **Personal Trusted Contacts (Family)** and Emergency Services (112), preventing unauthorized workplace surveillance.
- **Two-Phase Zero-API-Cost Matching:** In-memory geometric polyline mathematics combined with PostgreSQL PostGIS spatial indexes, cutting map API costs to near ₹0.

### 1.4 Production Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| **Mobile Frontend** | **Flutter (Dart)** | Single cross-platform codebase for iOS & Android, high-performance UI rendering, robust Bluetooth LE & background location handling. |
| **Database & Auth** | **Supabase (PostgreSQL 15 + PostGIS)** | Relational data integrity, Row Level Security (RLS), ACID coin ledger transactions, and native geospatial queries. |
| **Realtime Engine** | **Supabase Realtime (WebSockets)** | Live GPS broadcasting and instant ride status updates without maintaining a separate Redis/Firebase cluster. |
| **Backend API / Cron** | **Node.js (Express) + Supabase Edge Functions** | High-performance in-memory polyline matching engine and nightly 8:00 PM auto-match cron jobs. |
| **Mapping & Routing** | **Ola Maps / Mapbox SDK** | High free-tier quotas (5M requests/mo on Ola Maps), accurate Indian road networks, and low-cost tile rendering. |
| **Push Notification Pipe** | **FCM (Android) / APNs (iOS) Gateway** | Standard mobile OS push notification bridges triggered via Supabase Edge Functions (used purely as a notification delivery pipe, not database/auth). |

---

## 2. System Overview & Architecture

### 2.1 Main User Flows

```
Driver Flow:
  GiveRideScreen → Vehicle & Helmet Picker → TimePicker (Now/Schedule/Recurring)
  → RouteMapScreen (Polyline generation) → Post to Supabase `rides` table
  → RequestsScreen (Review & Accept) → DriverLiveScreen (BLE Broadcast & GPS)

Rider Flow:
  FindRideScreen → RiderTimePicker → PostGIS + In-Memory Polyline Match
  → Filter by Women-Only / Building ID → Send Request (Coins locked)
  → RiderLiveScreen (BLE Scan / Screen Touch Verification / Live Map)

Corporate Manager / HR Flow:
  CompanyManagerSignup → ManagerDashboard → Employee Verification
  → Aggregated ESG & CO2 Savings Analytics (No individual live GPS tracking)
```

### 2.2 Supabase Relational Architecture (PostgreSQL)

**Core Relational Tables:**
- `users` — User profiles, auth links, verification badges (Work Email, Aadhaar/DL), gender, vehicle references.
- `emergency_contacts` — User-defined personal contacts for emergency SOS broadcasts.
- `buildings` — Physical IT parks, business complexes, and building hubs with centroid coordinates.
- `companies` — Registered corporate employers with domain validation rules (e.g. `@tcs.com`) and manager assignments.
- `rides` — Active, scheduled, and recurring ride offers with PostGIS line geometry (`geometry(LineString, 4326)`).
- `ride_requests` — Booking requests linking riders to posted rides, tracking lifecycle status and locked coins.
- `wallets` — User Karma Coin balances, earned coins, and platform credits.
- `family_wallets` — Primary driver coin sharing pools with authorized family sub-members.
- `coin_transactions` — Immutable double-entry ledger tracking every coin debit, credit, and escrow lock.

**Supabase Realtime Channels:**
- `ride_locations:{ride_id}` — High-frequency driver GPS stream broadcast during active rides (every 3–5 seconds).

---

## 3. User Roles & Authentication

### 3.1 Authentication & Registration Flows
1. **Primary Phone Auth:** User enters Indian mobile number (+91) → Receives SMS OTP via Supabase Auth → Session created.
2. **Registration Choice Screen (`registration_choice_screen.dart`):**
   - **Corporate Commuter (`corporate_signup_screen.dart`):**
     - Work email verification (`name@company.com`) via OTP.
     - Maps to `company_id` and office `building_id`.
   - **Public / Family User (`public_signup_screen.dart`):**
     - Mandatory Government ID verification: **Aadhaar / Driving License (DL)** via DigiLocker / OCR.
     - Optional link to an employee's **Family Wallet** for shared coin access.
   - **Company Manager (`company_manager_signup_screen.dart`):**
     - Corporate Email + Domain Whitelisting + Company Verification.

---

### 3.2 User Roles & Verification Specifications

| Role | Identity & Verification Tier | Capabilities & Access |
|---|---|---|
| **`corporate_employee`** | **Phone OTP + Corporate Work Email OTP**<br>*(e.g., user@infosys.com)* | • Post & book corporate rides.<br>• Access Building & Tech Park pools.<br>• Access "Women-Only" filter.<br>• Primary owner of Karma Coin & Family Wallet. |
| **`public_user` / `family_member`** | **Phone OTP + Aadhaar / Driving License (DL)**<br>*(Verified via DigiLocker / Govt ID check)* | • Post & book public corridor rides.<br>• If linked to an employee: can spend coins from the shared Family Wallet. |
| **`company_manager`** | **Corporate Official Work Email + Company GSTIN/CIN + Admin Approval** | • View company ESG & carbon reduction stats.<br>• View total monthly carpool participation.<br>• Manage company-sponsored ride subsidies. |

#### How Family Members are Verified vs. Linked:
*   **Identity Verification:** A family member goes through the **exact same legal identity verification as any public user (Aadhaar or Driving License)**.
*   **Family Wallet Link (Financial Only):** The link to a primary employee is strictly for **sharing the employee's Karma Coin wallet balance** so the family member can commute using earned coins.

#### How Company Managers are Verified:
1. **Official Corporate Email:** Registration restricted to corporate domains (no Gmail/Yahoo).
2. **Business Proof Verification:** Submission of Company Corporate Identification Number (CIN) / GSTIN or official corporate authorization letter.
3. **Approval:** Super Admin reviews and activates the manager's dashboard privileges.

---

### 3.3 Database Schema: `public.users`

```sql
CREATE TYPE user_role_enum AS ENUM ('corporate_employee', 'public_user', 'family_member', 'company_manager');
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');

CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    gender gender_enum NOT NULL,
    role user_role_enum DEFAULT 'corporate_employee',
    work_email VARCHAR(150) UNIQUE,
    work_email_verified BOOLEAN DEFAULT FALSE,
    company_id UUID REFERENCES public.companies(id),
    building_id UUID REFERENCES public.buildings(id),
    primary_account_id UUID REFERENCES public.users(id), -- Primary employee link for Family Wallet sharing
    gov_id_verified BOOLEAN DEFAULT FALSE, -- Aadhaar / Driving License verification flag
    gov_id_type VARCHAR(20), -- 'aadhaar', 'driving_license'
    profile_photo_url TEXT,
    emergency_contacts JSONB DEFAULT '[]'::jsonb, -- Array of { name, phone, relation }
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 4. Core Feature: Offer a Ride (Driver)

**Primary Screen:** `lib/screens/driver/post_ride_screen.dart`

The ride offering workflow allows drivers to publish empty vehicle seats on their daily route:
1. Select registered vehicle (Bike, Scooter, Car, Sedan) + helmet availability check.
2. Pick **From** (Pickup/Origin) and **To** (Destination/Building).
3. Select departure mode: **⚡ NOW**, **🕐 SCHEDULED**, or **🔄 RECURRING**.
4. Generate road-snapped polyline and sample route points.
5. Configure safety filters (e.g., "Women-Only" match flag).
6. Post the ride to the Supabase database.

---

### 4.1 Vehicle Selection & Seat Capacity Rules

#### Capacity Logic & 2-Wheeler Constraints

| Vehicle Type | Max Passenger Seats | Mandatory Equipment / Rules |
|---|---|---|
| **Motorcycle / Bike** | **1** | Spare Helmet Required (`has_spare_helmet = true`). |
| **Scooter (Gearless)** | **1** | Spare Helmet Required (`has_spare_helmet = true`). |
| **Auto-Rickshaw** | **2** | Commercial badge check (if public). |
| **Hatchback / Sedan / SUV** | **1 to 4** | Configurable by driver (Default: 3). |

```dart
int getMaxAllowedRiders(String vehicleType) {
  switch (vehicleType.toLowerCase()) {
    case 'bike':
    case 'scooter':
      return 1; // Strict rule: Max 1 pillion rider for 2-wheelers
    case 'auto':
      return 2;
    case 'car':
    case 'sedan':
    case 'suv':
    default:
      return 3;
  }
}
```

---

### 4.2 Location Picking & PostGIS Indexing

- **Search via Mapbox / Ola Places Autocomplete:** Resolves address strings to `{ lat, lng, formatted_address }`.
- **Snap to Tech Park / Building Gate:** If the destination is an office campus, coordinates snap to known security gate coordinates to avoid traffic blockages.
- **Geospatial Storage:** Locations are stored as native PostGIS 2D Point geometries (`GEOMETRY(Point, 4326)`), enabling sub-millisecond spatial index searches via spatial GiST indexes.

---

### 4.3 Departure Time Modes

#### 4.3.1 Mode A: ⚡ NOW
- **Use Case:** Driver is walking to their vehicle and leaving immediately.
- **Matching Behavior:** Instantly visible to riders searching in real-time. Uses **Phase 1 radius (500m)** while waiting; shifts to **Phase 2 radius (150m)** once driving starts.
- **Lifecycle:** Single instance. Terminates upon drop-off.

#### 4.3.2 Mode B: 🕐 SCHEDULED
- **Use Case:** Pre-planned trip for today or up to 6 days ahead.
- **Past Time Guard:** Prevents scheduling rides earlier than current local time.
- **Lifecycle:** Pre-matched with riders; triggers departure push notification 15 minutes before scheduled time.

#### 4.3.3 Mode C: 🔄 RECURRING (Commute Backbone)
- **Use Case:** Fixed daily office commutes (e.g., Mon–Fri at 8:30 AM).
- **Configuration:**
  1. Days of Week selection (Default: Mon, Tue, Wed, Thu, Fri).
  2. Fixed departure time (e.g., "08:30 AM").
  3. Validity duration: `1 week`, `1 month`, or `3 months` (stored as `valid_until` date).
  4. Skip Today toggle: Allows driver to take leave on a single day without destroying the recurring rule.
- **Nightly 8:00 PM Auto-Match Lock-in:** The backend cron job pairs recurring riders and drivers every evening at 8:00 PM, locking in seats and eliminating morning booking anxiety.
- **Per-Day Completion State:** Recurring rides **never** transition to a permanent `'completed'` status. Each day's execution adds `YYYY-MM-DD` to `completion_dates[]`, and the master status resets to `'posted'` for the next active calendar day.

---

### 4.4 Route Polyline & Point Extraction
- The application calls the Map Routing API to retrieve the route polyline string between Origin and Destination.
- The polyline is decoded into an array of discrete coordinate waypoints (`route_points = [{ lat, lng }]`) and stored as a PostGIS `LineString` for backend geospatial calculations.

---

### 4.5 Database Schema: `public.rides`

```sql
CREATE TYPE ride_status_enum AS ENUM ('posted', 'started', 'in_progress', 'completed', 'cancelled');
CREATE TYPE time_type_enum AS ENUM ('now', 'scheduled', 'recurring');

CREATE TABLE public.rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    vehicle_type VARCHAR(30) NOT NULL, -- 'bike', 'scooter', 'car', 'sedan'
    vehicle_number VARCHAR(20) NOT NULL,
    has_spare_helmet BOOLEAN DEFAULT FALSE,
    from_address TEXT NOT NULL,
    from_location GEOMETRY(Point, 4326) NOT NULL,
    to_address TEXT NOT NULL,
    to_location GEOMETRY(Point, 4326) NOT NULL,
    building_id UUID REFERENCES public.buildings(id), -- Target Tech Park / Building cluster
    route_geometry GEOMETRY(LineString, 4326) NOT NULL,
    route_points JSONB NOT NULL, -- Array of { lat, lng } points for in-memory algorithm
    distance_km NUMERIC(5, 2) NOT NULL,
    estimated_duration_mins INT NOT NULL,
    seats_offered INT NOT NULL DEFAULT 1,
    seats_available INT NOT NULL DEFAULT 1,
    time_type time_type_enum NOT NULL,
    depart_time TIME NOT NULL,
    depart_date DATE, -- For scheduled rides
    recurring_days INT[] DEFAULT '{}', -- 1 = Mon, 2 = Tue, ..., 7 = Sun
    valid_until DATE, -- Expiry date for recurring commutes
    completion_dates DATE[] DEFAULT '{}',
    skip_dates DATE[] DEFAULT '{}',
    women_only_flag BOOLEAN DEFAULT FALSE,
    boarding_daily_word VARCHAR(20) NOT NULL, -- e.g. "KARMA", "COFFEE"
    boarding_ble_uuid UUID DEFAULT gen_random_uuid(),
    ride_status ride_status_enum DEFAULT 'posted',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial indices for ultra-fast PostGIS route bounding queries
CREATE INDEX idx_rides_from_location ON public.rides USING GIST(from_location);
CREATE INDEX idx_rides_to_location ON public.rides USING GIST(to_location);
CREATE INDEX idx_rides_route_geometry ON public.rides USING GIST(route_geometry);
```

---

## 5. Core Feature: Find a Ride (Rider)

**Primary Screen:** `lib/screens/rider/find_ride_screen.dart`

The Rider flow enables corporate employees to discover drivers travelling on identical commute corridors.

---

### 5.1 Rider Search Flow & Two-Phase Discovery

```
[ Rider Inputs: Pickup + Drop Location + Time Window + Safety Filters ]
                                  │
                                  ▼
[ Step 1: PostGIS Spatial Pre-Filter (PostgreSQL Server) ]
  Filters rides whose route_geometry passes within 1.5 km of Pickup & Drop.
                                  │
                                  ▼
[ Step 2: In-Memory Polyline Matching (Node.js / Client Dart Engine) ]
  Calculates exact Cross-Track distance to line segments:
  - Phase 1 (Ride Posted): Within 500m pickup / 500m drop
  - Phase 2 (Ride Started): Within 150m pickup
                                  │
                                  ▼
[ Step 3: Corporate Trust & Building Filter ]
  - Same Company -> 100% Match Priority
  - Same Building ID -> 95% Match Priority (Basement/Lobby Pickup)
  - Women-Only Filter Check -> Hides male drivers if Rider requested Female-only
                                  │
                                  ▼
[ Step 4: Results Displayed with Match Score (0–100) & Instant Request Button ]
```

---

### 5.2 Rider Search Criteria & Matching Rules

| Parameter | Rule / Logic |
|---|---|
| **Pickup Location** | Must be within 500m of the driver's road path (Phase 1) or 150m (Phase 2). |
| **Drop Location** | Must be within 500m of the driver's destination or office building. |
| **Time Compatibility** | Departure time within ±15 minutes of rider's preferred time. |
| **Vehicle Match** | For bike-pool requests, verifies driver has `has_spare_helmet = true`. |
| **Gender Filter** | If rider enables "Women-Only", only female drivers offering rides with `women_only_flag = true` appear. |
| **Building ID Bonus** | If `driver.building_id == rider.building_id`, displays a **"Same Building" badge**, allowing direct basement parking pickups. |

---

### 5.3 Ride Request & Escrow Locking

When the rider taps "Request Ride", the application:
1. Calculates the required Karma Coins based on route distance (`distance_km * COIN_RATE_PER_KM`).
2. Checks wallet balance:
   - Evaluates Rider's individual `wallet`.
   - If balance is insufficient, checks if Rider is linked to an active `family_wallet` with available coin pool.
3. Places coins in **Escrow Lock** (`coins_locked`) inside `public.ride_requests`. Coins are deducted from spendable balance immediately to prevent double-spending, but are not released to the driver until physical ride completion.

---

### 5.4 Database Schema: `public.ride_requests`

```sql
CREATE TYPE request_status_enum AS ENUM ('pending', 'accepted', 'rejected', 'cancelled', 'in_ride', 'completed');

CREATE TABLE public.ride_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
    rider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    pickup_address TEXT NOT NULL,
    pickup_location GEOMETRY(Point, 4326) NOT NULL,
    drop_address TEXT NOT NULL,
    drop_location GEOMETRY(Point, 4326) NOT NULL,
    coins_locked NUMERIC(6, 2) NOT NULL,
    used_family_wallet_id UUID REFERENCES public.family_wallets(id),
    status request_status_enum DEFAULT 'pending',
    boarding_verified_at TIMESTAMPTZ,
    verification_method_used VARCHAR(30), -- 'ble_proximity', 'daily_word_touch', 'qr_code', 'pin'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for instant lookup of requests by ride or rider
CREATE INDEX idx_ride_requests_ride_id ON public.ride_requests(ride_id);
CREATE INDEX idx_ride_requests_rider_id ON public.ride_requests(rider_id);
```
