# Super Admin Management System — Software Requirements Specification (SRS)
### Version 2.25 | August 2026 | Dedicated Admin Portal

---

## 1. System Overview & Purpose

The **Super Admin Management System** is a dedicated web and desktop administrative platform designed for internal platform operators, trust & safety officers, and compliance administrators of the CorporatePooling platform.

### 1.1 Key Separation of Concerns
- The Consumer Application (`CorporatePoolingApp`) runs on mobile (Flutter for Android & iOS) and handles commuter ride discovery, boarding verification, and peer wallets.
- The **Super Admin System** is an isolated administrative application with elevated privileges interacting directly with Supabase via Service Role Keys, secure database webhooks, and administrative RPC endpoints.

---

## 2. User Roles, Corporate Verification & KYC Governance
*(Corresponds to Main SRS Section 3: User Roles & Auth)*

### 2.1 User Management & Manual KYC Audit Queue
1. **Global User Search & Profile Inspection:**
   - Search any user across mobile phone number, full name, or corporate work email.
   - Inspect verification badges (Work Email, Office ID Photo, Aadhaar KYC, DL, Vehicle RC), linked family accounts, and complete ride history.
2. **Employee Physical Office ID Card Review Queue:**
   - For employees who uploaded photos of their plastic Office ID badge (due to corporate email firewall blocks), Super Admin reviews the company logo, employee name, and employee ID with 1-click **Approve** or **Reject**.
3. **Driver KYC Inspection (Side-by-Side DL + Vehicle RC):**
   - Side-by-side high-resolution image viewer displaying the driver's **Driving License** and **Vehicle RC Card**.
   - 1-Click action updates `users.dl_verified = true` and `vehicles.rc_verified = true` at **₹0 API cost**.

### 2.2 Employer Verification & Anti-Fraud Governance Console
When an enterprise HR / Company Manager registers their company, Super Admin audits the 4 mandatory business documents:

```
+-----------------------------------------------------------------------------------+
|               Super Admin Console: Employer Business Verification                 |
+-----------------------------------------------------------------------------------+
|  Company Name: [ Infosys Limited ]              Domain: [ @infosys.com ]          |
|  Manager Name: [ Rahul Sharma ]                 Manager Email: [ hr@infosys.com ] |
|                                                                                   |
|  Uploaded Documents:                                                              |
|  [ 📄 GSTIN Certificate (REG-06) ]  --> Check on Govt GST Portal (15-digit active)|
|  [ 📄 Certificate of Inc. (CIN)   ]  --> Check on Govt MCA Database (Pvt/Ltd)     |
|  [ 📄 Company Corporate PAN       ]  --> Corporate Tax ID match                   |
|  [ 📄 Signed Letter of Authority  ]  --> Confirm Signer is an active MCA Director |
|                                                                                   |
|       [ ❌ REJECT (FRAUD BAN) ]       [ ✅ APPROVE & WHITELIST DOMAIN ]            |
+-----------------------------------------------------------------------------------+
```

---

### 2.3 Employer Pending Employee Join Queue & Super Admin Override Console

Super Admin has complete, real-time visibility into **how many employees are in pending status across every corporate client**:

```
+-------------------------------------------------------------------------------------------------------------------+
| COMPANY NAME       | DOMAIN           | ACTIVE EMPLOYEES | PENDING APPROVALS | HR MANAGER CONTACT | ACTION            |
+-------------------------------------------------------------------------------------------------------------------+
| 1. Infosys Limited | @infosys.com     | 342 Verified     | 🔴 14 Pending     | hr@infosys.com     | [ 🔍 VIEW QUEUE ] |
| 2. TCS Bangalore   | @tcs.com         | 512 Verified     | 🟡 6 Pending      | admin.blr@tcs.com  | [ 🔍 VIEW QUEUE ] |
| 3. Wipro Sarjapur  | @wipro.com       | 180 Verified     | 🟢 0 Pending      | mobility@wipro.com | [ 🔍 VIEW QUEUE ] |
+-------------------------------------------------------------------------------------------------------------------+
```

