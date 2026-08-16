# CorporatePoolingApp — Software Requirements Specification (SRS)
### Version 3.4 | August 2026 | Tech Stack: Flutter + Supabase (PostgreSQL & PostGIS)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Overview & Architecture](#2-system-overview--architecture)
3. [User Roles, Verification & Authentication](#3-user-roles-verification--authentication)
4. [Core Feature: Offer a Ride (Driver)](#4-core-feature-offer-a-ride-driver)
5. [Core Feature: Find a Ride (Rider)](#5-core-feature-find-a-ride-rider)
6. [Matching Algorithm — Phase-Based KM/Meter Logic & Scoring Engine](#6-matching-algorithm--phase-based-kmmeter-logic--scoring-engine)

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
    office_id_photo_url TEXT, -- Fallback photo verification
    office_id_verified BOOLEAN DEFAULT FALSE,
    company_id UUID REFERENCES public.companies(id),
    building_id UUID REFERENCES public.buildings(id),
    primary_account_id UUID REFERENCES public.users(id), -- Family wallet link
    aadhaar_verified BOOLEAN DEFAULT FALSE,
    aadhaar_masked_number VARCHAR(20), -- e.g. "XXXX-XXXX-8421"
    dl_verified BOOLEAN DEFAULT FALSE,
    dl_photo_url TEXT,
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

---

### 4.1.1 Driver Registration: Unified DL & Vehicle RC Verification (₹0 Workflow)

**Screen:** `lib/screens/driver/add_vehicle_screen.dart`

To register as a driver, the user completes a single unified form in under 60 seconds with **zero third-party government API costs**:

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

#### Step-by-Step Flow:
1. **Frontend Regex Validation (₹0):** Vehicle number format is validated instantly in Dart (`^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$`).
2. **Dual Photo Upload:** Driver snaps a photo of their **Driving License (DL)** and **Vehicle RC Card**. Files are uploaded to Supabase Storage (`driver-documents/`).
3. **Database Insertion:** Inserts record in `public.vehicles` with `rc_verified = false` and updates user with `dl_verified = false`.
4. **Super Admin 1-Click Verification (₹0):** Both photos appear side-by-side in the Super Admin KYC Audit Queue for 2-second visual verification and approval.
5. **Instant Badge Activation:** Once approved, the user receives the **"Verified Driver"** badge and can start posting rides immediately.

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
- **Configuration:** Days of week, fixed departure time, validity duration (`1 week`, `1 month`, `3 months`), skip today toggle.
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

CREATE INDEX idx_rides_from_location ON public.rides USING GIST(from_location);
CREATE INDEX idx_rides_to_location ON public.rides USING GIST(to_location);
CREATE INDEX idx_rides_route_geometry ON public.rides USING GIST(route_geometry);
```

---

## 5. Core Feature: Find a Ride (Rider)

**Primary Screen:** `lib/screens/rider/find_ride_screen.dart`

The Rider flow enables corporate employees to discover drivers travelling on identical commute corridors.

---

### 5.1 Rider Search Flow & Interactive Route Preview

1. **Search Criteria Input:** Rider specifies pickup location, drop location, departure window, and optional "Women-Only" safety toggle.
2. **PostGIS + In-Memory Evaluation:** Server filters candidate rides and computes compatibility scores (Section 6).
3. **Interactive Route Map Preview (`rider_route_preview_screen.dart`):**
   - Rider taps any matched driver card.
   - The driver’s full route polyline renders on the map (blue corridor).
   - Rider's proposed pickup pin (green) and drop pin (red) appear snapped to the driver's route.
   - **Pickup Landmark Adjustment:** Rider can fine-tune / drag their pickup pin to a convenient roadside node (e.g., "Gate 2 Bus Stop") directly on the driver's path to minimize driver detour.
4. **Request Submission & Escrow Lock:** Rider taps "Confirm Request", locking required Karma Coins in escrow.
5. **Driver Review & Decision (`requests_screen.dart`):**
   - Driver receives push notification with rider profile and requested pickup point.
   - Driver taps **Accept** (locks seat, updates request to `accepted`) or **Reject** (instantly releases locked coins back to rider).

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
    verification_method_used VARCHAR(30), -- 'ble_proximity', 'daily_word_touch', 'qr_code', 'pin'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ride_requests_ride_id ON public.ride_requests(ride_id);
CREATE INDEX idx_ride_requests_rider_id ON public.ride_requests(rider_id);
```

---

## 6. Matching Algorithm — Phase-Based KM/Meter Logic & Scoring Engine

**Module File:** `src/matchingAlgorithm.js` (Node.js) & `lib/services/matching_service.dart` (Dart)

The matching algorithm is the core computational engine of CorporatePoolingApp. It executes an ultra-fast, zero-map-API-cost two-tier spatial evaluation.

---

### 6.1 The 2-Tier Hybrid Funnel Architecture

```
[ 10,000 Potential City Rides in Database ]
                      │
                      ▼
[ Tier 1: PostGIS Server-side Spatial Pre-Filter ]
  • Uses spatial GiST index (`ST_DWithin`) with a dynamic Bounding Box.
  • Discards 95% of geographically irrelevant rides in < 5ms.
                      │
                      ▼
[ Tier 2: In-Memory Cross-Track Polyline Matcher ]
  • Node.js / Dart V8 in-memory engine executes line-segment vector math.
  • Checks dynamic Phase radii, directionality, and corporate trust scoring.
  • Execution Time: ~12 milliseconds (₹0 map API cost).
                      │
                      ▼
[ Top Ranked Matches Displayed to Rider (Sorted by Score 0–100) ]
```

---

### 6.2 Mathematical Foundation & Algorithmic Fixes

#### A. Haversine Great-Circle Distance
Computes raw spherical distance between two coordinate pairs $(lat_1, lng_1)$ and $(lat_2, lng_2)$ in meters:

$$\Delta lat = (lat_2 - lat_1) \cdot \frac{\pi}{180}, \quad \Delta lng = (lng_2 - lng_1) \cdot \frac{\pi}{180}$$

$$a = \sin^2\left(\frac{\Delta lat}{2}\right) + \cos\left(lat_1 \cdot \frac{\pi}{180}\right) \cdot \cos\left(lat_2 \cdot \frac{\pi}{180}\right) \cdot \sin^2\left(\frac{\Delta lng}{2}\right)$$

$$d = 2 \cdot R \cdot \arcsin(\sqrt{a}) \quad \text{where } R = 6,371,000\text{ meters}$$

#### B. Cross-Track Line-Segment Projection (Fixes Discrete Point Gap)
Rather than checking distance strictly to discrete waypoints $P_i$, the algorithm projects the rider's coordinate $R$ orthogonally onto the vector segment between road points $A$ and $B$:

$$\vec{v} = B - A, \quad \vec{u} = R - A$$

$$t = \text{clamp}\left(\frac{\vec{u} \cdot \vec{v}}{\|\vec{v}\|^2}, 0, 1\right)$$

$$\text{Closest Point on Road } P_{\text{closest}} = A + t \cdot \vec{v}$$

$$\text{Distance} = \text{Haversine}(R, P_{\text{closest}})$$

#### C. Urban Road Tortuosity Multiplier ($1.3\times$)
Estimates actual driving distance through Indian city street networks without invoking paid Directions APIs:

$$D_{\text{road}} \approx D_{\text{haversine}} \times 1.3$$

---

### 6.3 Phase-Aware Dynamic Radii (Meter-wise Logic)

The search tolerance adapts dynamically based on the driver's operational state:

| Matching Phase | Driver Ride Status | Pickup Distance Threshold | Drop-off Distance Threshold | Rationale |
|---|---|---|---|---|
| **Phase 1: Pre-Departure** | `posted` / `scheduled` | **500 meters**<br>*(Expanded to **1,500m** if `building_id` matches)* | **500 meters** | Driver is stationary at home/desk and can easily accommodate a minor route adjustment. |
| **Phase 2: Live On-Route** | `started` / `in_progress` | **150 meters** | **300 meters** | Driver is moving in traffic at 40 km/h; avoids dangerous U-turns, flyover misses, and sudden lane cuts. |

---

### 6.4 Directionality & Backward Route Guard

To prevent matching a rider traveling in the opposite direction along a shared bidirectional road:
1. The algorithm finds the polyline segment index nearest to Rider Pickup ($\text{Index}_{\text{pickup}}$).
2. The algorithm finds the polyline segment index nearest to Rider Drop ($\text{Index}_{\text{drop}}$).
3. **Hard Constraint:** $\text{Index}_{\text{pickup}} < \text{Index}_{\text{drop}}$.
4. If $\text{Index}_{\text{pickup}} \ge \text{Index}_{\text{drop}}$, the match is **immediately rejected (Score = 0)**.

---

### 6.5 Trust & Priority Scoring Formula (0 to 100 Points)

Every candidate passing the geometric and directional filters is assigned a composite score computed entirely in-memory:

$$\text{Total Match Score} = S_{\text{proximity}} (40) + S_{\text{trust}} (30) + S_{\text{time}} (20) + S_{\text{karma}} (10)$$

#### Component Breakdown:

1. **Proximity Score ($S_{\text{proximity}}$, Max 40 Pts):**
   $$S_{\text{proximity}} = 40 \times \left(1 - \frac{d_{\text{pickup}} + d_{\text{drop}}}{2 \times \text{MaxRadius}}\right)$$

2. **Corporate Trust Score ($S_{\text{trust}}$, Max 30 Pts):**
   - **Same Company Colleague** (`driver.company_id == rider.company_id`): **+30 Points**
   - **Same Building / Tech Park Hub** (`driver.building_id == rider.building_id`): **+25 Points**
   - **Verified Corporate (Other Tech Park)**: **+15 Points**
   - **Verified Public User (Aadhaar / DL)**: **+10 Points**

3. **Time Compatibility Score ($S_{\text{time}}$, Max 20 Pts):**
   - $\Delta \text{Time} \le 5\text{ mins}$: **+20 Points**
   - $\Delta \text{Time} \le 15\text{ mins}$: **+10 Points**
   - $\Delta \text{Time} > 15\text{ mins}$: **+0 Points**

4. **Karma Punctuality & Driver Rating ($S_{\text{karma}}$, Max 10 Pts):**
   $$S_{\text{karma}} = 2 \times \text{DriverRating (0.0 to 5.0)}$$

*Note: The raw numerical score is strictly internal. The frontend UI maps high scores to intuitive visual badges (`Colleague`, `Same Building`, `Top Rated`).*

---

### 6.6 Hard Exclusion Safety & Logic Filters

Before scoring, candidate rides must pass **4 mandatory gates**:

```
[ Candidate Ride ] ──► [ 1. Women-Only Check ] ──► [ 2. Directionality Check ]
                                                            │
[ Passed to Scoring ] ◄── [ 4. Seat Capacity ] ◄── [ 3. 2-Wheeler Helmet ]
```

1. **Women-Only Filter:** If Rider requested Female-only, strictly discard male drivers.
2. **Directionality Check:** Hard reject if $\text{Index}_{\text{pickup}} \ge \text{Index}_{\text{drop}}$.
3. **Two-Wheeler Helmet Rule:** If `vehicle_type` is Bike/Scooter, hard reject unless `has_spare_helmet = true`.
4. **Capacity Check:** Hard reject if `seats_available < seats_requested`.

---

### 6.7 Complete Node.js Matching Implementation Reference

```javascript
/**
 * CorporatePooling In-Memory Matching Engine
 * Version 3.4 | Production Zero-API-Cost Matcher
 */

function distanceMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

function getClosestPointOnSegment(pLat, pLng, aLat, aLng, bLat, bLng) {
  const dx = bLng - aLng;
  const dy = bLat - aLat;
  if (dx === 0 && dy === 0) return { lat: aLat, lng: aLng, t: 0 };
  
  let t = ((pLng - aLng) * dx + (pLat - aLat) * dy) / (dx * dx + dy * dy);
  t = Math.max(0, Math.min(1, t));
  return { lat: aLat + t * dy, lng: aLng + t * dx, t };
}

export function matchRiderToRide(ride, riderQuery, config) {
  // Gate 1: Hard Exclusion - Women-Only Filter
  if (riderQuery.womenOnly && (!ride.women_only_flag || ride.driver_gender !== 'female')) {
    return { isMatch: false, reason: 'WOMEN_ONLY_RESTRICTION' };
  }

  // Gate 2: Hard Exclusion - 2-Wheeler Helmet Guard
  if (['bike', 'scooter'].includes(ride.vehicle_type) && !ride.has_spare_helmet) {
    return { isMatch: false, reason: 'NO_SPARE_HELMET' };
  }

  // Gate 3: Hard Exclusion - Capacity Check
  if (ride.seats_available < (riderQuery.seatsRequested || 1)) {
    return { isMatch: false, reason: 'NO_SEATS_AVAILABLE' };
  }

  const isLive = ['started', 'in_progress'].includes(ride.ride_status);
  const isSameBuilding = riderQuery.buildingId && ride.building_id === riderQuery.buildingId;
  
  // Phase-aware Dynamic Radii
  const maxPickupRadius = isLive 
    ? config.phase2_pickup_radius // 150m
    : (isSameBuilding ? config.phase1_same_building_radius : config.phase1_pickup_radius); // 1500m vs 500m
  const maxDropRadius = isLive ? config.phase2_drop_radius : config.phase1_drop_radius; // 300m vs 500m

  const points = ride.route_points;
  let minPickupDist = Infinity;
  let minDropDist = Infinity;
  let pickupIndex = -1;
  let dropIndex = -1;

  for (let i = 0; i < points.length - 1; i++) {
    const pA = points[i];
    const pB = points[i + 1];

    // Cross-track line-segment evaluation
    const closestPickup = getClosestPointOnSegment(riderQuery.pickupLat, riderQuery.pickupLng, pA.lat, pA.lng, pB.lat, pB.lng);
    const dPickup = distanceMeters(riderQuery.pickupLat, riderQuery.pickupLng, closestPickup.lat, closestPickup.lng) * config.urban_tortuosity_multiplier;

    if (dPickup < minPickupDist) {
      minPickupDist = dPickup;
      pickupIndex = i;
    }

    const closestDrop = getClosestPointOnSegment(riderQuery.dropLat, riderQuery.dropLng, pA.lat, pA.lng, pB.lat, pB.lng);
    const dDrop = distanceMeters(riderQuery.dropLat, riderQuery.dropLng, closestDrop.lat, closestDrop.lng) * config.urban_tortuosity_multiplier;

    if (dDrop < minDropDist) {
      minDropDist = dDrop;
      dropIndex = i;
    }
  }

  // Gate 4: Hard Exclusion - Directionality Guard
  if (pickupIndex >= dropIndex) {
    return { isMatch: false, reason: 'REVERSE_DIRECTION' };
  }

  if (minPickupDist > maxPickupRadius || minDropDist > maxDropRadius) {
    return { isMatch: false, reason: 'OUT_OF_RADIUS' };
  }

  // Scoring Calculation (0 to 100)
  const proximityScore = Math.max(0, 40 * (1 - (minPickupDist + minDropDist) / (maxPickupRadius + maxDropRadius)));
  
  let trustScore = 10;
  if (ride.driver_company_id && ride.driver_company_id === riderQuery.companyId) {
    trustScore = 30; // Same Company
  } else if (isSameBuilding) {
    trustScore = 25; // Same Building
  } else if (ride.driver_is_corporate) {
    trustScore = 15;
  }

  const timeDiffMins = Math.abs(ride.depart_timestamp - riderQuery.targetTimestamp) / (60 * 1000);
  const timeScore = timeDiffMins <= 5 ? 20 : (timeDiffMins <= 15 ? 10 : 0);
  const karmaScore = Math.min(10, (ride.driver_rating || 5.0) * 2);

  const totalScore = Math.round(proximityScore + trustScore + timeScore + karmaScore);

  return {
    isMatch: true,
    matchScore: totalScore,
    pickupDistanceMeters: Math.round(minPickupDist),
    dropDistanceMeters: Math.round(minDropDist),
    isSameBuilding,
    isSameCompany: ride.driver_company_id === riderQuery.companyId
  };
}
```
