# Super Admin Management System — Software Requirements Specification (SRS)
### Version 2.1 | August 2026 | Dedicated Admin Portal

---

## 1. System Overview & Purpose

The **Super Admin Management System** is a dedicated web and desktop administrative platform designed for internal platform operators, trust & safety officers, and compliance administrators of the CorporatePooling platform.

### 1.1 Key Separation of Concerns
- The Consumer Application (`CorporatePoolingApp`) runs on mobile (Flutter for Android & iOS) and handles commuter ride discovery, boarding verification, and peer wallets.
- The **Super Admin System** is an isolated administrative application with elevated privileges interacting directly with Supabase via Service Role Keys, secure database webhooks, and administrative RPC endpoints.

---

## 2. User Roles, Corporate Verification & KYC Governance
*(Corresponds to Main SRS Section 3: User Roles & Auth)*

### 2.1 User Management, Identity Audits & Ban Controls
1. **Global User Search & Profile Inspection:**
   - Search any user across mobile phone number, full name, or corporate work email.
   - Inspect account status, verification badges, vehicle details, linked family accounts, and complete ride history.
2. **Manual KYC / Government ID Audit Queue:**
   - Review pending or flagged DigiLocker / Aadhaar / Driving License verification exceptions.
   - High-resolution document inspection viewer with one-click **Approve** or **Reject with Reason** actions.
3. **Account Suspension & Blacklisting:**
   - Temporary suspension or permanent account ban across phone numbers, device hardware IDs, and corporate email addresses.
   - Immediate termination of all active ride postings and automatic refund of locked escrow coins upon account ban.

### 2.2 Corporate Domain Whitelisting & Entity Management
1. **Company Directory & Email Whitelisting:**
   - Add, edit, or disable corporate entities (e.g., *Tata Consultancy Services*, *Infosys*, *Wipro*).
   - Configure **Corporate Email Domain Whitelist rules** (e.g., auto-verifying any user registering with `@tcs.com`, `@tatamotors.com`).
2. **Domain Matching Policy:**
   - Configure domain strictness (e.g., require sub-domain match `@corp.wipro.com` vs root domain `@wipro.com`).

### 2.3 Company Manager & HR Dashboard Approval Queue
1. **Business Proof Verification:**
   - Review corporate registration documents uploaded by HR/Company Managers: Corporate Identification Number (CIN), GSTIN certificates, or official authorization letters.
2. **Privilege Grants:**
   - Approve or revoke `company_manager` dashboard privileges.
   - Assign corporate boundary scopes (e.g., manager can only view aggregated ESG statistics for their specific branch/building).

### 2.4 Family Wallet Linking Policy & Governance
1. **Family Linking Caps:**
   - Super Admin can globally configure the maximum number of family members a primary employee can link (Default: **4 sub-accounts**).
2. **Monthly Spending Limits:**
   - Configure global maximum monthly Karma Coin spending limits for linked family accounts to prevent system abuse.

---

## 3. Tech Park, Building & Node Directory
*(Corresponds to Main SRS Section 3 & 4: Location & Building Clusters)*

### 3.1 Building & IT Park Cluster Management
1. **Building Node Directory:**
   - Add, edit, or geo-fence physical IT parks (e.g., *Manyata Tech Park*, *DLF Cyber City*, *Mindspace*, *EON Free Zone*).
   - Configure central centroid coordinates and geofence radius.
2. **Multi-Company Mapping:**
   - Map multiple tenant companies to the same physical `building_id` to enable cross-company pooling.

### 3.2 Official Pickup & Drop Landmark Nodes
1. **Landmark Node Registry:**
   - Define verified campus meeting points (e.g., *Gate 1 Security Booth*, *Basement B2 Pillar 12*, *Metro Station Drop-off*).
2. **Route Snapping:**
   - Automatically snap rider pickup pins to these verified nodes to eliminate driver detour confusion.

---

## 4. Driver, Vehicle & Commute Policy Management
*(Corresponds to Main SRS Section 4: Offer a Ride)*

### 4.1 Vehicle Category & Seat Capacity Controls
1. **Seat Capacity Overrides:**
   - Dynamically adjust maximum allowed passenger limits per vehicle category without code redeployment:
     - Motorcycle / Scooter: **1 Passenger** (Strictly locked).
     - Auto-Rickshaw: **2 Passengers**.
     - Hatchback / Sedan / SUV: **1 to 4 Passengers** (Configurable).

### 4.2 Two-Wheeler Safety & Helmet Policy Toggles
1. **Spare Helmet Enforcement:**
   - Global or city-specific toggle: `ENFORCE_MANDATORY_SPARE_HELMET = TRUE`.
   - When enabled, hides all 2-wheeler rides from search results unless driver verified `has_spare_helmet = true`.

### 4.3 Karma Coin Pricing & Distance Rate Configurator
1. **Base Rate per Kilometer:**
   - Configure the base Karma Coin earn/spend rate per kilometer:
     - Four-Wheeler (Car/Sedan): Default = **2.0 Coins / km**.
     - Two-Wheeler (Bike/Scooter): Default = **1.0 Coin / km**.
2. **Dynamic Fuel Offset Multipliers:**
   - Adjust coin rates during high-demand peak traffic windows (e.g. 1.2x multiplier between 8:30 AM – 10:00 AM).