#### Inside the Pending Join Inspector (`AdminCompanyManagerScreen`):
When Super Admin clicks **`[ 🔍 VIEW QUEUE ]`** on any company:
* **Pending Details:** Displays Employee Full Name, Work Email (`amit.k@infosys.com`), Employee ID (`#INF-8842`), Joined Via (Deep-Link / Code), and Pending Duration (e.g. *Pending for 48 hours*).
* **Super Admin Intervention Actions:**
  * `[ 🔔 SEND URGENT HR APPROVAL REMINDER ]`: Dispatches automated high-priority push notification and email to HR Manager to approve pending employees.
  * `[ ⚡ SUPER ADMIN FORCE APPROVE ]`: If HR Manager is unresponsive or on leave, Super Admin can emergency-approve verified domain employees with 1 click!
  * `[ ❌ SUPER ADMIN FORCE REJECT ]`: Removes fraudulent or terminated employees from the queue.

---

## 3. Tech Park, Building & Node Directory
*(Corresponds to Main SRS Section 3 & 4: Location & Building Clusters)*

### 3.1 Building & IT Park Cluster Management
1. **Building Node Directory:**
   - Add, edit, or geo-fence physical IT parks (e.g., *Manyata Tech Park*, *DLF Cyber City*, *Mindspace*, *EON Free Zone*).
   - Configure central centroid coordinates and geofence radius.
2. **Multi-Company Mapping:**
   - Map multiple tenant companies to the same physical `building_id` to enable cross-company pooling.

---

## 4. Driver, Vehicle & Commute Policy Management
*(Corresponds to Main SRS Section 4: Offer a Ride)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Driver Commute Policies & Limits       |
+-------------------------------------------------------------------+
|  Driver Daily Posting Caps:                                       |
|  - MAX_DAILY_POSTED_RIDES_PER_DRIVER:          [ 4   ] rides/day  |
|  - [X] ENFORCE_TIME_OVERLAP_COLLISION_GUARD    (Block overlap)    |
|  - [X] ENFORCE_DUAL_ROLE_COLLISION_GUARD       (Block dual role)  |
|                                                                   |
|  Vehicle Category & Capacity Limits:                              |
|  - Motorcycle / Scooter Max Passengers:        [ 1   ] (Locked)   |
|  - Auto-Rickshaw Max Passengers:               [ 2   ]            |
|  - Car / Sedan / SUV Max Passengers:           [ 3   ] (1 to 4)   |
|  - [X] ENFORCE_MANDATORY_SPARE_HELMET          (2-Wheeler rule)   |
|                                                                   |
|  Karma Coin Rates:                                                |
|  - Four-Wheeler Base Rate:                     [ 2.0 ] Coins/km   |
|  - Two-Wheeler Base Rate:                      [ 1.0 ] Coins/km   |
|                                                                   |
|                                [ SAVE POLICY ]                    |
+-------------------------------------------------------------------+
```

---

## 5. Rider Booking, Escrow, Boarding & Lifecycle Governance
*(Corresponds to Main SRS Section 8, 9 & 10: Request Flow, 3-Level Boarding & Drop-Off)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Lifecycle & ESG Governance Dashboard   |
+-------------------------------------------------------------------+
|  Boarding & Anti-Fraud Controls:                                  |
|  - BLE Proximity Signal Threshold:             [ -65 ] dBm        |
|  - Drop-off Geofence Radius:                   [ 500 ] meters     |
|  - MAX_CONSECUTIVE_SKIPS_BEFORE_PENALTY:       [ 3   ] skips      |
|                                                                   |
|  ESG Carbon Engine & Attendance Policies:                         |
|  - ESG CO2 Emission Factor:                    [ 0.15] kg CO2/km  |
|  - Tree Offset Factor:                         [ 20.0] kg CO2/tree|
|  - Soft Attendance Morning Window Start:       [06:00] AM         |
|  - Soft Attendance Morning Window End:         [11:00] AM         |
|                                                                   |
|  Competitive Feature Switches:                                    |
|  - [X] ENABLE_AUTO_RETURN_RIDE_PROMPT          (Prompt on post)   |
|  - [X] ENABLE_RIDE_SEARCH_ALERTS               (Notify riders)    |
|  - [X] ENABLE_DRIVER_AUTO_ACCEPT_TOGGLE        (Smart auto-accept)|
|  - MAX_SEATS_PER_RIDER_BOOKING:                [ 2   ] seats max  |
|                                                                   |
|  Wait Timer & No-Show Compensation:                               |
|  - Pickup Arrival Geofence Radius:             [ 50  ] meters     |
|  - Driver Free Wait Window:                    [ 5   ] minutes    |
|  - Rider No-Show Compensation to Driver:       [ 0   ] Coins      |
|                                                                   |
|  Dispute & Escrow Intervention:                                   |
|  [ ⚡ FORCE RELEASE ESCROW TO RIDER ]    [ ⚡ FORCE SETTLE TO DRIVER] |
+-------------------------------------------------------------------+
```

