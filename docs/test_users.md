# Development Test Users

This file maintains a list of fake test users to be used during local development and testing. 
**Do not use real phone numbers or real Aadhaar numbers in development.** All OTPs in development are mocked (e.g., `123456`).

*Note: The Aadhaar numbers pass the Verhoeff checksum algorithm. The Vehicle plates follow strict Indian RTO Regex formatting (e.g., MH 12 AB 1234).*

## 🚗 5 Drivers (Aadhaar + Vehicle Verified)
These users went through the entire onboarding flow, verified their Aadhaar, and uploaded their vehicle RC/DL to offer rides.

| Phone Number | Name (Aadhaar) | Aadhaar No. (Verhoeff) | Company | Vehicle Type | Vehicle Plate (Vahan Regex Valid) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `99999 00001` | Rahul Sharma | `2222 1111 0002` | Infosys | Car (Tata Nexon) | `MH 12 AB 1234` |
| `99999 00002` | Priya Patel | `3333 2222 0005` | TCS | Scooter (Activa) | `KA 01 CD 5678` |
| `99999 00003` | Amit Singh | `4444 3333 0006` | Infosys | Car (Hyundai i20) | `DL 04 EF 9012` |
| `99999 00004` | Neha Gupta | `5555 4444 0002` | Wipro | Car (Maruti Swift) | `TS 09 GH 3456` |
| `99999 00005` | Vikram Reddy | `6666 5555 0006` | *Public Commuter* | Bike (Royal Enfield) | `MH 02 IJ 7890` |

---

## 🚶 3 Verified Riders (Aadhaar Only, No Vehicle)
These users verified their identity but skipped the "Driver KYC" screen. They can only search for rides.

| Phone Number | Name (Aadhaar) | Aadhaar No. (Verhoeff) | Company | Status |
| :--- | :--- | :--- | :--- | :--- |
| `99999 00006` | Sneha Desai | `7777 6666 0001` | Infosys | Rider |
| `99999 00007` | Rohan Joshi | `8888 7777 0002` | TCS | Rider |
| `99999 00008` | Pooja Iyer | `9999 8888 0000` | Wipro | Rider |

---

## 👤 2 Unverified Riders (Skipped Aadhaar & Vehicle)
These users just entered their phone number and skipped KYC. They have limited trust scores.

| Phone Number | Name (Manual Entry) | Aadhaar No. | Company | Status |
| :--- | :--- | :--- | :--- | :--- |
| `99999 00009` | Karan Malhotra | *Skipped* | Tech Mahindra | Rider |
| `99999 00010` | Anjali Verma | *Skipped* | *Public Commuter* | Rider |
