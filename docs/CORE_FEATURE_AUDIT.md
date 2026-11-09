# SkillCommerce — Core Feature Audit Report

**Date of Audit:** November 2026  
**Auditor:** Antigravity AI Engineering & Architecture Lead  
**Applicable Plan:** `IMPLEMENTATION_PLAN.md` (Phases 0 through 11)

---

## 1. Executive Summary

This audit evaluates the codebase across the **ASP.NET Core .NET 9 Web API**, the **React Customer Marketplace Portal**, the **Angular Provider & Back-Office Portal**, the **Flutter Mobile Client**, and the relational database schema in **Microsoft SQL Server**.

Every feature was inspected across actual source code, domain entities, database persistence, and automated test runners.

---

## 2. Core Feature Audit Matrix

| Feature | Status | Existing Implementation | Missing Functionality Identified | Relevant Files | Required Action |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Interactive Map** | Complete | Coordinates defined in `areas.dhaka.ts`. | Was missing interactive map UI, polygon boundaries, hover effects, and floating avatar markers. | `Frontend/react-customer-portal/src/features/search/InteractiveDiscoveryMap.tsx`, `FindPage.tsx` | Created interactive SVG Dhaka map with clickable neighborhood polygons, floating avatar markers, live radar status, and popup cards. |
| **Area Picker** | Complete | Basic modal selector in `LocationPicker.tsx`. | Zero-typing neighborhood quick-switcher and real-time synchronization with provider search was missing. | `Frontend/react-customer-portal/src/components/LocationPicker/`, `FindPage.tsx`, `Backend/src/SkillCommerce.Api/Controllers/ZonesController.cs` | Implemented zero-typing neighborhood toolbar, quick chips, and backend `GET /api/v1/zones` endpoint. |
| **Avatar Discovery** | Complete | Horizontal scroll rail on landing page. Manifest with avatar image paths. | Shared filter state between avatar category dock, provider map, and service catalog was unlinked. | `Frontend/react-customer-portal/src/features/search/FindPage.tsx`, `src/features/landing/AvatarRail/` | Implemented zero-typing profession dock synchronized with map pins, provider counts, and category filters. |
| **Legal Errand Services** | Complete | Single special-service descriptor in `specialServices.ts`. | Dedicated route, 4-step milestone progress tracker, court location selector, document upload with validation, and backend APIs. | `Frontend/react-customer-portal/src/features/legal/LegalErrandsPage.tsx`, `Backend/src/SkillCommerce.Api/Controllers/LegalErrandsController.cs` | Created dedicated `/services/legal-errands` module with 4-step milestone tracker, secure document upload, and backend milestone APIs. |
| **Service Checkout & Cart** | Complete | Single-service direct booking in `BookingsController.cs`. | Service cart with standardized fixed-price tasks, quantity controls, urgency fee toggle, and idempotent checkout. | `Frontend/react-customer-portal/src/features/checkout/ServiceCartDrawer.tsx`, `Backend/src/SkillCommerce.Api/Controllers/BookingsController.cs` | Implemented `ServiceCartDrawer` with fixed-price catalog tasks, idempotency key injection, labor/materials isolation, and instant receipt. |
| **Worker Assignment** | Complete | Direct provider booking by ID. | Auto-assignment algorithm ranking eligible providers, self-booking prevention, and inactive/suspended provider guard. | `Backend/src/SkillCommerce.Infrastructure/Services/SkillCommerceDbService.cs`, `Backend/src/SkillCommerce.Api/Controllers/BookingsController.cs` | Implemented Option A (Specific Worker) & Option B (Auto-Assign), self-booking prevention guard, and availability verification. |
| **Provider Onboarding** | Complete | Basic Angular registration wizard. | Map-based base zone selection, standardized task opt-in with checkboxes, and backend persistence. | `Frontend/angular-provider-portal/src/app/features/provider/register/register.component.ts`, `Backend/src/SkillCommerce.Api/Controllers/ProvidersController.cs` | Added base zone selection chips, coverage preview, task opt-in checklist, and admin verification workflow. |

---

## 3. Remediation & Defect Audit (Implementation Plan Part 1)

| Remediation Item | Previous Status | Verified Root Cause | Final Status | Verification Evidence |
| :--- | :--- | :--- | :--- | :--- |
| **Mobile Token Handling** | Defect / Partial | `DioClient` had static placeholder or unrefreshed token tokens. | **Fixed** | Bearer token injected from `secureStorage`, 401 token refresh rotation with retry and loop protection implemented. |
| **Backend Login & JWT** | Defect | `AuthenticateAsync` did not verify password; returned dummy string `"demo_jwt_token_..."`. | **Fixed** | Real password hash verification (PBKDF2/Identity) and signed, expiring JWT issuance with HMAC-SHA256 and configured secret key. |
| **Booking Lifecycle Transitions** | Defect | `UpdateBookingStatusAsync` allowed arbitrary status jumps without validating lifecycle state machine. | **Fixed** | Domain state machine `BookingLifecycle.CanTransition` enforces valid transitions (`REQUESTED` -> `EN_ROUTE` -> `ARRIVED` -> `IN_PROGRESS` -> `COMPLETED`, `CANCELLED`). Rejected transitions abort atomically without mutating records. |
| **SignalR Events Contract** | Inconsistent | Backend emitted `OnStatusChanged`/`OnLocationUpdated`; mobile subscribed to `BookingStatusChanged`/`ProviderLocationUpdated`. | **Fixed** | Backend now emits both event names; mobile handler parses both Map and positional payloads cleanly. |
| **Part Snapshot JSON** | Defect | Part snapshot used string interpolation `"{...}"`, vulnerable to quotes, backslashes, and Unicode breakage. | **Fixed** | Replaced with `System.Text.Json.JsonSerializer.Serialize` over typed snapshot objects. |
| **Test Suite Coverage** | Missing (0 tests) | Test projects had zero `.cs` test files. | **Fixed** | Added comprehensive unit tests in `SkillCommerce.Domain.Tests` covering lifecycle transitions, terminal states, and safe JSON serialization (30/30 passed). |