---

## 6. Dynamic Matching Algorithm & Parameter Control Console
*(Corresponds to Main SRS Section 6: Matching Algorithm)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Algorithm Tuning Dashboard             |
+-------------------------------------------------------------------+
|  Matching Radii Controls:                                         |
|  - Phase 1 Pickup Radius (Pre-departure):      [ 500  ] meters    |
|  - Same Building Expanded Radius:              [ 1500 ] meters    |
|  - Phase 2 Pickup Radius (Live On-Route):      [ 150  ] meters    |
|  - Drop-off Radius Threshold:                  [ 500  ] meters    |
|                                                                   |
|  Trust & Priority Scoring Weights (Total = 100):                  |
|  - Proximity Weight:                           [  40  ] pts       |
|  - Same Company Colleague Bonus:               [  30  ] pts       |
|  - Same Building Cluster Bonus:                [  25  ] pts       |
|  - Time Compatibility Weight:                  [  20  ] pts       |
|  - Driver Karma Rating Weight:                 [  10  ] pts       |
|                                                                   |
|  Hard Safety Filter Policies:                                     |
|  - [X] Enforce Mandatory 2-Wheeler Spare Helmet Guard             |
|  - [X] Enforce Strict Polyline Directionality Index Check         |
|  - [X] Enforce Women-Only Hard Cryptographic Isolation            |
|                                                                   |
|                    [ TEST ALGORITHM SIMULATOR ]   [ SAVE CONFIG ] |
+-------------------------------------------------------------------+
```

---

## 7. Trust, Safety & Incident Response (SOS)

### 7.1 Real-Time SOS Emergency Console
1. **Live Incident Map:**
   - Active visual map flashing emergency markers whenever any commuter taps the SOS button.
   - Shows live GPS location, driver/rider profiles, vehicle plate number, and emergency contacts alerted.
2. **Dispatch Escalation:**
   - Direct integration link to emergency dispatch authorities (112) with pre-generated incident summary tokens.

---

## 8. Karma Coin Economy & Corporate Prepaid Plan Management

### 8.1 Double-Entry Ledger & Supply Audit
1. **Ledger Monitor:** Real-time audit of total platform Karma Coins in circulation, locked escrow volume, and historical burn/mint rates.

### 8.2 Corporate Prepaid Commute Pools & Invoicing
1. **Prepaid Pool Management:** Monitor employer prepaid wallet balances and generate clean **Tax-Exempt B2B Commercial Invoices** (Sec 22 CGST Act - Turnover < ₹20L).
2. **Fuel Voucher Reconciliation:** Reconcile HPCL/BPCL/IOCL gift card distributions against employer-funded subsidy pools.

---

## 9. In-App Communication & Chat Governance
*(Corresponds to Main SRS Section 15: Per-Ride Chat, Masked Calling & Company Workspace Groups)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Chat & In-App Calling Governance       |
+-------------------------------------------------------------------+
|  Per-Ride Commute Communication Controls:                         |
|  - [X] REQUIRE_DRIVER_ACCEPTANCE_FOR_COMMUNICATION (Strict Gate)  |
|  - [X] ENABLE_AGORA_MASKED_VOIP_CALLS              (Zero SIM leak)|
|  - AUTO_CLOSE_RIDE_CHAT_ON_DROPOFF:                [X] TRUE       |
|                                                                   |
|  Company Workspace Chat Controls:                                 |
|  - [X] ENFORCE_SAME_COMPANY_DOMAIN_ISOLATION       (Strict Gate)  |
|  - MAX_MEMBERS_PER_ROUTE_GROUP:                    [ 50  ] members|
|  - [X] ENABLE_HR_OFFICIAL_BROADCAST_CHANNELS                      |
|  - [X] ENABLE_AUTOMATED_PROFANITY_FILTERING                       |
|                                                                   |
|              [ ⚡ VIEW LIVE CHAT AUDIT LOGS ]   [ SAVE CONFIG ]    |
+-------------------------------------------------------------------+
```

