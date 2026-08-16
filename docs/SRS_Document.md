# CorporatePoolingApp — Software Requirements Specification (SRS)
### Version 3.10 | August 2026 | Tech Stack: Flutter + Supabase (PostgreSQL & PostGIS)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Overview & Architecture](#2-system-overview--architecture)
3. [User Roles, Verification & Authentication](#3-user-roles-verification--authentication)
4. [Core Feature: Offer a Ride (Driver)](#4-core-feature-offer-a-ride-driver)
5. [Core Feature: Find a Ride (Rider)](#5-core-feature-find-a-ride-rider)
6. [Matching Algorithm — Phase-Based KM/Meter Logic & Scoring Engine](#6-matching-algorithm--phase-based-kmmeter-logic--scoring-engine)
7. [GPS Tracking System & Live Navigation](#7-gps-tracking-system--live-navigation)
8. [Ride Request, Acceptance Flow, Wait Timers & Commute Calendar](#8-ride-request-acceptance-flow-wait-timers--commute-calendar)
9. [Hardware-Agnostic 3-Level Boarding Verification & State Machine](#9-hardware-agnostic-3-level-boarding-verification--state-machine)
10. [Ride Completion, Atomic Coin Transfer & ESG Engine](#10-ride-completion-atomic-coin-transfer--esg-engine)

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
- **Hardware-Agnostic 3-Level Boarding Verification:** Streamlined multi-tier verification using Bluetooth Low Energy (BLE) auto-handshake, dynamic QR codes, and fallback PIN (zero NFC hardware dependency).
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
  → Approx Reach Time (ETA) Calculated → RouteMapScreen (Polyline generation)
  → Post to Supabase `rides` table (Max 4/day cap check)
  → "Create Return Ride?" 1-Tap Prompt → RequestsScreen (Review & Accept)
  → DriverLiveScreen (BLE Broadcast & GPS) → Boarding Verified → Complete Ride (Drop-off & Coins)

Rider Flow:
  FindRideScreen → RiderTimePicker → PostGIS + In-Memory Polyline Match
  → (If 0 rides: "Set Search Alert" 🔔) → RoutePreviewScreen (Drag & Snap Pins)
  → Multi-Seat Selection [1 or 2] → Send Request (Smart Escrow locked)
  → RiderLiveScreen (Live Tracking & 5-min timer) → Boarding (BLE/QR/PIN) → Drop-off & Receipt

Corporate Employer / HR Manager Flow:
  CompanyManagerSignup (Upload GSTIN + CIN + LOA) → Super Admin Review
  → ManagerDashboard (Prepaid Commute Pool Recharge & Soft Attendance Reports)
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
    auto_accept_colleagues BOOLEAN DEFAULT FALSE,
    auto_accept_max_detour_m INT DEFAULT 100,
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
- **Mode C: 🔄 RECURRING** (Mon–Fri fixed commute, 8:00 PM auto-match cron, per-day completion in `completion_dates[]`, and daily skip toggle in `skip_dates[]`).

---

### 4.4 Route Polyline & Point Extraction
- Decodes route polyline into coordinate waypoints (`route_points = [{ lat, lng }]`) stored as PostGIS `LineString`.

---

### 4.5 1-Tap Evening Return Commute Prompt

Immediately after a driver posts a morning ride (whether **NOW ⚡** or **SCHEDULED 🕐**), the application displays a friendly 1-tap modal:

```
+-------------------------------------------------------------------+
|                 🚗 POST YOUR EVENING RETURN TRIP?                 |
+-------------------------------------------------------------------+
|  You posted: Home ➔ Manyata Tech Park (Morning 8:30 AM)           |
|                                                                   |
|  Would you like to schedule your evening return ride?             |
|  📍 Return Route:  Manyata Tech Park ➔ Home                       |
|  ⏰ Suggested:     5:30 PM Today                                  |
|                                                                   |
|         [ ✕ NO, JUST THIS RIDE ]    [ ⚡ YES, POST RETURN RIDE ]   |
+-------------------------------------------------------------------+
```

---

### 4.6 Driver Daily Posting Limits & Collision Detection (Max 4 Rides/Day)

1. **Daily Posting Cap:** Maximum **4 active rides per user per calendar day** (Configurable in Super Admin).
2. **Approximate Destination Arrival Time (ETA Calculation):**
   * Stores `approx_reach_time TIME NOT NULL` based on road distance and traffic speed.
3. **Time-Overlap Collision Guard:**
   * A driver cannot post a second ride whose time window `[depart_time, approx_reach_time]` overlaps with another active ride of that driver.
4. **Dual-Role Collision Prevention:**
   * The database prevents a user from posting a ride as a Driver during any time slot where they already have a confirmed booking as a Rider.

---

### 4.7 Database Schema: `public.rides`

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
    depart_time TIME NOT NULL,
    approx_reach_time TIME NOT NULL,
    depart_date DATE,
    seats_offered INT NOT NULL DEFAULT 1,
    seats_available INT NOT NULL DEFAULT 1,
    time_type time_type_enum NOT NULL,
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

### 5.1 Rider Search Flow & Interactive Route Preview (`rider_route_preview_screen.dart`)

```
+-------------------------------------------------------------------+
| [ ‹ Back ]            Commute with Rahul Sharma (Infosys)         |
+-------------------------------------------------------------------+
|                                                                   |
|   ══════════════ Driver's Posted Route (Blue Line) ════════════   |
|                 │                                 │               |
|                 📍 🟢 [ DRAG PICKUP PIN ]          📍 🔴 [ DROP ]  |
|                 "Manyata Gate 2 Bus Stop"         "Hinjewadi Cir" |
|                                                                   |
|   💡 Tip: Drag your pin onto the blue line for instant acceptance!|
|                                                                   |
+-------------------------------------------------------------------+
|  📍 Selected Pickup: Gate 2 Bus Stop (0m Detour for Driver)       |
|  🏁 Selected Drop:   Hinjewadi Phase 1 Main Circle                |
|  👥 Seats Requested: [ 1 Seat (Default) ]  [ 2 Seats (Teammate) ] |
|  🪙 Karma Coins:     24 Coins (Locked in Escrow)                  |
|                                                                   |
|                 [ 🚀 CONFIRM & SEND REQUEST ]                     |
+-------------------------------------------------------------------+
```

#### Step-by-Step Interactive Pin Snapping:
1. **Visual Highway Overlay:** Rider taps matched driver card $\rightarrow$ renders driver’s **Blue Highway Polyline Route**.
2. **Draggable Pickup & Drop Pins:** Rider drags **Green Pickup Pin** and **Red Drop Pin** directly onto the driver's road line.
3. **Snap-to-Route Magnet Effect:** When dragged within 100m of the line, the pin snaps to popular roadside landmarks with **0 meters of detour**.
4. **Dynamic Recalculation:** Instantly recalculates driving distance ($km$) and required Karma Coins in real-time.

---

### 5.2 "Notify Me When a Ride Appears" (Search Alerts)

If a rider searches for a morning route and **zero matching drivers** are currently posted:
1. The app displays an empty state with a prominent action: **"🔔 Notify Me When a Colleague Posts"**.
2. Rider taps the button $\rightarrow$ Creates a record in `public.search_alerts`.
3. **Automated Match Listener:** When any driver posts a matching route corridor later, Supabase Edge Functions trigger a high-priority push alert to the rider:
   * *"🔔 Matching Ride Found! Rahul (Infosys) just posted a commute to Manyata for 8:30 AM. Tap to book!"*

---

### 5.3 Multi-Seat Booking (1 or 2 Seats)
* Riders can choose `seats_requested = 1` (Default) or `seats_requested = 2` (e.g., traveling with a project teammate).
* Escrow locks $(N \times \text{Coins})$, and booking decrements $N$ seats from the driver's vehicle upon acceptance.

---

### 5.4 Database Schema: `public.ride_requests` & `public.search_alerts`

```sql
CREATE TYPE request_status_enum AS ENUM ('pending', 'accepted', 'rejected', 'cancelled', 'expired', 'in_ride', 'completed');

CREATE TABLE public.ride_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
    rider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    pickup_address TEXT NOT NULL,
    pickup_location GEOMETRY(Point, 4326) NOT NULL,
    drop_address TEXT NOT NULL,
    drop_location GEOMETRY(Point, 4326) NOT NULL,
    seats_requested INT DEFAULT 1,
    coins_locked NUMERIC(6, 2) NOT NULL,
    used_family_wallet_id UUID REFERENCES public.family_wallets(id),
    status request_status_enum DEFAULT 'pending',
    expires_at TIMESTAMPTZ NOT NULL,
    driver_arrived BOOLEAN DEFAULT FALSE,
    driver_arrived_at TIMESTAMPTZ,
    boarding_verified_at TIMESTAMPTZ,
    verification_method_used VARCHAR(30),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.search_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    from_location GEOMETRY(Point, 4326) NOT NULL,
    to_location GEOMETRY(Point, 4326) NOT NULL,
    target_time TIME NOT NULL,
    target_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ride_requests_ride_id ON public.ride_requests(ride_id);
CREATE INDEX idx_ride_requests_rider_id ON public.ride_requests(rider_id);
CREATE INDEX idx_search_alerts_user_id ON public.search_alerts(user_id);
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

---

### 7.1 Real-Time GPS Broadcasting Architecture
* Broadcasts over private Supabase WebSocket channel (`ride_locations:{ride_id}`) every **3 to 5 seconds**.
* Realtime Payload: `{ ride_id, driver_id, lat, lng, heading, speed_kmh, timestamp }`.

---

### 7.2 Battery, Data & Motion Optimization
1. **Motion Filter:** Only emits if moved **$> 5\text{ meters}$**.
2. **On-Device Kalman Filter:** Eliminates urban GPS jitter.
3. **Automated Lifecycle:** Foreground location task terminates immediately upon trip completion.

---

### 7.3 Client-Side Smooth Marker Animation (Flutter)
* Uses spherical linear interpolation (`slerp`) and heading-based car icon rotation for smooth rendering.

---

### 7.4 Privacy & Legal Isolation (DPDP Act 2023 Compliance)
* **Confirmed Rider:** Live 3–5s moving car stream.
* **Confirmed Driver:** Static pickup landmark pin.
* **Employer / HR Desk:** 🔴 **100% BLOCKED from live GPS**. HR dashboard receives text milestone status only (`In-Transit`, `ETA: 8:45 AM`, `Arrived at Tech Park`).

---

### 7.5 Network Resiliency & 1-Tap External Voice Navigation
* Auto-reconnects in 0.5s after tunnels/basements.
* 1-Tap deep link launches **Ola Maps / Google Maps** for voice navigation while tracking in the background.

---

## 8. Ride Request, Acceptance Flow, Wait Timers & Commute Calendar

**Primary Modules:** `lib/screens/driver/requests_screen.dart`, `lib/screens/rider/rider_calendar_screen.dart`, `lib/screens/driver/driver_calendar_screen.dart`

---

### 8.1 Request Submission & Escrow Locking (Step-by-Step)

```
[ Rider Taps "Confirm & Send Request" ]
                  │
                  ▼
[ 1. Distance & Coin Calculation ] ──► Exact KM along road polyline × Coin Rate
                  │
                  ▼
[ 2. Wallet Balance & Priority Check ] ──► Corporate Grant ➔ Personal Wallet ➔ Family Wallet
                  │
                  ▼ (If balance sufficient)
[ 3. Smart Multi-Request Escrow Lock ] ──► Locks highest single fare (Up to 3 Drivers)
                  │
                  ▼
[ 4. Atomic PostgreSQL ACID Transaction ] ──► `SELECT FOR UPDATE` prevents double-spending
                  │
                  ▼
[ 5. High-Priority Driver Push Alert ] ──► FCM/APNs wake up driver with custom chime
                  │
                  ▼
[ 6. Rider Live Waiting UI ] ──────────► Active radar ring + countdown + 1-Tap Cancel
                  │
                  ▼
[ 7. Automated Self-Healing Rollback ] ──► Instant 100% coin refund on Reject/Timeout
```

#### Multi-Request Smart Escrow Rule (Up to 3 Drivers):
* Riders can send simultaneous requests to **up to 3 matching drivers** for the same commute slot.
* The system locks **ONLY the single highest fare** (e.g. if Driver A is 24 coins, Driver B is 22 coins, Driver C is 25 coins $\rightarrow$ locks **25 coins max**, not $71$ coins).
* **First-to-Accept Race Condition:** The first driver to tap "Accept" secures the passenger. The system **instantly and automatically cancels the pending requests to the other 2 drivers in 0.1 seconds**, unlocking any surplus escrow coins.

---

### 8.2 2-Tier Driver Review Screen (`requests_screen.dart`)

The Driver review interface provides two distinct inspection modes:

#### 1. Default Mode: Rider Summary Card
```
+-------------------------------------------------------------------+
|                     NEW COMMUTE RIDE REQUEST                      |
+-------------------------------------------------------------------+
|  👤 Rahul Sharma  ⭐ 4.9 (42 Rides)                               |
|  🏢 Verified: Infosys (@infosys.com) | 🆔 Aadhaar Verified        |
|                                                                   |
|  📍 Pickup: Manyata Tech Park, Gate 2 Bus Stop                    |
|  🏁 Drop:   Hinjewadi Phase 1, Main Circle                        |
|  🪙 You Earn: +24 Karma Coins                                     |
|                                                                   |
|  +-------------------------------------------------------------+  |
|  | [🗺️ Mini Map Preview - Tap to Maximize Full Screen]        |  |
|  |  🔵 Your Route Line  ──────►  🟢 Rider Pickup Pin           |  |
|  +-------------------------------------------------------------+  |
|                                                                   |
|         [ ❌ DECLINE ]              [ ✅ ACCEPT RIDE ]            |
+-------------------------------------------------------------------+
```

#### 2. Maximized Mode: Full-Screen Interactive Road Overlay
* Tapping the map expands it full-screen, showing the driver's **Blue Route Polyline**, the **Green Pickup Pin**, and the **Red Drop Pin** with floating action buttons.

---

### 8.3 Mode-Specific Auto-Expiry Response Timers

| Departure Mode | Driver Response Window | Hard Departure Cutoff Rule | Expiry Action |
|---|---|---|---|
| **⚡ NOW** | **3 Minutes (180s)** | Immediate real-time expiry | Marks request `'expired'`, 100% coins unlocked. |
| **🕐 SCHEDULED** | **15 Minutes** | Auto-expires **15 mins before departure** | Marks request `'expired'`, 100% coins unlocked. |
| **🔄 RECURRING** | **2 Hours (8 PM – 10 PM)** | Auto-expires at 10:00 PM nightly | Seat opens for other commuters. |

---

### 8.4 Driver Arrival (50m Geofence) & Synchronized 5-Minute Wait Timer

```
[ Phase 1: 500m Nudge ] ──► Rider receives: "Driver is 2 mins away, head to pickup!"
            │
            ▼
[ Phase 2: 50m Geofence Arrival ] ──► Driver reaches 50m radius ➔ Status: "ARRIVED"
            │
            ▼
[ Phase 3: Synchronized 5-Min Timer ] ──► Live 05:00 countdown ticks on BOTH screens
            │
            ├──► 🟢 If Rider Boards before 00:00 ──► 4-Level Boarding verified ➔ Trip Starts!
            │
            └──► 🔴 If Timer hits 00:00 (No-Show) ──► Driver taps "Start Solo" ➔ Seats recycled
```

* **500m Pre-Arrival Nudge:** Automated push alert nudging rider to walk to the gate.
* **50m Arrival Geofence:** When driver enters 50m radius, `driver_arrived = true` is set.
* **Synchronized 5-Minute Timer:** Live countdown (`05:00 ➔ 00:00`) displays on both Driver and Rider screens with real-time sync.

---

### 8.5 Friendly Zero-Deduction No-Show Flow & Solo Ride Continuation

When the 5-minute wait timer reaches `00:00` and the rider has not boarded:

```
+-------------------------------------------------------------------+
|                     ⏳ 5-MINUTE WAIT COMPLETED                    |
+-------------------------------------------------------------------+
|  Rider has not boarded yet.                                       |
|                                                                   |
|  What would you like to do?                                       |
|                                                                   |
|  [ ⏳ WAIT A FEW MORE MINS ]       [ 🚀 START SOLO (DEPART) ]     |
|  (If you spoke to rider and       (Continue your commute; seats   |
|   agreed to wait)                  will open for on-route riders) |
+-------------------------------------------------------------------+
```

#### No-Show Rules:
1. **Default Zero Coin Penalty ($0\text{ Coins}$):** 100% of escrow coins are refunded to the rider during platform launch.
2. **Driver Choice A ("Wait a bit more"):** Driver can voluntarily extend waiting time if communicated via chat/call.
3. **Driver Choice B ("Start Solo"):** Driver continues commute; ride status becomes `in_progress`.
4. **Seat Recycling for Live Matching:** The vacated seat is immediately reopened for **Phase 2 (150m) live on-route matching**, allowing other commuters ahead on the road to hop in.
5. **1-Hour Trip-Level Cooldown:** The dropped rider is blocked from re-requesting this specific driver for 1 hour, preventing awkward spam.

---

### 8.6 The Color-Coded Commute Calendar System

Both riders and drivers manage recurring monthly commutes through an interactive calendar interface.

#### 🎨 Universal Calendar Color Legend:
* 🟢 **GREEN (Confirmed):** Ride accepted and seat locked for this calendar date.
* 🟡 **YELLOW (Pending):** Request sent, awaiting driver confirmation.
* ⚪ **GRAY (Skipped / WFH):** Work-From-Home day, holiday, or weekend.
* 🔴 **RED (Rejected / Cancelled):** Commute declined or cancelled.

---

### 8.7 1-Month Bulk Recurring Booking (`rider_calendar_screen.dart`)

```
+-------------------------------------------------------------------+
|                     MY AUGUST COMMUTE CALENDAR                    |
+-------------------------------------------------------------------+
|  [‹ July]                     AUGUST 2026                 [Sept ›]|
|                                                                   |
|   MON       TUE       WED       THU       FRI       SAT   SUN     |
|  [ 03 🟢]  [ 04 🟢]  [ 05 🟢]  [ 06 🟢]  [ 07 🟢]  [ 08 ] [ 09 ]  |
|  [ 10 🟢]  [ 11 🟢]  [ 12 ⚪]  [ 13 🟢]  [ 14 🟢]  [ 15 ] [ 16 ]  |
|  [ 17 🟡]  [ 18 🟡]  [ 19 🟡]  [ 20 🟡]  [ 21 🟡]  [ 22 ] [ 23 ]  |
|                                                                   |
|  🟢 Confirmed with Rahul (Infosys)  |  ⚪ Aug 12: WFH (Skipped)    |
|  🟡 Aug 17–21: Pending Approval                                   |
|                                                                   |
|         [ 🗓️ REQUEST NEXT 30 DAYS ]    [ ⚪ SKIP A DATE ]         |
+-------------------------------------------------------------------+
```

* **Bulk 30-Day Requests:** Riders can select up to 30 days of Mon–Fri commute dates and dispatch a single recurring booking request.
* **Driver 1-Tap Bulk Approval (`driver_calendar_screen.dart`):** Drivers can accept or decline the entire monthly schedule with 1 tap.
* **Skip Date Feature:** Commuters can tap "Skip This Day" before 8:00 PM on any date to mark it in `skip_dates[]` without cancelling their remaining month.

---

### 8.8 Anti-Spam Rejection Cooling-Off Rule (7-Day Cooldown)

```
[ Rider sends Request to Driver ] ──► Driver Rejects (Strike 1)
                │
[ Rider sends Request next day ]   ──► Driver Rejects (Strike 2)
                │
[ Rider sends 3rd Request ]        ──► Driver Rejects (Strike 3)
                │
                ▼
[ 🔴 7-DAY MUTUAL COOLING-OFF LOCKOUT ACTIVATED ]
• System hides that driver from the rider's search results for 7 Days.
• The rider sees: "Driver is unavailable for your schedule. Please select other matching colleagues."
• After 7 days, the lock automatically resets!
```

---

### 8.9 Driver Late Cancellation 3-Strike Penalty System

To protect riders from morning abandonment:
* **Cancellation $< 30\text{ mins}$ before departure:**
  * **Strike 1:** Formal in-app warning notification.
  * **Strike 2:** 7-day suspension from posting rides.
  * **Strike 3:** 30-day suspension + Super Admin account review.

---

### 8.10 Smart Driver Auto-Accept Engine (Zero-Tap Option)

Drivers can toggle **"Smart Auto-Accept"** in their profile settings with strict route-alignment criteria:
```
[X] Auto-Accept Verified Same-Company Colleagues
    • Route Alignment Guard: Pickup must be directly on route line (Detour <= 100m)
    • Passenger Trust Gate: Must have Verified Corporate Badge + Aadhaar KYC
```
* If a matching request satisfies both gates, the system **instantly accepts and locks the seat**, notifying the driver: *"🎉 Rahul Sharma auto-confirmed for tomorrow at Gate 2!"*

---

## 9. Hardware-Agnostic 3-Level Boarding Verification & State Machine

**Primary Modules:** `lib/services/boarding_verification_service.dart`, `lib/screens/live/driver_live_screen.dart`, `lib/screens/live/rider_live_screen.dart`

---

### 9.1 Streamlined 3-Level Boarding Hierarchy

```
[ Rider Steps into Vehicle ]
             │
             ▼
[ LEVEL 1: BLE Proximity Auto-Handshake (Zero-Touch Primary) ]
  • Driver's phone acts as BLE Peripheral advertising `boarding_ble_uuid`.
  • Rider's phone scans in the background.
  • Signal strength threshold (RSSI >= -65 dBm, within 3 meters) triggers cryptographic handshake.
  • 🟢 Status updates to `in_progress` in < 0.5 seconds with ZERO user touch!
             │
             ▼ (If Bluetooth is disabled / unsupported)
[ LEVEL 2: Dynamic In-App QR Code (Visual Fallback) ]
  • Driver displays dynamic rotating QR code on screen (HMAC signed token).
  • Rider scans QR with Flutter camera.
  • 🟢 Status updates to `in_progress` instantly.
             │
             ▼ (If camera is cracked / dark night / extreme glare)
[ LEVEL 3: 4-Digit Emergency PIN (Manual Fallback) ]
  • Rider's screen displays a 4-digit OTP (e.g., "8421").
  • Rider speaks PIN to Driver; Driver enters PIN into app.
  • 🟢 Status updates to `in_progress`.
```

---

### 9.2 Master Ride Lifecycle & State Machine

```
   [ posted ] ──────────────► [ cancelled ] (Driver cancels before depart)
       │
       ▼ (Driver taps "Start Ride")
   [ started ] ─────────────► [ cancelled ] (Driver cancels on way)
       │
       ▼ (Driver enters 50m geofence)
[ driver_arrived ] ─────────► [ start_solo ] (5-min wait expires; seats recycled)
       │
       ▼ (Boarding Verified: BLE / QR / PIN)
  [ in_progress ]
       │
       ▼ (Driver reaches destination & taps "Complete Ride")
  [ completed ]
```

#### State Transition Matrix:

| Current State | Target State | Trigger Event | Database & Escrow Action |
|---|---|---|---|
| `posted` | `started` | Driver taps *"Start Ride"* (T-15 mins). | Background GPS starts broadcasting (Section 7). |
| `started` | `driver_arrived` | Driver enters 50m pickup geofence. | 5-Minute live countdown timer starts on both screens. |
| `driver_arrived`| `in_progress` | Boarding verified (BLE / QR / PIN). | Escrow locked; trip timer starts; live in-ride tracking. |
| `driver_arrived`| `started` (Solo) | 5-min timer hits 00:00 & Driver taps *"Start Solo"*. | Rider escrow 100% refunded; empty seats open for live on-route matching (Phase 2). |
| `in_progress` | `completed` | Driver taps *"Complete Ride"* at office. | Atomic SQL transfer: Coins credited to Driver + ESG CO₂ logged. |
| `posted` | `expired` | Response timer expires (3m NOW / 15m Scheduled). | 100% coins unlocked back to rider. |

---

### 9.3 Infinite Recurring State Machine (`completion_dates[]`)

* A recurring commute exists as **ONE single master record** in `public.rides` with `time_type = 'recurring'`.
* **Daily Execution Cycle:**
  1. **8:00 PM Nightly:** Pre-match pairs recurring commuters.
  2. **8:30 AM Morning:** Ride executes (`posted` $\to$ `started` $\to$ `in_progress`).
  3. **9:15 AM Drop-Off:** When driver completes the ride:
     * Appends today's date (`2026-08-17`) to `completion_dates[]`.
     * **Auto-Reset:** Master `ride_status` **immediately resets back to `'posted'` for the next working day!**
  4. **Skip Dates:** If driver or rider toggles *"Skip Today"*, date is appended to `skip_dates[]`.

---

### 9.4 Day-Wise "Skip Today" & Advance WFH Calendar Exclusion

```
+-------------------------------------------------------------------+
|               🔄 TODAY'S RECURRING COMMUTE (8:30 AM)              |
+-------------------------------------------------------------------+
|  Route: Home ➔ Manyata Tech Park                                  |
|  Confirmed Passengers: 2 Colleagues (Rahul & Priya)               |
|                                                                   |
|  [ 🚀 START TODAY'S RIDE ]             [ ⚪ SKIP TODAY'S RIDE ]   |
|                                        (If you are taking WFH or  |
|                                         leave today)              |
+-------------------------------------------------------------------+
```

#### Skip Rules:
1. **Single-Day Scope:** Tapping *"Skip Today"* skips **only that single day**. The rest of the monthly recurring schedule remains 100% active.
2. **Advance Calendar Planning:** Drivers/Riders can tap any future date on the calendar (e.g. Wednesday) and mark it as **⚪ Skipped (WFH / Leave)**.
3. **Automated Backup Suggester for Riders:** When a driver skips, the rider's coins are 100% refunded and the app immediately suggests alternative colleagues leaving at that exact time.
4. **Auto-Resume:** The dashboard automatically refreshes and activates for the next working day with zero manual setup.

---

### 9.5 Atomic PostgreSQL Escrow Settlement on Drop-Off

```sql
CREATE OR REPLACE FUNCTION public.complete_ride(p_ride_id UUID, p_driver_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_req RECORD;
    v_total_coins NUMERIC(8,2) := 0;
BEGIN
    -- 1. Settle all verified riders in this trip
    FOR v_req IN 
        SELECT id, rider_id, coins_locked 
        FROM public.ride_requests 
        WHERE ride_id = p_ride_id AND status = 'in_ride'
    LOOP
        -- Credit Driver Wallet
        UPDATE public.wallets 
        SET available_balance = available_balance + v_req.coins_locked 
        WHERE user_id = p_driver_id;

        -- Update Request Status to Completed
        UPDATE public.ride_requests 
        SET status = 'completed', updated_at = NOW() 
        WHERE id = v_req.id;

        -- Record Immutable Ledger Entry
        INSERT INTO public.coin_transactions (user_id, amount, transaction_type, status)
        VALUES (p_driver_id, v_req.coins_locked, 'ride_earning', 'completed');

        v_total_coins := v_total_coins + v_req.coins_locked;
    END LOOP;

    -- 2. If Recurring Ride -> Append today to completion_dates[] and reset status to 'posted'
    UPDATE public.rides 
    SET completion_dates = array_append(completion_dates, CURRENT_DATE),
        ride_status = CASE WHEN time_type = 'recurring' THEN 'posted'::ride_status_enum ELSE 'completed'::ride_status_enum END,
        updated_at = NOW()
    WHERE id = p_ride_id;

    RETURN jsonb_build_object('success', true, 'coins_earned', v_total_coins);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### 9.6 Negative Perspectives, Failure Modes & Anti-Fraud Defense Matrix

```
+----------------------------------------------------------------------------------------------------------------+
| FAILURE / FRAUD SCENARIO                 | RISK & ATTACK VECTOR                | SYSTEM DEFENSE & MITIGATION   |
+----------------------------------------------------------------------------------------------------------------+
| 1. Phantom Boarding Attempt              | Driver drives off alone, claims     | BLOCKED: Driver cannot start  |
|                                          | rider boarded to steal escrow coins.| without BLE / QR / Secret PIN.|
|------------------------------------------|-------------------------------------|-------------------------------|
| 2. Premature Drop-Off Fraud              | Driver drops rider halfway on highway| Spatial Drop Guard: System    |
|                                          | and taps "Complete Ride".           | blocks complete if > 500m away|
|                                          |                                     | from agreed destination pin.  |
|------------------------------------------|-------------------------------------|-------------------------------|
| 3. Habitual / Chronic Skipping           | Driver skips 4 days a week, leaving | Reliability Score Penalty:    |
|                                          | recurring riders stranded.          | > 3 consecutive skips drops   |
|                                          |                                     | matching rank in search.      |
|------------------------------------------|-------------------------------------|-------------------------------|
| 4. Dead Battery / Mid-Ride Power Loss    | Phone dies during active commute.   | On-Device SQLite Cache: State |
|                                          |                                     | auto-syncs upon reboot.       |
|------------------------------------------|-------------------------------------|-------------------------------|
| 5. Tunnel / Basement Network Blackout    | Zero internet during drop-off tap.  | Offline Queue: Signed token   |
|                                          |                                     | syncs to Supabase on reconnect|
|------------------------------------------|-------------------------------------|-------------------------------|
| 6. Stuck Escrow Lockout                  | Transaction hangs due to crash.     | Automated Cron Self-Healing:  |
|                                          |                                     | Auto-refunds locks > 4 hours. |
+----------------------------------------------------------------------------------------------------------------+
```

---

## 10. Ride Completion, Atomic Coin Transfer & ESG Engine

**Primary Modules:** `lib/screens/live/driver_live_screen.dart`, `lib/screens/live/rider_receipt_screen.dart`, Supabase Database RPCs

Section 10 defines the spatial drop-off geofence triggers, staggered multi-passenger completion workflows, atomic double-entry ledger coin transfers, automated ESG carbon calculations, and commute-derived soft attendance logging.

---

### 10.1 Drop-Off Geofence Detection & Completion Slider

```
[ Vehicle Enters 500m Drop Geofence at Tech Park ]
                       │
                       ▼
[ Driver Screen Unlocks "🏁 Complete Ride" Slider ]
                       │
                       ▼
[ Atomic PostgreSQL Function Executes (`complete_ride`) ]
  ├──► 1. Coin Transfer: Escrow Coins ➔ Driver's Spendable Wallet (0.05s)
  ├──► 2. Double-Entry Ledger: Immutable transaction logged
  ├──► 3. ESG Engine: Calculates CO₂ Saved (KM × 0.15 × Riders)
  └──► 4. Soft Attendance: Auto-marks employee arrival at Tech Park campus
                       │
                       ▼
[ Realtime Push Notifications & Instant Receipts to Both Screens ]
```

#### Step-by-Step Drop-Off Flow:
1. **500m Destination Arrival Geofence:** When vehicle coordinates enter within **500 meters** of the destination building (`building_id`), the driver's screen unlocks the green completion slider.
2. **Premature Drop-Off Anti-Fraud Guard:** If the driver attempts to complete the ride when $> 500\text{ meters}$ away from the destination, the app blocks the action to prevent passenger abandonment.

---

### 10.2 Driver Drop-Off Cockpit (`driver_live_screen.dart`)

```
+-------------------------------------------------------------------+
|               🏢 ARRIVED AT MANYATA TECH PARK                     |
+-------------------------------------------------------------------+
|  Trip Distance: 12.4 km  |  Duration: 28 mins                     |
|                                                                   |
|  Passengers to Drop Off:                                          |
|  • 🟢 Rahul Sharma (Infosys)  ➔ [ 🏁 DROP OFF (+24 Coins) ]       |
|  • 🟢 Priya Patel  (Wipro)    ➔ [ 🏁 DROP OFF (+18 Coins) ]       |
|                                                                   |
|          ============================================             |
|          >>> SLIDE TO COMPLETE ALL & DROP OFF >>>                 |
|          ============================================             |
+-------------------------------------------------------------------+
```

#### Staggered Multi-Passenger Drops:
* When carrying multiple passengers with different drop-off gates (e.g. *Gate 1* vs. *Gate 4*):
* Driver can tap **"Drop Off Rahul"** individually. Rahul's 24 coins are settled immediately and his receipt opens, while the ride continues for Priya until Gate 4.

---

### 10.3 Atomic Coin Transfer & Double-Entry Ledger

The exact millisecond a passenger drop-off is completed:
1. `coins_locked` in Escrow are **unlocked and credited directly to `driver_wallet.available_balance`**.
2. An immutable double-entry ledger entry is logged in `public.coin_transactions`:
   * **Sender:** Rider UUID (or Corporate Subsidy Pool)
   * **Receiver:** Driver UUID
   * **Amount:** e.g., `+24.00 Karma Coins`
   * **Transaction Type:** `'ride_earning'`
3. **Instant Push Receipt:** Rider’s phone vibrates:
   * *"🎉 Ride Complete! 24 Karma Coins transferred to Rahul. Thank you for carpooling green!"*

---

### 10.4 Automated Corporate ESG Carbon Engine

Upon trip completion, the backend ESG engine computes environmental savings:

$$\text{CO}_2\text{ Saved (kg)} = \text{Distance (km)} \times 0.15\text{ kg} \times \text{Number of Riders}$$

$$\text{Tree Equivalence} = \frac{\text{CO}_2\text{ Saved (kg)}}{20.0\text{ kg/tree/year}}$$

* **Data Aggregation:**
  * **Driver Stats:** Adds to driver's lifetime carbon offset total on profile.
  * **Rider Stats:** Adds to rider's personal green commuter badge.
  * **Corporate ESG Report:** Aggregated monthly for employer sustainability audits (BRSR / Scope 3 emissions reporting).

---

### 10.5 Commute-Derived Soft Attendance Integration

If a verified corporate employee completes a morning carpool between **6:00 AM – 11:00 AM** at their registered corporate campus (`building_id`):
* System automatically logs an arrival record in `public.corporate_attendance`:
  * `employee_id`: UUID
  * `company_id`: UUID
  * `building_id`: UUID
  * `status`: `'arrived_at_campus'`
  * `arrival_time`: `08:42 AM`
  * `transport_mode`: `'carpool'`
* Enables HR Managers to view real-time morning presence on their dashboard without biometric card lines.
