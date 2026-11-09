# SkillCommerce Remediation Implementation Plan

## Objective

Resolve the verified defects identified in the project audit, align the backend and mobile client contracts, and reduce deployment/configuration drift. Make changes only in the chosen, supported application path; do not make unrelated refactors.

## Scope and implementation rules

- Treat `Skill-Based_E-Commerce_Platform-Project/Backend` and `mobile_app` as the primary API/client pair unless repository configuration or the project owner confirms otherwise.
- First verify which application path is authoritative. The workspace also contains `MauiMobileApp_SkillServicePlatform` and a second database tree under `DataBase`; do not silently change either as part of the primary implementation.
- Preserve existing conventions, public contracts, and migrations where possible. If a contract must change, update all consumers and tests together.
- Never add real credentials, signing keys, or secrets to source control. Load secrets and environment-specific settings from configuration providers.
- Do not substitute demo behavior or silent fallbacks for errors. Return explicit validation/authentication failures using the existing API conventions.
- Do not upgrade unrelated packages solely to make the changes. Propose dependency/toolchain upgrades separately unless a supported version is required to build or test the fix.

## Phase 0 — Establish the supported path and baseline

1. Inspect the root and project READMEs, solution/project files, app configuration, and test projects. Confirm the supported backend, mobile app, and database setup.
2. Record current build/test outcomes before editing. Restore dependencies only if required for validation and permitted by the environment.
3. Identify existing identity/token infrastructure, booking status enums and call sites, SignalR group membership, and API error/DTO conventions before implementing replacements.
4. Choose one canonical database deployment/migration tree. Compare both trees before consolidation; preserve any unique scripts or documentation rather than deleting them.

**Acceptance criteria**

- The implementation targets one explicitly identified backend/client path.
- Baseline build/test results and any environment blockers are recorded.
- No generated output, secrets, or unrelated project files are changed.

## Phase 1 — Repair mobile authentication token handling

**Relevant area:** `mobile_app/lib/core/network/dio_client.dart`

1. Trace the existing secure-storage/token persistence and refresh flow.
2. Replace placeholder authorization values in both normal request and retry paths with the actual stored access token.
3. Ensure missing/expired credentials follow the established unauthenticated/refresh behavior; do not send a placeholder token or silently treat a request as authenticated.
4. Avoid logging tokens or including them in errors.
5. Add focused tests for authenticated requests, missing tokens, and retry/refresh behavior using the project’s existing test conventions.

**Acceptance criteria**

- Requests with a stored token send the expected bearer token.
- The retry path uses the current token after refresh and cannot loop indefinitely.
- Missing credentials produce the expected unauthenticated behavior.
- Tests do not expose token values in output.

## Phase 2 — Implement real backend login and token issuance

**Relevant area:** `Skill-Based_E-Commerce_Platform-Project/Backend/src/SkillCommerce.Infrastructure/Services/SkillCommerceDbService.cs` and related identity/API configuration.

1. Inspect the user schema, password storage/migration history, existing authentication dependencies, and API authorization setup.
2. If a secure password-hash scheme is already present, verify submitted passwords against it. If not, design a backward-compatible password-hash migration and registration/credential provisioning flow before enabling password login. Never compare or store plaintext passwords.
3. Issue a properly signed, expiring access token using the application’s configured issuer, audience, and signing key. Keep keys outside source control and fail clearly when required production configuration is absent.
4. Return a consistent unauthorized response for invalid credentials without disclosing whether an account exists.
5. Update client token parsing/storage only as needed to match the real response contract.
6. Add tests for valid credentials, invalid passwords, unknown accounts, inactive accounts, token claims/expiry, and missing signing configuration.

**Acceptance criteria**

- The submitted password is verified against a secure stored hash.
- No demo/predictable token is issued.
- Tokens are signed, expire, and contain only intended claims.
- Configuration failures are explicit; no production path silently falls back to demo auth.

**Decision gate:** If the project has no established account provisioning or password-hash path, document the required migration and provisioning behavior and obtain product-owner agreement before changing existing account semantics.

## Phase 3 — Enforce booking lifecycle transitions

**Relevant area:** `SkillCommerce.Domain` booking entities/enums and `SkillCommerce.Infrastructure/Services/SkillCommerceDbService.cs`; API entry point in `BookingsController.cs`.

1. Map all existing booking statuses, valid transitions, and actors allowed to request each transition.
2. Implement transition rules in the domain layer (or an existing domain service), not as scattered controller checks.
3. Validate the current persisted status and requested transition atomically to avoid concurrent updates applying stale decisions.
4. Reject invalid transitions with the existing domain/API error convention; preserve valid flows.
5. Add domain tests covering every allowed transition and representative skipped, reversed, terminal-state, and concurrent/stale-update cases.

**Acceptance criteria**

- Every status change is checked against an explicit lifecycle.
- Invalid transitions do not modify the booking or create status-history entries.
- Existing valid transitions and authorization rules are covered by tests.

## Phase 4 — Align SignalR events and payloads

**Relevant areas:** `mobile_app/lib/core/realtime/signalr_service.dart`, backend `BookingsController.cs` and `BookingHub.cs`.

