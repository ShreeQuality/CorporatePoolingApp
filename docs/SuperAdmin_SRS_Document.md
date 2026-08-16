# Super Admin Management System — Software Requirements Specification (SRS)
### Version 2.0 | August 2026 | Dedicated Admin Portal

---

## 1. System Overview & Purpose

The **Super Admin Management System** is a dedicated web and desktop administrative platform designed for internal platform operators, trust & safety teams, and compliance officers of the CorporatePooling platform.

### 1.1 Key Separation of Concerns
- The Consumer Application (`CorporatePoolingApp`) runs on mobile (Flutter for Android & iOS) and handles commuter ride discovery, boarding verification, and peer wallets.
- The **Super Admin System** is an isolated administrative application with elevated privileges interacting directly with Supabase via Service Role Keys and Administrative RPC endpoints.

---

## 2. Core Functional Modules

### 2.1 Corporate Entity & Manager Verification Module
1. **Company Onboarding Review:**
   - Super admin reviews company registration requests submitted by HR/Company Managers.
   - Verifies Company GSTIN / CIN / Certificate of Incorporation against official MCA (Ministry of Corporate Affairs) records.
   - Configures corporate email domain whitelisting (e.g., auto-verifying all `@tcs.com` or `@wipro.com` registrations).
2. **Manager Approval:**
   - Approves or rejects `company_manager` accounts.
   - Assigns administrative boundaries (e.g., manager can only view ESG reports for their specific registered branch/building).

### 2.2 Tech Park & Building Cluster Management
1. **Building Node Directory:**
   - Add, edit, or geo-fence IT parks (e.g., Manyata Tech Park, DLF Cyber City, Mindspace).
   - Configure **Official Meeting / Pickup Nodes** (Gate 1, Basement B2 Pillar 10, Metro Station Drop-off) to ensure drivers and riders meet at accessible, legal spots.
2. **Cluster Mapping:**
   - Map multiple companies to the same `building_id` to enable cross-company pooling.

### 2.3 Dynamic Matching Algorithm & Parameter Control Console (NEW)

The Super Admin has complete, hot-reloading control over the platform's matching math and thresholds without requiring backend code deployments:

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
1. **Live Parameter Overrides:** Changes saved in the admin console update the `app_config` table in Supabase and hot-reload in the Node.js matching engine in under 5 seconds.
2. **Algorithm Sandbox Simulator:** Admin can input sample coordinates (e.g. Pune Station to Hinjewadi) and preview how match scores change before publishing parameters live to production.

---

### 2.4 Trust, Safety & Fraud Prevention
1. **Government ID / Aadhaar Manual Audit Queue:**
   - Review flagged DigiLocker / Aadhaar / Driving License verification exceptions.
   - Audit rejected verification attempts.
2. **SOS Emergency Monitor & Incident Escalation:**
   - Real-time incident console showing any triggered SOS alerts across active trips.
   - Displays live GPS coordinates, vehicle registration numbers, and driver/rider identities.
   - Direct integration link to emergency dispatch authorities (112).
3. **Safety Dispute Resolution:**
   - Manage user reports (e.g., no helmet provided on bike ride, rash driving, off-route deviations).
   - Temporary suspension or permanent blacklisting of users across phone numbers and corporate emails.

### 2.5 Karma Coin Economy & Corporate Petrol Card Subsidies
1. **Double-Entry Ledger Audit:**
   - Monitor total platform Karma Coins in circulation, locked escrow volume, and transaction history.
2. **Corporate Voucher / Petrol Card Reconciliation:**
   - Manage employer-funded fuel subsidy pools (HPCL, BPCL, IOCL gift card integration).
   - Approve enterprise invoice generation based on company commuter carbon offset reports.

---

## 3. Security, Access Control & Compliance

### 3.1 Role-Based Access Control (RBAC)

| Admin Role | Permissions |
|---|---|
| **`super_admin`** | Full access: algorithm tuning, system settings, financial ledgers, company approvals, user ban/unban. |
| **`support_officer`** | Dispute resolution, user identity verification review, SOS emergency monitor. |
| **`finance_admin`** | Corporate invoice generation, Karma Coin minting/burning audits, fuel card reconciliation. |

### 3.2 Security Architecture
- Mandatory Multi-Factor Authentication (MFA / TOTP) on all admin accounts.
- Granular Audit Logging (`admin_audit_logs` table recording IP address, timestamp, and modified records for every action).
- Zero plain-text storage of sensitive government documents.
