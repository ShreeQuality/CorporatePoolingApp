# 🎯 SPRINT 2: Home & Core Shell
*Status: ACTIVE | Branch: `sprint-2`*

## Sprint Objective
Build the foundational post-login UI shell, the main dashboard for quick actions, and the user profile management screen.

---

## 1. Home Bottom Navigation (The Core Shell)
**File:** `lib/screens/home/home_shell_screen.dart`

**Requirements:**
* A master `Scaffold` that holds the `BottomNavigationBar`.
* Must handle seamless tab switching without losing the state of the individual tabs.
* **Tabs:**
  1. Home / Dashboard
  2. My Rides
  3. Wallet
  4. User Profile

---

## 2. Commute Dashboard (Tab 1)
**File:** `lib/screens/home/dashboard_tab.dart`

**Requirements:**
* **Wallet Summary Banner:** A glassmorphic top widget displaying:
  * Available Karma Coins balance.
  * Monthly Employer Grant Remaining (if applicable).
  * Lifetime CO2 saved (kg).
  * Safety Trust Score badge (0–100 scale).
* **Quick Commute Smart Card:** A 1-Tap action card (e.g., "Start Morning Commute to Manyata Tech Park").
* **Upcoming Rides Section:** A horizontal scroll or list showing approved/pending rides for today.

---

## 3. User Profile (Tab 4)
**File:** `lib/screens/profile/user_profile_tab.dart`

**Requirements:**
* **User Identity:** Display Profile Photo, Full Name (from Aadhaar), and Corporate Verification Badge.
* **Trust & Safety Metrics:** Display Trust Score and ride statistics.
* **Driver Upgrade Flow:** If the user "Skipped" Screen 7 during onboarding, provide a prominent CTA here: *"Add Vehicle to Offer Rides"*. Tapping this should open the Driver KYC flow so they can add their DL and RC at any time.
* **Settings & Preferences:** Basic list tiles for Notification settings, Emergency Contacts (SOS), and App Theme.