1. Inventory all backend-emitted and client-subscribed event names, payload arguments, and client handlers.
2. Define one event contract for booking status, provider location, and parts updates, including typed payload fields and stable identifier/status representations.
3. Make the backend emit the agreed event names and DTO payloads, and make the Flutter client subscribe to and parse exactly those contracts.
4. Check that authenticated clients are added to the correct booking groups and that users cannot subscribe to bookings they are not authorized to view.
5. Add backend contract/serialization tests and client parsing tests. If the repository supports a shared schema/OpenAPI artifact, use it rather than duplicating undocumented shapes.

**Acceptance criteria**

- Each required event is received by the Flutter handler with the expected values.
- Event names and payload shape have a single documented/tested contract.
- Group membership and authorization remain enforced.

## Phase 5 — Serialize part snapshot JSON safely

**Relevant area:** `SkillCommerceDbService.cs` part snapshot creation and relevant API DTOs.

1. Replace interpolated JSON strings with serialization of a typed object using the project’s configured JSON serializer.
2. Preserve the existing stored JSON shape where consumers depend on it; if shape changes are necessary, version or migrate the contract.
3. Add tests for quotes, backslashes, Unicode, and control characters in user-provided part fields, plus deserialization of the resulting snapshot.

**Acceptance criteria**

- All accepted input values produce valid JSON.
- Snapshot properties and stored representation remain compatible with existing readers.

## Phase 6 — Reconcile API tests and database configuration

1. Update `test_mobile_api_suite.js` only after confirming whether it targets the selected backend. Align endpoint paths, booking statuses, IDs, and response fields with the actual API contract; remove assumptions for endpoints not implemented or add them only if they are in scope.
2. Make the selected backend’s connection string configuration explicit. Remove or constrain development fallbacks that can mask missing configuration; do not commit credentials.
3. Compare `DataBase/` and `Skill-Based_E-Commerce_Platform-Project/Database/` migrations, seeds, Compose files, and docs. Designate one canonical source and document the other as legacy/reference or migrate its unique content safely.
4. Align the documented MVP services with the services actually required by the selected backend. Avoid removing existing deployment services until their consumers and dependencies have been checked.
5. Add a check or documented procedure to detect future migration/Compose drift.

**Acceptance criteria**

- API tests exercise the selected backend contract and do not expect nonexistent routes or fields.
- The selected application fails clearly when required database configuration is missing.
- Documentation names the authoritative database setup and matches the actual deployment configuration.
- No unique migration, seed, or operational instruction is lost during reconciliation.

## Phase 7 — Toolchain, CI, and regression coverage

1. Add or update CI checks for the selected backend build and test suites, Flutter formatting/analyzer/tests, and API contract tests.
2. Pin supported .NET SDK and Flutter/Dart versions in the repository’s established toolchain files/CI. Do not choose versions without checking project compatibility and available CI runners.
3. Review dependency updates separately; update only packages needed for compatibility or a concrete fix, and run tests after each relevant update.
4. Ensure new tests cover the authentication, booking lifecycle, SignalR, and JSON serialization behavior above.

**Acceptance criteria**

- CI fails on a regression in the changed areas.
- Toolchain versions used locally and in CI are documented and consistent.
- Dependency changes are justified and the applicable build/test suite passes.

## Recommended execution order

1. Phase 0 baseline and supported-path decision.
2. Phase 5 JSON serialization (isolated correctness fix).
3. Phase 3 booking lifecycle validation.
4. Phase 4 SignalR contract alignment.
5. Phase 1 mobile token handling.
6. Phase 2 real authentication (after confirming password provisioning and key configuration).
7. Phase 6 API/config/database reconciliation.
8. Phase 7 CI/toolchain and final regression validation.

Phase 1 and Phase 2 should be developed and tested as a coordinated client/server change before release. Do not enable real-login behavior in an environment until credentials are provisioned securely.

## Final verification checklist

- Build the selected backend solution and run all backend unit/integration tests.
- Run Flutter analyze and all Flutter tests.
- Run the Node API suite against the selected backend and its documented database configuration.
- Verify invalid login, valid login, authenticated API requests, token refresh/retry, and expired-token behavior.
- Verify allowed and rejected booking status transitions, including no mutation on rejection.
- Verify status/location/parts SignalR events end-to-end with the expected payloads.
- Verify part snapshots remain valid JSON for escaped and Unicode input.
- Review the final diff for unrelated edits, generated files, secrets, and stale documentation.


Second Part: # SKILLCOMMERCE

## AI Development Agent — Repository Audit, Feature Integration & Implementation

### ROLE AND PRIMARY OBJECTIVE

You are a Senior Full-Stack Software Architect, ASP.NET Core Backend Engineer, React Developer, Angular Developer, Database Architect, and UI/UX Engineer.

Your assignment is to inspect, improve, and extend the existing **SkillCommerce — Skilled Professional Service Marketplace**.

This is an existing project, NOT a new project.

**Your most important instruction: DO NOT rebuild functionality that already exists.**

First inspect the actual source code, database structures, API controllers, frontend components, and existing business logic.

Identify which requested features are:

* Fully implemented and working.
* Partially implemented.
* Present only in documentation.
* Completely missing.
* Implemented but requiring correction.

Only develop the missing or incomplete functionality.

Preserve existing working features, architecture, naming conventions, authentication, database configurations, and established business rules.

---

# PHASE 0: MANDATORY PROJECT AUDIT

Before making any code changes, inspect the entire existing repository.

### 0.1 Read Existing Project Instructions

Locate and read, where available:

