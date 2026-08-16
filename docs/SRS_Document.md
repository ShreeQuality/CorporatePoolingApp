# CorporatePoolingApp — Software Requirements Specification (SRS)
### Version 3.5 | August 2026 | Tech Stack: Flutter + Supabase (PostgreSQL & PostGIS)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Overview & Architecture](#2-system-overview--architecture)
3. [User Roles, Verification & Authentication](#3-user-roles-verification--authentication)
4. [Core Feature: Offer a Ride (Driver)](#4-core-feature-offer-a-ride-driver)
5. [Core Feature: Find a Ride (Rider)](#5-core-feature-find-a-ride-rider)
6. [Matching Algorithm — Phase-Based KM/Meter Logic & Scoring Engine](#6-matching-algorithm--phase-based-kmmeter-logic--scoring-engine)
7. [GPS Tracking System & Live Navigation](#7-gps-tracking-system--live-navigation)

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
- **Tech Park & Building ID Clustering:** Overcomes the "Company Isolation Trap". While verification is done via corporate email or office ID badge, matching allows cross-company pooling if commuters share the same physical office building or tech park.
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

Corporate Employer / HR Manager Flow:
  CompanyManagerSignup (Upload GSTIN + CIN + LOA) → Super Admin Review
  → ManagerDashboard (Prepaid Commute Pool Recharge & ESG Carbon Reports)
```

---

## 3. User Roles, Verification & Authentication

### 3.1 Finalized Verification Framework by User Role

```
+---------------------------------------------------------------------------------------------------+
|                                 PLATFORM VERIFICATION MATRIX                                      |
+---------------------------------------------------------------------------------------------------+
| 1. Corporate Employee  -> Phone OTP + [Work Email OTP OR Office ID Photo] + Mandatory Aadhaar KYC|
| 2. Public / Family User-> Phone OTP + Mandatory Aadhaar / DL KYC (QR / ML Kit / Photo)            |
| 3. Corporate Employer  -> Phone OTP + Admin Work Email OTP + GSTIN + CIN + Signed Letterhead (LOA)|
| 4. Driver (Bike/Car)   -> Vehicle Plate Regex Check + Driving License Photo + Vehicle RC Photo    |
+---------------------------------------------------------------------------------------------------+
```

---

### 3.2 Detailed Verification Specifications

#### A. Corporate Employees (`corporate_signup_screen.dart`)
To ensure total safety and community trust, corporate commuters complete **Dual-Shield Verification**:
1. **Employment Verification (Choice of 2 Methods):**
   - **Method 1 (Instant):** Corporate Work Email OTP (`@company.com`). System validates domain against `public.companies` whitelist.
   - **Method 2 (Firewall Fallback):** Physical Office ID Card photo upload (for employees in banks or defense companies where firewalls block external OTPs). Verified via on-device OCR / Super Admin review.
2. **Legal Identity Verification (Mandatory Aadhaar KYC):**
   - **Phase 1 (₹0 Launch):** On-Device Aadhaar Secure QR Code scan / Google ML Kit text extraction with Verhoeff mathematical checksum + photo upload.
   - **Phase 2 (Scale):** Optional automated DigiLocker API (Setu / Cashfree) for instant 2-second Govt OTP KYC.
3. **Result:** Employee gets the **"Verified Corporate Citizen"** badge, mapping them to their `company_id` and `building_id`.

#### B. Public & Family Users (`public_signup_screen.dart`)
1. **Primary Phone Auth:** SMS OTP via Supabase Auth + Fast2SMS/MSG91.
2. **Identity KYC:** Mandatory Government ID verification (Aadhaar or Driving License) via Secure QR scan / on-device OCR / Super Admin audit.
3. **Family Account Linking:** Optional link to a primary employee's account for **sharing Karma Coin balances only**.

#### C. Corporate Employers / HR Managers (`company_manager_signup_screen.dart`)
To onboard an enterprise onto the platform's B2B prepaid program:
1. **Account Creation:** Phone SMS OTP + Authorized Corporate Work Email OTP (`hr.director@company.com`).
2. **Required Business Documents:**
   - **GSTIN Certificate (Form GST REG-06):** 15-digit tax registration proof.
   - **Certificate of Incorporation (CIN):** 21-digit MCA registration document.
   - **Company Corporate PAN Card:** 10-digit tax ID.
   - **HR Letter of Authority (LOA):** 1-page signed authorization on official company letterhead with corporate stamp.
3. **Super Admin Verification & Anti-Fraud Gates:**
   - Super Admin cross-references GSTIN on the official Govt GST Portal (`services.gst.gov.in`).
   - Super Admin verifies company status and confirms signing Director name on the official MCA Master Database (`mca.gov.in`).
   - Super Admin verifies corporate email domain ownership before whitelisting.
4. **Activation:** Super Admin activates the company portal, enabling prepaid wallet recharges and employee commute grants.

#### D. Drivers (`add_vehicle_screen.dart`)
1. **Format Validation (₹0):** Vehicle registration number validated in Dart (`^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$`).
2. **Dual Document Upload:** Snaps photo of **Driving License (DL)** and **Vehicle RC Card**.
3. **1-Click Super Admin Approval:** Documents audited side-by-side in the Super Admin KYC queue at **₹0 API cost**.

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
    office_id_photo_url TEXT,
    office_id_verified BOOLEAN DEFAULT FALSE,
    company_id UUID REFERENCES public.companies(id),
    building_id UUID REFERENCES public.buildings(id),
    primary_account_id UUID REFERENCES public.users(id),
    aadhaar_verified BOOLEAN DEFAULT FALSE,
    aadhaar_masked_number VARCHAR(20),
    dl_verified BOOLEAN DEFAULT FALSE,
    dl_photo_url TEXT,
    profile_photo_url TEXT,
    emergency_contacts JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 4. Core Feature: Offer a Ride (Driver)

**Primary Screen:** `lib/screens/driver/post_ride_screen.dart`

---

### 4.1 Vehicle Selection & Seat Capacity Rules

| Vehicle Type | Max Passenger Seats | Mandatory Equipment / Rules |
|---|---|---|
| **Motorcycle / Bike** | **1** | Spare Helmet Required (`has_spare_helmet = true`). |
| **Scooter (Gearless)** | **1** | Spare Helmet Required (`has_spare_helmet = true`). |
| **Auto-Rickshaw** | **2** | Commercial badge check (if public). |
| **Hatchback / Sedan / SUV** | **1 to 4** | Configurable by driver (Default: 3). |

---

### 4.1.1 Driver Registration: Unified DL & Vehicle RC Verification (₹0 Workflow)

**Screen:** `lib/screens/driver/add_vehicle_screen.dart`

```
+-------------------------------------------------------------------+
|                     Register Driver & Vehicle                     |
+-------------------------------------------------------------------+
|  1. Vehicle Details:                                              |
|     - Vehicle Type:   [ Bike 🛵 ]  [ Car 🚗 ]                     |
|     - Vehicle Plate:  [ MH-12-AB-1234 ]  (Instant Regex Check ✅) |
|     - Spare Helmet:   [X] Yes, I have a spare helmet              |
|                                                                   |
|  2. Document Photos (Saved to Supabase Storage):                  |
|     [ 📷 Upload Driving License (DL) ]                            |
|     [ 📷 Upload Vehicle RC Card      ]                            |
|                                                                   |
|                    [ SUBMIT FOR VERIFICATION ]                    |
+-------------------------------------------------------------------+
```

---

### 4.2 Location Picking & PostGIS Indexing
- Locations are stored as native PostGIS 2D Point geometries (`GEOMETRY(Point, 4326)`), enabling sub-millisecond spatial index searches via spatial GiST indexes.

---

### 4.3 Departure Time Modes
- **Mode A: ⚡ NOW** (Single instance, real-time discovery).
- **Mode B: 🕐 SCHEDULED** (Future departure, departure push notification).
- **Mode C: 🔄 RECURRING** (Mon–Fri fixed commute, 8:00 PM auto-match cron, per-day completion state in `completion_dates[]`).

---

### 4.4 Route Polyline & Point Extraction
- Decodes route polyline into coordinate waypoints (`route_points = [{ lat, lng }]`) stored as PostGIS `LineString`.

---

### 4.5 Database Schema: `public.rides`

```sql
CREATE TYPE ride_status_enum AS ENUM ('posted', 'started', 'in_progress', 'completed', 'cancelled');
CREATE TYPE time_type_enum AS ENUM ('now', 'scheduled', 'recurring');

CREATE TABLE public.rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    vehicle_type VARCHAR(30) NOT NULL,
    vehicle_number VARCHAR(20) NOT NULL,
    has_spare_helmet BOOLEAN DEFAULT FALSE,
    from_address TEXT NOT NULL,
    from_location GEOMETRY(Point, 4326) NOT NULL,
    to_address TEXT NOT NULL,
    to_location GEOMETRY(Point, 4326) NOT NULL,
    building_id UUID REFERENCES public.buildings(id),
    route_geometry GEOMETRY(LineString, 4326) NOT NULL,
    route_points JSONB NOT NULL,
    distance_km NUMERIC(5, 2) NOT NULL,
    estimated_duration_mins INT NOT NULL,
    seats_offered INT NOT NULL DEFAULT 1,
    seats_available INT NOT NULL DEFAULT 1,
    time_type time_type_enum NOT NULL,
    depart_time TIME NOT NULL,
    depart_date DATE,
    recurring_days INT[] DEFAULT '{}',
    valid_until DATE,
    completion_dates DATE[] DEFAULT '{}',
    skip_dates DATE[] DEFAULT '{}',
    women_only_flag BOOLEAN DEFAULT FALSE,
    boarding_daily_word VARCHAR(20) NOT NULL,
    boarding_ble_uuid UUID DEFAULT gen_random_uuid(),
    ride_status ride_status_enum DEFAULT 'posted',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rides_from_location ON public.rides USING GIST(from_location);
CREATE INDEX idx_rides_to_location ON public.rides USING GIST(to_location);
CREATE INDEX idx_rides_route_geometry ON public.rides USING GIST(route_geometry);
```

---

## 5. Core Feature: Find a Ride (Rider)

**Primary Screen:** `lib/screens/rider/find_ride_screen.dart`

---

### 5.1 Rider Search Flow & Interactive Route Preview
1. Rider specifies pickup, drop, departure time, and safety preferences.
2. Two-tier evaluation returns ranked drivers (Section 6).
3. **Interactive Route Map Preview (`rider_route_preview_screen.dart`):** Displays driver route corridor and allows rider to fine-tune pickup landmark pin directly on the driver's road vector.
4. **Escrow Lock:** Tapping request locks Karma Coins in escrow.
5. **Driver Review (`requests_screen.dart`):** Driver receives push notification and taps Accept or Reject.

---

### 5.2 Database Schema: `public.ride_requests`

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
    verification_method_used VARCHAR(30),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ride_requests_ride_id ON public.ride_requests(ride_id);
CREATE INDEX idx_ride_requests_rider_id ON public.ride_requests(rider_id);
```

---

## 6. Matching Algorithm — Phase-Based KM/Meter Logic & Scoring Engine

**Module File:** `src/matchingAlgorithm.js` (Node.js) & `lib/services/matching_service.dart` (Dart)

---

### 6.1 The 2-Tier Hybrid Funnel Architecture
- **Tier 1 (PostGIS Spatial Pre-Filter):** `ST_DWithin` with dynamic Bounding Box prunes 95% of candidates in < 5ms.
- **Tier 2 (In-Memory Cross-Track Polyline Matcher):** Evaluates line-segment distance, phase radii, and scoring in 12ms.

---

### 6.2 Mathematical Foundation
- **Cross-Track Line-Segment Projection:** Projects rider coordinate onto road segment $(A \to B)$ avoiding discrete waypoint gaps.
- **Urban Tortuosity Multiplier:** $D_{\text{road}} \approx D_{\text{haversine}} \times 1.3$.

---

### 6.3 Phase-Aware Dynamic Radii
- **Phase 1 (Pre-Departure):** **500 meters** (Expanded to **1,500m** if `building_id` matches).
- **Phase 2 (Live On-Route):** **150 meters** (Tightened for driver traffic safety).

---

### 6.4 Directionality & Backward Route Guard
- Enforces $\text{Index}_{\text{pickup}} < \text{Index}_{\text{drop}}$. Hard rejects opposite direction rides.

---

### 6.5 Trust & Priority Scoring Formula (0 to 100 Points)
$$\text{Total Score} = S_{\text{proximity}} (40) + S_{\text{trust}} (30) + S_{\text{time}} (20) + S_{\text{karma}} (10)$$
- **Same Company Colleague:** +30 Pts.
- **Same Building / Tech Park:** +25 Pts.
- **Other Corporate:** +15 Pts.
- **Public Verified:** +10 Pts.

---

### 6.6 Hard Exclusion Gates
1. Women-Only Check $\rightarrow$ 2. Directionality Check $\rightarrow$ 3. 2-Wheeler Helmet Guard $\rightarrow$ 4. Seat Capacity Check.

---

## 7. GPS Tracking System & Live Navigation

**Primary Module:** `lib/services/gps_tracking_service.dart` & Supabase Realtime Channels

The GPS Tracking System powers real-time vehicle movement visualization, battery-efficient telemetry, and legal privacy isolation.

---

### 7.1 Real-Time GPS Broadcasting Architecture

```
[ Driver Phone in Motion ] ──► Flutter Background GPS Task (3–5s interval)
                                      │
                                      ▼
[ Supabase Realtime Channel: `ride_locations:{ride_id}` ]
                                      │
                                      ▼
[ Rider Phone Screen ] ───────► Smooth Marker Interpolation & Vehicle Rotation
```

#### Protocol & Payload Schema:
* Driver broadcasts over a private WebSocket channel (`ride_locations:{ride_id}`).
* Realtime Payload emitted every **3 to 5 seconds**:
```json
{
  "ride_id": "8421a1b2-c3d4-4e5f-6a7b-8c9d0e1f2a3b",
  "driver_id": "u1234567-89ab-cdef-0123-456789abcdef",
  "lat": 18.520432,
  "lng": 73.856743,
  "heading": 142.5,
  "speed_kmh": 42.0,
  "timestamp": "2026-08-16T17:55:00.000Z"
}
```

---

### 7.2 Battery, Data & Motion Optimization

To prevent battery drain and excessive mobile data usage during peak Indian traffic:
1. **Motion Distance Threshold:** The GPS service only emits a WebSocket packet if the vehicle has moved **$> 5\text{ meters}$** from the previous broadcast (prevents spamming during red lights and traffic jams).
2. **On-Device Kalman Filtering:** Applies linear quadratic estimation (Kalman filter) to smooth raw GPS noise and eliminate erratic jumping caused by urban high-rise buildings.
3. **Automated Lifecycle Management:** The background GPS foreground service (`geolocator`) strictly terminates the moment the ride status transitions to `'completed'` or `'cancelled'`, releasing battery lock immediately.

---

### 7.3 Client-Side Smooth Marker Animation (Flutter)

* **Tween Interpolation:** Rider's Flutter app uses spherical linear interpolation (`slerp`) between coordinate packets $(P_{\text{old}} \to P_{\text{new}})$ over a 3-second transition duration.
* **Heading Rotation:** Vehicle icon rotates smoothly to align with the driver's current heading angle (`heading` in degrees), ensuring realistic navigation graphics identical to Uber and Google Maps.

---

### 7.4 Privacy & Legal Isolation (DPDP Act 2023 Compliance)

```
+-------------------------------------------------------------------------------------------------------+
| VIEWER                 | DRIVER LOCATION VISIBILITY      | RIDER LOCATION VISIBILITY | PRIVACY STATUS |
+-------------------------------------------------------------------------------------------------------+
| 1. Confirmed Rider     | 🟢 Full Live 3–5s Moving Stream | (Own screen)              | Active in-ride |
| 2. Confirmed Driver    | (Own vehicle GPS)               | 📍 Static Pickup Landmark | Active in-ride |
| 3. Employer / HR Desk  | 🔴 100% BLOCKED (Zero GPS)      | 🔴 100% BLOCKED (Zero GPS)| Private Commute|
+-------------------------------------------------------------------------------------------------------+
```

#### Employer Milestone Status (Soft Attendance Only):
Under Section 4 and 6 of the Indian DPDP Act, the Employer HR Dashboard **NEVER** receives raw live GPS maps or home address coordinates. The HR dashboard strictly displays abstract operational status milestones:
* 🚗 `Commute In-Transit` (ETA to Tech Park: ~8:45 AM)
* 🏢 `Arrived at Tech Park` (Checked into Basement / Campus Gate at 8:40 AM)
* 🏠 `Working from Home` / `On Leave Today`

---

### 7.5 Network Resiliency & Flyover/Basement Recovery

1. **Last-Known Coordinate Cache:** If mobile network drops under flyovers or in basement parking, the rider UI maintains the last known position with a subtle *"Reconnecting..."* status chip.
2. **Exponential Backoff Auto-Reconnect:** Supabase WebSocket reconnects automatically within 0.5 seconds upon regaining network signal, resuming real-time streaming with zero user intervention.

---

### 7.6 1-Tap External Turn-by-Turn Voice Navigation

**Driver Action Button:** `"🗺️ Start Turn-by-Turn Navigation"`
* When tapped, the Flutter app triggers a deep link intent (`geo:lat,lng` / `https://maps.google.com/maps?daddr=...` or `olamaps://`) opening the driver's preferred native navigation app (**Ola Maps / Google Maps / Apple Maps**).
* The CorporatePooling Flutter background service continues streaming vehicle GPS telemetry to the rider in the background while the driver hears voice driving directions.
