# SkillCommerce Mobile Client Migration Summary
**From .NET MAUI (`MauiMobileApp_SkillServicePlatform/`) to Flutter (`mobile_app/`)**  
*Project: Skill-Based E-Commerce Platform ("Dokkho Lok Khuji" / দক্ষ লোক খুঁজি)*  
*Author / Architecture Lead: A.H.M. Zafir Hasan (@Zafff-e)*  
*Date: November 2026*

---

## 1. Executive Summary

The mobile client for **SkillCommerce** has been completely modernized from the previous .NET MAUI client into a high-performance, polished **Flutter** application located in `mobile_app/`. 

The new client connects directly to the ASP.NET Core Clean Architecture Web API (`Skill-Based_E-Commerce_Platform-Project/Backend/`) and is specifically tailored for emerging-market users across Bangladesh, offering an **Uber/Pathao-grade** on-demand experience with bilingual (Bengali/English) localization, low-tech friendly visual design, real-time WebSocket telemetry via SignalR, and transparent commission-isolated billing.

---

## 2. Directory Structure (`mobile_app/`)

```text
mobile_app/
├── assets/
│   ├── avatars/                   # 35 localized skill avatar illustrations
│   ├── icons/                     # UI icons and symbols
│   └── audio/                     # Dispatch alerts (job_incoming_ping.mp3)
├── lib/
│   ├── main.dart                  # App bootstrap, DI initialization, theme & locale loading
│   ├── app.dart                   # MaterialApp with routing, localization, and theme
│   ├── core/
│   │   ├── constants/             # ApiEndpoints, AssetPaths, StorageKeys
│   │   ├── network/               # DioClient, ApiException (RFC 9457), SkillCommerceRepository
│   │   ├── realtime/              # SignalRService (WebSocket client for /hubs/bookings)
│   │   ├── theme/                 # AppColors (Forest Green & Mint), AppTheme (Material 3)
│   │   └── localization/          # LanguageCubit, AppStrings (English & Bengali)
│   ├── features/
│   │   ├── auth/                  # Phone OTP, RoleCubit, DualOnboardingScreen
│   │   ├── seeker/                # Customer Experience
│   │   │   ├── discovery/         # ServiceCatalogScreen (40+ skills, categories, search)
│   │   │   ├── booking/           # MapBookingScreen (OpenStreetMap with technician radar)
│   │   │   ├── checkout/          # BookingCheckoutModal (Labor, urgency fee, bKash/Nagad)
│   │   │   └── tracking/          # LiveTrackingScreen (Real-time GPS en-route tracking)
│   │   └── provider/              # Technician / Professional Experience
│   │       ├── dashboard/         # ProviderHomeScreen (Online toggle, active jobs queue)
│   │       ├── requests/          # IncomingRequestModal (30-second accept/reject countdown)
│   │       └── materials/         # AdHocMaterialsSheet (Add repair parts, 0% platform commission)
│   └── shared/
│       ├── models/                # PolyglotModels (SQL Server, Redis, ES contracts)
│       └── widgets/               # AvatarSelectorWidget (Zero-permission avatar picker)
├── l10n/
│   ├── app_en.arb                 # English ARB translations
│   └── app_bn.arb                 # Bengali ARB translations
├── test/
│   └── polyglot_models_test.dart  # Unit tests for contracts and commission formulas
├── pubspec.yaml                   # Dependencies and asset registrations
└── analysis_options.yaml          # Linting and quality rules
```

---

## 3. Backend Route Bindings & Network Configuration

### 3.1 Base URLs by Environment
| Environment | Base URL | Note |
| :--- | :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:5242` | Maps directly to Windows host `.NET API` |
| **iOS Simulator / Web / Desktop** | `http://localhost:5242` | Direct local binding |
| **Physical Device (Wi-Fi LAN)** | `http://<YOUR_LAN_IP>:5242` | Connect device and workstation on same Wi-Fi |