* `InstructionsGuide.md`
* `SkillCommerce_API_Agent_Build_Guide.md`
* `client_spec_react_angular.md`
* `AGENTS.md`
* Existing README files
* Existing architecture documentation
* Existing database schemas and migrations
* Existing API specifications
* Existing frontend design documentation

Treat these documents as specifications, not proof that functionality exists.

Resolve contradictions by prioritizing verified repository behavior, explicit current project requirements, and the latest applicable instructions. Report material conflicts.

### 0.2 Inspect Existing Architecture

Expected architecture:

**Backend**

* ASP.NET Core Web API
* MVC Controllers
* Clean Architecture
* Repository Pattern
* Dependency Injection
* Feature-based application services
* Business-rule validation
* Transactional persistence

**Frontend**

* React: Customer-facing marketplace
* Angular: Provider and administrative management

**Databases**

* Microsoft SQL Server: Authoritative transactional records
* MongoDB: Flexible catalog and portfolio documents
* Redis: Temporary carts, availability, cache, and provider presence
* Elasticsearch: Service and geographic search

**Real-Time Communication**

* ASP.NET Core SignalR

Use the versions already present in the repository unless a justified, compatible upgrade is necessary.

Do not automatically replace existing dependencies or introduce new frameworks.

### 0.3 Required Audit Report

Before implementation, produce:

`docs/CORE_FEATURE_AUDIT.md`

Use this structure:

| Feature               | Status                                    | Existing Implementation | Missing Functionality | Relevant Files | Required Action     |
| --------------------- | ----------------------------------------- | ----------------------- | --------------------- | -------------- | ------------------- |
| Interactive Map       | Complete / Partial / Missing / Unverified | Evidence                | Gaps                  | File paths     | Reuse/Extend/Create |
| Area Picker           | ...                                       | ...                     | ...                   | ...            | ...                 |
| Avatar Discovery      | ...                                       | ...                     | ...                   | ...            | ...                 |
| Legal Errand Services | ...                                       | ...                     | ...                   | ...            | ...                 |
| Service Checkout      | ...                                       | ...                     | ...                   | ...            | ...                 |
| Worker Assignment     | ...                                       | ...                     | ...                   | ...            | ...                 |
| Provider Onboarding   | ...                                       | ...                     | ...                   | ...            | ...                 |

For each feature, examine actual source code, API behavior, database support, and tests.

Do not mark a feature complete because a component, route, interface, or mock response exists.

A complete feature must demonstrate a functioning frontend-to-backend workflow with persistent state where applicable.

Run available build and test commands before making changes and record the results.

---

# PHASE 1: INTERACTIVE MAP AND ZERO-TYPING AREA PICKER

## 1.1 Objective

Develop an interactive, map-based professional discovery interface.

A customer should be able to choose a neighborhood and discover nearby service providers without manually entering an address.

The map should feel like an integrated marketplace, not an ordinary static Google Map embedded into a website.

## 1.2 Frontend Design

Use the existing React customer application.

Implement a responsive split-screen discovery interface.

Recommended desktop layout:

**LEFT PANEL — 35–40%**

Display:

* Selected area
* Service category
* Available professionals
* Professional avatar cards
* Average ratings
* Verified badges
* Starting prices
* Availability
* Booking buttons

**RIGHT PANEL — 60–65%**

Display:

* Interactive map
* Clickable geographic zones
* Professional avatar markers
* Selected neighborhood boundaries
* Provider clusters
* Active service filters

Do not apply fixed dimensions blindly. Use the existing design system and adapt the split according to screen size.

For mobile devices:

* Show a full-width interactive map.
* Provide a collapsible provider-results panel or bottom sheet.
* Keep category avatars accessible through horizontal scrolling.
* Make map and service navigation touch-friendly.

## 1.3 Clickable Neighborhood Zones

Customers should select neighborhoods directly from the map.

Initial demonstration location:

**Dhaka, Bangladesh**

Potential areas include:

* Dhanmondi
* Gulshan
* Banani
* Mirpur
* Uttara
* Mohammadpur
* Motijheel
* Badda

These are example labels, not validated geographic boundaries.

Use a legitimate and appropriately licensed geographic dataset or administrator-maintained GeoJSON boundaries.

Do not fabricate official neighborhood polygons.

Required functionality:

1. Display selectable neighborhood boundaries.
2. Highlight a neighborhood on hover or focus.
3. Allow selection by mouse click, touch, or keyboard.
4. Show the selected neighborhood name.
5. Filter providers by their actual service coverage.
6. Display the number of eligible providers.
7. Update provider avatars immediately.
8. Permit changing areas without reloading the page.
9. Support clearing the area filter.
10. Provide an accessible list-based neighborhood selector as an alternative to the map.

**Zero typing is the default interaction requirement.**

Text search can remain available as an optional secondary feature.

Do not require GPS permission to discover professionals.

## 1.4 Map Technology

Inspect the existing mapping library.

If Leaflet and OpenStreetMap are already implemented, reuse them.

Suggested capabilities:

* React Leaflet or the existing map adapter
* GeoJSON polygon overlays
* Custom avatar markers
* Marker clustering
* Geographic bounding-box queries
* Responsive popup cards
* Accessible map controls

Avoid replacing an existing functioning map without technical justification.

## 1.5 Floating Worker Avatars

Display workers as circular avatar markers positioned over their approximate service areas.

Each marker should visually communicate:

* Professional profile image or category avatar
* Availability status
* Rating
* Verification status

When the customer clicks a marker, show a popup with:

