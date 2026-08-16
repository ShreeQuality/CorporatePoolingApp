# Implementation Plan - CorporatePoolingApp Architecture

We are building the complete production features for **CorporatePoolingApp** based on our finalized product decisions.

## Proposed Components & Architecture

### 1. Data Models & Database Extensions
- **`user_model.dart`**: Add family account links, primary/family wallet distinction, Aadhaar verification flags, vehicle type (`bike`, `scooter`, `car`), and helmet availability.
- **`ride_model.dart`**: Add vehicle type, helmet flag, dynamic ride PIN/secret word, BLE secret UUID, and recurring schedule attributes.
- **`family_wallet_model.dart`**: Model for family members sharing the primary driver's Karma Coin pool.
- **`building_model.dart`**: Integrate Building ID / Tech Park ID logic to allow matching across different companies in the same physical building.
- **Safety & Compliance**: Add `gender` tracking for a "Women-Only" match filter, and personal `emergency_contacts` for the SOS feature (never sharing with HR without explicit opt-in).
- **Auto-Match Scheduler**: Add recurring schedule preferences (e.g., Mon-Fri 9:00 AM) to allow the backend to cron-job auto-match users at 8:00 PM the night before.

---
### 2. Multi-Level Boarding & Verification Engine
Implement the 4-level verification system for smooth, zero-cab-app ride starting:
1. **Level 1: Bluetooth LE / Proximity Auto-Connect**: Uses BLE scan/advertise matching against secret trip UUIDs.
2. **Level 2: Virtual Screen Touch ("Daily Karma Word")**: Secret passcode word (e.g. "COFFEE", "KARMA") + Touch Animation + Audio Beep + Haptic Vibration.
3. **Level 3: Dynamic QR Scanner**: Fast optical fallback.
4. **Level 4: In-App 4-Digit Secret PIN**: 100% emergency backup.

---

### 3. Family Karma Wallet & Sharing Screen
- **Family Wallet UI**: Allow primary drivers to link family members (spouse, children) to their shared Karma Coin balance.
- **Family Usage History**: Track coins earned by the driver and used by family members for free local commutes.

---

### 4. Vehicle Selection & Recurring Commute Schedules
- **Bike / Scooter Support**: Set max passengers = 1 for two-wheelers, enable spare helmet indicator.
- **Pre-Scheduled Commutes**: Support recurring 8:00 PM evening lock-in and morning departure nudges.

---

### 5. Auto-End Ride Detection
- **Separation Sensing**: Bluetooth disconnect detection when passenger steps off + GPS location check near destination.

---

## User Review Required

> [!IMPORTANT]
> **Key Design Highlights**:
> 1. **No Cash Liability**: Platform pays ₹0 for petrol. Karma Coins are for family commute sharing & office perks.
> 2. **Verification Hardware**: Bluetooth LE works on 100% of Android & iOS devices without requiring NFC hardware.

---

## Proposed File Changes

#### [MODIFY] [user_model.dart](file:///c:/Users/shiva/CorporatePoolingApp/lib/models/user_model.dart)
#### [MODIFY] [ride_model.dart](file:///c:/Users/shiva/CorporatePoolingApp/lib/models/ride_model.dart)
#### [NEW] [family_wallet_model.dart](file:///c:/Users/shiva/CorporatePoolingApp/lib/models/family_wallet_model.dart)
#### [NEW] [family_wallet_screen.dart](file:///c:/Users/shiva/CorporatePoolingApp/lib/screens/wallet/family_wallet_screen.dart)
#### [NEW] [boarding_verification_screen.dart](file:///c:/Users/shiva/CorporatePoolingApp/lib/screens/safety/boarding_verification_screen.dart)
#### [MODIFY] [post_ride_screen.dart](file:///c:/Users/shiva/CorporatePoolingApp/lib/screens/driver/post_ride_screen.dart)
#### [MODIFY] [find_ride_screen.dart](file:///c:/Users/shiva/CorporatePoolingApp/lib/screens/rider/find_ride_screen.dart)

---

## Verification Plan

### Manual Verification
- Run the Flutter app (`flutter run` / inspect via web/emulator/device).
- Test vehicle selection (Bike vs Car) and passenger limits.
- Test Family Wallet UI (adding family member, shared balance display).
- Test 4-Level Verification screen (switching between BLE, Daily Word, QR, and PIN).
