# CorporatePoolingApp — Software Requirements Specification (SRS)
### Version 3.25 | August 2026 | Tech Stack: Flutter + Supabase (PostgreSQL & PostGIS)

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
11. [Recurring Commute Engine — Full Logic Deep Dive](#11-recurring-commute-engine--full-logic-deep-dive)
12. [Wallet & Cashless Karma Economy (No Fiat Exchange)](#12-wallet--cashless-karma-economy-no-fiat-exchange)
13. [Presence & Soft Attendance System](#13-presence--soft-attendance-system)
14. [Company & Enterprise Features (B2B SaaS Subscriptions, Monthly Coin Grants & ESG Engine)](#14-company--enterprise-features-b2b-saas-subscriptions-monthly-coin-grants--esg-engine)
15. [In-App Chat & Communication System](#15-in-app-chat--communication-system)
16. [Push Notification Engine & Multi-Role Notification Matrix](#16-push-notification-engine--multi-role-notification-matrix)
17. [Admin Panel, Multi-Tier 2FA Security & Dynamic Remote Theme System](#17-admin-panel-multi-tier-2fa-security--dynamic-remote-theme-system)
18. [Complete UI Screen Catalogue & Component Inventory (The 37 Application Flows)](#18-complete-ui-screen-catalogue--component-inventory-the-37-application-flows)
19. ["My Rides" Screen, Commute History & Active Booking Tabs](#19-my-rides-screen-commute-history--active-booking-tabs)
20. [Ratings, Compliments, Badges & Automated Telematics Rash Driving Engine](#20-ratings-compliments-badges--automated-telematics-rash-driving-engine)

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
To ensure total safety and community trust, corporate commuters complete **Dual-Shield Verification with Mandatory Employer Approval**:

```
[ STEP 1: INVITATION DELIVERY ]
• Primary: Universal Smart Deep-Link (https://join.corporatepooling.com/infy2026) via Slack / Teams / Email.
• Fallback: 6-Character Company Invite Code (e.g. "INFY26") entered manually on signup screen.
                          │
                          ▼
[ STEP 2: WORK EMAIL OTP & DOMAIN MATCH ]
• Employee enters work email (@infosys.com) ➔ Validates domain ➔ Submits 6-digit OTP.
                          │
                          ▼
[ STEP 3: EMPLOYER / HR REAL-TIME APPROVAL GATE (Pending State) ]
• Employee placed in "pending_approval" status.
• Real-time Popup / Alert appears on Employer HR Portal:
  "🔔 Amit Kumar (amit.k@infosys.com • #INF-8842) wants to join your carpool workspace."
                          │
         ┌────────────────┴────────────────────────┐
         ▼ (Option A: HR Clicks [ ✅ APPROVE ])     ▼ (Option B: HR Clicks [ ❌ REJECT ])
[ VERIFIED CORPORATE MEMBER ACTIVATED ]     [ REJECTED / PUBLIC MODE ]
• Status updated to "active".               • User restricted from company roster & funds.
• "Verified Corporate Citizen" Badge awarded.• Gracefully operates in Public Commuter mode.
• 100 Welcome Karma Coins airdropped!       • Zero access to company master coin pool.
• Internal company carpool roster unlocked!
```

1. **Invitation & Onboarding Channels:**
   - **Method 1 (Primary - Smart Deep-Link):** HR Manager copies the company's unique deep-link (`https://join.corporatepooling.com/infy2026`) and posts it in company Slack, Microsoft Teams, or internal intranet. Clicking the link auto-installs the app and pre-fills company details.
   - **Method 2 (Fallback - 6-Character Invite Code):** If firewall/MDM policies block deep-links, the employee manually enters the company code (e.g. `INFY26`) on the signup screen.
2. **Real-Time Employer / HR Approval Gate:**
   - When an employee signs up, their profile is held in a `pending_approval` state.
   - The Employer HR Manager receives an instant **Real-Time Popup / Banner Alert** in the Corporate Portal.
   - **Strict Governance Rule:** ONLY when the Employer/HR clicks **`[ ✅ APPROVE ]`** is the employee officially admitted into the corporate workspace, awarded the corporate badge, granted **100 Welcome Karma Coins**, and linked to the monthly prepaid coin grant pool.
3. **Legal Identity Verification (Mandatory Aadhaar KYC):**
   - **Phase 1 (₹0 Launch):** On-Device Aadhaar Secure QR Code scan / Google ML Kit text extraction with Verhoeff mathematical checksum + photo upload.
   - **Phase 2 (Scale):** Optional automated DigiLocker API (Setu / Cashfree) for instant 2-second Govt OTP KYC.

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


---

## 11. Recurring Commute Engine — Full Logic Deep Dive

**Primary Modules:** `lib/services/recurring_commute_service.dart`, Supabase `pg_cron` Engine, `lib/screens/rider/rider_calendar_screen.dart`

Section 11 defines the complete operational, financial, and lifecycle architecture for daily Monday-through-Friday recurring commutes for both Corporate Employees and Verified Public Users.

---

### 11.1 Universal Single-Row Recurring Master Architecture (`time_type = 'recurring'`)

To eliminate database bloat, indexing degradation, and duplicate matching conflicts:
* A recurring commute exists as **ONE single master record** in `public.rides`.
* **Universal Access:** Open to both **Corporate Employees** and **Verified Public Commuters** (e.g. students, daily neighborhood commuters).
* **Key Columns:**
  * `time_type: 'recurring'`
  * `recurring_days: INT[] DEFAULT '{1,2,3,4,5}'` (1 = Monday, 5 = Friday).
  * `completion_dates: DATE[]` (Array tracking completed commute dates).
  * `skip_dates: DATE[]` (Array tracking skipped WFH / leave dates).
  * `valid_until: DATE` (Expiry of recurring schedule, e.g., 90 days out).

---

### 11.2 The 8:00 PM Nightly Auto-Pairing Cron Engine (`process_nightly_recurring_rides`)

Commuters require certainty before sleeping without daily manual searching. Every evening at **8:00 PM IST**, Supabase `pg_cron` executes the automated recurring matcher:

```sql
-- Nightly 8:00 PM Recurring Commute Matcher & Micro-Escrow
CREATE OR REPLACE FUNCTION public.process_nightly_recurring_rides()
RETURNS VOID AS $$
DECLARE
    v_ride RECORD;
    v_tomorrow_day INT := EXTRACT(ISODOW FROM (CURRENT_DATE + INTERVAL '1 day'));
    v_tomorrow_date DATE := CURRENT_DATE + INTERVAL '1 day';
    v_wallet RECORD;
    v_max_overdraft NUMERIC(6,2);
BEGIN
    -- Fetch dynamic Super Admin Overdraft Limit (Default: 30.00 Coins)
    SELECT COALESCE(setting_value::NUMERIC, 30.00) INTO v_max_overdraft 
    FROM public.system_settings 
    WHERE setting_key = 'MAX_RECURRING_OVERDRAFT_COINS';

    FOR v_ride IN 
        SELECT r.id, r.driver_id, r.time_type, r.recurring_days, r.skip_dates, 
               req.id AS request_id, req.rider_id, req.coins_locked, u.full_name AS rider_name
        FROM public.rides r
        JOIN public.ride_requests req ON req.ride_id = r.id
        JOIN public.users u ON u.id = req.rider_id
        WHERE r.time_type = 'recurring'
          AND v_tomorrow_day = ANY(r.recurring_days)
          AND NOT (v_tomorrow_date = ANY(r.skip_dates))
          AND req.status = 'accepted'
    LOOP
        -- 1. Check 3-Tier Wallet Waterfall (Corporate Grant -> Personal Earned -> Family Pool)
        SELECT * INTO v_wallet FROM public.wallets WHERE user_id = v_ride.rider_id;

        IF v_wallet.available_balance >= v_ride.coins_locked THEN
            -- Balance Sufficient: Lock Daily Micro-Escrow
            UPDATE public.wallets 
            SET locked_balance = locked_balance + v_ride.coins_locked,
                available_balance = available_balance - v_ride.coins_locked
            WHERE user_id = v_ride.rider_id;

            -- 8:05 PM Evening Push Confirmation
            PERFORM net.http_post(
                url := 'https://api.corporatepooling.internal/notify-recurring-confirmed',
                body := jsonb_build_object('rider_id', v_ride.rider_id, 'driver_id', v_ride.driver_id, 'date', v_tomorrow_date)
            );
        ELSIF (v_wallet.available_balance + v_max_overdraft) >= v_ride.coins_locked THEN
            -- Apply Super Admin Configured Emergency Overdraft Buffer (Section 11.3)
            UPDATE public.wallets 
            SET locked_balance = locked_balance + v_ride.coins_locked,
                available_balance = available_balance - v_ride.coins_locked
            WHERE user_id = v_ride.rider_id;

            -- 8:05 PM Overdraft Confirmation & Notice
            PERFORM net.http_post(
                url := 'https://api.corporatepooling.internal/notify-recurring-overdraft-applied',
                body := jsonb_build_object('rider_id', v_ride.rider_id, 'driver_id', v_ride.driver_id, 'date', v_tomorrow_date, 'new_balance', (v_wallet.available_balance - v_ride.coins_locked))
            );
        ELSE
            -- Balance Beyond Overdraft Limit: Trigger 2-Hour Grace Period Alert (Section 11.3)
            PERFORM net.http_post(
                url := 'https://api.corporatepooling.internal/notify-recurring-low-balance',
                body := jsonb_build_object('rider_id', v_ride.rider_id, 'request_id', v_ride.request_id, 'needed_coins', v_ride.coins_locked, 'current_balance', v_wallet.available_balance)
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### 11.3 Cashless Low-Balance Protocol & Emergency Overdraft Leeway

Because Karma Coins **cannot be purchased directly with fiat cash or UPI** (to legally protect private white-plate vehicles from commercial taxi laws) and **peer-to-peer arbitrary transfers between colleagues are disallowed**, low balance situations are governed strictly by the following rules:

```
+-------------------------------------------------------------------------------------------------------+
| RIDE MODE         | OVERDRAFT ALLOWED? | MAX NEGATIVE BALANCE ALLOWED | REASON / LOGIC                |
+-------------------------------------------------------------------------------------------------------+
| ⚡ NOW            | ❌ NO               | 0 Coins (Strict 0 Overdraft)  | Instant booking. Rider must   |
| (Real-time Ride)  |                    | (Must have 100% fare upfront) | have full coins to request.   |
|-------------------|--------------------|-------------------------------|-------------------------------|
| 🕐 SCHEDULED       | ❌ NO               | 0 Coins (Strict 0 Overdraft)  | Planned one-off trip. Must    |
| (One-time Future) |                    | (Must have 100% fare upfront) | have full balance upfront.    |
|-------------------|--------------------|-------------------------------|-------------------------------|
| 🔄 RECURRING      | ✅ YES (Emergency) | Up to -30 Coins (Default)     | Configurable by Super Admin.  |
| (Mon–Fri Commute) |                    | (Editable: 0 to 100 Coins)    | Prevents 8:30 AM stranding.   |
+-------------------------------------------------------------------------------------------------------+
```

```
[ 8:00 PM Nightly Cron Runs for Tomorrow's Commute ]
                         │
                         ▼
[ 1. Check 3-Tier Wallet Waterfall ]
  ├──► Check 1: Employer Corporate Monthly Grant Coins (Corporate only)
  ├──► Check 2: Personal Earned Karma Balance (from Driving)
  └──► Check 3: Linked Family Shared Wallet Pool
                         │
                         ▼ (If Total Balance < Ride Fare, e.g., Has 5 Coins, Needs 24 Coins)
[ 2. Emergency Overdraft Check (Super Admin Configured Limit, Default: -30 Coins) ]
  ├──► 🟢 If Deficit <= Max Overdraft:
  │      • Wallet moves to negative balance (e.g. -19 Coins).
  │      • Commute is 100% CONFIRMED for morning 8:30 AM!
  │      • Anti-Abuse Lock: Rider CANNOT book a 2nd subsequent ride until restored >= 0.
  │
  └──► 🔴 If Deficit Exceeds Overdraft Limit:
         • 8:00 PM Push Alert: "⚠️ Low Karma Coins: Needed: 24, Available: 5. 
           Please switch to Family Wallet or skip tomorrow before 10:00 PM."
         • 10:00 PM Driver Protection Cutoff: Tomorrow's seat is unlinked & reopened for colleagues.
         • Future recurring days (Wed, Thu, Fri) remain intact on the calendar!
```

#### 👨‍👩‍👧 Family Wallet Exit Rule:
* **The Rule:** The shared coin pool belongs to the **Primary Account Owner (Family Admin)**.
* When a family member leaves or disconnects from the family group:
  * **0 coins leave the family.**
  * The departing member departs with only their personal standalone account (0 family coins).
  * The pooled funds **remain 100% intact with the Primary Family Owner**.

---

### 11.4 Day-Wise "Skip Today" & Multi-Day Vacation Pause Mode

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

#### Skip & Vacation Mechanics:
1. **1-Tap "Skip Today":** Tapping *"Skip Today"* in the morning appends today's date to `skip_dates[]`. Only today is skipped; tomorrow auto-resumes.
2. **Multi-Day Vacation Pause Mode:**
   * Commuters taking leave (e.g. *Aug 20 to Aug 27*) select start and end dates on the calendar and tap **"Pause Commute (Vacation)"**.
   * System bulk-appends those dates to `skip_dates[]`, frees the driver's seats for temporary on-route co-riders, and auto-resumes on Aug 28 without manual setup.
3. **Automated Backup Suggester:** Stranded riders instantly receive recommendations for alternative colleagues leaving at that exact time.

---

### 11.5 The 90-Day Array Auto-Pruning Rule (`pruneOldDates`)

To prevent `completion_dates[]` and `skip_dates[]` arrays from growing without bound and degrading SQL performance over months of daily carpooling:
* Any date older than **90 days** is automatically pruned whenever the arrays are updated:

```sql
-- Automated 90-Day Array Pruning
UPDATE public.rides 
SET completion_dates = ARRAY(
        SELECT unnest(completion_dates) 
        WHERE unnest >= CURRENT_DATE - INTERVAL '90 days'
    ),
    skip_dates = ARRAY(
        SELECT unnest(skip_dates) 
        WHERE unnest >= CURRENT_DATE - INTERVAL '90 days'
    )
WHERE id = p_ride_id;
```

* **Audit Integrity:** Lifetime ride records and financial ledger entries are permanently and immutably preserved in `public.ride_requests` and `public.coin_transactions`. The 90-day pruning applies **strictly to the live runtime cache array on active recurring rides**.

---

### 11.6 Next-Day Auto-Resume & Lifecycle Reset

When the morning drop-off finishes:
1. Today's date is appended to `completion_dates[]`.
2. **Auto-Reset:** Master `ride_status` immediately resets back to `'posted'` for the next working day with zero manual setup.


---

## 12. Wallet & Cashless Karma Economy (No Fiat Exchange)

**Primary Modules:** `lib/services/wallet_service.dart`, Supabase Ledger RPCs, `lib/screens/wallet/wallet_screen.dart`, `lib/screens/wallet/family_wallet_screen.dart`

Section 12 defines the cashless, non-fiat peer-to-peer Karma Coin economy, the RTO white-plate legal shield, the 3-tier wallet waterfall, the immutable double-entry ledger architecture, family wallet fund retention rules, deterministic vehicle-tier fare calculation, and self-healing escrow reconciliation.

---

### 12.1 RTO Legal Shield & 100% Cashless Non-Fiat Framework

A foundational differentiator of CorporatePoolingApp from commercial ride-hailing services (Ola/Uber) and commercialized carpooling apps is the **complete absence of direct cash or UPI exchange between drivers and riders**.

* **The Law (Section 66 of Indian Motor Vehicles Act 1988):** Private white-plate vehicles (`non-transport vehicles`) are legally barred from plying for *"hire or reward"*. Apps that facilitate direct cash/UPI driver payouts face severe regulatory crackdowns, vehicle impoundments, and taxi union protests.
* **Our Closed-Loop Legal Shield:**
  * **Zero In-Ride Cash / Zero UPI:** Riders never hand cash or transfer UPI directly to drivers for a ride.
  * **Non-Fiat Karma Coins:** Karma Coins are closed-loop cost-sharing utility tokens. Coins cannot be cashed out directly to bank accounts like commercial taxi fares.
  * **Ecosystem Utility:** Drivers use earned coins to fund their own future rides, share with family members, or redeem for employer-sponsored green fuel cards / cafeteria credits.
  * **Legal Status:** Classifies platform commutes as **100% genuine non-commercial peer carpooling and voluntary ride-sharing**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 CORPORATEPOOLING CASHLESS COST-SHARING FLOW                 │
│                                                                             │
│  ┌───────────────────────────────┐     1. Posts Commute     ┌────────────┐  │
│  │ Verified Driver (Car / Bike)  │ ───────────────────────> │ Platform   │  │
│  │ (White Plate - Non-Commercial)│ <─────────────────────── │ Escrow &   │  │
│  │ [Corporate or Public User]    │   Earns Karma Coins      │ Ledger     │  │
│  └───────────────────────────────┘   (Auto-Credit on Drop)  └────────────┘  │
│                                                                    ▲        │
│                                                                    │        │
│  ┌───────────────────────────────┐     2. Books Seat               │        │
│  │ Verified Rider                │ ────────────────────────────────┘        │
│  │ [Corporate or Public User]    │    Spends Karma Coins                    │
│  └───────────────────────────────┘   (Locked at Req, Auto-Transferred on Drop)│
│                                                                             │
│  * ZERO CASH / ZERO UPI TRANSFERRED BETWEEN RIDER & DRIVER *                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 12.2 Three Legitimate Coin Sources (Zero Arbitrary P2P Transfers)

To eliminate illegal underground token trading and protect regulatory compliance, Karma Coins enter the ecosystem through **three legitimate channels only**:

1. **Earning by Driving:** Offering empty seats on daily commutes is the primary way drivers earn Karma Coins.
2. **Employer Monthly B2B Grants (Corporate Commute Subsidies):**
   * Partnered enterprises purchase corporate commute packages.
   * HR auto-airdrops **300 to 500 Karma Coins** on the 1st of every month to verified employee wallets.
   * Employees use these corporate-funded coins to commute to the office without personal out-of-pocket expenses.
3. **Linked Family Shared Wallet Pool:** Verified family members draw from the primary account owner's balance.

> **Anti-Abuse Rule:** Direct arbitrary peer-to-peer coin transfers between random users are **strictly blocked**. Coins can only move during verified commute drop-offs, family pool sharing, or employer B2B grants.

---

### 12.3 Automated Atomic Escrow Transfer on Every Drop-Off

* **Zero-Tap Driver Settlement:** The exact millisecond a passenger drop-off is verified (Section 10), Supabase executes an atomic database function (`complete_ride` RPC):
  1. `coins_locked` in Escrow are **unlocked and credited directly to the driver's spendable wallet** in $< 0.05\text{ seconds}$.
  2. The rider's locked balance is cleared.
  3. An immutable transaction receipt is written to `public.coin_transactions`.
  4. Both driver and rider receive instant push notifications and digital receipts.

---

### 12.4 Double-Entry PostgreSQL ACID Ledger Schema

```sql
CREATE TABLE public.wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    available_balance NUMERIC(8, 2) DEFAULT 0.00,
    locked_balance NUMERIC(8, 2) DEFAULT 0.00,
    corporate_grant_balance NUMERIC(8, 2) DEFAULT 0.00,
    lifetime_earned NUMERIC(8, 2) DEFAULT 0.00,
    lifetime_spent NUMERIC(8, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.coin_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES public.users(id),
    receiver_id UUID REFERENCES public.users(id),
    amount NUMERIC(8, 2) NOT NULL,
    transaction_type VARCHAR(35) NOT NULL, 
    -- 'ride_earning', 'ride_fare', 'escrow_lock', 'escrow_refund', 'corporate_grant', 'overdraft_adjustment'
    ride_id UUID REFERENCES public.rides(id),
    request_id UUID REFERENCES public.ride_requests(id),
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_wallets_user_id ON public.wallets(user_id);
CREATE INDEX idx_coin_transactions_sender ON public.coin_transactions(sender_id);
CREATE INDEX idx_coin_transactions_receiver ON public.coin_transactions(receiver_id);
```

---

### 12.5 Family Shared Wallet & Member Exit Fund Protection

```
+-------------------------------------------------------------------+
|               👨‍👩‍👧 RAHUL'S FAMILY COMMUTE WALLET                   |
+-------------------------------------------------------------------+
|  Master Family Balance: 380 Karma Coins                           |
|  Primary Account Owner: Rahul Sharma (Family Admin)               |
|                                                                   |
|  Linked Verified Family Members (Max 4):                          |
|  • 🟢 Priya Sharma (Spouse)    - Verified Aadhaar ✅ [ Active ]    |
|  • 🟢 Anita Sharma (Mother)    - Verified Aadhaar ✅ [ Active ]    |
|  • 🟢 Rohan Sharma (Brother)   - Verified DL ✅      [ Active ]    |
|                                                                   |
|  [ + LINK NEW FAMILY MEMBER ]         [ ⚙️ SET MONTHLY LIMITS ]   |
+-------------------------------------------------------------------+
```

#### Family Wallet Exit & Ownership Rules:
1. **Fund Ownership:** The entire pooled balance belongs exclusively to the **Primary Account Owner (Family Admin)**.
2. **Member Disconnection / Exit:** When a secondary family member leaves or disconnects from the family group:
   * **0 coins leave the family.**
   * The departing member departs with only their personal standalone account ($0\text{ family coins}$).
   * The pooled balance **remains 100% intact with the Primary Family Owner**.

---

### 12.6 Vehicle-Tier Deterministic Fare Calculation Matrix

Ride fares are calculated deterministically based on exact road polyline distance ($km$) and vehicle tier:

$$\text{Ride Fare (Coins)} = \text{Exact Road Distance (km)} \times \text{Vehicle Tier Rate (Coins/km)}$$

```
+-----------------------------------------------------------------------------------+
| VEHICLE CATEGORY             | BASE RATE      | 15 KM COMMUTE FARE CALCULATION    |
+-----------------------------------------------------------------------------------+
| 🛵 Motorcycle / Scooter      | 1.0 Coin / km  | 15 km × 1.0 = 15 Karma Coins      |
| 🛺 Auto-Rickshaw             | 2.0 Coins / km | 15 km × 2.0 = 30 Karma Coins      |
| 🚗 Hatchback / Sedan / SUV   | 2.0 Coins / km | 15 km × 2.0 = 30 Karma Coins      |
+-----------------------------------------------------------------------------------+
```

---

### 12.7 Self-Healing Escrow Recovery Cron (`reconcile_stuck_escrow`)

If an active commute is interrupted by sudden network loss, battery death, or app crash:
* An automated Supabase `pg_cron` job executes hourly:

```sql
-- Automated Self-Healing Escrow Recovery for Orphaned Locks > 4 Hours
CREATE OR REPLACE FUNCTION public.reconcile_stuck_escrow()
RETURNS VOID AS $$
BEGIN
    -- Unlock coins for requests stuck in pending/accepted where ride never started
    UPDATE public.wallets w
    SET locked_balance = locked_balance - r.coins_locked,
        available_balance = available_balance + r.coins_locked
    FROM public.ride_requests r
    WHERE w.user_id = r.rider_id
      AND r.status IN ('pending', 'accepted')
      AND r.created_at < NOW() - INTERVAL '4 hours';
      
    UPDATE public.ride_requests
    SET status = 'expired', updated_at = NOW()
    WHERE status IN ('pending', 'accepted')
      AND created_at < NOW() - INTERVAL '4 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```


---

## 13. Presence & Soft Attendance System

**Primary Modules:** `lib/services/presence_service.dart`, Supabase Attendance RPCs, `lib/screens/presence/presence_status_screen.dart`, `lib/screens/dashboard/hr_attendance_dashboard.dart`

Section 13 defines the Presence and Soft Attendance System, governing commute availability, leave synchronization (eliminating ghost riders), multi-modal campus arrival logging, zero-cron dynamic status derivation, and enterprise HRMS/ESG integration.

---

### 13.1 Philosophy & Role-Based Presence Architecture

Presence serves two distinct operational objectives based on the user's role:

```
+-------------------------------------------------------------------------------------------------------+
| USER ROLE             | PRESENCE CAPABILITIES                                                         |
+-------------------------------------------------------------------------------------------------------+
| 🏢 CORPORATE EMPLOYEE  | • Commute Availability & WFH/Leave Schedule Sync                              |
|                       | • Automated Campus Soft Attendance on Morning Arrival (6:00 AM – 11:00 AM)    |
|                       | • Corporate Scope 3 ESG Carbon Commute Logging & Employer HRMS Sync           |
|-----------------------|-------------------------------------------------------------------------------|
| 🌐 PUBLIC / FAMILY    | • Commute Availability & Vacation/Sick Leave Sync (Unlinks recurring seat)   |
|   COMMUTER            | • Green Commuter Carbon Badges on Personal Profile                            |
|                       | • ZERO Corporate HR Reporting (100% Personal Privacy Isolation)               |
+-------------------------------------------------------------------------------------------------------+
```

#### Eliminating the "Ghost Commuter" Problem:
* **The Problem:** When an employee takes Work-From-Home (WFH) or leave but forgets to notify their daily carpool driver, the driver wastes 5–10 minutes waiting at their pickup gate.
* **The Solution:** Tapping *"On Leave Today"* or scheduling a vacation range in Presence **automatically unlinks their recurring seat** and reopens it for colleagues, saving drivers from wasted trips.

---

### 13.2 The Four Presence States & Dynamic Read-Time Resolution

```
+-----------------------------------------------------------------------------------+
| STATE       | OPERATIONAL MEANING                | RESOLUTION PRIORITY & TRIGGER  |
+-----------------------------------------------------------------------------------+
| available   | Working today, no commute logged   | Default state for active days  |
| present     | Confirmed on campus working today  | Auto on morning arrival / tap  |
| week_off    | Scheduled non-working day          | Derived from working_days[]    |
| on_leave    | Approved leave / WFH / Vacation    | Manual chip / Vacation picker  |
+-----------------------------------------------------------------------------------+
```

#### Smart Read-Time Resolution (Zero Midnight Cron Overhead):
To eliminate heavy scheduled midnight cron jobs scanning thousands of user rows:
* Presence status is **dynamically computed at read time** against `CURRENT_DATE`:
  1. A stale `presence_date` from yesterday automatically reads as `'available'` today.
  2. If today is Sunday and Sunday is not in `working_days[]`, it dynamically reads as `'week_off'`.
  3. If a 5-day leave ended yesterday, it automatically reads as `'available'` today.

```dart
// lib/services/presence_service.dart
String resolveTodayPresence(Map<String, dynamic>? userData) {
  if (userData == null) return 'available';
  final todayStr = DateTime.now().toIso8601String().substring(0, 10);
  final currentWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun

  // Priority 1: Explicit same-day status
  if (userData['presence_date'] == todayStr) {
    return userData['presence_status'] ?? 'available';
  }

  // Priority 2: Multi-day Vacation / Leave range
  if (userData['leave_from'] != null && userData['leave_to'] != null) {
    if (todayStr.compareTo(userData['leave_from']) >= 0 &&
        todayStr.compareTo(userData['leave_to']) <= 0) {
      return 'on_leave';
    }
  }

  // Priority 3: Commute Schedule (working_days check)
  final List<dynamic> workingDays = userData['working_days'] ?? [1, 2, 3, 4, 5];
  if (!workingDays.contains(currentWeekday)) {
    return 'week_off';
  }

  return 'available';
}
```

---

### 13.3 Multi-Modal Attendance Ingestion Streams & Fail-Safe Architecture

To ensure 100% employee coverage regardless of how an individual travels to work:

```
[ Employee Arrives at Workplace ]
               │
   ┌───────────┼───────────────────────────────────────────────┐
   ▼           ▼                                               ▼
[ STREAM A: Green Carpool ]   [ STREAM B: Bus / Metro / Shuttle ]   [ STREAM C: Office Turnstile (Fail-Safe) ]
• 100% Automated Ingress.     • 1-Tap Geofence Check-In.            • If employee forgot their phone / app,
• Drop-off verified at        • App detects inside 500m Tech Park   • Swipes physical RFID company ID card
  campus gate (0 taps).         boundary ➔ Shows "Campus Check-In".  at building lobby turnstile as normal.
• Logged: 'carpool'           • Logged: 'public_transit' (+5 Karma) • Logged: 'turnstile_backup'
               │                               │                               │
               └───────────────────────────────┼───────────────────────────────┘
                                               ▼
                         [ Consolidated HR Attendance Stream ]
                         • Earliest timestamp accepted ("Rule of First Touch")
                         • Zero accidental absenteeism penalties!
```

---

### 13.4 Database Schema (`public.corporate_attendance`)

```sql
CREATE TABLE public.corporate_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES public.companies(id),
    building_id UUID NOT NULL REFERENCES public.buildings(id),
    commute_role VARCHAR(20) NOT NULL, -- 'driver', 'rider', 'public_transit', 'solo'
    transport_mode VARCHAR(30) NOT NULL, -- 'carpool', 'bike_pool', 'bus', 'metro', 'turnstile_backup'
    attendance_status VARCHAR(20) DEFAULT 'present',
    arrival_time TIMESTAMPTZ DEFAULT NOW(),
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(employee_id, date)
);

CREATE INDEX idx_attendance_company_date ON public.corporate_attendance(company_id, date);
CREATE INDEX idx_attendance_employee ON public.corporate_attendance(employee_id);
```

---

### 13.5 Enterprise HRMS Export & SEBI BRSR ESG Reporting

1. **Automated HRMS Webhook Integration:** Real-time event dispatch to enterprise HR platforms (Darwinbox, Workday, Keka, SAP SuccessFactors) upon campus arrival.
2. **SEBI BRSR Scope 3 Commute Carbon Reports:**
   * Generates monthly corporate audits displaying:
     * Total employee carpool commutes vs solo transit.
     * Total Net $\text{CO}_2$ emissions avoided (kg).
     * Single-occupancy vehicles eliminated from city roads.
   * Direct 1-click CSV/PDF export for corporate sustainability compliance filings.


---

## 14. Company & Enterprise Features (B2B SaaS Subscriptions, Monthly Coin Grants & ESG Engine)

**Primary Modules:** `lib/services/corporate_service.dart`, Supabase Corporate RPCs, `lib/screens/dashboard/manager_dashboard_screen.dart`, `lib/screens/corporate/corporate_schedule_screen.dart`

Section 14 defines the B2B enterprise subscription architecture, employee headcount-dependent pricing tiers, the complete multi-channel payment processing system (Online Gateway + Corporate Bank Transfer), clean tax-exempt startup invoicing, automated 1st-of-the-month coin grants, graceful fallback to normal user mode when a company skips recharge, the HR Manager portal, and SEBI BRSR Scope 3 ESG carbon reporting.

---

### 14.1 Headcount-Based B2B Subscription Tiers & Payment Processing Architecture

Our platform operates a high-margin **B2B Employer SaaS Model**:
* Corporate employers (e.g. Infosys, TCS, Wipro) subscribe to monthly packages tied directly to **Employee Headcount Tiers**:

```
+-------------------------------------------------------------------------------------------------------------------+
| SUBSCRIPTION PLAN       | EMPLOYEE HEADCOUNT TIER | MONTHLY FLAT FEE        | INCLUDED MONTHLY COIN POOL | PER-EMPLOYEE COIN QUOTA |
+-------------------------------------------------------------------------------------------------------------------+
| 🌱 Starter Tier         | 1 to 50 Employees       | ₹4,999 / month          | Up to 20,000 Coins / month | 400 Coins / employee    |
|-------------------------|-------------------------|-------------------------|----------------------------|-------------------------|
| 🌿 Growth Tier          | 51 to 250 Employees     | ₹19,999 / month         | Up to 100,000 Coins / month| 400 Coins / employee    |
|-------------------------|-------------------------|-------------------------|----------------------------|-------------------------|
| 🌳 Enterprise Tier      | 251 to 1,000+ Employees | Custom Contract         | Dynamic Sizing             | 400–600 Coins (Custom)  |
|                         |                         | (₹89 / seat / month)    | (Headcount × Quota)        | (Configured by HR)      |
+-------------------------------------------------------------------------------------------------------------------+
```

#### Required Monthly Pool Sizing Formula:
$\text{Required Monthly Pool Size} = \text{Total Active Verified Employees} \times \text{Monthly Quota Per Employee (e.g., 400 Coins)}$

---

### 14.2 Multi-Channel B2B Payment Processing Workflow (Company ➔ Us)

To support both instant online checkouts and large corporate enterprise procurement:

```
[ STEP 1: HR MANAGER SELECTS A PACKAGE IN PORTAL ]
• Infosys HR selects "Growth Plan: 100 Employees (40,000 Coins) - ₹10,000 / month".
                         │
                         ▼
[ STEP 2: COMPANY CHOOSES PAYMENT METHOD ]
                         │
        ┌────────────────┴────────────────────────┐
        ▼ (Option A: Instant Online Gateway)       ▼ (Option B: Corporate Bank Transfer / NEFT)
[ RAZORPAY / CASHFREE CHECKOUT ]          [ CORPORATE INVOICE GENERATION ]
• Corporate Credit Card / UPI / NetBanking.• System generates digital invoice with our
• Payment completes in 10 seconds.         Bank Account, IFSC, & UPI ID.
• Webhook fires to `POST /api/payment`:   • Infosys Finance executes NEFT/RTGS transfer.
  verifies HMAC signature & auto-activates.• Money arrives in our business bank account.
                         │                                │
                         │                                ▼
                         │                 [ SUPER ADMIN 1-CLICK VERIFICATION ]
                         │                 • Super Admin enters Bank UTR / Txn ID.
                         │                 • Clicks: [ ⚡ ACTIVATE COIN POOL ].
                         │                                │
                         └────────────────────────────────┘
                                          ▼
[ STEP 3: INSTANT MASTER COIN POOL ACTIVATION ]
• Database sets: `companies.total_coins_pool = 40,000`.
• Automated payment receipt generated and emailed to HR.
• On the 1st of next month, 400 coins are automatically airdropped to every employee!
```

#### Startup Clean & Tax-Exempt Invoicing:
* As an early-stage startup under the statutory ₹20 Lakhs turnover threshold (Section 22 of CGST Act), all B2B invoices are issued cleanly as **Tax-Exempt Commercial Invoices** (Zero GST):

```
+-------------------------------------------------------------------+
|                     CORPORATEPOOLING B2B INVOICE                  |
+-------------------------------------------------------------------+
|  Invoice No: INV-2026-0042        | Date: 17-Aug-2026             |
|  Billed To: Infosys Limited       | Plan: Growth Tier (100 Seats) |
|                                                                   |
|  Item Description                           Qty       Amount      |
|  ---------------------------------------------------------------  |
|  Corporate Commute Software Subscription     1        ₹10,000.00  |
|  (Includes 40,000 Master Karma Coin Pool)                         |
|  ---------------------------------------------------------------  |
|  GST (Exempt under Sec 22 of CGST Act):               ₹0.00       |
|  TOTAL PAYABLE:                                       ₹10,000.00  |
|                                                                   |
|  Bank Details: HDFC Bank | A/C: 50200012345678 | IFSC: HDFC0001234 |
+-------------------------------------------------------------------+
```

---

### 14.3 The 1st-of-the-Month Automated Employee Coin Grant Engine

On the **1st day of every calendar month at 00:01 AM IST**, an automated Supabase database cron executes:

```sql
-- 1st-of-the-Month Automated Employee Coin Grant Distribution
CREATE OR REPLACE FUNCTION public.distribute_monthly_corporate_grants()
RETURNS VOID AS $$
DECLARE
    v_company RECORD;
    v_emp RECORD;
    v_grant_per_user NUMERIC(8,2);
BEGIN
    FOR v_company IN 
        SELECT id, name, total_coins_pool, default_monthly_grant_per_employee 
        FROM public.companies 
        WHERE is_active = TRUE AND total_coins_pool > 0
    LOOP
        v_grant_per_user := v_company.default_monthly_grant_per_employee; -- e.g. 400 Coins

        FOR v_emp IN 
            SELECT id FROM public.users 
            WHERE company_id = v_company.id AND is_active = TRUE AND role = 'corporate_employee'
        LOOP
            IF v_company.total_coins_pool >= v_grant_per_user THEN
                -- 1. Deduct from Company Master Pool
                UPDATE public.companies 
                SET total_coins_pool = total_coins_pool - v_grant_per_user 
                WHERE id = v_company.id;

                -- 2. Credit Employee's Corporate Grant Wallet
                UPDATE public.wallets 
                SET corporate_grant_balance = corporate_grant_balance + v_grant_per_user,
                    available_balance = available_balance + v_grant_per_user
                WHERE user_id = v_emp.id;

                -- 3. Log Immutable Audit Ledger Entry
                INSERT INTO public.coin_transactions (receiver_id, amount, transaction_type, status)
                VALUES (v_emp.id, v_grant_per_user, 'corporate_grant', 'completed');
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

* **Morning Push Notification (07:00 AM):** Every verified employee wakes up to a morning alert:
  > *"🎉 Happy 1st of the Month! Infosys has granted you 400 Karma Coins for your monthly office commute!"*

---

### 14.4 Unrecharged / Skipped Company Policy (Graceful Normal User Fallback)

```
[ 1st of the Month: System Checks Company Coin Pool ]
                          │
         ┌────────────────┴────────────────────────┐
         ▼ (Pool Has Funds)                        ▼ (Company Skipped / Empty Pool)
[ SENDS 400 MONTHLY GRANT COINS ]        [ 0 COINS SENT TO EMPLOYEES ]
• Employer funds commute subsidy.        • No free corporate grant coins issued.
• Wallet corporate grant credited.       • Employees are NOT blocked or suspended!
• Commutes for free via employer.        • Seamlessly treated like NORMAL USERS:
                                           ├──► Drivers earn coins by giving rides.
                                           ├──► Riders spend earned coins or family pool.
                                           └──► App remains 100% functional & active!
```

#### The Core Operating Rules:
1. **Zero Coins Sent:** If a company skips renewal or its master pool is empty, **the platform does not send any monthly grant coins to its employees**.
2. **Graceful Normal User Mode:** Employees are **never blocked or locked out** of the app:
   * They continue to give rides as drivers to earn Karma Coins.
   * They take rides as riders using their personal earned balance or linked family pool.
   * The carpool network stays 100% operational for peer commuting!

---

### 14.5 Multi-Tenant Enterprise Database Schema

```sql
CREATE TABLE public.companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(100) UNIQUE NOT NULL, -- e.g. 'infosys.com'
    gstin VARCHAR(15), -- 18% GST Tax Identification
    manager_id UUID REFERENCES public.users(id),
    total_coins_pool NUMERIC(10, 2) DEFAULT 0.00,
    default_monthly_grant_per_employee NUMERIC(6, 2) DEFAULT 400.00,
    subscription_plan VARCHAR(30) DEFAULT 'starter', -- 'starter', 'growth', 'enterprise'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.corporate_invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    base_amount NUMERIC(10, 2) NOT NULL,
    gst_amount NUMERIC(10, 2) NOT NULL, -- 18% GST
    total_amount NUMERIC(10, 2) NOT NULL,
    sac_code VARCHAR(10) DEFAULT '9984',
    status VARCHAR(20) DEFAULT 'paid', -- 'pending', 'paid', 'failed'
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### 14.6 HR & Facility Manager Portal (`ManagerDashboardScreen.dart`)

```
+-------------------------------------------------------------------+
|               🏢 INFOSYS HINJEWADI - HR COMMUTE PORTAL            |
+-------------------------------------------------------------------+
|  Active Enrolled Employees: 1,420     |  Company Pool: 85,400 Coins|
|  Today's Carpool Commuters: 612       |  Today's CO2 Saved: 918 kg |
|                                                                   |
|  Quick Actions:                                                   |
|  [ ➕ RECHARGE COIN POOL ]               [ 👥 INVITE EMPLOYEES ]   |
|  [ 📄 EXPORT SEBI ESG REPORT (PDF) ]     [ 📊 ATTENDANCE CSV ]     |
+-------------------------------------------------------------------+
```

* **Employee Onboarding System:**
  1. **Domain Auto-Verification:** Anyone signing up with `@infosys.com` is auto-linked to the company.
  2. **HR Invite Codes:** For contractors/vendors without corporate emails, HR generates an **8-character secure invite code** (e.g. `INFY-2026`).
* **Company Broadcast Messages:** HR can broadcast announcements (e.g. *"Manyata Gate 2 closed due to metro work — please use Gate 4"*).

---

### 14.7 Official Scope 3 ESG Sustainability Engine & SEBI BRSR Compliance

Under **SEBI BRSR (Business Responsibility and Sustainability Reporting)** mandates in India, top listed companies must disclose their Scope 3 greenhouse gas emissions.

$$\text{Monthly Net }\text{CO}_2\text{ Saved (kg)} = \sum (\text{Trip KM} \times 0.15\text{ kg} \times \text{Carpool Passengers})$$

$$\text{Equivalent Trees Planted} = \frac{\text{Monthly }\text{CO}_2\text{ Saved (kg)}}{20.0\text{ kg CO}_2\text{ / tree / year}}$$

* **1-Click Audit Export:** HR downloads a branded, auditor-ready ESG certificate showing exact carbon offsets, fuel liters saved, and single-occupancy highway vehicles eliminated.

---

### 14.8 Enterprise Commute Schedule Setup (`CorporateScheduleScreen.dart`)

Employees configure their baseline commute preferences:
* Working days of week (toggles for Mon–Sun, default: Mon–Fri).
* Usual morning departure time (e.g. `08:00 AM`).
* Usual evening departure time (e.g. `06:30 PM`).
* **Intelligent Auto-Fill:** The system automatically uses these preferences to pre-populate search chips in `RiderTimePickerScreen` and automatically derive `week_off` attendance states.

---

## 15. In-App Chat & Communication System

**Primary Modules:** `lib/services/chat_service.dart`, `lib/screens/chat/ride_chat_screen.dart`, `lib/screens/chat/company_workspace_chat_screen.dart`, Supabase Realtime Engine

Section 15 defines the communication architecture across two isolated systems: the transient **Per-Ride Commute Chat & Masked Calling** (unlocked strictly upon driver acceptance) and the permanent **Home Page Company Workspace Chat** (restricted strictly to verified colleagues of the same company).

---

### 15.1 Dual-Ecosystem Communication Architecture

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ SYSTEM 1: 🚗 PER-RIDE COMMUTE CHAT & MASKED CALLING (Transient - Post-Acceptance Only)                │
│ • Driver UI: Chat & Call icons appear on the specific ride card ONLY once Driver taps "Accept".       │
│ • Rider UI: Chat & Call icons unlock on the requested trip card/tab ONLY once Driver taps "Accept".   │
│ • Purpose: Trip pickup spot coordination, live delays & in-app masked Agora VoIP voice calling.       │
│ • Lifecycle: Strictly per-ride; auto-closes and archives upon trip drop-off. Zero phone numbers shown!│
├───────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ SYSTEM 2: 🏢 DEDICATED COMPANY WORKSPACE CHAT (Home Screen Icon - Same-Company Colleagues Only)       │
│ • Dedicated "💬 Company Chat" Icon on the Home Screen Navbar for verified corporate employees.        │
│ • STRICT VERIFICATION GATE: Employees can ONLY search, message & join groups with SAME company peers. │
│ • Structure: HR/Admin Official Broadcasts + Employee Route Channels + 1:1 Colleague Direct Chats.    │
│ • 100% Privacy: Displays Full Name + Department + Office Block — Zero personal phone numbers exposed! │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

### 15.2 Per-Ride Commute Chat & Masked Calling (Post-Acceptance Flow)

```
[ Rider Sends Request (status = 'pending') ] ──► 🚫 ZERO CHAT & 🚫 ZERO CALL (Locked)
                                                 (Prevents unsolicited spamming)
                                                 │
                                                 ▼ (Driver Taps "Accept" ➔ status = 'accepted')
[ 🟢 DRIVER & RIDER SCREENS UNLOCK SIMULTANEOUSLY ]
  ├──► Driver Side UI: Accepted Request Card displays 💬 [Chat] and 📞 [Call] action buttons.
  └──► Rider Side UI: Requested Ride Tab displays 💬 [Chat] and 📞 [Call] action buttons.
```

#### 1. In-App Masked Voice Calling (Agora VoIP Audio):
* Tapping **📞 [ Call ]** does **NOT** expose personal SIM phone numbers.
* Connects via in-app encrypted VoIP audio:
  * **Driver Cockpit Displays:** *"Incoming Call from Priya (Rider - Gate 2)"*
  * **Rider Screen Displays:** *"Calling Rahul (Driver - Honda City KA01MJ5521)"*
  * **Privacy Guarantee:** Neither party ever sees the other person's private 10-digit mobile number.

#### 2. Driving-Friendly 1-Tap Quick Action Chips:
Drivers cannot type text while navigating morning highway traffic:
* Prominent 1-tap quick response chips sit directly above the keyboard:
  * **Driver Quick Chips:** `[ 🚗 On My Way ]` `[ 📍 At Pickup Gate ]` `[ 🚦 5 min Traffic Delay ]`
  * **Rider Quick Chips:** `[ 🏃‍♂️ In Elevator ]` `[ 🚪 Reaching in 1 min ]` `[ 📍 Near Security Booth ]`

#### 3. Ride Completion & Chat Archive Lifecycle:
* The exact millisecond passenger drop-off is verified (Section 10), the per-ride chat is closed and archived, preventing unwanted post-ride contact.

---

### 15.3 Home Page Company Workspace Chat (Dedicated Home Icon & Same-Company Gate)

On the **Home Screen Navbar**, a dedicated **"💬 Company Chat"** icon is unlocked for users with `role = 'corporate_employee'`:

```
+-------------------------------------------------------------------+
| 🏢 INFOSYS HINJEWADI - WORKSPACE CHAT                             |
| 🔒 Verified Company Network (@infosys.com Only)                   |
+-------------------------------------------------------------------+
|  📢 Official HR Announcements                                     |
|     HR Admin: "Gate 2 closed today for metro work. Use Gate 4."   |
|                                                                   |
|  👥 Whitefield ➔ Hinjewadi Daily Carpoolers                       |
|     Rahul S.: "Leaving at 8:30 AM today, 2 seats open."           |
|                                                                   |
|  👥 Electronic City Commuters                                     |
|     Priya P.: "Anyone leaving Electronic City around 6:00 PM?"    |
|                                                                   |
|  💬 1:1 DIRECT COLLEAGUE CHATS:                                   |
|  • Amit Kumar (Backend Team • Block 3)                            |
|  • Sneha Sharma (Product Design • Block 1)                        |
|                                                                   |
|  [ + CREATE NEW ROUTE GROUP ]        [ 🔍 SEARCH COLLEAGUES ]     |
+-------------------------------------------------------------------+
```

#### Strict Same-Company Security & Privacy Rules:
1. **Cryptographic Domain Gate:** Employees can **ONLY** discover, message, and form groups with peers sharing the **exact same `company_id`**:
   $$\text{Access Allowed IF: } \text{RequestingUser.company\_id} == \text{TargetUser.company\_id}$$
   * External public users or employees of other companies are cryptographically blocked from seeing or joining company channels.
2. **100% Identity Masking:** In all company channels and 1:1 colleague chats, profiles display:
   * **Full Name** (e.g. `Amit Kumar`)
   * **Department / Designation** (e.g. `QA Engineer • Block 2`)
   * **Verified Corporate Badge** (`@infosys.com ✅`)
   * **Personal phone numbers are strictly hidden.**
3. **Channel Categories:**
   * **Official Broadcasts:** Read-only announcements posted by Company HR / Admin.
   * **Employee Route Groups:** Community carpool groups created by employees for specific commute corridors (e.g. *"Koramangala to Manyata Carpoolers"*).
   * **1:1 Colleague Direct Chats:** Private direct chat between two coworkers of the same company.

---

### 15.4 WhatsApp-Style Realtime Experience & Supabase Schema

```
+-------------------------------------------------------------------+
| 💬 RIDE CHAT: INFOSYS COMMUTE (8:30 AM)                           |
| 👥 Rahul (Driver), Priya (Rider), Amit (Rider)                    |
+-------------------------------------------------------------------+
|                                                                   |
|  [ Rahul (Driver) ]                                   08:24 AM    |
|  🚗 Starting now from HSR Layout. See you at Gate 2!              |
|                                                                   |
|                                         [ You (Priya) ] 08:26 AM  |
|                                   🏃‍♂️ In elevator, reaching now! 🔵🔵|
|                                                                   |
|  [ Amit (Rider) ]                                     08:28 AM    |
|  📍 Waiting near the security booth.                              |
|                                                                   |
|  [ Type a message...                                        ] [➤] |
+-------------------------------------------------------------------+
```

* **Message Status Ticks:** ⚪ Sent to Server $\rightarrow$ ⚪⚪ Delivered to Device $\rightarrow$ 🔵🔵 Read by Recipient.
* **Sub-50ms Speed:** Uses Supabase Realtime Channels (`supabase.channel('room:id')`).

```sql
CREATE TABLE public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_type VARCHAR(20) NOT NULL, -- 'ride', 'company_broadcast', 'company_route_group', 'colleague_direct'
    ride_id UUID REFERENCES public.rides(id) ON DELETE CASCADE,
    company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
    name VARCHAR(100), -- Group Name for Route Groups
    created_by UUID REFERENCES public.users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.chat_room_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_id, user_id)
);

CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'quick_chip', 'system_alert'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_room_created ON public.chat_messages(room_id, created_at DESC);
CREATE INDEX idx_chat_room_members_user ON public.chat_room_members(user_id);
```

---

### 15.5 Push Notifications & FCM Deep-Linking

* **Background Delivery:** If the app is minimized or phone locked, Firebase Cloud Messaging (FCM) sounds a high-priority sound chime:
  > *"💬 Rahul S. (Driver): On my way, reaching Gate 2 in 2 mins."*
* **1-Tap Deep Link:** Tapping the notification opens the Flutter app and routes directly into the specific active chat room.

---

## 16. Push Notification Engine & Multi-Role Notification Matrix

**Primary Modules:** `lib/services/notification_service.dart`, Firebase Cloud Messaging (`firebase_messaging`), Flutter Local Notifications (`flutter_local_notifications`), Supabase Edge Functions

Section 16 defines the push notification delivery pipeline, operating via a hybrid architecture where Supabase database events trigger Google Firebase Cloud Messaging (FCM) at ₹0 cost to ring locked Android and iOS devices, complete with priority sound channels, FCM token lifecycle management, direct deep-linking, and a multi-role notification matrix covering Riders, Drivers, Employers/HR, and Super Admins.

---

### 16.1 Hybrid Architecture (Supabase Engine ➔ Firebase FCM Gateway)

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 🗄️ SUPABASE DATABASE & BACKEND (Master Database & Business Logic)                                      │
│ • Database triggers (e.g. Driver Arrival, Request Accepted, 8:00 PM Nightly Cron, Instant Drop Credit).│
│ • Dispatches push payload via Supabase Edge Function to Google FCM API (100% Free / ₹0).             │
└──────────────────────────────────────────────────┬────────────────────────────────────────────────────┘
                                                   │
                                                   ▼ (HTTPS Payload with Target Device Token)
┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 🔔 GOOGLE FIREBASE CLOUD MESSAGING (FCM) — The Free Mobile Delivery Pipeline (₹0)                    │
│ • Encrypted push packet delivered directly through Android Google Play Services and Apple APNs.       │
│ • Wakes up mobile OS when screen is locked or app is closed in user's pocket.                         │
└──────────────────────────────────────────────────┬────────────────────────────────────────────────────┘
                                                   │
                                                   ▼
                     [ 📱 User's Phone Sounds High-Priority Commute Chime & Vibrates! ]
```

---

### 16.2 Complete Multi-Role Notification Event Matrix

#### 1. 👤 Rider Notifications (Public Commuters & Corporate Employees):

```
+-------------------------------------------------------------------------------------------------------------------+
| EVENT TRIGGER                        | PRIORITY | PUSH NOTIFICATION MESSAGE TEXT & SOUND CHIME        | DEEP-LINK TARGET    |
+-------------------------------------------------------------------------------------------------------------------+
| 1. Request Accepted by Driver        | 🟢 HIGH   | "🎉 Rahul accepted your request! Pickup at 8:30 AM" | Live Ride Cockpit   |
| 2. Request Rejected / Expired        | 🟡 NORMAL | "⚠️ Driver was full. Tap to find alternative rides" | Search Results      |
| 3. Driver Started Trip (En Route)    | 🟢 HIGH   | "🚗 Rahul has started the ride (ETA: 10 mins away)" | Live GPS Map        |
| 4. Driver Arrived at Pickup (50m)    | 🔴 URGENT | "📍 Driver is at your gate! Boarding PIN: 4821 ⏱️"   | Boarding PIN Card   |
| 5. Drop-Off Completed & Receipt      | 🟢 HIGH   | "✅ Arrived! 24 Coins transferred. 1.8 kg CO2 saved 🌱"| Rating & Receipt    |
| 6. 8:00 PM Nightly Recurring Confirm | 🟢 HIGH   | "🌙 Tomorrow's 8:30 AM ride confirmed (24 coins locked)"| Commute Calendar   |
| 7. 8:00 PM Low-Balance Nudge (Grace) | 🔴 URGENT | "⚠️ Low Coins: Tomorrow needs 24. Tap to switch wallet"| Wallet Screen       |
| 8. New Chat Message / Masked Call    | 🔴 URGENT | "💬 Rahul (Driver): Standing near Gate 2."          | Ride Chat Screen    |
+-------------------------------------------------------------------------------------------------------------------+
```

#### 2. 🚗 Driver Notifications (Public Commuters & Corporate Employees):

```
+-------------------------------------------------------------------------------------------------------------------+
| EVENT TRIGGER                        | PRIORITY | PUSH NOTIFICATION MESSAGE TEXT & SOUND CHIME        | DEEP-LINK TARGET    |
+-------------------------------------------------------------------------------------------------------------------+
| 1. New Ride Request Received         | 🔴 URGENT | "🔔 Priya wants to join (Manyata). Detour: +2 mins"  | Request Accept Card |
| 2. Rider Cancelled Request           | 🟡 NORMAL | "ℹ️ Priya cancelled her request for tomorrow."      | Ride Overview       |
| 3. Rider Boarded Successfully        | 🟢 HIGH   | "✅ Priya boarded! Carpool Occupancy: 2/3 Seats."   | Driver Cockpit HUD  |
| 4. Instant Drop-Off Coin Payout      | 🟢 HIGH   | "💰 +24 Karma Coins credited to your wallet!"       | Wallet Ledger       |
| 5. 8:00 PM Nightly Partner Summary   | 🟢 HIGH   | "🌙 Tomorrow's ride has 2 confirmed colleagues."    | Driver Calendar     |
| 6. Rider Skipped Today (WFH / Leave) | 🟡 NORMAL | "⚪ Priya skipped today. Your seat reopened."       | Seat Roster         |
| 7. Driver KYC Verification Approved  | 🟢 HIGH   | "🎉 Vehicle KA01MJ5521 Approved! You can offer rides"| Post Ride Screen    |
| 8. Driver KYC Rejected (Blurry Photo)| 🔴 URGENT | "⚠️ DL Photo Blurry: Tap here to re-take photo."    | Re-Upload KYC Screen|
+-------------------------------------------------------------------------------------------------------------------+
```

#### 3. 🏢 Employer & HR Manager Notifications (B2B SaaS Portal):

```
+-------------------------------------------------------------------------------------------------------------------+
| EVENT TRIGGER                        | PRIORITY | NOTIFICATION MESSAGE & DELIVERY CHANNEL             | TARGET SCREEN       |
+-------------------------------------------------------------------------------------------------------------------+
| 1. Low Coin Pool Alert (T-24h)       | 🔴 URGENT | "⚠️ Infosys Pool is at 15%. Recharge before 1st."   | HR Billing Screen   |
| 2. Monthly Airdrop Execution (1st)   | 🟢 HIGH   | "✅ Grants Dispatched: 400 coins sent to 1,420 emp" | HR Employee Roster  |
| 3. New Employee Domain Registration  | 🟡 NORMAL | "👤 12 new @infosys.com employees joined today."    | HR Commuter Roster  |
| 4. Monthly SEBI BRSR ESG Report Ready| 🟢 HIGH   | "🌿 Monthly ESG Audit Ready: 14.2 Tons CO2 Saved."  | HR ESG Export       |
+-------------------------------------------------------------------------------------------------------------------+
```

#### 4. 🛡️ Super Admin Notifications (Platform Governance & Emergency Response):

```
+-------------------------------------------------------------------------------------------------------------------+
| EVENT TRIGGER                        | PRIORITY | PUSH / SYSTEM ALERT MESSAGE (SIREN / BANNER)        | ADMIN ACTION SCREEN |
+-------------------------------------------------------------------------------------------------------------------+
| 1. 🚨 REAL-TIME SOS EMERGENCY        | 🚨 CRITICAL| "🚨 SOS ALERT: Priya triggered SOS on Ride #RD-8842| Live SOS Incident   |
|                                      |          | near Silk Board! Driver: Rahul (KA01MJ5521)"        | Map & Dispatch Link |
|--------------------------------------|----------|-----------------------------------------------------|---------------------|
| 2. Pending Driver KYC Queue Alert    | 🟡 NORMAL | "📄 8 new drivers submitted DL & RC for review."    | Driver Review Queue |
| 3. B2B Subscription Payment Received | 🟢 HIGH   | "💵 Infosys paid ₹19,999 (Growth Plan) via Gateway" | Financial Invoices  |
| 4. Stuck Escrow Auto-Recovery Notice | 🟡 NORMAL | "🛡️ 3 orphaned rides > 4h auto-refunded to riders."| Escrow Audit Ledger |
+-------------------------------------------------------------------------------------------------------------------+
```

---

### 16.3 Custom Notification Channels & Sound Priority

To prevent critical commute alerts from being missed or muted:

```dart
// lib/services/notification_service.dart
const AndroidNotificationChannel commuteUrgentChannel = AndroidNotificationChannel(
  'commute_urgent',
  'Urgent Commute Alerts',
  description: 'High-priority chimes for Driver Arrival, Boarding PINs, and SOS emergencies.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

const AndroidNotificationChannel commuteChatChannel = AndroidNotificationChannel(
  'commute_chat',
  'Chat & Messaging',
  description: 'Subtle notification sound for new messages and quick chips.',
  importance: Importance.high,
  playSound: true,
);

const AndroidNotificationChannel commuteGeneralChannel = AndroidNotificationChannel(
  'commute_general',
  'General Reminders',
  description: 'Standard notifications for 8:00 PM nightly confirmations and monthly coin grants.',
  importance: Importance.defaultImportance,
);
```

---

### 16.4 FCM Device Token Lifecycle & Secure Database Storage

```
[ App Launch / Login ] ──► FirebaseMessaging.instance.getToken()
                             │
                             ▼
[ Auto-Saved to public.users.fcm_token in Supabase PostgreSQL ]
  • On Token Refresh: FirebaseMessaging.instance.onTokenRefresh updates DB immediately.
  • On User Logout: UPDATE public.users SET fcm_token = NULL WHERE id = auth.uid();
    (Guarantees zero notification leakage across shared mobile devices).
```

---

### 16.5 Direct Deep-Linking Routing Architecture

Every push notification sent by our backend includes structured JSON data payload:

```json
{
  "notification": {
    "title": "📍 Driver Arrived at Pickup!",
    "body": "Rahul is waiting at Gate 2. Boarding PIN: 4821"
  },
  "data": {
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "route": "/live_cockpit",
    "ride_id": "b47c8a12-8821-4f10-911a-7821948123aa",
    "screen_type": "boarding_pin"
  }
}
```

* **1-Tap Routing:** When the user taps the notification banner on their locked phone screen, the Flutter app launches and immediately routes directly into the target screen (`/live_cockpit`, `/chat`, `/wallet`, or `/admin_sos`) with zero manual menu navigation!

---

### 16.6 UI/UX Notification Presentation Styles & In-App Rendering Engine

To ensure an intuitive, non-intrusive, and safety-focused user experience across all mobile states, the platform implements **6 distinct visual notification presentation styles**:

```
+-------------------------------------------------------------------------------------------------------------------+
| NOTIFICATION PRESENTATION STYLE     | WHERE IT APPEARS                     | BEST USE CASE / TRIGGER              |
+-------------------------------------------------------------------------------------------------------------------+
| 1. 🔔 System Lock Screen Banner     | Phone Lock Screen / Status Bar       | When phone is locked / App in pocket |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 2. 🪟 In-App Top Floating Banner    | Slides down from top of active screen| When user is ALREADY inside the app  |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 3. 🔴 App Icon & Bell Badge Counter | Red dot (`🔴 3`) on app icon & navbar | Unread chat messages & coin credits  |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 4. ⚡ Actionable Bottom Sheet Popup  | Slides up from bottom with buttons   | Driver incoming request (Accept/Pass)|
|-------------------------------------|--------------------------------------|--------------------------------------|
| 5. 🚗 Sticky Ongoing Commute Bar    | Pinned in Android notification shade | Live Ride in Progress (Live ETA HUD) |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 6. 📜 In-App Notification Center    | Dedicated Inbox Screen (`/inbox`)    | Past receipts, history & B2B updates |
+-------------------------------------------------------------------------------------------------------------------+
```

#### 1. 🪟 In-App Top Floating Banner (Active App State):
* When the user is actively viewing a map or browsing profiles:
* A glassmorphic card slides down from the top edge for 4 seconds without interrupting ongoing navigation:
  ```
  +-------------------------------------------------------------------+
  | 💬 Rahul S. (Driver): "At Gate 2 now!"                 [ Reply ➤ ] |
  +-------------------------------------------------------------------+
  ```

#### 2. ⚡ Actionable Modal / Bottom Sheet Popup (Time-Sensitive Actions):
* Triggered when an immediate response is required (e.g. Driver incoming ride request):
* Displays a **30-second circular countdown timer**:
  ```
  +-------------------------------------------------------------------+
  |               🔔 NEW RIDE REQUEST (8:30 AM COMMUTE)               |
  +-------------------------------------------------------------------+
  |  Priya Patel (Infosys • Verified Aadhaar ✅)                      |
  |  Route: HSR Gate ➔ Manyata Gate 2                                 |
  |  Detour: +150 meters (+2 mins) | Fare: +24 Karma Coins            |
  |                                                                   |
  |  [ ✅ ACCEPT REQUEST (24s) ]          [ ❌ DECLINE ]              |
  +-------------------------------------------------------------------+
  ```

#### 3. 🚗 Sticky Ongoing Commute Notification (Android Notification Shade):
* While a commute is in progress, a persistent, non-dismissible status card remains pinned in the notification bar showing live ETA and quick safety actions:
  ```
  +-------------------------------------------------------------------+
  | 🚗 CorporatePooling: In Trip with Rahul                           |
  | Destination: Manyata Tech Park | ETA: 8:42 AM (3.2 km left)       |
  | [ 📞 Call Driver (Masked) ]               [ 🚨 Emergency SOS ]     |
  +-------------------------------------------------------------------+
  ```

#### 4. 📜 In-App Notification Center / Inbox Screen (`/notifications`):
* A persistent activity tray with 4 filter tabs (`All`, `Rides`, `Wallet`, `Company`) allowing commuters to review historical pickup confirmations, coin credit receipts, and official HR announcements.

---

## 17. Admin Panel, Multi-Tier 2FA Security & Dynamic Remote Theme System

**Primary Modules:** `lib/screens/admin/admin_dashboard_screen.dart`, `lib/screens/admin/admin_theme_editor_screen.dart`, `lib/services/admin_service.dart`, Supabase Auth MFA (`local_auth` & TOTP)

Section 17 defines the administrative command architecture, including ₹0 cost dual access (Desktop Web Portal + Mobile Executive Mode), role-based two-factor authentication (2FA), immutable admin audit logging, core operational modules (Live Ride Map, Driver KYC Review, B2B Invoicing, Escrow Disputes), the Dynamic Remote Theme Engine, and the Central Real-Time SOS Emergency Command.

---

### 17.1 Dual Access Architecture (Desktop Web + Mobile Executive at ₹0 Cost)

```
+-------------------------------------------------------------------------------------------------------------------+
| ACCESS FORM FACTOR                  | PLATFORM / TECHNOLOGY                | HOW IT WORKS & RUNNING COST          |
+-------------------------------------------------------------------------------------------------------------------+
| 🖥️ 1. Desktop Web Admin Portal       | Flutter Web (`flutter build web`)   | • Hosted on Cloudflare Pages / Vercel|
|    (`admin.corporatepooling.com`)  | Compiled from same Flutter codebase  |   for **₹0.00 / month (Free Tier)**! |
|                                     |                                      | • Best for side-by-side KYC reviews, |
|                                     |                                      |   city carpool maps & B2B ledgers.   |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 📱 2. Mobile Executive Mode         | Role-Gated Screen inside Mobile APK  | • Uses existing mobile app on phone  |
|    (In-App Super Admin Tab)         | (`if (user.role == 'super_admin')`)  |   for **₹0.00 / month**.             |
|                                     |                                      | • Instant 🚨 SOS sirens & 1-tap KYC  |
|                                     |                                      |   document approvals on-the-go!      |
+-------------------------------------------------------------------------------------------------------------------+
```

---

### 17.2 Multi-Tier Two-Factor Authentication (2FA) Architecture

To provide bank-grade security for administrative and enterprise access while maintaining zero friction for daily commuters:

```
+-------------------------------------------------------------------------------------------------------------------+
| USER ROLE                           | 2FA METHOD USED                      | OPERATIONAL RATIONALE       | RUNNING COST|
+-------------------------------------------------------------------------------------------------------------------+
| 👑 1. Super Admin & Platform Staff  | 📱 **Google Authenticator (TOTP)**    | Maximum unhackable security | **₹0.00**   |
|    (`super_admin`, `support_officer`) | (6-digit rotating app code)          | for master control. Zero SMS| (100% Free) |
|-------------------------------------|--------------------------------------|-----------------------------|-------------|
| 🏢 2. Company HR / Facility Managers| 📧 **Work Email 6-Digit Magic OTP**   | Verifies corporate identity | **₹0.00**   |
|    (`role = 'company_manager'`)     | (Sent to verified corporate inbox)   | without personal phone SMS. | (100% Free) |
|-------------------------------------|--------------------------------------|-----------------------------|-------------|
| 🚗 3. Everyday Commuters            | 👆 **Phone Biometrics (Face/Touch ID)**| Daily commuters must open   | **₹0.00**   |
|    (Drivers & Riders)               | + 90-Day Secure Persistent Session   | app in 1 sec without typing!| (100% Free) |
+-------------------------------------------------------------------------------------------------------------------+
```

---

### 17.3 Role-Based Access Control (RBAC) & Immutable Audit Logging

```sql
CREATE TYPE admin_role_enum AS ENUM ('super_admin', 'support_officer', 'finance_admin');

CREATE TABLE public.admin_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL REFERENCES public.users(id),
    action_type VARCHAR(50) NOT NULL, 
    -- 'driver_approved', 'driver_rejected', 'escrow_force_settled', 'company_created', 'theme_updated', 'user_banned'
    target_id UUID,
    details JSONB DEFAULT '{}'::jsonb,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_admin_audit_logs_action ON public.admin_audit_logs(action_type, created_at DESC);
```

---

### 17.4 Core Operational Modules (The 6 Administrative Super-Tools)

The Super Admin Console provides **6 dedicated administrative tools** for complete operational, legal, and financial platform governance:

```
+-------------------------------------------------------------------------------------------------------+
| 1. 🗺️ LIVE CITY-WIDE COMMUTE MAP        ──► Real-time visual bird's-eye fleet monitor across the city |
| 2. 🪪 DRIVER KYC VERIFICATION QUEUE     ──► High-res side-by-side document review (DL, RC, Aadhaar)  |
| 3. 🏢 B2B COMPANY & POOL MANAGER        ──► Add employers, assign HR admins, recharge coin pools     |
| 4. ⚖️ ESCROW DISPUTE & RESOLUTION HUB    ──► 1-Click force refund to rider or force payout to driver  |
| 5. 🚫 USER TRUST & BAN MANAGEMENT       ──► Warning strikes, 7-day suspension & permanent phone bans  |
| 6. 🪙 PLATFORM COIN SUPPLY AUDIT        ──► Total coins minted, in circulation, locked & burned       |
+-------------------------------------------------------------------------------------------------------+
```

#### 1. 🗺️ Live City-Wide Commute Map & Fleet Monitor:
* Real-time vector map tracking all active in-progress carpools across metropolitan corridors:
  * 🟢 **Green Vehicles:** On-track within 50m of planned route, normal speed ($< 60\text{ km/h}$).
  * 🟡 **Yellow Vehicles:** Stuck in traffic congestion / delayed $> 10\text{ mins}$.
  * 🔴 **Red Vehicles:** Off-route detour $> 1\text{ km}$ or stopped $> 10\text{ mins}$ without passenger drop-off.
* Clicking any vehicle displays: Driver Name, Vehicle Plate Number, Verified Passenger List, Planned Route Polyline, and live speed.

#### 2. 🪪 Driver KYC Verification Queue & Side-by-Side Inspector:
* High-resolution split-screen document viewer for fast, accurate verification:
  * **Applicant Details:** Name, Phone Number, Company, Vehicle Make/Model, Plate Number.
  * **Zoomable Image Inspector:** Driving License (DL), Vehicle Registration Card (RC), Aadhaar Card, and Profile Selfie.
  * **1-Click Approvals:** Sets `is_verified_driver = TRUE` and dispatches instant push notification.
  * **Standard Rejection Presets:** `"DL photo blurry / dark"`, `"Vehicle RC is expired"`, `"Name mismatch on Aadhaar"`, or `"Custom Reason"`.
  * **Integrity Guarantee:** User photos are 100% immutable; zero editing or modification by administrators.

#### 3. 🏢 B2B Company & Master Coin Pool Manager:
* **Client Onboarding:** Register new corporate clients (*e.g. Wipro Sarjapur*), define company email domains (`@wipro.com`), set campus geofence pins, and assign verified HR Manager logins.
* **Master Coin Pool Recharge:** View real-time balance (*e.g. 85,400 Coins*) and 1-click activate prepaid pool top-ups upon verifying bank NEFT/RTGS UTR numbers.
* **Subscription Management:** Upgrade employer plan tiers (Starter $\to$ Growth $\to$ Enterprise) and configure default monthly employee coin grant quotas.

#### 4. ⚖️ Escrow Dispute & Mid-Route Intervention Center:
* Resolves edge-case commuter disputes with complete audit transparency:
  * **Premature Drop-Off Fraud:** Driver terminates trip 5km away from destination $\rightarrow$ Super Admin reviews GPS trail and clicks **`[ ⚡ FORCE REFUND ESCROW TO RIDER ]`**.
  * **Rider Refuses Boarding PIN:** Driver legitimately transports passenger to campus but rider refuses to share PIN $\rightarrow$ Super Admin reviews overlapping GPS breadcrumbs and clicks **`[ ⚡ FORCE SETTLE FARE TO DRIVER ]`**.

#### 5. 🚫 User Trust, Warning Strikes & 3-Tier Ban Discipline:
* Commuter profile lookup by Phone Number, Full Name, or Corporate Email.
* View Safety Trust Score (0–100), Star Ratings, and Telematics Rash Driving violations.
* **Three Levels of Platform Discipline:**
  1. 🟡 **Issue Formal Warning:** Dispatches high-priority warning push to user's device.
  2. ⏸️ **Temporary 7-Day Suspension:** For chronic unannounced cancelers or rude behavior.
  3. 🚫 **Permanent Blacklist Ban:** Instantly revokes JWT auth tokens, terminates active sessions, and blacklists phone number and Aadhaar hash from re-registering.

#### 6. 🪙 Platform-Wide Karma Coin Supply & Ledger Audit:
* Real-time financial health dashboard:
  * **Total Platform Coins in Existence** (Minted via B2B subscriptions & system pools).
  * **Active Coins Locked in Trip Escrows** (Escrows currently pending drop-off verification).
  * **Monthly Burn vs. Mint Velocity** (Tracks coin circulation and economic stability).

---

### 17.5 Dynamic Remote Theme & Home Screen Editor

The platform includes a **Remote Theme Engine** that allows Super Admin to modify visual styling, festival campaigns, and promotional taglines across **all user mobile phones in real-time without requiring a Google Play Store or Apple App Store update**:

```sql
CREATE TABLE public.app_remote_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallpaper_url TEXT DEFAULT 'https://assets.corporatepooling.internal/default_bg.webp',
    wallpaper_opacity NUMERIC(3, 2) DEFAULT 0.85,
    glass_card_color VARCHAR(20) DEFAULT 'rgba(20,25,35,0.75)',
    accent_color VARCHAR(10) DEFAULT '#FF6B00', -- Saffron / Green / Custom Accent
    active_festival_banner_url TEXT, -- Diwali, New Year, Independence Day Campaigns
    banner_action_route VARCHAR(50) DEFAULT '/offer_ride',
    tagline_primary VARCHAR(150) DEFAULT 'Share the Ride, Multiply the Karma',
    tagline_secondary VARCHAR(150) DEFAULT 'Join 10,000+ Corporate Colleagues Commuting Green',
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

* **Realtime Propagation:** Flutter clients listen to Supabase Realtime changes on `app_remote_config` and instantly re-render the Home Screen theme dynamically!

---

### 17.6 Central Real-Time SOS Emergency Command (End-to-End Safety Protocol)

Section 17.6 defines the high-priority emergency command architecture, operating an instantaneous multi-channel safety protocol when a commuter triggers SOS during an active carpool:

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: Emergency Trigger (T+0.00s)     ──► 3s Cancel Ring ➔ Instant Multi-Channel Broadcast         │
│ PHASE 2: Super Admin Command Console     ──► High-Frequency Audio Siren, Live Breadcrumbs & Telemetry │
│ PHASE 3: Multi-Agency Dispatch           ──► Police 112 API, Family Live Link & Corporate Security    │
│ PHASE 4: Incident Sealing & DPDP Archive ──► Cryptographic Evidence Lock & Mandatory Admin Report    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 17.6.1 Commuter Emergency Trigger Flow & 3-Second Cancel Ring:
* The commuter taps the floating **🚨 SOS Button** on the live cockpit or presses the physical phone power button 3 times.
* A **3-second circular countdown ring** appears with haptic vibration, allowing instant cancellation if tapped accidentally in a bag or pocket.
* If not cancelled within 3 seconds, the emergency sequence executes irreversibly.

#### 17.6.2 Instant 4-Way Parallel Broadcast Dispatch:
```
[ 🚨 SOS TRIGGERED ]
         │
         ├──► 1. 📱 TO FAMILY CONTACTS: Automated SMS/WhatsApp with live GPS tracking link:
         │       "🚨 EMERGENCY ALERT: Priya Patel triggered SOS on carpool with Rahul (KA-01-MJ-5521). Track live:..."
         │
         ├──► 2. 🚓 TO POLICE CONTROL (112): Pre-formatted emergency dispatch packet with live GPS Lat/Long,
         │       current street address, vehicle plate number, driver identity, and incident token.
         │
         ├──► 3. 🏢 TO COMPANY HR SECURITY: Webhook alert sent directly to corporate campus security desk.
         │
         └──► 4. 👑 TO SUPER ADMIN CONSOLE: Real-time high-frequency audio siren and emergency HUD popup!
```

#### 17.6.3 Super Admin Central Emergency Command HUD (`lib/screens/admin/admin_sos_command.dart`):
* The Super Admin web and mobile console instantly sounds a **continuous high-frequency audio siren** and displays the incident cockpit:
  * **Commuter in Distress:** Full Name, Corporate Badge (`@infosys.com`), Verified Phone Number, Device Battery Level (`🔋 14%`).
  * **Driver & Vehicle Profile:** Driver Full Name, Vehicle Make/Model, License Plate Number (`KA-01-MJ-5521`), Driver Phone.
  * **Live Breadcrumb GPS Map:** Real-time marker updating every 2 seconds, vehicle heading, live speed (e.g. `52 km/h`), and last 15-minute trail highlighting off-route detours.
  * **Admin 1-Click Action Hub:**
    * `[ 🚓 1-TAP POLICE 112 DISPATCH ]` (Direct line with pre-populated incident token).
    * `[ 📞 CALL COMMUTER (Direct / Masked VoIP) ]`.
    * `[ 📞 CALL DRIVER (Direct / Masked VoIP) ]`.
    * `[ 🔒 INSTANT DRIVER LOCK & ESCROW FREEZE ]` (Precautionary vehicle suspension).

#### 17.6.4 Cryptographic Evidence Sealing & PostgreSQL Schema:
All telemetry, GPS trails, audio recordings (if microphone was activated), and chat transcripts are permanently locked into `public.emergency_sos_incidents` for police investigation and legal defense:

```sql
CREATE TABLE public.emergency_sos_incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES public.rides(id),
    triggered_by UUID NOT NULL REFERENCES public.users(id),
    driver_id UUID NOT NULL REFERENCES public.users(id),
    vehicle_plate VARCHAR(20) NOT NULL,
    trigger_lat DOUBLE PRECISION NOT NULL,
    trigger_lng DOUBLE PRECISION NOT NULL,
    live_speed_kmh NUMERIC(5, 2),
    battery_level_pct INT,
    police_notified BOOLEAN DEFAULT FALSE,
    family_notified_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'police_dispatched', 'resolved_safe', 'false_alarm'
    resolution_category VARCHAR(50), -- 'false_alarm', 'breakdown_medical', 'driver_misbehavior', 'critical'
    resolution_notes TEXT,
    resolved_by UUID REFERENCES public.users(id),
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sos_status ON public.emergency_sos_incidents(status, created_at DESC);
```

#### 17.6.5 Mandatory Super Admin Incident Resolution Protocol:
* An active SOS incident **cannot be dismissed without a formal audit trail**.
* The Super Admin or Support Officer must submit a verified resolution category and resolution notes (*"Resolved Safe by Local Police"*, *"Vehicle Breakdown Assistance Dispatched"*, or *"False Alarm by Commuter"*).
* Evidence logs are cryptographically preserved for 7 years in compliance with the **Digital Personal Data Protection (DPDP) Act** and Indian transport safety regulations.

---

## 18. Complete UI Screen Catalogue & Component Inventory (The 37 Application Flows)

**Primary Directories:** `lib/screens/auth/`, `lib/screens/home/`, `lib/screens/driver/`, `lib/screens/rider/`, `lib/screens/chat/`, `lib/screens/wallet/`, `lib/screens/rides/`, `lib/screens/safety/`, `lib/screens/hr/`

Section 18 provides the exhaustive, screen-by-screen architectural blueprint and UI component inventory for all **37 dedicated application flows across Commuters, Corporate Employees, Drivers, Riders, and Employer HR Desks**.

---

### 18.1 Master Architecture Hierarchy Matrix

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 🔑 MODULE A: Authentication, Onboarding & Corporate Verification (6 Screens)                         │
│ 🏠 MODULE B: Master Home, Activity Inbox & Dynamic Remote Theme (2 Screens)                           │
│ 🚗 MODULE C: Driver Commute Cockpit & Boarding Flow (6 Screens)                                       │
│ 🚶 MODULE D: Rider Commute Cockpit & Ride Booking Flow (6 Screens)                                    │
│ 💬 MODULE E: In-App Chat & Masked Agora VoIP Calling (3 Screens)                                      │
│ 🪙 MODULE F: Wallet, Double-Entry Ledger & ESG Carbon Dashboard (3 Screens)                           │
│ 📅 MODULE G: "My Rides" Commute History & Calendar Roster (2 Screens)                                 │
│ 🛡️ MODULE H: Personal Safety, SOS Emergency & User Profile (3 Screens)                                │
│ 🏢 MODULE I: Employer & HR Manager B2B SaaS Web Portal (6 Screens)                                    │
├───────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 🚀 TOTAL DETAILED PRODUCTION FLOWS: EXACTLY 37 SCREENS                                                │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

### 18.2 Module-by-Module Detailed Screen Inventory

#### 🔑 MODULE A: Authentication, Onboarding & Corporate Verification (6 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 1. Splash Screen             | `lib/screens/auth/splash_screen.dart`       | • Animated Karma Logo & pulse shader.|
|                              |                                             | • Fast session validator (0.2s auto- |
|                              |                                             |   route if 90-day JWT token valid).  |
|------------------------------|---------------------------------------------|--------------------------------------|
| 2. Onboarding Carousel       | `lib/screens/auth/onboarding_screen.dart`   | • 3 Value Prop Cards (Save Fuel,     |
|                              |                                             |   Green Commute, Verified Peers).    |
|                              |                                             | • [ Get Started ] action button.     |
|------------------------------|---------------------------------------------|--------------------------------------|
| 3. Phone Login & OTP Screen  | `lib/screens/auth/login_phone_screen.dart`  | • +91 Phone input + Country picker.  |
|                              |                                             | • 6-Digit SMS OTP input box with     |
|                              |                                             |   auto-sms listener & 30s resend.    |
|------------------------------|---------------------------------------------|--------------------------------------|
| 4. Role Selection Screen     | `lib/screens/auth/role_selection_screen.dart`| • Dual selection cards: "Corporate   |
|                              |                                             |   Employee" vs "Public Commuter".    |
|------------------------------|---------------------------------------------|--------------------------------------|
| 5. Corporate Verification    | `lib/screens/auth/corporate_verify_screen.dart`| • Work Email input (`@infosys.com`).|
|                              |                                             | • 6-Digit Magic Link OTP validator.  |
|                              |                                             | • Corporate Badge locked animation.  |
|------------------------------|---------------------------------------------|--------------------------------------|
| 6. Driver KYC Upload Screen  | `lib/screens/auth/driver_kyc_screen.dart`   | • On-Device Compression (1280x960).  |
|                              |                                             | • Driving License (DL), RC & Aadhaar |
|                              |                                             |   card document pickers + 380 DPI.   |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 🏠 MODULE B: Master Home, Activity Inbox & Dynamic Remote Theme (2 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 7. Master Home Screen        | `lib/screens/home/home_screen.dart`         | • Dynamic Remote Wallpaper Engine.   |
|                              |                                             | • Glassmorphic Quick Action Cards:   |
|                              |                                             |   [ 🚗 Offer Ride ] [ 🔍 Find Ride ] |
|                              |                                             |   [ 🔁 Recurring Mon-Fri Setup ]     |
|                              |                                             | • Karma Coin HUD (`🪙 380 Coins`).   |
|                              |                                             | • 💬 Company Chat Navbar Icon.       |
|                              |                                             | • 🏢 Soft Attendance 1-Tap Check-In. |
|                              |                                             | • Active Festival Campaign Banner.   |
|------------------------------|---------------------------------------------|--------------------------------------|
| 8. Notification Center Inbox | `lib/screens/notifications/inbox_screen.dart`| • 4 Filter Tabs: `All`, `Rides`,       |
|                              |                                             |   `Wallet`, `Company`. Swipe-dismiss.|
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 🚗 MODULE C: Driver Commute Cockpit & Boarding Flow (6 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 9. Offer a Ride Screen       | `lib/screens/driver/offer_ride_screen.dart` | • Origin & Destination search boxes. |
|                              |                                             | • Corridor Waypoint selector.        |
|                              |                                             | • Time selector: Leave Now, Schedule.|
|                              |                                             | • Seat Capacity Selector (1 to 4).   |
|------------------------------|---------------------------------------------|--------------------------------------|
| 10. Recurring Commute Setup  | `lib/screens/driver/recurring_setup_screen.dart`| • Day-wise Checklist (Mon to Fri).  |
|                              |                                             | • Recurring Departure Time & Auto-   |
|                              |                                             |   Match Nightly Cron toggle.         |
|------------------------------|---------------------------------------------|--------------------------------------|
| 11. Driver Requests Screen   | `lib/screens/driver/driver_requests_screen.dart`| • Incoming Request Cards showing:    |
|                              |                                             |   Detour Distance (+150m), Detour    |
|                              |                                             |   Time (+2 mins), Rider Company &    |
|                              |                                             |   Earned Coins (+24).                |
|                              |                                             | • [ Accept ] [ Decline ] (30s timer).|
|------------------------------|---------------------------------------------|--------------------------------------|
| 12. Driver Live Cockpit HUD  | `lib/screens/driver/driver_live_cockpit.dart`| • Real-Time Turn-by-Turn Navigation. |
|                              |                                             | • Passenger Occupancy HUD (`2/3`).   |
|                              |                                             | • 1-Tap Driving Chips (`[ At Gate ]`).|
|                              |                                             | • 📞 In-App Masked VoIP Call button. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 13. Boarding Verify Screen   | `lib/screens/driver/boarding_verify_screen.dart`| • 4-Digit PIN Keypad Validator.    |
|                              |                                             | • BLE Radar Auto-Detector & QR Scan. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 14. Driver Ride Summary      | `lib/screens/driver/ride_summary_screen.dart`| • Instant Coin Credit Animation (+24)|
|                              |                                             | • Trip Distance, Time & Ratings.     |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 🚶 MODULE D: Rider Commute Cockpit & Ride Booking Flow (6 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 15. Find a Ride Screen       | `lib/screens/rider/find_ride_screen.dart`   | • Pickup & Drop Search Autocomplete. |
|                              |                                             | • Gender Filter (Women-Only toggle). |
|                              |                                             | • Same-Company Colleague Filter.     |
|------------------------------|---------------------------------------------|--------------------------------------|
| 16. Route Preview Screen     | `lib/screens/rider/route_preview_screen.dart`| • Map displaying matching driver poly|
|                              |                                             | • Walking Distance to pickup (80m).  |
|                              |                                             | • Driver vehicle plate & star rating.|
|------------------------------|---------------------------------------------|--------------------------------------|
| 17. Booking Status Screen    | `lib/screens/rider/booking_status_screen.dart`| • "Waiting for driver..." countdown. |
|                              |                                             | • 5-Minute Auto-Expiry ring & Cancel.|
|------------------------------|---------------------------------------------|--------------------------------------|
| 18. Rider Live Cockpit       | `lib/screens/rider/rider_live_cockpit.dart` | • Live Driver Car moving on map.     |
|                              |                                             | • Real-Time ETA Countdown (4 mins).  |
|                              |                                             | • 📞 Masked Call & 🚨 SOS buttons.   |
|------------------------------|---------------------------------------------|--------------------------------------|
| 19. Rider Boarding PIN Screen| `lib/screens/rider/boarding_pin_screen.dart`| • Giant 4-Digit Boarding PIN (4821). |
|                              |                                             | • Dynamic Boarding QR Code.          |
|------------------------------|---------------------------------------------|--------------------------------------|
| 20. Rider Receipt & Rating   | `lib/screens/rider/receipt_rating_screen.dart`| • 24 Karma Coins transfer receipt.  |
|                              |                                             | • 1.8 kg CO₂ Saved Green Badge 🌱.   |
|                              |                                             | • 5-Star Rating & Compliment Chips.  |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 💬 MODULE E: In-App Chat & Masked Calling (3 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 21. Per-Ride Commute Chat    | `lib/screens/chat/ride_chat_screen.dart`    | • Unlocked post-driver acceptance.   |
|                              |                                             | • Group chat (Driver + Co-Riders).   |
|                              |                                             | • 1-Tap Driving Action Chips.        |
|                              |                                             | • Auto-archives on trip drop-off.    |
|------------------------------|---------------------------------------------|--------------------------------------|
| 22. Company Workspace Chat   | `lib/screens/chat/company_workspace_screen.dart`| • HR Official Announcements.     |
|                              |                                             | • Employee Carpool Route Groups.     |
|                              |                                             | • 1:1 Colleague Direct Chats.        |
|                              |                                             | • Strictly same-company verified.    |
|------------------------------|---------------------------------------------|--------------------------------------|
| 23. In-App Masked Call Screen| `lib/screens/chat/masked_call_screen.dart`  | • Full-screen Agora VoIP voice call. |
|                              |                                             | • 100% Masked phone numbers.         |
|                              |                                             | • Mute, Speakerphone & End Call.     |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 🪙 MODULE F: Wallet, Payments & ESG Impact (3 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 24. Master Wallet Screen     | `lib/screens/wallet/wallet_screen.dart`     | • Total Balance (`🪙 380 Coins`).    |
|                              |                                             | • Balance Waterfall: Corporate Grant,|
|                              |                                             |   Personal Earned & Family Pool.     |
|                              |                                             | • 1-Tap Fuel Voucher Redeem Card.    |
|------------------------------|---------------------------------------------|--------------------------------------|
| 25. Transaction Ledger Screen| `lib/screens/wallet/transactions_screen.dart`| • Double-entry immutable ledger.    |
|                              |                                             | • Credit & Debit receipt receipts.   |
|------------------------------|---------------------------------------------|--------------------------------------|
| 26. ESG Carbon Dashboard     | `lib/screens/esg/esg_dashboard_screen.dart` | • Total CO₂ Saved (kg), Fuel Saved.  |
|                              |                                             | • Tree planting equivalent badge.    |
|                              |                                             | • Company Green Commute Leaderboard. |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 📅 MODULE G: Commute Calendar & History (2 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 27. "My Rides" Screen        | `lib/screens/rides/my_rides_screen.dart`    | • 4 Tabs: Active, Upcoming,          |
|                              |                                             |   Recurring & Past Trips.            |
|                              |                                             | • 1-Tap "Repeat Commute" & "Skip".   |
|------------------------------|---------------------------------------------|--------------------------------------|
| 28. Trip Details Screen      | `lib/screens/rides/ride_details_screen.dart`| • Full breadcrumb route map.         |
|                              |                                             | • Co-riders list, escrow receipt.    |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 🛡️ MODULE H: Personal Safety, SOS & Profile (3 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 29. Emergency SOS Screen     | `lib/screens/safety/sos_screen.dart`        | • High-frequency audio siren.        |
|                              |                                             | • 1-Tap Police 112 Dispatch link.    |
|                              |                                             | • Family Live Tracking Webhook.      |
|------------------------------|---------------------------------------------|--------------------------------------|
| 30. User Profile Screen      | `lib/screens/profile/profile_screen.dart`   | • Verified Aadhaar & Company Badges. |
|                              |                                             | • Trust Score (0-100) & Star Rating. |
|                              |                                             | • Registered Vehicles list.          |
|------------------------------|---------------------------------------------|--------------------------------------|
| 31. Edit Profile Screen      | `lib/screens/profile/edit_profile_screen.dart`| • Change Default Home / Work pins. |
|                              |                                             | • Manage Emergency Contacts.         |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 🏢 MODULE I: Employer & HR Manager B2B SaaS Web Portal (6 Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 32. HR Login & 2FA Screen    | `lib/screens/hr/hr_login_screen.dart`       | • Work Email (`hr@infosys.com`).     |
|                              |                                             | • 6-Digit Email Magic OTP field (₹0).|
|------------------------------|---------------------------------------------|--------------------------------------|
| 33. HR Overview Dashboard    | `lib/screens/hr/hr_overview_screen.dart`    | • Daily Active Commuters Counter.    |
|                              |                                             | • Master Coin Pool Balance Widget.   |
|                              |                                             | • Monthly CO₂ Saved (Tons).          |
|                              |                                             | • Quick Actions: Top-up, Broadcast.  |
|------------------------------|---------------------------------------------|--------------------------------------|
| 34. HR Employee Roster       | `lib/screens/hr/hr_roster_screen.dart`      | • Searchable Employee Directory.     |
|                              |                                             | • Department / Office Block filters. |
|                              |                                             | • Invite via CSV or Company Code.    |
|                              |                                             | • 1-Click Revoke resigned employees. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 35. HR Coin Pool & Billing   | `lib/screens/hr/hr_billing_screen.dart`     | • Set 1st-of-month Grant Quota       |
|                              |                                             |   (e.g. 400 Coins / employee).       |
|                              |                                             | • 1-Click Pool Recharge (Gateway or  |
|                              |                                             |   Bank NEFT UTR confirmation).       |
|                              |                                             | • Download Clean Non-GST Invoices.   |
|------------------------------|---------------------------------------------|--------------------------------------|
| 36. HR SEBI BRSR ESG Report  | `lib/screens/hr/hr_esg_screen.dart`         | • SEBI BRSR Scope 3 GHG Compliance.  |
|                              |                                             | • Total Vehicle KMs reduced.         |
|                              |                                             | • 1-Click Statutory PDF & Excel exp. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 37. HR Official Broadcast    | `lib/screens/hr/hr_broadcast_screen.dart`   | • Compose official company alerts.   |
|                              |                                             | • Broadcasts directly into employee  |
|                              |                                             |   Workspace Chat channels!           |
+-------------------------------------------------------------------------------------------------------------------+
```

---

#### 👑 MODULE J: Super Admin Master Command Console (10 Dedicated Screens)

```
+-------------------------------------------------------------------------------------------------------------------+
| SCREEN NAME                  | FILE PATH                                   | KEY UI DETAILS, WIDGETS & STATE FLOW |
+-------------------------------------------------------------------------------------------------------------------+
| 38. Admin Login & 2FA Screen | `lib/screens/admin/admin_login_screen.dart` | • Admin Email + Password + TOTP 2FA. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 39. Executive Dashboard      | `lib/screens/admin/admin_dashboard.dart`    | • Master KPIs, Active Commutes, ESG. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 40. Live Fleet Vector Map    | `lib/screens/admin/admin_live_fleet.dart`   | • City-Wide Live Carpool Radar.      |
|------------------------------|---------------------------------------------|--------------------------------------|
| 41. Driver KYC Review Queue  | `lib/screens/admin/admin_kyc_review.dart`   | • Split-Screen 380 DPI DL/RC Viewer. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 42. B2B Company Manager      | `lib/screens/admin/admin_company_mgr.dart`  | • Employer Setup & Bank UTR Top-up.  |
|------------------------------|---------------------------------------------|--------------------------------------|
| 43. Escrow Dispute Hub       | `lib/screens/admin/admin_disputes.dart`     | • Force Refund / Force Settle Fares. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 44. User Trust & Ban Hub     | `lib/screens/admin/admin_user_trust.dart`   | • 3-Tier Discipline (Warn/Suspend/Ban|
|------------------------------|---------------------------------------------|--------------------------------------|
| 45. Coin Supply Ledger       | `lib/screens/admin/admin_coin_ledger.dart`  | • Double-Entry Platform Balance Sheet|
|------------------------------|---------------------------------------------|--------------------------------------|
| 46. Dynamic Theme Editor     | `lib/screens/admin/admin_theme_editor.dart` | • Wallpaper, Banners & Color Picker. |
|------------------------------|---------------------------------------------|--------------------------------------|
| 47. 🚨 SOS Emergency Command | `lib/screens/admin/admin_sos_command.dart`  | • Audio Siren & Police 112 Dispatch. |
+-------------------------------------------------------------------------------------------------------------------+
```

---

### 18.3 Grand Total Screen Inventory Across Entire Platform

```
+-------------------------------------------------------------------------------------------------------+
| SYSTEM MODULE & USER ROLE                                           | TOTAL DEDICATED SCREENS         |
+-------------------------------------------------------------------------------------------------------+
| 🚗 1. Commuter & Corporate Employee Flows (Riders & Drivers)        | **21 to 24 Screens**            |
| 🏢 2. Employer & HR Manager B2B SaaS Portal (Client Companies)      | **6 Screens**                   |
| 👑 3. Super Admin Master Command Console (Platform Operations)      | **10 Screens**                  |
+-------------------------------------------------------------------------------------------------------+
| 🚀 GRAND TOTAL ACROSS THE COMPLETE ECOSYSTEM                        | **EXACTLY 47 PRODUCTION SCREENS**|
+-------------------------------------------------------------------------------------------------------+
```

---

## 19. "My Rides" Screen, Commute History & Active Booking Tabs

**Primary Modules:** `lib/screens/rides/my_rides_screen.dart`, `lib/screens/rides/ride_details_screen.dart`, `lib/services/ride_service.dart`, Supabase Realtime Engine

Section 19 defines the comprehensive commute management dashboard across 4 segmented tabs (`Active`, `Upcoming`, `Recurring`, `Past`), commute lifecycle actions ("Skip Today", Vacation Pause Mode, 1-Tap Repeat Commute), the immutable ESG receipt view, and sub-20ms database query optimizations.

---

### 19.1 The 4 Segmented Tab Architecture & Real-Time Status Engine

```
+-------------------------------------------------------------------------------------------------------+
|  [ 🟢 ACTIVE (1) ]    [ 🟡 UPCOMING (2) ]    [ 🔁 RECURRING (1) ]    [ 📜 PAST (24) ]                 |
+-------------------------------------------------------------------------------------------------------+
| • Dynamic unread badges with instant sub-20ms tab switching.                                          |
| • Listens to Supabase Realtime for automatic status transitions without manual page refreshes.        |
+-------------------------------------------------------------------------------------------------------+
```

#### 1. 🟢 TAB 1: `ACTIVE` Commutes (Happening Right Now!):
* **State Trigger:** Displays commutes in state `accepted`, `driver_en_route`, `arrived_at_pickup`, or `in_trip`.
* **Rider Active Card:**
  * Driver Name, Photo, Corporate Badge (`@infosys.com ✅`), Star Rating (`⭐ 4.9`), Vehicle Make/Model & License Plate (`KA-01-MJ-5521`).
  * Live ETA Countdown HUD (*"Driver 4 mins away"* or *"In Trip: Arriving Gate 2 at 8:42 AM"*).
  * Action Hub: `[ 📍 OPEN LIVE MAP HUD ]`, `[ 🔑 BOARDING PIN: 4821 ]`, `[ 💬 CHAT ]`, `[ 🚨 SOS ]`.
* **Driver Active Card:**
  * Passenger Roster with Boarding Checkmarks (e.g. `Priya Patel - Boarded ✅`, `Amit Kumar - Waiting at Gate 2 ⏳`).
  * Action Hub: `[ 🧭 RESUME TURN-BY-TURN NAVIGATION ]`, `[ 💬 GROUP CHAT ]`.

#### 2. 🟡 TAB 2: `UPCOMING` Commutes (Scheduled for Today / Tomorrow):
* **State Trigger:** Displays confirmed one-time future bookings (`status = 'accepted'`, `departure_time > NOW()`).
* **Card Information:**
  * Route corridor (*"Electronic City Phase 1 ➔ Manyata Tech Park"*).
  * Departure Date & Time (*"Tomorrow, 8:30 AM"*).
  * Escrow Status (*"24 Karma Coins locked in secure escrow"*).
  * Actions: `[ 💬 CHAT WITH DRIVER ]`, `[ ❌ CANCEL RIDE (Free Cancellation Window) ]`.

#### 3. 🔁 TAB 3: `RECURRING` Commutes (Daily Monday-to-Friday Office Carpools):
* **State Trigger:** Displays persistent weekly commute schedules (`time_type = 'recurring'`).
* **Card Information:**
  * Schedule Pill: `[ MON | TUE | WED | THU | FRI ]` (Active days highlighted).
  * Morning Pickup Time (`8:30 AM`) & Evening Return Time (`6:00 PM`).
  * Regular Carpool Partner Roster (`Rahul S. (Driver), Priya P. (Rider)`).
  * Today's Commute Status (`🟢 Confirmed for Today • 24 coins in micro-escrow`).
  * Actions: `[ ⚪ SKIP TODAY (WFH / Leave) ]`, `[ ⏸️ VACATION PAUSE ]`, `[ ⚙️ EDIT SCHEDULE ]`.

#### 4. 📜 TAB 4: `PAST / HISTORY` (Completed & Cancelled Trips):
* **State Trigger:** Displays historical rides (`status = 'completed'`, `'cancelled_by_user'`, `'cancelled_by_driver'`).
* **Card Information:**
  * Departure Timestamp (*"Yesterday, 8:30 AM"*).
  * Status Badge: `🟢 COMPLETED`, `⚪ CANCELLED BY USER`, `🔴 CANCELLED BY DRIVER (Refunded)`.
  * Double-Entry Coin Receipt (`-24 Karma Coins transferred to Rahul`).
  * Environmental Impact Badge (`🌱 1.8 kg CO₂ Saved | 0.8L Fuel Saved`).
  * Rating Stars & Compliments (`⭐⭐⭐⭐⭐ "Punctual & Clean Car"`).
  * Actions: `[ 🔁 1-TAP REPEAT COMMUTE ]`, `[ 📄 VIEW FULL ESG RECEIPT ]`.

---

### 19.2 Commute Lifecycle Management Actions (Topic 2 Deep-Dive)

```
+-------------------------------------------------------------------------------------------------------------------+
| LIFECYCLE ACTION                     | HOW IT WORKS & SYSTEM BEHAVIOR      | FINANCIAL & NOTIFICATION IMPACT      |
+-------------------------------------------------------------------------------------------------------------------+
| 1. ⚪ "Skip Today" (WFH / Leave)     | • 1-Tap on the Recurring Card skips | • Instantly refunds today's 24 Karma |
|                                      |   today's single ride only.         |   coins from micro-escrow to wallet. |
|                                      | • Tomorrow's schedule stays intact! | • Pushes polite alert to driver:     |
|                                      | • Re-opens seat for other commuters.|   "⚪ Priya is WFH today. Seat open."|
|--------------------------------------|-------------------------------------|--------------------------------------|
| 2. ⏸️ "Vacation Pause Mode"          | • Commuter picks date range         | • Zero coins deducted during vacation|
|                                      |   (*e.g. Dec 24 to Jan 2*).         |   dates.                             |
|                                      | • Automatically suspends nightly    | • Auto-resumes on return date without|
|                                      |   8:00 PM matching during vacation. |   re-configuring recurring schedule. |
|--------------------------------------|-------------------------------------|--------------------------------------|
| 3. 🔁 "1-Tap Repeat Commute"         | • Tapping "Repeat" on any past trip | • Validates wallet balance and       |
|                                      |   clones origin, destination, time, |   submits ride request in < 1 second!|
|                                      |   and preferred colleague driver.   |                                      |
+-------------------------------------------------------------------------------------------------------------------+
```

#### 19.2.1 Cancellation Windows, Late Fees & Dynamic Super Admin Governance:
All timings, courtesy fees, wait timers, and penalty thresholds are **100% dynamically controllable by the Super Admin via the central console** without requiring mobile app updates:

```
+-------------------------------------------------------------------------------------------------------------------+
| CANCELLATION SCENARIO               | DYNAMIC ADMIN CONFIG (DEFAULT)       | COIN & PENALTY SETTLEMENT            |
+-------------------------------------------------------------------------------------------------------------------+
| 1. Free Cancellation Window         | Cancelled $> 30	ext{ mins}$ before  | • 100% Full Coin Refund to Rider.    |
|                                     | pickup (FREE_CANCEL_MINS = 30).      | • Zero penalty to anyone.            |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 2. Rider Late Cancellation          | Cancelled $< 15	ext{ mins}$ before  | • 5 Karma Coins (RIDER_LATE_FEE = 5) |
|                                     | pickup (LATE_CANCEL_MINS = 15).      |   credited to Driver for fuel/detour.|
|                                     |                                      | • Remaining coins refunded to Rider. |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 3. Driver Late Cancellation         | Driver cancels $< 15	ext{ mins}$    | • 100% Full Refund to Rider +        |
|                                     | before pickup time.                  |   5 Bonus Platform Apology Coins.    |
|                                     |                                      | • Driver gets -5 Trust Score strike. |
|-------------------------------------|--------------------------------------|--------------------------------------|
| 4. Rider No-Show at Gate            | Driver waits 5 mins at gate          | • 100% of Trip Fare released to      |
|                                     | (WAIT_TIMER_MINS = 5) & timer = 0:00.|   Driver for punctuality!            |
+-------------------------------------------------------------------------------------------------------------------+
```

---

### 19.3 Historical Trip Details & ESG Receipt Breakdown (`lib/screens/rides/ride_details_screen.dart`)

Tapping any trip card in the Past tab opens the detailed audit screen:

```
+-------------------------------------------------------------------+
| 📜 COMMUTE RECEIPT & AUDIT: TRIP #RD-8842                         |
+-------------------------------------------------------------------+
|  Route: HSR Layout Gate ➔ Manyata Tech Park Gate 2 (18.4 km)      |
|  Departure: Monday, Aug 17, 2026 at 08:30 AM (Duration: 42 mins)  |
|                                                                   |
|  🗺️ INTERACTIVE BREADCRUMB ROUTE REPLAY:                          |
|  [ Full recorded GPS polyline trail with pickup/drop pins ]       |
|                                                                   |
|  👥 COMMUTE COMPANIONS:                                           |
|  • Driver: Rahul Sharma (Infosys • KA-01-MJ-5521)                 |
|  • Co-Rider: Amit Kumar (Infosys • QA Team)                       |
|                                                                   |
|  🪙 FINANCIAL TRANSACTION LEDGER:                                 |
|  • Base Distance Rate (18.4 km @ 1.3 Coins/km):       24.00 Coins |
|  • Escrow Lock Timestamp:                    08:00 PM (Night Prior)|
|  • Escrow Settlement Timestamp:              09:12 AM (Drop-Off)   |
|  • Net Wallet Deduction:                             -24.00 Coins |
|                                                                   |
|  🌱 STATUTORY SEBI BRSR ESG CERTIFICATE:                          |
|  • Carbon Emissions Avoided:                         1.84 kg CO₂  |
|  • Fossil Fuel Conserved:                            0.82 Litres  |
|  • Scope 3 Commuter Transit Decarbonization Certified ✅           |
|                                                                   |
|  [ 🔁 REPEAT THIS COMMUTE ]            [ 📄 DOWNLOAD PDF RECEIPT ]|
+-------------------------------------------------------------------+
```

---

#### 19.3.1 Multi-Role Historical Trip Visibility & Permission Matrix

To enforce strict DPDP data privacy while providing full transparency for corporate ESG accounting and administrative governance:

```
+-------------------------------------------------------------------------------------------------------------------+
| AUDIT DATA FIELD / CAPABILITY        | PUBLIC COMMUTERS    | CORPORATE EMPLOYEES | EMPLOYERS / HR DESK | SUPER ADMIN CONSOLE |
+-------------------------------------------------------------------------------------------------------------------+
| 1. Full Recorded GPS Breadcrumb Map  | 🟢 Own Trip Route   | 🟢 Own Trip Route   | 🟡 Anonymized Line  | 🟢 Full Raw GPS Pins|
| 2. Co-Commuter Profile & Rating      | 🟢 Name & Plate Only| 🟢 Name, Dept & Co. | 🟢 Employee Name/Dept| 🟢 Full KYC & Phone|
| 3. SIM Phone Numbers                 | 🚫 100% Masked      | 🚫 100% Masked      | 🚫 Masked           | 🟢 Unmasked (Audit) |
| 4. Coin Waterfall Breakdown          | 🟢 Personal Balance | 🟢 Corp Grant + Own | 🟢 Corp Pool Impact | 🟢 Double-Entry DDL |
| 5. Soft Attendance Arrival Timestamp | ⚪ N/A (Not Tracked)| 🟢 Gate Timestamp   | 🟢 HR Roster Sync   | 🟢 Geofence Audit   |
| 6. Scope 3 ESG Carbon Certificate    | 🟢 Personal (kg CO₂)| 🟢 Personal + Co.   | 🟢 Corp Report (PDF)| 🟢 Platform Total   |
| 7. Telematics Driving Score          | 🟢 Smoothness Score | 🟢 Smoothness Score | ⚪ N/A              | 🟢 Raw G-Force Logs |
| 8. Dispute & Escrow Intervention     | 🟡 Raise Ticket     | 🟡 Raise Ticket     | ⚪ N/A              | 🟢 1-Click Settle/Ban|
+-------------------------------------------------------------------------------------------------------------------+
```

* **1. 🚗 Public Commuters:** View their personal trip route, masked driver/rider profiles, vehicle plate number, personal coin deductions, and personal CO₂ savings. Zero phone numbers are ever exposed.
* **2. 🏢 Corporate Employees:** View verified company badges, department names, exact corporate grant coin waterfall splits, campus arrival timestamps, and verifiable SEBI BRSR ESG certificates.
* **3. 👥 Employers & HR Desks:** View aggregated corporate commuter metrics, employee names, department carpooling rates, company master coin pool deductions, campus attendance timestamps, and 1-click Scope 3 ESG audit PDF exports. Personal weekend rides remain 100% invisible to employers.
* **4. 👑 Super Admin Console:** Complete, unrestricted audit visibility including unmasked raw GPS coordinates, unmasked phone numbers, device battery levels, telematics G-force logs, and 1-click escrow dispute intervention tools.

---

### 19.4 PostgreSQL Query Architecture, Indexes & Real-Time Tab Badges

To guarantee sub-20ms query latency when loading all 4 tabs on user devices:

```sql
-- Composite index for instant Active & Upcoming tab retrieval
CREATE INDEX idx_rides_user_status_time ON public.rides(driver_id, status, departure_time);
CREATE INDEX idx_ride_requests_rider_status ON public.ride_requests(rider_id, status, created_at DESC);

-- Composite index for instant Recurring schedule lookups
CREATE INDEX idx_rides_recurring ON public.rides(driver_id, time_type) WHERE time_type = 'recurring';

-- PostgreSQL View for Unified Commuter Ride History
CREATE OR REPLACE VIEW public.view_my_rides AS
SELECT 
    r.id AS ride_id,
    r.driver_id,
    req.rider_id,
    r.origin_address,
    r.dest_address,
    r.departure_time,
    r.time_type,
    r.recurring_days,
    COALESCE(req.status, r.status) AS commute_status,
    r.fare_coins,
    r.created_at
FROM public.rides r
LEFT JOIN public.ride_requests req ON r.id = req.ride_id;
```

* **Sub-20ms Realtime Tab Sync:** The Flutter app subscribes to `supabase.channel('my_rides:' + auth.uid())`. When a driver accepts a request or begins a trip, the corresponding tab badges (`🔴 1 Active`, `🟡 2 Upcoming`) update dynamically across the screen in real-time!

---

## 20. Ratings, Compliments, Badges & Automated Telematics Rash Driving Engine

**Primary Modules:** `lib/screens/rider/receipt_rating_screen.dart`, `lib/screens/driver/ride_summary_screen.dart`, `lib/services/telematics_service.dart`, Flutter Sensors Plus (`sensors_plus`), Geolocator (`geolocator`)

Section 20 defines the commuter civility, trust evaluation, and zero-hardware smartphone telematics safety architecture, covering mutual 5-star reviews, 1-tap positive compliment chips, automated accelerometer/gyroscope rash driving detection, and dynamic Super Admin telematics governance.

---

### 20.1 Mutual 5-Star Rating Architecture & Positive Compliment Chips

Upon verified trip completion (Section 10), a sleek modal review card opens simultaneously on both Rider and Driver screens:

```
+-------------------------------------------------------------------------------------------------------+
| 1. TRIGGER TIMING:       Appears instantly upon Drop-Off Verification as a sleek modal card           |
| 2. MUTUAL REVIEW:        Rider rates Driver & Driver rates Rider (Both ways!)                         |
| 3. 1-TAP CHIPS:          Zero typing required — instant 1-tap compliment or feedback chips            |
| 4. CIVILITY INCENTIVE:   High ratings boost matching priority and unlock Karma Badges                 |
+-------------------------------------------------------------------------------------------------------+
```

#### 1. 📱 Rider Reviewing Driver (5-Star & Positive Compliment Chips):
* **Rating Stars:** 1 to 5 Stars with gold fill animation.
* **Positive 5-Star Chips (Tap to Highlight):**
  * `[ 🏆 Super Punctual ]`
  * `[ 🚗 Smooth & Safe Driving ]`
  * `[ 🌟 Clean & Fresh Car ]`
  * `[ 💬 Pleasant Conversation ]`
  * `[ ❄️ Perfect AC & Music ]`
  * `[ 🛡️ Felt 100% Safe ]`
* **Constructive Low-Rating Chips (Triggered if $\le 3$ Stars):**
  * `[ ⏱️ Late Arrival (>10m delay) ]`
  * `[ 📱 Distracted Driving / On Phone ]`
  * `[ 🚗 Rash Speeding / Sudden Brakes ]`
  * `[ ❄️ AC Not Turned On / Unclean Car ]`
  * `[ 🚫 Unprofessional / Rude Demeanor ]`

#### 2. 📱 Driver Reviewing Rider:
* **Positive Compliments:** `[ ⏱️ At Pickup Gate on Time ]`, `[ 🤝 Polite & Respectful ]`, `[ 🚪 Careful with Car Doors ]`, `[ 🌟 Great Co-Commuter ]`.
* **Constructive Issues ($\le 3$ Stars):** `[ ⏱️ Made Driver Wait (>5m at gate) ]`, `[ 🍔 Eating / Messy in Car ]`, `[ 🚫 Slammed Door / Rude ]`, `[ 📍 Asked for Off-Route Drop ]`.

---

### 20.2 Automated Mobile Telematics & Rash Driving Engine (Zero Extra Hardware!)

The platform monitors driving safety using the driver's smartphone IMU sensors (Accelerometer + Gyroscope + GPS) at **₹0 extra hardware cost**:

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. 💰 ZERO HARDWARE COST: Uses the driver's phone's built-in sensors (Accelerometer + Gyroscope + GPS)│
│ 2. 🛑 HARSH BRAKING:     Detects dangerous emergency brake slams (G-Force < -0.30g)                   │
│ 3. 🔄 SWIFT SWERVING:    Detects erratic zig-zag lane cuts (Gyro Yaw Rate > 25°/sec)                  │
│ 4. 🚀 OVER-SPEEDING:     Flags driving > 15 km/h above corridor speed limits                          │
│ 5. 🏆 SMOOTHNESS SCORE:  Automated 0–100% Trip Score awarding bonus Karma Points for safe drivers!    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 1. Sensor Trigger Thresholds & Mathematical Models:
* **🛑 Harsh Braking Event:** Forward longitudinal deceleration $\mathbf{a_{\text{long}} < -0.30\text{g}}$ ($> 2.94\text{ m/s}^2$ in $< 1\text{ second}$). Detects panic braking due to tailgating or phone distraction.
* **🔄 Swift Swerving Event:** Gyroscope Z-axis rotational yaw rate $\mathbf{\omega_{\text{yaw}} > 25.0^\circ/\text{second}}$ combined with lateral acceleration $> 0.25\text{g}$. Detects aggressive zig-zag highway lane cutting.
* **🚀 Over-Speeding Event:** Sustained GPS velocity $\mathbf{v_{\text{gps}} > \text{SpeedLimit} + 15\text{ km/h}}$ for $> 10\text{ seconds}$.
* **🛡️ Pothole & Speed-Bump Defense Filter:** Uses a digital 2nd-order Butterworth low-pass filter (Cutoff: $2.0\text{ Hz}$) to completely ignore physical road bumps, potholes, or dropping the phone inside the car.

#### 2. Automated 0–100% Trip Smoothness Scorecard:
Every commute starts with a default score of **100% Smoothness**:

$$\text{Trip Smoothness} = 100 - (5 \times \text{HarshBrakes}) - (5 \times \text{Swerves}) - (10 \times \text{SpeedingEvents})$$

* **🟢 Score $\ge 90\%$ (Safe & Smooth Commute):** Driver earns a **"Smooth Commute Bonus" (+2.0 Bonus Karma Coins / Green Points)** and displays the **"Verified Smooth Driver" Gold Badge**.
* **🟡 Score $70\% - 89\%$ (Normal Commute):** Standard completion with regular fare payout.
* **🔴 Score $< 70\%$ (Rash Driving Alert):** Triggers private in-app safety coaching. If average score remains $< 70\%$ over 5 consecutive commutes, the driver's algorithm matching priority is automatically downgraded.

---

### 20.3 PostgreSQL Schemas: `public.ride_ratings` & `public.telematics_violations`

```sql
CREATE TABLE public.ride_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
    rater_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ratee_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    is_driver_rating BOOLEAN NOT NULL, -- TRUE if rider reviewing driver, FALSE if driver reviewing rider
    stars INT NOT NULL CHECK (stars >= 1 AND stars <= 5),
    compliment_chips TEXT[] DEFAULT '{}'::text[],
    feedback_text VARCHAR(250),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(ride_id, rater_id, ratee_id)
);

CREATE TABLE public.telematics_violations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
    driver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    violation_type VARCHAR(30) NOT NULL, -- 'harsh_braking', 'swift_swerving', 'over_speeding'
    g_force_magnitude NUMERIC(5, 3),
    yaw_rate_dps NUMERIC(5, 2),
    recorded_speed_kmh NUMERIC(5, 2),
    location_geom geometry(Point, 4326),
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ride_ratings_ratee ON public.ride_ratings(ratee_id, stars);
CREATE INDEX idx_telematics_driver ON public.telematics_violations(driver_id, recorded_at DESC);
```

---

### 20.4 Safety Trust Score (0–100) & Corporate Badges System

To establish a transparent, high-trust corporate carpooling culture, every commuter profile maintains a dynamically calculated **Safety Trust Score (0–100 Points)**:

```
+-------------------------------------------------------------------------------------------------------+
| 1. DYNAMIC TRUST FORMULA: Base score (50) + Verification Boosts + Commute Performance - Penalties     |
| 2. 4 TRUST TIERS:         🟢 Elite (90-100), 🟡 Standard (70-89), 🟠 Low (50-69), 🔴 Critical (<50)  |
| 3. 5 VISUAL BADGES:       Aadhaar Verified, Corporate Elite, Eco-Warrior, Smooth Driver, Punctual     |
+-------------------------------------------------------------------------------------------------------+
```

#### 1. Mathematical Trust Score Model:
$$\text{Trust Score} = 50 + \text{Verifications} + \text{Performance} - \text{Safety Penalties}$$

```
+-------------------------------------------------------------------------------------------------------------------+
| COMPONENT                           | POINT VALUE                          | MAX CAP / LIFECYCLE                  |
+-------------------------------------------------------------------------------------------------------------------+
| 📱 1. Phone OTP Verification        | +10 Points                           | Permanent                            |
| 🏢 2. Corporate Work Email Verified | +20 Points                           | Active while employed at company     |
| 🪪 3. Aadhaar / Govt ID Verified    | +20 Points                           | Permanent                            |
| ⭐ 4. 5-Star Reviews Exchanged       | +1 Point per 5-Star Review           | Max +15 Points                       |
| 🚗 5. High Telematics Smoothness    | +5 Points per 10 Smooth Trips (≥90%) | Max +15 Points                       |
|-------------------------------------|--------------------------------------|--------------------------------------|
| ⏱️ 6. Late Cancellation (<15 mins)  | -5 Points per late cancel            | 30-day decay window                  |
| 🛑 7. Telematics Rash Driving Flag  | -5 Points per harsh event            | 30-day decay window                  |
| ⚠️ 8. Low Rating (< 3 Stars)        | -10 Points per verified complaint    | 30-day decay window                  |
| 🚨 9. Verified SOS Fault Violation  | -50 Points                           | Immediate Account Suspension         |
+-------------------------------------------------------------------------------------------------------------------+
```

#### 2. The 4 Dynamic Trust Tiers:
* 🟢 **Elite Trust (90 – 100 Points):** Displays a glowing **Gold Shield** on profile card; receives a **+25% Match Priority Boost** in the 8:00 PM matching algorithm.
* 🟡 **Standard Trust (70 – 89 Points):** Regular verified corporate commuter.
* 🟠 **Low Trust (50 – 69 Points):** Yellow warning banner on profile; algorithm matching priority reduced by 20%.
* 🔴 **Critical Safety Risk (< 50 Points):** Account temporarily locked pending manual Super Admin KYC review.

#### 3. Visual Commuter Badges:
* `[ 🛡️ Aadhaar Verified ✅ ]`: Awarded on completing government document check.
* `[ 🏢 Corporate Elite ]`: Awarded on verifying corporate domain (`@infosys.com`).
* `[ 🌿 Eco-Warrior ]`: Awarded on preventing $> 500\text{ kg CO}_2$ through carpooling.
* `[ 🚗 Smooth Master Driver ]`: Awarded on completing 50+ commutes with $\ge 90\%$ telematics smoothness.
* `[ ⏱️ Punctuality Star ]`: Awarded on maintaining $> 95\%$ on-time gate arrival rate.

---

### 20.5 Anti-Retaliation "Double-Blind" Review Shield & Malicious Review Filter

To eliminate retaliatory revenge 1-star reviews between co-commuters:

```
[ Commute Drop-Off Verified ]
              │
              ├──► 1. Rider Submits Review (⭐ 5.0) ──► 🔒 LOCKED IN DATABASE (Hidden from Driver)
              │
              └──► 2. Driver Submits Review (⭐ 5.0) ──► 🔒 LOCKED IN DATABASE (Hidden from Rider)
                                       │
                                       ▼
[ 🔓 BOTH REVIEWS UNLOCK SIMULTANEOUSLY & BECOME PUBLIC! ]
```

* **1. Double-Blind Lock Protocol:** Ratings and feedback comments remain strictly private and encrypted in the database until **BOTH the driver and rider submit their ratings** (or **24 hours elapse**).
* **2. Automatic 24-Hour Expiry:** If one party neglects to submit a review within 24 hours, the submitted review automatically unlocks and posts publicly.
* **3. Malicious Review Anomaly Detection:** If a user awards 1-star ratings to $> 80\%$ of their commute partners, the algorithm flags their account for **"Review Sabotage Anomaly"**.
* **4. Super Admin Review Intervention:** Super Admin console provides a 1-click **`[ ⚡ Dismiss Malicious Review ]`** tool to remove fraudulent reviews and restore the victim's rating!
