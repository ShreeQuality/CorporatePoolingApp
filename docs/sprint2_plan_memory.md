# 🧠 SPRINT 2: MASTER MEMORY & ARCHITECTURAL SOURCE OF TRUTH

> **Sprint Status:** ACTIVE  
> **Target Module:** Post-Login Core Navigation Shell, Commute Cockpit & Multi-Tab Ecosystem  
> **Master Branch:** `sprint-2`  
> **Target Directory:** `lib/screens/home/`  
> **Source Documents:** `SRS_Document.md` (v3.0, Sections 4, 5, 11, 12, 18, 19), `phase3_flutter_implementation_plan.md`

---

## 1. Executive Vision & Scope

Sprint 2 establishes the primary foundation of the KarmaRide mobile application after authentication (Sprint 1). It provides a persistent, state-preserving **2-Tab Navigation Shell**, the **Dual-Mode Commute Dashboard** (Find a Ride vs. Give a Ride), the **Wallet & ESG Banner**, the **Personal Safety Hub**, and the **User Profile Management Suite**.

```text
+-----------------------------------------------------------------------------------------------+
|                                  MAIN APPLICATION SHELL                                       |
|                                                                                               |
|                         [ Dashboard Header: Safety | Notifications | Profile ]                |
|                                                                                               |
|  [ Bottom Navigation: Tab 1: Home (Dashboard) ]  |  [ Bottom Navigation: Tab 2: My Rides ]    |
+-----------------------------------------------------------------------------------------------+
```

---

## 2. Master Navigation Shell (2 Primary Tabs + Header Navigation)

The core shell (`lib/screens/home/home_shell_screen.dart`) manages a custom transparent floating bottom navigation bar wrapping an `IndexedStack` to ensure **zero state loss** during tab switching. The navigation has been refactored to focus solely on Commute tasks at the bottom, moving secondary screens (Wallet, Safety, Profile) to the Dashboard header and standalone screens.

### 🏠 Tab 1: Home / Commute Dashboard (`tabs/dashboard_tab.dart`)
* **Top Header:** Greeting ("Good morning, [Name]"), Corporate Verification Badge (`[ 🏢 Infosys ]` or `[ 👤 Public Commuter ]`), Safety Shield Icon (routes to `/safety`), Notification Bell, and Profile Avatar (routes to `/profile`).
* **`WalletSummaryBanner` (SRS §12.4):** Top glassmorphic dashboard widget displaying:
  1. **Total Spendable Karma Coins:** Sum of Corporate Grant and Personal Coins.
  2. **Monthly Employer Subsidy Grant Remaining:** Non-transferable B2B grant expiring at month-end.
  3. **Lifetime CO₂ Saved ($kg$):** Real-time SEBI Scope 3 ESG carbon accounting ($0.15\text{ kg CO}_2\text{/km}$).
  4. **Safety Trust Score Badge ($0–100$):** Double-blind peer review score with colored status aura.
* **`QuickCommuteCard`:** Time-aware predictive 1-Tap routine card (Morning office commute vs. Evening return ride home).
* **Dual Commute Mode Switcher:** Top segmented toggle between:
  * 🔍 **Find a Ride (Rider Mode)**
  * 🚗 **Give a Ride (Driver Mode)**

---

### 🚗 Tab 2: "My Rides" & Commute Roster (`tabs/my_rides_tab.dart` — SRS §19)
Manages the full lifecycle of commutes across **4 internal segmented sub-tabs**:

| Sub-Tab | Status Filters | Key Features & Interactions |
| :--- | :--- | :--- |
| **1. 🟡 ACTIVE** | `started`, `driver_en_route`, `arrived_at_pickup` | Live GPS map preview, real-time 5-minute arrival countdown timer, and 1-Tap Boarding PIN/BLE trigger. |
| **2. 🔵 UPCOMING** | `published`, `requested`, `accepted` | Confirmed bookings for today & tomorrow, companion profiles, seat counts, and "Cancel Commute" option. |
| **3. 🔁 RECURRING** | `scheduled_recurring` (Mon–Fri) | Monthly commute calendar roster, "Skip Today" button, and Vacation Pause Mode toggle. |
| **4. 📜 PAST** | `completed`, `cancelled` | Historic breadcrumb GPS route replay, transaction cost breakdown, and **Downloadable PDF SEBI ESG Carbon Certificate**. |

---

### 💰 Header Nav: Wallet, Double-Entry Ledger & ESG (`tabs/wallet_screen.dart` — SRS §12)
Manages the 100% cashless, non-fiat peer-to-peer Karma Coin economy:

* **3-Tier Balance Cards:**
  1. **Corporate Grant Coins:** Employer-subsidized monthly pool for office commutes.
  2. **Personal Karma Coins:** Earned from driving or purchased via non-fiat recharges.
  3. **Locked Escrow Coins:** Temporary lock guaranteeing active ride reservations.
* **1-Tap Colleague Transfer CTA (SRS §12.7):** Send thank-you coins to pool partners with a personalized note.
* **Double-Entry Financial Ledger:** Real-time audit trail displaying `+` Green credit earnings and `-` Red ride payments.

---

### 🛡️ Header Nav: Safety Shield & Emergency Center (`tabs/safety_screen.dart` — SRS §11)
Dedicated safety cockpit for both passengers and drivers:

* **Live SOS Emergency Trigger:** Giant red panic button broadcasting live GPS coordinates, vehicle plate, and driver/rider IDs directly to Police and Corporate Security.
* **Emergency Contacts Management:** Up to 3 verified phone numbers receiving automatic SMS panic alerts with live tracking URLs.
* **Discreet Safety Tools:**
  * **Fake Call Simulator:** Triggers an artificial incoming phone call to give commuters a graceful exit from uncomfortable situations.
  * **Ride Audio Recording Shield:** Encrypted ambient audio buffer stored strictly on-device for incident dispute resolution.
  * **24x7 Emergency Helpline:** 1-Tap direct dialer to company security desks and emergency response.

