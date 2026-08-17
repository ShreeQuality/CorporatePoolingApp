# Super Admin Management System — Software Requirements Specification (SRS)
### Version 2.9 | August 2026 | Dedicated Admin Portal

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
1. **Prepaid Pool Management:** Monitor employer prepaid wallet balances and generate automated **18% GST B2B Tax Invoices** (SAC 9984).
2. **Fuel Voucher Reconciliation:** Reconcile HPCL/BPCL/IOCL gift card distributions against employer-funded subsidy pools.

---

## 9. Security, Access Control & Audit Logging

### 9.1 Role-Based Access Control (RBAC)

| Admin Role | Permissions & Scope |
|---|---|
| **`super_admin`** | Full platform access: algorithm tuning, system policies, financial ledgers, company approvals, user ban/unban. |
| **`support_officer`** | Dispute resolution, manual KYC review, escrow unlock tool, SOS emergency monitor. |
| **`finance_admin`** | Corporate invoice generation, Karma Coin minting/burning audits, fuel voucher reconciliation. |

### 9.2 Audit Logging
- Mandatory Multi-Factor Authentication (MFA / TOTP) on all admin accounts.
- Granular Audit Logging: Every parameter change, user ban, or escrow release is immutably logged in `admin_audit_logs`.