* Worker name
* Profession
* Rating and number of reviews
* Verified status
* Starting service price
* Supported services
* Profile button
* Book button

Use the existing public provider-profile API wherever possible.

### Critical Privacy Requirement

Do not expose a worker's precise live GPS location to the public.

Public marketplace markers should represent approximate provider coverage, an approved service area, or a privacy-preserving location.

Precise GPS tracking may be enabled only for an authorized active booking when permitted by the applicable privacy policy.

Live availability and location are different concepts.

Use Redis or another existing temporary-state service for presence and availability.

Keep stale or offline professionals from appearing as currently available.

---

# PHASE 2: AVATAR-DRIVEN PROFESSIONAL DISCOVERY

## 2.1 Objective

Implement an interactive profession-based avatar dock.

The user should understand available services by looking at recognizable profession-specific illustrations.

This is a core visual identity of SkillCommerce.

## 2.2 Existing Avatar Assets

Inspect the existing:

`Avatar's_Pictures`

folder, or its current equivalent.

Reuse existing illustrations before adding new assets.

Do not overwrite existing artwork.

If the folder is missing, report the issue and use a clear placeholder with documented asset requirements.

## 2.3 Avatar Categories

Display avatars for professions such as:

* Electrician
* Plumber
* AC Technician
* Cleaner
* Carpenter
* Painter
* Appliance Repair Technician
* Computer Technician
* Court & Legal Errand Runner

Make categories data-driven.

Do not hardcode the entire category taxonomy into React components.

Use category IDs and approved service records from the backend.

## 2.4 User Interaction

When a customer clicks the Electrician avatar:

1. Highlight the selected avatar.
2. Filter the map to eligible electricians.
3. Filter the service catalog.
4. Update provider counts.
5. Show relevant electrician service cards.
6. Preserve the currently selected neighborhood.
7. Allow the customer to open the dedicated electrician page.

The same behavior must work for other professions.

### Important

The avatar dock, provider map, and service catalog must share the same filter state.

Do not implement three independent filters that become inconsistent.

A recommended filter model includes:

* `categoryId`
* `serviceTaskId`
* `zoneId`
* `availability`
* `minimumRating`
* `sortBy`

Synchronize these filters with the URL where practical so users can share or revisit selected views.

## 2.5 Dedicated Profession Pages

Each major profession should have a dedicated service page.

Examples:

`/services/electrician`

`/services/plumber`

`/services/ac-repair`

`/services/legal-errands`

These routes are illustrative. Preserve existing routing conventions.

Each page should include:

* Profession-related hero illustration
* Short service introduction
* Relevant subcategories
* Fixed-price service cards where applicable
* Nearby eligible professionals
* Verification information
* Area selection
* Booking options

Preserve the existing landing-page structure, branding, and illustrations wherever possible.

Do not redesign unrelated sections.

---

# PHASE 3: COURT AND LEGAL ERRAND SERVICE MODULE

## 3.1 Objective

Create a dedicated marketplace category for administrative court-related and legal-document errands.

This service category must be clearly separated from professional legal advice and legal representation.

It is intended to help customers locate eligible service providers who can perform authorized administrative tasks.

## 3.2 Proposed Service Categories

Create configurable task types such as:

**Court Administrative Services**

* Certified copy or নকল collection assistance
* Court document submission assistance
* Publicly accessible case-status information retrieval
* Authorized document collection
* Court-related courier services

**Notary Assistance**

* Document delivery to an authorized notary
* Notarization appointment coordination
* Collection of completed notarized documents

**Legal Document Logistics**

* Document pickup
* Document delivery
* Administrative follow-up
* Application status follow-up through permitted channels

Each task must contain:

* Name in English
* Name in Bengali
* Description
* Required documentation
* Eligibility requirements
* Fixed service fee where appropriate
* Estimated completion time
* Service restrictions
* Supported courts or locations
* Availability

Do not imply that a runner can act as a licensed lawyer, authorized notary, or court official.

The project administrator must validate permitted task types and provider eligibility against applicable Bangladesh laws and court rules before production activation.

## 3.3 Dedicated Legal Service Page

Create a distinct page for legal errands.

Suggested route:

`/services/legal-errands`

The page should contain:

1. Court-related banner or illustration.
2. Service subcategory cards.
3. Supported court/location selection.
4. Eligible runner profiles.
5. Transparent service prices.
6. Required-document checklist.
7. Document upload interface.
8. Booking initiation.
9. Order milestone tracking.

Use appropriate legal-themed illustrations.

Do not redesign the rest of the marketplace.

## 3.4 Legal Service Booking Workflow

Customer journey:

**Step 1 — Select Service**

Example: Certified Copy Collection Assistance.

**Step 2 — Select Court or Service Location**

Choose a supported court from an administrator-maintained list.

**Step 3 — Upload Required Documents**

The customer uploads relevant documents and provides authorized instructions.

**Step 4 — Choose a Service Provider**

Select a qualified and approved runner or request automatic assignment.

**Step 5 — Confirm Price and Booking**

The backend validates the final price, provider eligibility, service coverage, and requirements.

**Step 6 — Track Progress**

Display the service milestone tracker.

## 3.5 Four-Step Milestone Tracker

Implement the following main milestones:

| Step | Milestone             | Description                                                      |
| ---- | --------------------- | ---------------------------------------------------------------- |
| 1    | Request Submitted     | Booking created and required information submitted               |
| 2    | Documents Reviewed    | Documents checked for completeness and task acceptance           |
| 3    | Service In Progress   | Assigned runner is processing the authorized errand              |
| 4    | Completed & Delivered | Authorized output or document delivered with completion evidence |