---

### 👤 Header Nav: User Profile & Identity (`tabs/profile_screen.dart` — SRS Module H)
* **Verified Identity Card:** Profile photo, legal full name (from Aadhaar DigiLocker), corporate email verification badge, and verified phone number.
* **`DriverUpgradeCard` (Critical Flow):**
  * Displayed if the user hit "Skip" during onboarding Screen 7 (Driver KYC).
  * Prominent CTA: *"Add Vehicle to Offer Rides & Earn Coins"*.
  * Tapping launches the full `DriverKycScreen` (DL & RC verification) so riders can upgrade to drivers anytime.
* **Preferences & Settings:** Notification toggles, Women-Only default preference, DPDP Data Privacy controls, and Theme settings.

---

## 3. Dual Commute Modes on Dashboard (Find vs. Give a Ride)

The Home Dashboard hosts a dedicated top-segmented toggle between the two commute operations:

```
+-----------------------------------------------------------------------------------------------+
|                       [ 🔍 Find a Ride (Rider) ]  |  [ 🚗 Give a Ride (Driver) ]              |
+-----------------------------------------------------------------------------------------------+
```

### 🔍 A. "Find a Ride" (Rider Mode Panel)
* **Origin & Destination:** Place search with Google / Ola Maps autocomplete.
* **Time Selector:** *"Leave Now"* vs. *"Schedule for Later"*.
* **Vehicle Filter Chips:** `[ Any ]`, `[ Bike ]`, `[ Scooter ]`, `[ Auto ]`.
* **Colleague Filter:** *"Same Company (Infosys) Only"* toggle.
* **Women-Only Filter:** Restricted matching for female commuters.
* **CTA Button:** `"Find rides near me"` — triggers spatial search into Sprint 4.

### 🚗 B. "Give a Ride" (Driver Mode Panel)
* **Route Corridor Input:** Start location, End location, and intermediate corridor waypoints.
* **Available Empty Seats:** `[ 1 Seat ]`, `[ 2 Seats ]`, `[ 3 Seats ]`.
* **Vehicle Selector:** `[ Bike (Helmet required) ]`, `[ Scooter ]`, `[ Auto ]`, `[ Car ]`.
* **Detour Appreciation Toggle:** Accept minor route diversions for $+3.0\text{ Coins/500m}$.
* **Recurring Commute Toggle:** 1-Tap toggle to repeat Mon–Fri.
* **CTA Button:** `"Post my route"` — publishes ride into Sprint 3.

---

## 4. Reusable Widgets Component Inventory

```
lib/screens/home/widgets/
 ├── wallet_summary_banner.dart   <-- Coins, Corporate Grant, CO2 & Trust Score
 ├── quick_commute_card.dart      <-- Time-aware 1-Tap predictive commute suggestion
 └── driver_upgrade_card.dart     <-- CTA for commuters who skipped Driver KYC
```

---

## 5. Backend Database & API Readiness (No Database Changes Needed)

All required database schemas and stored procedures are **100% operational** from Phase 1 and Phase 2 backend implementations:

| Required Data | Backend Source | API Endpoint | Schema / RPC |
| :--- | :--- | :--- | :--- |
| **User Profile & Badges** | Supabase Auth / PostgreSQL | `GET /api/v1/auth/me` | `public.users` |
| **3-Tier Wallet Balances** | Wallet Service | `GET /api/v1/wallet/balance` | `public.wallets` |
| **Active & Upcoming Rides** | Ride Controller | `GET /api/v1/rides/my` | `public.rides`, `public.ride_requests` |
| **Spatial Matching Engine** | PostGIS & In-Memory Polyline | `GET /api/v1/rides/search` | `ST_DWithin`, `ST_Distance` |
| **Push Notifications** | FCM Service | `GET /api/v1/notifications` | `public.notifications` |

---

## 6. Design System & Glassmorphic Rules

* **Background:** 100% transparent Scaffold (`backgroundColor: Colors.transparent`) allowing global `AppBackground` (Stardust Rainfall + Radial Glow) to render seamlessly.
* **Glass Panels (`GlassPanel`):**
  * `sigma: 8.0` to `12.0` backdrop blur.
  * `opacity: 0.03` to `0.08` luminous white surface.
  * `1.0px` hairline accent borders:
    * 🟡 Gold (`0xFFFFB74D`): Karma Coins & Financials.
    * 🔵 Cyan (`0xFF00E5FF`): Corporate Badges & Identity.
    * 🟢 Emerald (`0xFF00E676`): Driver Mode & Eco CO₂.
    * 🔴 Coral (`0xFFFF5252`): Safety SOS & Alerts.
* **Haptics:**
  * `HapticFeedback.lightImpact()` on tab switches and vehicle selections.
  * `HapticFeedback.mediumImpact()` on 1-Tap Commute and SOS actions.

---

## 7. State Management & Navigation Architecture

* **Router Integration:** `GoRouter` path `/home` loads `HomeShellScreen`.
* **State Preservation:** `HomeShellScreen` utilizes `IndexedStack` or `PageController` with `PageStorageKey` so that map polylines, scroll positions, and form inputs are never reset when navigating between tabs.
* **Provider Binding:** Consumes `AuthProvider` (`currentUser`, `tryAutoLogin()`) and `WalletProvider` (`karmaCoins`, `grantRemaining`).

---

*This document is permanently preserved as the active design and memory specification for Sprint 2.*
