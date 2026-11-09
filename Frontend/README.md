# Kaarigor · Frontend 2.0

A fresh implementation of the Bangladesh skilled-services marketplace. React owns the customer journey; Angular owns provider registration, onboarding, work orders and the illustrative verification desk. They share data types, pricing rules, design tokens and theme behavior, never mount inside one another.

## Run

Requires Node 22.14+ (Angular 19 supports Node 18.19, 20.11 and 22; Node 22 LTS is recommended), npm 10+.

```bash
npm ci
npm run dev:customer
# in a second terminal
npm run dev:provider
```

Customer development: http://localhost:5173. Provider development: http://localhost:4200/provider/#/register. In development, set the provider link origin using the customer portal's provider URL helper (see below). Production paths are `/#/` and `/provider/#/register`.

```bash
npm test
npm run build
```

`build` type-checks React, runs Vite, compiles Angular with strict template checking, and assembles both apps and their shared local SVG assets in `dist/`. Serve `dist/` with an SPA fallback to `index.html`, preserving the `/provider/` directory index and files. Both portals use hash routes intentionally so deep links work on static hosting. To replace hash routing on a .NET reverse proxy, replace React HashRouter with BrowserRouter, remove Angular `withHashLocation()`, and configure separate customer and `/provider/*` fallbacks.

## What is implemented

- Redesigned home with separate hire / join entry points, restrained animated silk navigation, original vector worker portraits, neighbourhood search, trade dock, specialist errands and a short how-it-works section.
- Customer discovery with category / area selectors, keyboard-accessible SVG zones, area-level worker pins, list/map toggle, available-today and saved filters, rating / experience sorting, and profile/task selection.
- Service catalog and local persistent bag, per-task quantities, optional ৳300 urgency fee, labour-only commission included in the displayed total, worker selection or auto-assignment per trade, appointment and address validation.
- Court intake with court, case reference, optional file selection, and a four-stage request tracker.
- Session-only demo requests. Later tracking steps are deliberately not simulated as completed.
- CandidateForce-inspired provider registration composition: original portrait on the left, light form card on the right, account fields and password reveal, followed by skills, service territory and identity-document steps.
- Provider workspace: sequential demo work-order transitions, availability, weekly schedule, pending parts requests and a commission ledger.
- Demo verification desk: placeholder portrait/document comparison, approval, rejection with reason and resubmission request.
- English/Bengali copy, theme controls, local-time daypart colors, reduced-motion support, hidden-tab animation pause, responsive layouts and local assets.
- Jontu is explicitly an offline category guide using simple keyword matching. It is not presented as a connected LLM.

## The boundary: frontend versus production

This deliverable is a working **frontend demo**, not a new ASP.NET backend. The input was a compressed AI context pack, not the original repository, API schema, database, real worker assets or server secrets. Nothing here represents a verified real professional. All people, ratings, job records, credentials and prices are sample data. Forms do not transmit credentials, NIDs or files. Payment controls cannot collect money. Demo admin routes have no access to real data.

The existing context pack silently converted booking errors into “confirmed” mock transactions. This rewrite does not do that. User-facing messages explicitly distinguish a sample request from a server-confirmed booking.

The shared `request()` adapter is a foundation with credentials, timeout, structured errors and optional memory-held bearer token support; it is not a claim that backend integration has been completed. See `docs/API_HANDOFF.md` for the exact live-integration work and existing contract issues. Do not enable live writes until those issues are resolved against the actual OpenAPI schema.

## File structure

```
shared-design/
  styles.css                 Shared tokens, typography, primitives
  assets/                    Original replaceable vector characters + landscape
  src/catalog.ts             Typed sample catalog, areas, professionals, currency
  src/booking.ts             Quote, lifecycle, phone and file validation
  src/theme.ts               Shared local-time theme engine
  src/api.ts                 Fail-closed HTTP adapter
react-customer-portal/src/
  state/AppState.tsx          Central customer context and session state
  components/                Shell, area map, cart, assistant, accessible dialog
  pages/                     Home, discovery, services, bookings, account, info
angular-provider-portal/src/app/
  core/workspace.ts          Signals and demo workspace state
  features/register.*        Reactive forms and four-step onboarding
  features/dashboard.ts      Jobs, earnings, availability
  features/admin.ts          Sample verification workflow
scripts/build.mjs            Assemble both independent applications
tests/booking.test.ts        Business-rule checks
```

## Design decisions

The uploaded requirements conflict: one asks for paper, hard shadows and no gradients; another asks for glass and an animated living landscape. This implementation uses a calm warm-paper base, forest green, sage and ochre; editorial serif headings; original cutout-style SVG illustrations; a subtle silk-line navbar; and a restrained landscape rather than a full-screen moving scene. Content and forms stay still. Trade browsing is manually scrollable rather than continuously moving so every item remains easy to select.

Provider signup borrows only the reference's composition and spacing. CandidateForce branding, copy, code and photography were not copied. That style is not applied to the customer site. No image files from the owner's earlier Avatar's_Pictures folder were attached, so the provided SVGs are original placeholders with stable per-trade filenames. Replace those files with the owner's portraits when available.

## Privacy, accessibility and persistence

- Local storage contains language, theme and task IDs/quantities only. It contains no tokens, credentials, addresses, NIDs or file bytes.
- Booking requests, signup fields, uploaded file objects, schedules and workspace mutations are memory-only. Reload clears them.
- Client file checks are UX checks only; production must validate MIME signatures, sizes, malware and access server-side.
- Customer dialogs close on Escape, trap focus and restore focus. Map zones respond to Enter/Space. Inputs use visible labels. Ambient motion stops under reduced motion and while hidden.
- Theme dayparts use the visitor's local clock with fixed-hour boundaries. Astronomical sunrise/sunset, live location and SignalR tracking are not implemented.
- Google Fonts are optional external font requests. CSS includes local fallbacks; no third-party worker photos are hotlinked.
- There is no analytics, geolocation request, voice recording or hidden network call for demo data.

## Deployment and migration

Keep the current implementation in a separate branch before replacing it. This is a standalone replacement frontend monorepo; no backend or old repository has been overwritten. Run both builds and business-rule tests, review the browser QA notes, then merge into the real repository with the actual API contract. Set API origin, credential handling, CORS and production CSP explicitly. Never deploy the demo verification desk against a real identity store without server authorization.