---

## 10. Push Notification & Alert Engine Governance
*(Corresponds to Main SRS Section 16: Multi-Role Push Notifications & FCM Engine)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Push Notification & Dispatch Engine    |
+-------------------------------------------------------------------+
|  FCM Dispatch & Channel Controls:                                 |
|  - [X] ENABLE_HIGH_PRIORITY_URGENT_CHANNELS        (Sound & Vibrate)|
|  - [X] ENABLE_AUTOMATED_DEEP_LINKING               (1-Tap Routing)  |
|  - FCM_TOKEN_EXPIRY_DAYS:                          [ 60  ] days     |
|  - [X] ENABLE_SUPER_ADMIN_SOS_SIREN_BROADCAST      (Emergency Alert)|
|                                                                   |
|  Dispatch Statistics:                                             |
|  - Daily Push Dispatches:                          [ 18,420 ] msgs  |
|  - Push Delivery Success Rate:                     [ 99.8%  ]       |
|                                                                   |
|              [ ⚡ BROADCAST SYSTEM-WIDE ALERT ]   [ SAVE CONFIG ]   |
+-------------------------------------------------------------------+
```

---

## 11. Core Platform Operational Governance & Tools
*(Corresponds to Main SRS Section 17.4: The 6 Administrative Super-Tools)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Core Operational Super-Tools           |
+-------------------------------------------------------------------+
|  1. 🗺️ LIVE FLEET & COMMUTE MONITOR:                              |
|     - [X] ENABLE_REALTIME_MAP_POLLING              (5s Refresh)   |
|     - OFF_ROUTE_DETOUR_THRESHOLD:                  [ 1000 ] meters|
|     - TRAFFIC_DELAY_ALERT_THRESHOLD:               [ 10   ] mins  |
|                                                                   |
|  2. 🪪 DRIVER KYC VERIFICATION PIPELINE:                          |
|     - REQUIRE_380_DPI_MINIMUM_CLARITY:             [X] TRUE       |
|     - [X] AUTO_DISPATCH_REUPLOAD_NOTIFICATION_ON_REJECT           |
|                                                                   |
|  3. ⚖️ ESCROW DISPUTE & INTERVENTION HUB:                          |
|     - MAX_DISPUTE_RESOLUTION_WINDOW:               [ 24   ] hours |
|     - [X] REQUIRE_GPS_BREADCRUMB_AUDIT_BEFORE_FORCE_SETTLE        |
|                                                                   |
|  4. 🚫 3-TIER DISCIPLINE & BAN MANAGEMENT:                         |
|     - WARNING_STRIKES_BEFORE_SUSPENSION:           [ 3    ] strikes|
|     - TEMPORARY_SUSPENSION_DURATION:               [ 7    ] days  |
|     - [X] BLACKLIST_AADHAAR_HASH_ON_PERMANENT_BAN                 |
|                                                                   |
|              [ ⚡ VIEW LIVE DISPUTE QUEUE ]   [ SAVE CONFIG ]      |
+-------------------------------------------------------------------+
```

---

