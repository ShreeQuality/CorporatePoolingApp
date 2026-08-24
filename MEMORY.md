# 🧠 PROJECT MEMORY & CORE ARCHITECTURE
*This file serves as the permanent "Source of Truth" for AI context. It contains all major architectural decisions and business logic discussed since the beginning of the project.*

## 1. Project Overview
* **Name:** Corporate Pooling App
* **Architecture:** Dual-Repo System
  * `CorporatePoolingApp`: Frontend (Flutter)
  * `CorporatePooling`: Backend API (Node.js / Express) + Database (Supabase / PostgreSQL)
* **Core Business Model:** Social Carpooling / Passenger Matching. The platform operates on a **subscription/membership revenue model**, NOT a per-trip commission (to avoid being legally classified as a transport aggregator like Ola/Uber).

## 2. The 5 User Types & KYC Logic (Sprint 1 Finalized)
We completely revamped the onboarding flow to prioritize speed and match industry standards (like Quick Ride / sRide):

1. **Pure Rider (No Vehicle):** 
   * Requires: Aadhaar KYC only.
   * Can hit "Skip" on the Driver KYC screen.
2. **Private Car/Bike Driver (White Board):** 
   * Requires: Aadhaar + Driving License (DL) + Vehicle RC + Vehicle Photo.
3. **Auto / Cab Passenger (Commercial Vehicle Sharer):** 
   * Requires: Aadhaar + Vahan Commercial Plate verification. (They do NOT need to upload DL/RC because they are passengers sharing empty seats, not the driver).
4. **Corporate Employee:**
   * Requires: Work Email Domain Verification + Employer HR Real-Time Approval + Aadhaar KYC.
5. **Corporate Employer (HR / Admin):**
   * Requires: GSTIN + CIN + Letter of Authority (LOA) for B2B prepaid wallet access.

## 3. Core KYC Engineering Decisions
* **Aadhaar:** Uses DigiLocker Webview (Setu/Cashfree) + Selfie Liveness Face Match.
* **DL & RC:** Uses real-time Sarathi and Vahan APIs.
* **Non-Blocking Safety Rules:** To maximize onboarding conversion, **Insurance Expiry, PUC Expiry, and RC Owner Mismatches are INFORMATIVE WARNINGS ONLY.** They do not block the user from proceeding (matching Quick Ride standard).
* **Storage:** All photos (Selfie, DL, RC) are uploaded to Cloud Storage. The PostgreSQL database only stores the URL paths, never the raw image files.

## 4. Backend Database State (Supabase)
* **Database Phase:** Base architecture completed. Sprint 1 Gap Analysis applied.
* **Sprint 1 Schema Updates:** 
  * `users` table added: `date_of_birth`, `home_city`, `selfie_photo_url`, `is_driver` (Boolean).
  * `vehicles` table added: `fuel_type`, `seating_capacity`, `insurance_expiry_date`, `puc_expiry_date`, `vehicle_exterior_photo_url`.
* **Sprint 1 API Routes:** 
  * `POST /api/v1/auth/invite-hr` (Employee-Led B2B Lead Generator. Blocks unauthorized domains).
  * `POST /api/v1/kyc/vahan` (Securely calls Vahan and saves fuel/capacity data).
* **Security:** Row-Level Security (RLS) is strictly enforced on all tables. (e.g., Users can only query their own wallets).
* **Key Tables:** `users`, `vehicles`, `rides`, `ride_requests`, `wallets`, `coin_transactions`.
* **Advanced Logic:** Uses Atomic RPC stored procedures (`complete_ride`, `reconcile_stuck_escrow`) and PostgreSQL Row Locks (`FOR UPDATE`) to prevent race conditions during Karma Coin wallet transactions.

## 5. Current Development State
* **Completed:** Sprint 1 (Screens 1 through 7 - Auth & Onboarding). Handled completely on the Frontend.
* **Active:** Sprint 2 (Home & Core Shell). 
* **Next Steps Reference:** See `docs/Sprint_2_Plan.md` for current active tasks.