### 4.4 Recurring Commute & Nightly Auto-Match Controller
1. **Validity Duration Settings:**
   - Set maximum allowed validity for recurring rides (Default options: `1 week`, `1 month`, `3 months`).
2. **Nightly Cron Trigger Window:**
   - Configure the execution schedule for the pre-matching cron job (Default: **8:00 PM Local Time daily**).

---

## 5. Rider Booking, Escrow & Dispute Resolution
*(Corresponds to Main SRS Section 5: Find a Ride)*

### 5.1 Request Expiry & Auto-Cancellation Timeout
1. **Driver Response Window:**
   - Configure how long a driver has to accept a ride request before it auto-expires (Default: **15 minutes**; drops to **3 minutes** for *NOW ⚡* rides).
2. **Auto-Refund:**
   - Unaccepted or expired requests automatically release locked escrow coins back to the rider's balance.

### 5.2 Escrow Lock Intervention & Manual Refund Tool
1. **Stuck Escrow Management:**
   - Inspect any ride request in `'pending'` or `'in_ride'` status.
   - Admin action: **"Force Release Escrow"** (instantly returns coins to rider) or **"Force Settle to Driver"** (resolves driver compensation in network failure scenarios).

### 5.3 Booking Velocity & Abuse Protection
1. **Concurrent Request Limits:**
   - Set maximum active simultaneous ride requests allowed per rider (Default: **3 active requests** to prevent seat hoarding).

---

## 6. Dynamic Matching Algorithm & Parameter Control Console
*(Corresponds to Main SRS Section 6: Matching Algorithm)*

```
+-----------------------------------------------------------------------------------+
|               Super Admin Console: Algorithm Tuning Dashboard                     |
+-----------------------------------------------------------------------------------+
|  Matching Radii Controls:                                                         |
|  - Phase 1 Pickup Radius (Pre-departure):      [ 500  ] meters                    |
|  - Same Building Expanded Radius:              [ 1500 ] meters                    |
|  - Phase 2 Pickup Radius (Live On-Route):      [ 150  ] meters                    |
|  - Drop-off Radius Threshold:                  [ 500  ] meters                    |
|                                                                                   |
|  Mathematical Multipliers:                                                        |
|  - Urban Road Tortuosity Multiplier:           [ 1.30 ] x  (Slider: 1.0 - 2.0)    |
|                                                                                   |
|  Trust & Priority Scoring Weights (Total = 100):                                  |
|  - Proximity Weight:                           [  40  ] pts                       |
|  - Same Company Colleague Bonus:               [  30  ] pts                       |
|  - Same Building Cluster Bonus:                [  25  ] pts                       |
|  - Time Compatibility Weight:                  [  20  ] pts                       |
|  - Driver Karma Rating Weight:                 [  10  ] pts                       |
|                                                                                   |
|  Hard Safety Filter Policies:                                                     |
|  - [X] Enforce Mandatory 2-Wheeler Spare Helmet Guard                             |
|  - [X] Enforce Strict Polyline Directionality Index Check                         |
|  - [X] Enforce Women-Only Hard Cryptographic Isolation                            |
|                                                                                   |
|                    [ TEST ALGORITHM SIMULATOR ]   [ SAVE & PUBLISH CONFIG ]       |
+-----------------------------------------------------------------------------------+
```

#### Capabilities:
1. **Live Parameter Overrides:** Changes saved in the admin console update the `app_config` table in Supabase and hot-reload in the Node.js matching engine in under 5 seconds without server restarts.
2. **Algorithm Sandbox Simulator:** Admin can input sample coordinates (e.g. Pune Station to Hinjewadi) and preview how match scores and filtered candidates change before publishing parameters live.

---

## 7. Trust, Safety & Incident Response (SOS)

### 7.1 Real-Time SOS Emergency Console
1. **Live Incident Map:**
   - Active visual map flashing emergency markers whenever any commuter taps the SOS button.
   - Shows live GPS location, driver/rider profiles, vehicle plate number, and emergency contacts alerted.
2. **Dispatch Escalation:**
   - Direct integration link to emergency dispatch authorities (112) with pre-generated incident summary tokens.

### 7.2 Safety Dispute & Strike Audit Console
1. **User Reports & Strike System:**
   - Audit rider/driver reports (rash driving, rude behavior, no spare helmet).
   - Manage the **3-Strike System** (Strike 1: Warning, Strike 2: 7-day matching freeze, Strike 3: Permanent ban).

---

## 8. Karma Coin Economy & Corporate Petrol Card Reconciliation

### 8.1 Double-Entry Ledger & Supply Audit
1. **Ledger Monitor:**
   - Real-time audit of total platform Karma Coins in circulation, locked escrow volume, and historical burn/mint rates.

### 8.2 Corporate Fuel Voucher (HPCL/BPCL/IOCL) Reconciliation
1. **Subsidy Pool Management:**
   - Manage employer-funded fuel subsidy pools (HPCL, BPCL, IOCL gift card integrations).
2. **Enterprise Invoicing:**
   - Generate monthly corporate invoices based on verified employee carbon savings reports.

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
- Granular Audit Logging: Every parameter change, user ban, or escrow release is immutably logged in `admin_audit_logs` with admin UID, IP address, old value, and new value.