## 12. Super Admin 2FA Security, Access Control & Audit Logging
*(Corresponds to Main SRS Section 17: Admin Panel, 2FA Authentication & Remote Theme System)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Security & Multi-Factor Auth (2FA)     |
+-------------------------------------------------------------------+
|  Authentication & Access Policies:                                |
|  - Super Admin 2FA Method:                     [ Google Authenticator TOTP ] |
|  - Company HR 2FA Method:                      [ Work Email Magic OTP ]      |
|  - Commuter Session Persistence:               [ 90  ] days       |
|  - Admin Session Inactivity Timeout:           [ 15  ] minutes    |
|                                                                   |
|  Dual Access Form Factors:                                        |
|  - [X] ENABLE_DESKTOP_WEB_PORTAL               (Cloudflare Pages ₹0) |
|  - [X] ENABLE_MOBILE_EXECUTIVE_MODE            (In-App Admin Tab ₹0) |
|                                                                   |
|  Remote Dynamic Theme Controls:                                   |
|  - [X] ENABLE_DYNAMIC_REMOTE_THEME_ENGINE                          |
|  - [X] PROPAGATE_REALTIME_THEME_CHANGES                           |
|                                                                   |
|              [ ⚡ EDIT HOME THEME & WALLPAPER ]   [ SAVE CONFIG ]  |
+-------------------------------------------------------------------+
```

### 12.1 Role-Based Access Control (RBAC)

| Admin Role | Permissions & Scope |
|---|---|
| **`super_admin`** | Full platform access: algorithm tuning, system policies, financial ledgers, company approvals, user ban/unban. |
| **`support_officer`** | Dispute resolution, manual KYC review, escrow unlock tool, SOS emergency monitor. |
| **`finance_admin`** | Corporate invoice generation, Karma Coin minting/burning audits, fuel voucher reconciliation. |

### 12.2 Audit Logging
- Mandatory Multi-Factor Authentication (MFA / TOTP) on all admin accounts.
- Granular Audit Logging: Every parameter change, user ban, or escrow release is immutably logged in `admin_audit_logs`.

---

## 13. Complete Super Admin Screen Inventory (The 10 Administrative Screens)

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. Admin Login & 2FA Screen          ──► Master login with Google Authenticator TOTP code             │
│ 2. Executive KPI Dashboard           ──► Real-time platform health, active carpools & coin solvency   │
│ 3. City-Wide Live Fleet Map          ──► Visual bird's-eye vector radar of all moving commutes        │
│ 4. Driver KYC Verification Queue     ──► High-res side-by-side document inspector (DL, RC, Aadhaar)   │
│ 5. B2B Company & Pool Manager        ──► Employer onboarding, HR assignment & Bank UTR pool top-ups   │
│ 6. Escrow Dispute & Resolution Hub   ──► 1-Click force refund to rider or force payout to driver      │
│ 7. User Trust & Ban Management       ──► Safety scores, 3-tier discipline (Warning, Suspend, Ban)    │
│ 8. Financial Coin Supply Ledger      ──► Platform-wide double-entry balance sheet & fuel vouchers     │
│ 9. Dynamic Remote Theme Editor       ──► Change wallpaper, festival banners & colors without app update│
│ 10. 🚨 Central SOS Emergency Command ──► Audio siren map, live GPS telemetry & Police 112 dispatch    │
├───────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 👑 TOTAL CALCULATED SUPER ADMIN SCREENS: EXACTLY 10 DEDICATED COMMAND SCREENS                         │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 13.1 Detailed Screen Breakdown & Route Specifications

```
+-------------------------------------------------------------------------------------------------------------------+
| #  | SCREEN NAME                    | FILE PATH                                   | EXACT PURPOSE & KEY CAPABILITIES |
+-------------------------------------------------------------------------------------------------------------------+
| 1. | `AdminLoginScreen`             | `lib/screens/admin/admin_login_screen.dart` | • Admin Email + Strong Password. |
|    |                                |                                             | • Google Authenticator 2FA TOTP. |
|    |                                |                                             | • Rate-limited to 3 attempts (₹0)|
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 2. | `AdminDashboardScreen`         | `lib/screens/admin/admin_dashboard.dart`    | • Executive KPIs & Realtime HUD. |
|    | (Executive Command Center)     |                                             | • Active Commutes & Coin Solvency|
|    |                                |                                             | • Metric Tons of CO₂ Saved.      |
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 3. | `AdminLiveFleetScreen`         | `lib/screens/admin/admin_live_fleet.dart`   | • City-Wide Live Carpool Map.    |
|    |                                |                                             | • Color-Coded Commute Markers    |
|    |                                |                                             |   (Green On-Track / Red Detour). |
|    |                                |                                             | • Click Car ➔ View Plate & Route.|
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 4. | `AdminKycReviewScreen`         | `lib/screens/admin/admin_kyc_review.dart`   | • Split-Screen 380 DPI Inspector.|
|    |                                |                                             | • Driving License & RC Zoomable. |
|    |                                |                                             | • 1-Click Approve / Reject Preset|
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 5. | `AdminCompanyManagerScreen`    | `lib/screens/admin/admin_company_mgr.dart`  | • B2B Employer Onboarding.       |
|    |                                |                                             | • Set Domain (@infosys.com).     |
|    |                                |                                             | • 1-Click Bank UTR Pool Recharge.|
|    |                                |                                             | • Real-Time Pending Join Queue   |
|    |                                |                                             |   (View & Force-Approve Staff).  |
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 6. | `AdminDisputeEscrowScreen`     | `lib/screens/admin/admin_disputes.dart`     | • Force Refund Escrow to Rider.  |
|    |                                |                                             | • Force Settle Fare to Driver.   |
|    |                                |                                             | • GPS Breadcrumb Replay Audit.   |
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 7. | `AdminUserTrustScreen`         | `lib/screens/admin/admin_user_trust.dart`   | • Commuter Safety Trust Lookup.  |
|    |                                |                                             | • 3-Tier Discipline Action Hub:  |
|    |                                |                                             |   1. Formal Warning Push         |
|    |                                |                                             |   2. 7-Day Temporary Suspension  |
|    |                                |                                             |   3. Permanent Blacklist Ban     |
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 8. | `AdminCoinLedgerScreen`        | `lib/screens/admin/admin_coin_ledger.dart`  | • Double-Entry Platform Balance. |
|    |                                |                                             | • Minted vs Burned Coin Supply.  |
|    |                                |                                             | • Fuel Voucher Claims Reconcile. |
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 9. | `AdminThemeEditorScreen`       | `lib/screens/admin/admin_theme_editor.dart` | • Live Remote Theme Editor.      |
|    |                                |                                             | • Wallpaper URL & Opacity Slider.|
|    |                                |                                             | • Festival Banner Uploader.      |
|    |                                |                                             | • Instant 0.05s Cloud Publish!   |
|----|--------------------------------|---------------------------------------------|----------------------------------|
| 10.| `AdminSosCommandScreen`        | `lib/screens/admin/admin_sos_command.dart`  | • 🚨 Audible Continuous Siren.   |
|    |                                |                                             | • Live GPS Incident Telemetry.   |
|    |                                |                                             | • 1-Tap Police 112 Dispatch Link.|
+-------------------------------------------------------------------------------------------------------------------+
```

---

## 14. Ratings, Compliments & Telematics Safety Governance
*(Corresponds to Main SRS Section 20: Ratings, Compliment Chips & Mobile Telematics Engine)*

```
+-------------------------------------------------------------------+
|       Super Admin Console: Telematics & Rating Governance         |
+-------------------------------------------------------------------+
|  Mobile Telematics Sensor Thresholds:                             |
|  - HARSH_BRAKING_G_FORCE_THRESHOLD:            [ -0.30 ] g        |
|  - SWIFT_SWERVING_YAW_THRESHOLD:               [ 25.0  ] deg/sec  |
|  - OVER_SPEEDING_CORRIDOR_BUFFER:              [ 15.0  ] km/h     |
|  - BUTTERWORTH_FILTER_CUTOFF:                  [ 2.0   ] Hz       |
|                                                                   |
|  Smooth Driver Rewards & Penalties:                               |
|  - MIN_SMOOTHNESS_SCORE_FOR_BONUS:             [ 90%   ]          |
|  - SMOOTH_COMMUTE_BONUS_COINS:                 [ 2.0   ] Coins    |
|  - RASH_DRIVING_DEMOTION_THRESHOLD:            [ 70%   ] avg/5ride|
|                                                                   |
|  Review & Anti-Fraud Policies:                                    |
|  - AUTO_FLAG_LOW_STAR_REVIEWS:                 [ <= 2  ] stars    |
|  - [X] ENABLE_DOUBLE_BLIND_REVIEW_LOCK         (Anti-Retaliation) |
|  - [X] ENABLE_AUTOMATED_PROFANITY_FILTER                          |
|                                                                   |
|  Trust Score & Badge Governance:                                  |
|  - MIN_TRUST_SCORE_FOR_ELITE_BADGE:            [ 90    ] points   |
|  - CRITICAL_TRUST_SCORE_LOCKOUT:               [ 50    ] points   |
|  - DOUBLE_BLIND_EXPIRY_WINDOW:                 [ 24    ] hours    |
|                                                                   |
|  Review Moderation & Badge Tools:                                 |
|  [ ⚡ DISMISS MALICIOUS 1-STAR REVIEW ]  [ ⚡ OVERRIDE TRUST SCORE ] |
|  [ ⚡ MANUALLY AWARD / REVOKE BADGE ]   [ SAVE CONFIG ]            |
+-------------------------------------------------------------------+
```
