# Development Test Users

This file maintains a list of fake test users to be used during local development and testing. 
**Do not use real phone numbers or real Aadhaar numbers in development.** All OTPs in development are mocked (e.g., `123456`).

*Note: The Aadhaar numbers pass the Verhoeff checksum algorithm. The Vehicle plates follow strict Indian RTO Regex formatting without spaces (e.g., MH12AB1234).*

## 🚗 5 Drivers (Aadhaar + Vehicle Verified)
These users went through the entire onboarding flow, verified their Aadhaar, and uploaded their vehicle RC/DL to offer rides.

| Phone Number | Name (Aadhaar) | Aadhaar No. (Verhoeff) | Company | Vehicle Type | Vehicle Plate (No Spaces) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `9999900001` | Rahul Sharma | `222211110002` | Infosys | Car (Tata Nexon) | `MH12AB1234` |
| `9999900002` | Priya Patel | `333322220005` | TCS | Scooter (Activa) | `KA01CD5678` |
| `9999900003` | Amit Singh | `444433330006` | Infosys | Car (Hyundai i20) | `DL04EF9012` |
| `9999900004` | Neha Gupta | `555544440002` | Wipro | Car (Maruti Swift) | `TS09GH3456` |
| `9999900005` | Vikram Reddy | `666655550006` | *Public Commuter* | Bike (Royal Enfield) | `MH02KL7890` |

---

## 🚶 3 Verified Riders (Aadhaar Only, No Vehicle)
These users verified their identity but skipped the "Driver KYC" screen. They can only search for rides.

| Phone Number | Name (Aadhaar) | Aadhaar No. (Verhoeff) | Company | Status |
| :--- | :--- | :--- | :--- | :--- |
| `9999900006` | Sneha Desai | `777766660001` | Infosys | Rider |
| `9999900007` | Rohan Joshi | `888877770002` | TCS | Rider |
| `9999900008` | Pooja Iyer | `999988880000` | Wipro | Rider |

---

## 👤 2 Unverified Riders (Skipped Aadhaar & Vehicle)
These users just entered their phone number and skipped KYC. They have limited trust scores.

| Phone Number | Name (Manual Entry) | Aadhaar No. | Company | Status |
| :--- | :--- | :--- | :--- | :--- |
| `9999900009` | Karan Malhotra | *Skipped* | Tech Mahindra | Rider |
| `9999900010` | Anjali Verma | *Skipped* | *Public Commuter* | Rider |
