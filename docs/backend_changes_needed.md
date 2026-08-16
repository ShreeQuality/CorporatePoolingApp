# Backend Changes Needed - Corporate Pooling

This document outlines the specific changes required in the backend (`CorporatePooling` Node.js/Supabase repository) to support the competitive features finalized during our architectural planning. 

## 1. Why are we making these changes? (The 5 Strategic Reasons)

Before touching the code, it is critical to understand *why* we are implementing these specific features. These address major friction points and legal compliance issues in the Indian carpooling market:

1.  **The "Company Isolation" Trap (Building ID Logic):** If we only match people within the *exact same company*, we drastically reduce our match rate. By grouping users by **Building ID** or **Tech Park ID**, a TCS employee can securely carpool with an IBM employee in the exact same building. This maximizes ride liquidity while ensuring perfect pickup/drop-off logistics (same basement/lobby).
2.  **Crucial Safety Adoption (Women-Only Filter):** In the Indian market, female adoption of carpooling relies heavily on the ability to exclusively match with other verified female corporate employees. 
3.  **Legal Privacy Compliance (Personal SOS over HR Tracking):** Under Indian privacy laws (DPDP Act), a commute is personal time. We cannot legally share a live SOS GPS tracker with Corporate HR automatically. Therefore, the SOS button must route exclusively to **Personal Trusted Contacts (Family)** and Police (112) unless the user explicitly opts into a 24/7 Corporate Security desk.
4.  **Commuter Retention (Nightly Auto-Match):** Corporate employees commute on fixed schedules (e.g., Mon-Fri, 9 AM). Forcing them to manually post a ride every day causes churn. A nightly cron job (8:00 PM) removes this friction entirely.
5.  **Hardware Realities (BLE over NFC):** NFC is absent on most sub-₹15k Indian smartphones. We are implementing a 4-level verification system prioritizing **Bluetooth LE (BLE)** and a **Daily Karma Word** (Screen Touch) to ensure a seamless, hardware-agnostic boarding experience.

---

## 2. Specific Backend Files to Modify or Create

The following files in the `CorporatePooling` repository require updates. **No existing API routes or core functions have been modified yet.**

### A. Database Migrations (Supabase)
We need to create a new SQL migration file (e.g., `supabase/migrations/013_add_enterprise_features.sql`) to alter the existing tables:
*   **`users` table:**
    *   Add `building_id` (UUID or String)
    *   Add `gender` (Enum: Male, Female, Other)
    *   Add `emergency_contacts` (JSONB array for SOS feature)
*   **`rides` table:**
    *   Add `women_only_flag` (Boolean)
    *   Add `recurring_schedule` (JSONB - e.g., `{ days: [1,2,3,4,5], time: "09:00" }`)
    *   Add `boarding_daily_word` (String - e.g., "COFFEE")
    *   Add `boarding_ble_uuid` (String/UUID)

### B. Core Matching Algorithm
*   **`src/matchingAlgorithm.js`**
    *   **Change 1:** Add a condition that if `driver.company_id != rider.company_id`, fallback to checking if `driver.building_id == rider.building_id`.
    *   **Change 2:** If `ride.women_only_flag == true`, strictly filter out any users where `gender != 'Female'`.

### C. Ride Management & Boarding Secrets
*   **`src/routes/rides.js`**
    *   **Change 1:** When a `POST /rides` request is made, the backend must randomly generate the `boarding_daily_word` and a unique `boarding_ble_uuid` and insert them into the database alongside the ride details.

### D. New API Endpoints (To be created)
*   **`src/routes/sos.js` (NEW)**
    *   **Change 1:** Create `POST /api/sos/trigger`. This endpoint will read the user's `emergency_contacts` JSON array and trigger SMS or Push Notifications containing the live tracking link.
*   **`src/jobs/nightlyMatch.js` (NEW)**
    *   **Change 1:** Create a cron-job script (using `node-cron` or similar) that executes at 8:00 PM daily. It must query all users with active `recurring_schedule` preferences, feed them into `matchingAlgorithm.js`, and generate pre-matched rides for the following day.

---

## 3. Next Steps
The backend is currently functional with basic rides and wallets. To proceed with implementation, the recommended first step is writing the **Supabase SQL Migration** to add the new columns (`gender`, `building_id`, `emergency_contacts`), followed by updating the frontend signup screens to collect this data.