Display milestones visually using:

* Progress indicators
* Status badges
* Completed timestamps
* Current milestone highlighting
* Optional customer notifications

Additional exception statuses must include:

* Awaiting Documents
* On Hold
* Rejected
* Cancelled
* Failed
* Delivery Disputed

Do not count an unsuccessful request as completed.

Only authorized users may change milestone states.

Maintain a permanent, access-controlled milestone history.

## 3.6 Secure Document Management

Create secure document upload functionality.

Supported formats may include:

* PDF
* JPG
* PNG

Requirements:

* Validate file extensions and actual content types.
* Apply configurable maximum file sizes.
* Scan uploads for malicious content.
* Store files privately.
* Encrypt sensitive documents at rest.
* Use short-lived authorized download links or authenticated streaming.
* Keep file metadata in the transactional database.
* Apply role-based and resource-level access control.
* Record upload and access audit events.
* Support document rejection and re-upload.
* Apply an administrator-approved retention and deletion policy.

Never publicly expose NID scans, legal documents, case information, or private court-related material.

Do not place raw private documents in Elasticsearch.

## 3.7 Legal Service Restrictions

The system must not:

* Guarantee legal outcomes.
* Represent an unqualified person as a lawyer.
* Represent a runner as a court employee.
* Claim court authorization without verified evidence.
* Provide unauthorized access to case records.
* Encourage unofficial payments.
* Enable document impersonation or forgery.
* Automatically disclose private case information.
* Allow providers to access documents unrelated to their assigned tasks.

Sensitive or regulated service types must remain disabled until their specific eligibility requirements have been configured and approved.

---

# PHASE 4: E-COMMERCE SERVICE CART AND WORKER-BASED CHECKOUT

## 4.1 Objective

Extend the existing commerce and booking architecture so customers can add standardized fixed-price services to a cart.

Customers should then choose a specific professional or request automatic assignment.

Do not build a second, unrelated checkout system.

Reuse existing cart, booking, pricing, payment, and invoice functionality whenever feasible.

## 4.2 Fixed-Price Service Catalog

Introduce or extend standardized service-task records.

Example services:

| Service                     | Example Display Price |
| --------------------------- | --------------------- |
| AC General Servicing        | ৳800                  |
| Ceiling Fan Installation    | ৳500                  |
| Basic Electrical Inspection | ৳400                  |
| Bathroom Cleaning           | ৳700                  |
| Legal Document Pickup       | ৳350                  |

These prices are illustrative development data, not approved commercial prices.

All prices must be configured and validated through the backend.

Each service record should contain:

* Service ID
* Category ID
* Service name
* Description
* Fixed labor/service price
* Estimated duration
* Required provider qualifications
* Supported service zones
* Active/inactive status
* Price-policy version

Do not trust frontend-submitted prices.

## 4.3 Add to Cart

Customers can add one or more supported fixed-price tasks to the service cart.

The cart should show:

* Selected tasks
* Quantity, where meaningful
* Service fee
* Applicable disclosed charges
* Estimated duration
* Service location
* Selected worker, if any
* Total estimated cost

For services requiring inspection or a variable quote, use the existing quote/approval workflow rather than pretending that every job has a fixed final price.

## 4.4 Worker Selection

At checkout, provide two options:

### Option A — Choose a Specific Worker

The customer selects a professional from the map or provider list.

Validate:

* Provider is approved.
* Provider offers the selected tasks.
* Provider covers the selected area.
* Provider is currently eligible for new bookings.
* Provider has the necessary credentials.
* Requested time slot is available.
* Provider is not suspended.
* Provider cannot book themselves.

A visible avatar alone must not establish eligibility.

### Option B — Auto-Assign

The backend selects an eligible professional using defined assignment rules.

Suggested ranking criteria:

1. Required task qualifications.
2. Verified eligibility.
3. Geographic coverage.
4. Schedule availability.
5. Appropriate service price.
6. Provider responsiveness.
7. Customer rating.

Use deterministic eligibility checks before optional ranking.

Do not allow AI scoring or search relevance to override mandatory business rules.

Record assignment decisions for auditability.

If no provider is available, display a clear message and allow the customer to change the time, location, or assignment method.

## 4.5 Multi-Service Cart Handling

A cart may contain tasks that cannot be completed by one provider.

Handle this explicitly.

For example:

* AC Servicing
* Electrical Repair
* Court Document Collection

These services may require different professionals.

The system must not silently assign all tasks to one unqualified provider.

Group compatible tasks into one booking only when the selected provider can perform all of them within the reserved schedule.

Otherwise, split checkout into independently validated bookings.

Display the resulting booking groups and total cost before confirmation.

Ensure partial failures cannot create duplicate charges or silently discard tasks.

## 4.6 Checkout Workflow

Required workflow:

1. Validate cart ownership.
2. Validate selected service tasks.
3. Validate selected zone.
4. Validate provider or auto-assignment eligibility.
5. Recalculate authoritative prices.
6. Verify availability.
7. Reserve the necessary booking capacity.
8. Present the final customer quote.
9. Confirm booking through an idempotent operation.
10. Record booking and financial snapshots in SQL Server.
11. Initiate the configured payment workflow.
12. Return booking references and current status.
13. Notify authorized parties.