### 3.2 Key API Endpoint Bindings

| Feature | Method & Route | Handled In Flutter | Role / Auth |
| :--- | :--- | :--- | :--- |
| **Auth** | `POST /api/v1/auth/login` | `DioClient.login()` | Anonymous |
| **Token Refresh** | `POST /api/v1/auth/refresh` | `DioClient` (Automatic Interceptor) | Silent rotation |
| **Categories** | `GET /api/v1/categories` | `SkillCommerceRepository.getCategories()` | Public |
| **Geo Search** | `GET /api/v1/providers/search` | `SkillCommerceRepository.searchNearbyProviders()` | Public / Radial |
| **Create Job / Booking** | `POST /api/v1/jobs` | `SkillCommerceRepository.createBooking()` | `Idempotency-Key` |
| **My Bookings** | `GET /api/v1/bookings/mine?as=` | `SkillCommerceRepository.getMyBookings()` | Authenticated |
| **Start Travel** | `POST /api/v1/bookings/{id}/start-travel` | `ProviderHomeScreen._handleAdvanceState('start-travel')` | Provider |
| **Arrive** | `POST /api/v1/bookings/{id}/arrive` | `ProviderHomeScreen._handleAdvanceState('arrive')` | Provider |
| **Start Work** | `POST /api/v1/bookings/{id}/start-work` | `ProviderHomeScreen._handleAdvanceState('start-work')` | Provider |
| **Complete Job** | `POST /api/v1/bookings/{id}/complete` | `ProviderHomeScreen._handleAdvanceState('complete')` | Provider |
| **Add Parts** | `POST /api/v1/bookings/{id}/parts` | `AdHocMaterialsSheet` | Provider |
| **Approve / Reject Part** | `POST /api/v1/bookings/{id}/parts/{pId}/approve` | `SkillCommerceRepository.decidePartApproval()` | Customer |
| **SignalR Telemetry** | `/hubs/bookings` | `SignalRService` (WebSockets) | `access_token` query |

---

## 4. Polyglot Database Mapping

| Backend Store | Technology | Flutter Model / Component | Operational Role |
| :--- | :--- | :--- | :--- |
| **Transactional Core** | SQL Server 2022 | `BookingModel`, `InvoiceModel`, `BookingPartModel` | Master ACID record, state machine transitions, immutable invoice snapshots. |
| **Real-Time Presence** | Redis 7.2 | `ProviderHomeScreen._isOnline` | Heartbeat availability (`provider:online:{id}`) and slot concurrency locks (`SET NX PX`). |
| **Radial Geo-Search** | Elasticsearch 8.13 | `ProviderGeoModel` / `MapBookingScreen` | Haversine distance calculations on `geo_point` within `MaxRadiusKm`. |
| **Dynamic Specs & Media** | MongoDB 7.0 | `CategoryModel`, `SkillModel` | Product catalog specs and technician portfolio media. |

---

## 5. Financial Settlement & Fee Isolation Verification

The Flutter client models and calculates pricing according to the master architecture specification:

$$\text{Commissionable Amount} = \text{LaborAmount} + \text{UrgencyFee}$$
$$\text{PlatformFee} = \operatorname{round}(\text{Commissionable Amount} \times \text{CommissionRate},\ 2)$$
$$\text{TotalPayable} = \text{Commissionable Amount} + \text{MaterialsAmount}$$
$$\text{ProviderPayout} = (\text{Commissionable Amount} - \text{PlatformFee}) + \text{MaterialsAmount}$$

**Hardware parts replaced during repairs bypass platform commission completely (0% fee).** Technicians receive 100% reimbursement for parts entered via `AdHocMaterialsSheet`.

---

## 6. Avatar Ingestion & Visual Asset Registry

All **35 illustrated avatars** from `Avatar's_Pictures/` have been copied to `mobile_app/assets/avatars/` with canonical aliases registered in `AssetPaths`:

