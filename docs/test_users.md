# Development Test Users

This file maintains a list of fake test users to be used during local development and testing. 
**Do not use real phone numbers or real Aadhaar numbers in development.** All OTPs in development are mocked (e.g., `123456`).

## 🚗 5 Drivers (Aadhaar + Vehicle Verified)
These users went through the entire onboarding flow, verified their Aadhaar, and uploaded their vehicle RC/DL to offer rides.

| Phone Number | Name (Aadhaar) | Aadhaar No. | Company | Vehicle Type | Vehicle Plate (Vahan) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `99999 00001` | Rahul Sharma | `1111 2222 3333` | Infosys | Car (Tata Nexon) | `MH 12 AB 1234` |
| `99999 00002` | Priya Patel | `2222 3333 4444` | TCS | Scooter (Activa) | `KA 01 CD 5678` |
| `99999 00003` | Amit Singh | `3333 4444 5555` | Infosys | Car (Hyundai i20) | `DL 4C EF 9012` |
| `99999 00004` | Neha Gupta | `4444 5555 6666` | Wipro | Car (Maruti Swift) | `TS 09 GH 3456` |
| `99999 00005` | Vikram Reddy | `5555 6666 7777` | *Public Commuter* | Bike (Royal Enfield) | `MH 02 IJ 7890` |

---

## 🚶 3 Verified Riders (Aadhaar Only, No Vehicle)
These users verified their identity but skipped the "Driver KYC" screen. They can only search for rides.

| Phone Number | Name (Aadhaar) | Aadhaar No. | Company | Status |
| :--- | :--- | :--- | :--- | :--- |
| `99999 00006` | Sneha Desai | `6666 7777 8888` | Infosys | Rider |
| `99999 00007` | Rohan Joshi | `7777 8888 9999` | TCS | Rider |
| `99999 00008` | Pooja Iyer | `8888 9999 0000` | Wipro | Rider |

---

## 👤 2 Unverified Riders (Skipped Aadhaar & Vehicle)
These users just entered their phone number and skipped KYC. They have limited trust scores.

| Phone Number | Name (Manual Entry) | Aadhaar No. | Company | Status |
| :--- | :--- | :--- | :--- | :--- |
| `99999 00009` | Karan Malhotra | *Skipped* | Tech Mahindra | Rider |
| `99999 00010` | Anjali Verma | *Skipped* | *Public Commuter* | Rider |
