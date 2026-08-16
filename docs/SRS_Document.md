# CorporatePoolingApp — Software Requirements Specification (SRS)
### Version 3.9 | August 2026 | Tech Stack: Flutter + Supabase (PostgreSQL & PostGIS)

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
  → DriverLiveScreen (BLE Broadcast & GPS) → Boarding Verified → Complete Ride

Rider Flow:
  FindRideScreen → RiderTimePicker → PostGIS + In-Memory Polyline Match
  → (If 0 rides: "Set Search Alert" 🔔) → RoutePreviewScreen (Drag & Snap Pins)
  → Multi-Seat Selection [1 or 2] → Send Request (Smart Escrow locked)
  → RiderLiveScreen (Live Tracking & 5-min timer) → Boarding (BLE/QR/PIN) → Drop-off
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

### 4.2 Location Picking & PostGIS Indexing
- Stored as native PostGIS 2D Point geometries (`GEOMETRY(Point, 4326)`), indexed via spatial GiST indexes.

---

### 4.3 Departure Time Modes
- **Mode A: ⚡ NOW** (Single instance, real-time discovery).
- **Mode B: 🕐 SCHEDULED** (Future departure, departure push notification).
- **Mode C: 🔄 RECURRING** (Mon–Fri fixed commute, 8:00 PM auto-match cron, per-day completion in `completion_dates[]`, and daily skip toggle in `skip_dates[]`).

---

### 4.4 1-Tap Evening Return Commute Prompt
* Automatically prompts drivers after posting a morning ride to schedule their 5:30 PM return trip in 1 second.

---

### 4.5 Driver Daily Posting Limits & Collision Detection (Max 4 Rides/Day)
* **Daily Cap:** Maximum **4 active rides per user per day** (accommodating family and corporate commute needs).
* **Destination ETA Calculation:** Stores `approx_reach_time TIME NOT NULL`.
* **Time-Overlap Collision Guard:** Blocks posting overlapping time windows for the same driver.
* **Dual-Role Collision Guard:** Prevents a user from acting as a driver during an active rider booking.

---

## 5. Core Feature: Find a Ride (Rider)

**Primary Screen:** `lib/screens/rider/find_ride_screen.dart`

---

### 5.1 Rider Route Preview & Draggable Pins (`rider_route_preview_screen.dart`)
* Renders driver's **Blue Route Polyline**.
* Rider drags **Green Pickup Pin** and **Red Drop Pin** directly onto the highway line (0m driver detour).
* Automatically recalculates distance ($km$) and Karma Coins in real-time.

---

### 5.2 Search Alerts & Multi-Seat Booking
* **Search Alerts (`search_alerts`):** Alerts rider via push notification when a matching driver posts later.
* **Multi-Seat Selection:** Supports `seats_requested = 1 or 2` (locks $N \times \text{Coins}$).

---

## 6. Matching Algorithm — Phase-Based KM/Meter Logic & Scoring Engine

**Module File:** `src/matchingAlgorithm.js` (Node.js) & `lib/services/matching_service.dart` (Dart)

* **2-Tier Funnel:** PostGIS `ST_DWithin` bounding box (< 5ms) $\to$ In-Memory Cross-Track line-segment math (12ms).
* **Phase Radii:** Phase 1 (**500m / 1500m building**) $\to$ Phase 2 (**150m live on-route**).
* **Scoring Formula (0 to 100):** Proximity (40) + Trust (30) + Time (20) + Karma (10).

---

## 7. GPS Tracking System & Live Navigation

**Primary Module:** `lib/services/gps_tracking_service.dart` & Supabase Realtime Channels

* **Cadence:** 3 to 5-second WebSocket broadcasts on `ride_locations:{ride_id}`.
* **Optimization:** $> 5\text{m}$ motion threshold + on-device Kalman filter smoothing.
* **Legal Privacy (DPDP Act):** Confirmed rider sees live moving car; **Employer HR Dashboard receives milestone text status only** (`In-Transit`, `ETA: 8:45 AM`, `Arrived`).

---

## 8. Ride Request, Acceptance Flow, Wait Timers & Commute Calendar

**Primary Modules:** `lib/screens/driver/requests_screen.dart`, `lib/screens/rider/rider_calendar_screen.dart`, `lib/screens/driver/driver_calendar_screen.dart`

* **Smart Multi-Request Escrow:** Up to 3 simultaneous driver requests, single highest fare locked, 0.1s instant auto-cancellation upon first acceptance.
* **2-Tier Driver Review:** Summary Card Mode vs Maximized Full-Screen Map Overlay.
* **Response Timers:** 3 mins (NOW) / 15 mins (Scheduled) / 2 hours (8 PM Recurring).
* **50m Arrival & 5-Minute Live Wait Timer:** Synchronized countdown on both screens.
* **Friendly Zero-Deduction No-Show:** 0 Coins deducted (100% refund); driver departs solo; empty seats recycled for live Phase 2 matching; 1-hour rider cooldown.
* **Monthly Commute Calendar UI:** Universal color codes (🟢 Green, 🟡 Yellow, ⚪ Gray, 🔴 Red) and 1-month bulk 30-day recurring booking.
* **Anti-Spam Rejection Rule:** 3 rejections in 7 days $\to$ 7-day search cooldown.
* **Smart Auto-Accept Engine:** Optional driver toggle with $\le 100\text{m}$ detour guard.

---

## 9. Hardware-Agnostic 3-Level Boarding Verification & State Machine

**Primary Modules:** `lib/services/boarding_verification_service.dart`, `lib/screens/live/driver_live_screen.dart`, `lib/screens/live/rider_live_screen.dart`

Section 9 defines the hardware-agnostic boarding verification protocol, the master ride lifecycle state machine, the infinite recurring state machine, day-wise skip mechanisms, and the comprehensive anti-fraud failure matrix.

---

### 9.1 Streamlined 3-Level Boarding Hierarchy

To guarantee 100% boarding reliability on budget Indian smartphones without NFC chips, the system implements a strict 3-tier hierarchy:

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

To eliminate database bloat and query slowdowns from duplicate rows:
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
3. **Automated Backup Suggester for Riders:**
   * When a driver skips, the rider's coins are 100% refunded and the app immediately pops up:
   * *"Rahul is taking WFH today. Here are 2 other colleagues leaving at 8:30 AM to Manyata — Tap to book!"*
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

The platform incorporates comprehensive defense controls for every potential failure, edge case, and fraud attempt:

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