Preserve the project's labor-based commission isolation.

Additional repair materials must remain subject to customer approval and immutable price snapshots.

Redis may help with temporary cart state and reservations, but confirmed booking capacity and financial obligations must remain authoritative in SQL Server.

## 4.7 Checkout Security

Implement:

* Idempotency keys.
* Server-side price validation.
* Transaction-safe booking allocation.
* SQL uniqueness and concurrency protection.
* Protection against duplicate payment requests.
* Proper authorization.
* Audit logging.
* Safe handling of payment timeouts.
* Clear pending-payment and pending-assignment states.

Never claim a real payment succeeded based only on frontend confirmation.

Use the existing mock payment adapter for local demonstrations unless a real gateway is already correctly configured and authorized.

---

# PHASE 5: MAP-BASED PROVIDER ONBOARDING

## 5.1 Objective

Allow professionals to register, choose their base service zone visually, select standardized tasks, upload credentials, and submit their profile for verification.

Reuse the existing professional registration and verification modules.

## 5.2 Registration Workflow

Provider onboarding should follow:

**Account Registration**

Create or authenticate an existing user account.

**Professional Profile**

Collect necessary profile and contact information.

**Profession Selection**

Select one or more supported professional categories.

**Service Zone Selection**

Choose the provider's base zone directly from the interactive map.

**Service Task Selection**

Select supported standardized tasks.

**Credential Upload**

Submit required identity and professional qualification evidence.

**Submission**

Submit the profile for administrative review.

**Verification**

An administrator checks the required evidence and eligibility.

**Activation**

Approved providers become eligible for the corresponding service categories.

## 5.3 Map-Based Base Zone Selection

Providers should select their base neighborhood on the map.

Requirements:

* Clickable zones
* Selected zone highlighting
* Optional GPS-assisted positioning
* Service-radius configuration
* Multiple service zones where business rules permit
* Coverage preview
* Validation against supported geographic areas

Do not allow an arbitrary client request to claim unrestricted service coverage.

Persist zone IDs and approved coverage rules.

Use existing spatial data structures wherever possible.

## 5.4 Standardized Task Opt-In

Example:

Profession: Electrician

Available tasks:

* Ceiling Fan Installation
* Switch Replacement
* Wiring Inspection
* Light Fixture Installation
* Circuit Breaker Inspection

The professional selects which tasks they offer.

Each selection may include:

* Task ID
* Experience
* Availability
* Required qualification status
* Provider-specific rate, only where the price policy permits it

Unapproved or suspended tasks must not appear as bookable offerings.

A professional must not be able to bypass qualification requirements by directly posting a task ID.

## 5.5 Professional Credentials

Support relevant document types such as:

* NID
* Trade License
* Technical Certificate
* Training Certificate
* Other administrator-approved credentials

For court-related providers, allow additional evidence types only after verifying their meaning and lawful use.

Do not assume every court runner possesses an official Court Clerk ID.

Do not treat an NID as proof of specialized professional qualification.

Verification badges must distinguish:

* Identity Verified
* Professional Qualification Verified
* Category-Specific Authorization Verified, where applicable

Never publicly display credential document images or sensitive ID numbers.

## 5.6 Administrative Verification

Extend the existing Angular administration portal.

Provide:

* Pending verification queue
* Credential review
* Approve/reject actions
* Rejection reasons
* Request additional information
* Task-specific eligibility decisions
* Credential expiration handling
* Suspension and re-verification
* Complete audit history

Only authorized administrators may approve credentials.

A provider must not activate their own verification status.

Pending or suspended providers must not receive new bookings.

---

# PHASE 6: DATABASE AND API INTEGRATION

## 6.1 Core Architectural Principle

Extend existing domain entities and database tables where appropriate.

Do not create duplicate provider, booking, account, payment, or verification models.

Follow the existing Clean Architecture dependencies.

Keep controllers thin and business validation inside domain/application logic.

Use business-specific repositories and query services.

## 6.2 Candidate Data Models

Inspect existing schemas before creating new tables.

Potential additions include:

**Geographic Discovery**

* ServiceZone
* ServiceZoneBoundary
* ProviderServiceCoverage

**Service Catalog**

* StandardServiceTask
* ServiceTaskPriceVersion
* ProviderTaskOffering

**Legal Errands**

* LegalErrandDetails
* LegalErrandMilestone
* LegalErrandDocumentReference
* SupportedCourtLocation

**Checkout**

* ServiceCartItem
* BookingTaskItem
* BookingAssignmentHistory

**Provider Verification**

* ProviderCredentialType
* ProviderCredentialSubmission
* ProviderTaskEligibility

These are logical concepts, not mandatory new tables.

Reuse compatible existing structures.

Avoid creating unnecessary entities or introducing incompatible parallel schemas.

## 6.3 Database Responsibilities

### SQL Server

Use for:

* Service zones and authoritative coverage rules
* Approved provider eligibility
* Standardized tasks and commercial prices
* Bookings and booking allocations
* Worker assignments
* Legal-service milestone history
* Document ownership metadata
* Payment records
* Immutable invoices
* Audit history
* Transactional outbox

### MongoDB

Use for:

* Public provider portfolios
* Flexible catalog descriptions
* Additional nonfinancial catalog metadata
* Public presentation assets and references

Keep confidential verification evidence separate from public portfolios.

### Redis

Use for:

* Temporary service carts
* Provider presence
* Availability cache
* Temporary coordination leases
* Rate-limit counters
* Expiring real-time state

