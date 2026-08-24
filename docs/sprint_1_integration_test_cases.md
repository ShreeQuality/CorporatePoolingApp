# Sprint 1 Integration Test Cases
*Covers all Backend (Node.js/Supabase) and Frontend (Flutter) updates made during Phase 1, 2, and 3 Integration.*

## 1. Backend API Test Cases (Node.js)

### TC-B1: Corporate Registration - Known Domain
* **Endpoint:** `POST /api/v1/auth/register-corporate`
* **Payload:** `{ "email": "user@known-company.com" }`
* **Expected Result:** Status `200 OK`. OTP is dispatched.

### TC-B2: Corporate Registration - Unknown Domain (B2B Trigger)
* **Endpoint:** `POST /api/v1/auth/register-corporate`
* **Payload:** `{ "email": "user@unknown-startup.com" }`
* **Expected Result:** Status `404 Not Found`. Response body contains `action: 'require_hr_email'`.

### TC-B3: B2B Employee-Led HR Invite
* **Endpoint:** `POST /api/v1/auth/invite-hr`
* **Payload:** `{ "hr_email": "hr@unknown-startup.com", "company_domain": "unknown-startup.com" }`
* **Expected Result:** Status `200 OK`. Console logs the dynamic Trial Days (e.g., "Sending 30-Day Free Trial"). Message returns "We have sent an invitation...".

### TC-B4: Update Profile (Aadhaar Hand-off)
* **Endpoint:** `PATCH /api/v1/auth/profile`
* **Headers:** `Authorization: Bearer <JWT>`
* **Payload:** `{ "date_of_birth": "15/08/1996", "home_city": "Bengaluru" }`
* **Expected Result:** Status `200 OK`. The `users` table in PostgreSQL is successfully updated with the new demographic data.

### TC-B5: Vahan RC Verification
* **Endpoint:** `POST /api/v1/kyc/vahan`
* **Headers:** `Authorization: Bearer <JWT>`
* **Payload:** `{ "vehicle_number": "KA01EV1234" }`
* **Expected Result:** Status `200 OK`. 
  * Mock logic correctly detects 'EV' and sets `fuel_type: 'EV'`.
  * The `vehicles` table is updated/inserted with `seating_capacity: 4` and expiry dates.
  * The `users` table is updated to `is_driver: true`.

---

## 2. Frontend UI Test Cases (Flutter)

### TC-F1: Corporate Verify - Unknown Domain Modal Trigger
* **Pre-condition:** User is on Screen 5 (Corporate Verify).
* **Action:** User enters an unwhitelisted email (e.g., `test@newcompany.com`) and taps "Send Magic OTP".
* **Expected Result:** The OTP Dispatch animation stops. The "Company Not Found" Glassmorphism modal appears, asking for the HR's email address.

### TC-F2: Corporate Verify - Submitting B2B Lead
* **Pre-condition:** "Company Not Found" modal is visible.
* **Action:** User enters `hr@newcompany.com` and taps "Send Invite".
* **Expected Result:** The submit button shows a loading spinner. Upon success, the modal dismisses, and a Green Snackbar appears: "Invite sent to HR!".

### TC-F3: Aadhaar KYC - Triggering Backend Save
* **Pre-condition:** User completes Aadhaar OCR/DigiLocker on Screen 6.
* **Action:** User taps the "Enter Dashboard" button.
* **Expected Result:** The app silently calls `authProvider.updateProfile()` and awaits the backend confirmation before navigating.

### TC-F4: Progressive Onboarding Navigation
* **Pre-condition:** User completes Aadhaar KYC.
* **Action:** User taps the "Enter Dashboard" button.
* **Expected Result:** The app skips the Driver/Vehicle KYC screen entirely and executes `Navigator.pushReplacementNamed('/home')`, placing the user directly into the active app shell.

---

## 3. Database Integrity Tests (Supabase)

### TC-D1: Aadhaar Schema Persistence
* **Action:** Query the `users` table after TC-F3.
* **Expected Result:** `date_of_birth`, `home_city`, and `selfie_photo_url` are properly populated and not null.

### TC-D2: Vahan Schema Persistence
* **Action:** Query the `vehicles` table after TC-B5.
* **Expected Result:** `fuel_type`, `seating_capacity`, `insurance_expiry_date`, and `rc_verified` (boolean = true) are properly populated.

### TC-D3: Role Flag Upgrade
* **Action:** Check the `users.is_driver` boolean after Vahan verification.
* **Expected Result:** `is_driver` successfully toggles from `false` (default) to `true`.