1. `ac_technician.jpg` (এসি মেকানিক)
2. `electrician.jpg` (ইলেকট্রিশিয়ান)
3. `plumber.jpg` (প্লাম্বার / নল মিস্ত্রি)
4. `technician_appliance.jpg` (যন্ত্রপাতি মেরামত)
5. `carpenter.jpg` (কাঠমিস্ত্রি)
6. `painter.jpg` (রং মিস্ত্রি)
7. `mason.jpg` (রাজমিস্ত্রি)
8. `locksmith.jpg` (তালা-চাবি বিশেষজ্ঞ)
9. `mechanic.jpg` (গাড়ি ও বাইক মেকানিক)
10. `cleaner.jpg` (পরিচ্ছন্নতাকর্মী)
11. `pest_control.jpg` (কীটপতঙ্গ দমনকারী)
12. `caregiver.jpg` (সেবিকা / নার্স)
13. `babysitter.jpg` (শিশু পরিচারিকা)
14. `gardener.jpg` (মালী)
15. `cctv_technician.jpg` (সিসিটিভি টেকনিশিয়ান)
16. `network_specialist.jpg` (নেটওয়ার্ক স্পেশালিস্ট)
17. `smart_security.jpg` (স্মার্ট সিকিউরিটি)
18. `software_engineer.jpg` (সফটওয়্যার ইঞ্জিনিয়ার)
19. `web_developer.jpg` (ওয়েব ডেভেলপার)
20. `ui_ux_designer.jpg` (ইউআই/ইউএক্স ডিজাইনার)
21. `seo_expert.jpg` (এসইও বিশেষজ্ঞ)
22. `digital_marketer.jpg` (ডিজিটাল মার্কেটার)
23. `virtual_assistant.jpg` (ভার্চুয়াল সহকারী)
24. `packer_mover.jpg` (বাসা বদল ও প্যাকিং)
25. `driver.jpg` (ড্রাইভার)
26. `food_delivery.jpg` (খাবার ডেলিভারিম্যান)
27. `parcel_delivery.jpg` (পার্সেল ডেলিভারি রাইডার)
28. `home_chef.jpg` (বাবুর্চি / রাঁধুনি)
29. `beautician.jpg` (বিউটিশিয়ান)
30. `tailor.jpg` (দর্জি)
31. `photographer.jpg` (ফটোগ্রাফার)
32. `videographer.jpg` (ভিডিওগ্রাফার)
33. `home_tutor.jpg` (গৃহশিক্ষক)
34. `event_planner.jpg` (অনুষ্ঠান পরিকল্পনাকারী)
35. `general_technician.jpg` (দক্ষ কারিগর)

### Zero-Permission `AvatarSelectorWidget`
Users can pick an avatar with a single tap from a bottom modal sheet without triggering Android `READ_EXTERNAL_STORAGE` or `CAMERA` permission dialogs, perfectly matching the requirements of low-tech users in Bangladesh.

---

## 7. Developer Run & Verification Guide

### 7.1 Prerequisites
- Flutter SDK (v3.16.0 or higher) with Dart (v3.2.0 or higher)
- Android Studio / VS Code with Flutter extension
- ASP.NET Core Web API running on `http://localhost:5242`

### 7.2 Running the Flutter Client
```bash
# Navigate to the mobile app directory
cd mobile_app

# Install dependencies
flutter pub get

# Run unit tests
flutter test

# Launch on connected device or emulator
flutter run
```

### 7.3 Testing Without the Live Backend
The `SkillCommerceRepository` includes a built-in mock fallback dataset. If the .NET Web API is offline, the app automatically switches to realistic Dhaka mock data, allowing all UI flows (Service Catalog, Map Radar, Checkout, Live Tracking, Provider Dashboard, Ad-Hoc Parts) to be demonstrated and tested offline without failures.