Redis must not be the sole authority for confirmed bookings or completed payments.

### Elasticsearch

Use for:

* Geographic provider discovery
* Approved service categories
* Searchable standardized tasks
* Language-aware search
* Rebuildable provider projections

Do not store confidential identity or legal documents in search indexes.

## 6.4 API Requirements

Inspect the existing `/api/v1` routes before implementing new endpoints.

Reuse compatible endpoints.

Potential operations include:

**Geographic Discovery**

* `GET /api/v1/zones`
* `GET /api/v1/zones/{id}`
* `GET /api/v1/providers/search`

**Service Tasks**

* `GET /api/v1/service-tasks`
* `GET /api/v1/service-tasks/{id}`

**Provider Onboarding**

* `PUT /api/v1/providers/me/service-coverage`
* `PUT /api/v1/providers/me/task-offerings`
* Existing document-upload and verification endpoints

**Service Cart**

* Existing cart endpoints, extended to support service-task items where appropriate
* Existing checkout-quote endpoints

**Booking Assignment**

* Existing booking creation routes, extended with explicit provider-selection and auto-assignment semantics

**Legal Errands**

* `GET /api/v1/legal-errand-services`
* `GET /api/v1/bookings/{id}/legal-errand`
* `GET /api/v1/bookings/{id}/milestones`
* Authorized milestone transition endpoints

These endpoints are suggestions, not instructions to duplicate existing functionality.

Follow established controller naming, route conventions, DTO contracts, API versioning, and error handling.

Return consistent RFC 9457 ProblemDetails errors with stable machine-readable error codes.

Generate or update OpenAPI documentation.

---

# PHASE 7: FRONTEND DESIGN AND USER EXPERIENCE

## 7.1 Design Principles

Maintain the existing SkillCommerce visual identity.

The interface should be:

* Modern
* Professional
* Visually descriptive
* Responsive
* Avatar-driven
* Accessible
* Bilingual
* Easy for first-time users
* Suitable for Bangladesh

Avoid unnecessary forms and typing.

Prefer:

* Visual profession selection
* Clickable geographic areas
* Illustrated service cards
* Clear price displays
* Recognizable worker avatars
* Simple booking actions
* Intuitive progress tracking

## 7.2 React Responsibilities

React owns:

* Landing page
* Avatar-based discovery
* Interactive area picker
* Customer map
* Service catalog
* Service cart
* Worker selection
* Checkout
* Customer legal-service request
* Customer document upload
* Customer milestone tracking

## 7.3 Angular Responsibilities

Angular owns:

* Provider onboarding and profile management
* Provider task offerings
* Provider service zones
* Provider credential submissions
* Provider booking management
* Legal-runner task operations
* Administrator verification
* Service catalog administration
* Zone and court/location management
* Operational oversight

Do not unnecessarily duplicate complete workflows between React and Angular.

Both applications must communicate with the same ASP.NET Core API.

## 7.4 Consistent Design

Reuse existing:

* Color tokens
* Typography
* Navigation
* Buttons
* Icons
* Component styles
* Avatar artwork
* Responsive breakpoints
* Authentication components

Support Bengali and English text.

Use proper Bengali fonts and avoid broken rendering.

Meet WCAG 2.2 AA accessibility expectations where applicable.

Provide keyboard-accessible alternatives to map interactions and meaningful text labels for illustrated controls.

---

# PHASE 8: SECURITY AND BUSINESS RULES

Implement security at the API and domain layers, not only in frontend components.

Required controls:

1. Authentication and authorization for protected actions.
2. Object-level authorization for bookings, documents, and milestones.
3. Strict role-based permission checks.
4. Verification before provider booking eligibility.
5. Prevention of self-booking.
6. Server-side price validation.
7. SQL-backed booking concurrency enforcement.
8. Input validation and output encoding.
9. Secure document upload and download.
10. Protection of customer and provider personal information.
11. Secure session and token handling.
12. Rate limiting.
13. Audit logging of sensitive actions.
14. Proper handling of retries and partial failures.
15. Secure configuration without hardcoded credentials.
16. Clear retention policies for sensitive identity and legal documents.
17. Revalidation of provider eligibility at checkout.
18. Protection against privilege escalation and mass assignment.
19. Restrictions against unauthorized court-record access.
20. Separation of public provider location from private booking GPS telemetry.

Do not copy sample credentials from project instruction files into application code.

Use environment secrets or the repository's established secure configuration approach.

Do not claim real-world credential verification unless the evidence and verification process justify the badge.

---

# PHASE 9: TESTING AND QUALITY ASSURANCE

Implement appropriate unit, integration, API, and end-to-end tests.

At minimum, verify the following scenarios.

### Geographic Discovery

* Selecting a zone updates eligible providers.
* Changing categories updates map markers and catalog results.
* Selecting the same zone again produces consistent results.
* Unapproved providers remain hidden.
* Offline or unavailable providers are represented correctly.
* No public request reveals precise private GPS coordinates.
* A keyboard user can select an area without using a mouse.

### Avatar Discovery

* Clicking Electrician filters providers and services.
* Selecting another category updates all discovery components.
* Selected filters persist when navigating between compatible views.
* Missing avatars fall back gracefully.
* Category IDs come from real backend data.

### Legal Errand Services

* Customers can create authorized requests.
* Required documents are validated.
* Unauthorized users cannot read uploaded documents.
* Milestones follow allowed transitions.
* Providers cannot complete unassigned tasks.
* Completion evidence is protected.
* Cancelled/rejected requests do not appear as completed.
* Sensitive information does not appear in public search indexes.

### Service Checkout

* Fixed prices are calculated by the backend.
* A customer can select a specific eligible worker.
* Auto-assignment chooses only eligible workers.
* Unavailable providers cannot be booked.
* Concurrent attempts cannot double-book a provider.
* Repeated checkout requests cannot create duplicate bookings.
* Mixed service tasks are grouped or separated correctly.
* Failed checkout does not incorrectly clear the cart.
* Payment retries cannot create duplicate charges.

### Provider Onboarding

* A provider can select a base zone.
* A provider can select approved standardized tasks.
* Credential upload works securely.
* Unverified providers cannot accept bookings.
* Administrators can approve or reject submissions.
* Providers cannot approve themselves.
* Verification decisions are auditable.

Use the existing test infrastructure wherever practical.

Run actual builds and tests.

Do not claim tests passed if they were not executed.

---

# PHASE 10: IMPLEMENTATION ORDER

Complete the work incrementally.

### Stage 1 — Audit

Inspect existing implementation.

Create:

`docs/CORE_FEATURE_AUDIT.md`

Record existing functionality and identified gaps.

### Stage 2 — Data and API Foundations

Implement only necessary:

* Database migrations
* Geographic zone models
* Standardized service tasks
* Provider task offerings
* Legal errand models
* Booking assignment extensions
* API endpoints

Keep database migrations safe and reversible where feasible.

### Stage 3 — Map and Avatar Discovery

Implement the React discovery interface.

Connect it to real API data.

### Stage 4 — Provider Onboarding

Extend Angular onboarding and administrative verification.

### Stage 5 — Legal Errand Module

Implement secure document workflows and milestone tracking.

### Stage 6 — Service Cart and Checkout

Integrate fixed-price tasks, worker selection, and automatic assignment into the existing booking and payment workflows.

### Stage 7 — Integration and Testing

Complete cross-application testing, security validation, and necessary corrections.

Do not move to an unrelated stage while leaving the current stage broken.

Keep the application buildable after each incremental change.

---

# PHASE 11: DELIVERABLES

Upon completion, provide:

**1. Feature Audit**

`docs/CORE_FEATURE_AUDIT.md`

**2. Implementation Summary**

`docs/CORE_FEATURE_IMPLEMENTATION.md`

Include:

* Existing functionality reused
* New functionality implemented
* Modified files
* Added database migrations
* New or changed API contracts
* Updated business rules
* Security decisions

**3. Architecture Documentation**

Document the new modules and their integration with the existing architecture.

**4. API Documentation**

Update OpenAPI definitions and examples.

**5. Tests**

Provide actual test commands, execution results, failures, and unverified scenarios.

**6. Demonstration Instructions**

Explain how to demonstrate:

* Customer selects Dhanmondi on the map.
* Customer selects Electrician.
* Available electrician avatars appear.
* Customer selects an electrician.
* Customer adds a fixed-price task to the cart.
* Customer checks out.
* Provider receives the booking.
* Provider updates the booking.
* Customer tracks the service.

Also demonstrate:

* Legal errand booking.
* Secure document upload.
* Four-step milestone tracking.
* Provider zone selection.
* Task opt-in.
* Administrative credential verification.

---

# FINAL AGENT INSTRUCTIONS

Follow these rules throughout development.

**RULE 1:** Audit before coding.

**RULE 2:** Never assume a documented feature is already implemented.

**RULE 3:** Never duplicate existing working functionality.

**RULE 4:** Preserve the established Clean Architecture and repository design.

**RULE 5:** Keep React and Angular responsibilities separate.

**RULE 6:** Implement real API integrations rather than decorative interfaces with fake success responses.

**RULE 7:** Keep SQL Server authoritative for bookings, prices, eligibility, and financial records.

**RULE 8:** Protect sensitive legal and identity documents.

**RULE 9:** Preserve all existing booking, commission, and payment invariants unless an approved requirement explicitly changes them.

**RULE 10:** Deliver working, tested, integrated functionality—not disconnected prototypes.

At the end, provide a feature-by-feature completion report.

Use the following reporting format:

| Feature               | Previous Status | Final Status | Backend | Frontend | Database | Tests |
| --------------------- | --------------- | ------------ | ------- | -------- | -------- | ----- |
| Interactive Map       | ...             | ...          | ...     | ...      | ...      | ...   |
| Area Picker           | ...             | ...          | ...     | ...      | ...      | ...   |
| Avatar Discovery      | ...             | ...          | ...     | ...      | ...      | ...   |
| Legal Errand Services | ...             | ...          | ...     | ...      | ...      | ...   |
| Service Checkout      | ...             | ...          | ...     | ...      | ...      | ...   |
| Worker Assignment     | ...             | ...          | ...     | ...      | ...      | ...   |
| Provider Onboarding   | ...             | ...          | ...     | ...      | ...      | ...   |

Clearly distinguish implemented, tested, partially implemented, blocked, and unverified features.

Do not report the project as complete until the relevant end-to-end scenarios have passed.

**BEGIN BY INSPECTING THE EXISTING REPOSITORY AND CREATING THE FEATURE AUDIT. THEN IMPLEMENT THE MISSING FEATURES IN THE SPECIFIED ORDER.**
