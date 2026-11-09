# API handoff — required before live use

## Known existing endpoints from the attached code pack

| Endpoint | Source evidence | Required work |
|---|---|---|
| `GET /api/v1/categories` | Existing category client | Map the real response to the shared typed catalog; preserve server skill IDs, rates and asset URLs. |
| `POST /api/v1/auth/login` | Existing login forms | Confirm `emailOrPhone`, response DTO, refresh-cookie behavior and current-user endpoint. Keep access tokens in memory. |
| `POST /api/v1/auth/register` | Existing customer form | Confirm fields, phone/email verification, consent version and return behavior. |
| `POST /api/v1/bookings` | Existing cart | The old payload takes one `skillId` and hardcodes customer/provider UUIDs. Do not reuse those IDs. Confirm multi-task booking and auto-assignment contracts first. |
| `/hubs/bookings` | Architecture summary | Add authenticated SignalR subscriptions after booking IDs and event schemas are confirmed. |

Provider registration in the old pack returns locally mocked profiles. Other provider/admin methods also mutate local signals. Those methods do not establish a production API contract.

## Explicit gaps

1. Multi-task cart: the new UI can bundle quantities and multiple trades; the old API example accepts only a single skill. Define a server-authoritative quote and booking-group contract or submit a coordinated request per trade with proper transaction handling. Do not drop all but the first cart item.
2. Worker assignment: derive provider IDs from actual availability results and customer identity from authenticated claims. Validate service zone, eligibility, skills and price on the server. Never rely on client-generated UUIDs for identity.
3. Booking writes: use an idempotency key retained for retries of the same logical operation; return server status and booking reference. Keep API errors as errors. Never switch a failed live write into demo success.
4. Search/discovery: verify provider-search endpoint, pagination, query schemas and neighborhood service coverage. Replace all sample names, counts, reviews and verification badges with authorized server data. Do not show exact home coordinates.
5. Registration: create/verify the account first, then submit provider profile/skills/area and separately authorized multipart document uploads. Do not store passwords, NID numbers or documents in browser persistence. Publish operator-approved privacy/terms with versioned consent.
6. Identity/admin: secure all real provider/admin routes at the API, not just in the UI. Fetch documents using short-lived, authorized URLs; redact logs; implement retention/deletion and audit records.
7. Pricing: the demo uses 10% commission deducted from labour (including urgency), not added to the customer total. Replacement parts have zero commission. The server must quote current rates, applicable tax and approved parts. Persist money as minor units/decimal server-side.
8. Job transitions: authorize the assigned provider and validate each transition server-side. Completing a job is distinct from payment settlement. Pending parts require the customer's explicit approval and cannot be included in payable earnings yet.
9. Tracking: initial request status is not proof of acceptance. Use authenticated server events for subsequent states. Never animate a worker's progress independently of actual server status.
10. Production services: online payments, SMS/OTP, real AI, voice, credential checks, uploads, notifications and payout integrations are not connected here. Connect them behind validated APIs and explicit consent before enabling UI actions.

## Suggested wiring sequence

Implement auth/current-user → catalog/quote → search → booking → provider registration/uploads → admin verification → provider job transitions → SignalR → payment and parts approvals. Use the actual ASP.NET OpenAPI output to generate DTOs rather than guessing endpoint schemas. Share contracts between React and Angular. A single HTTP adapter is provided in `shared-design/src/api.ts` for typed requests, timeouts and fail-closed demo handling.

## Development cross-origin navigation

The deployed apps share an origin (`/` and `/provider/`). For separate local development servers, set `VITE_PROVIDER_ORIGIN=http://localhost:4200` in `react-customer-portal/.env.local`. The customer links use this origin. Configure matching allowed origins on the .NET API, and use HttpOnly Secure SameSite cookies / server CSRF defenses according to your actual authentication design. Do not place secret API keys in Vite variables.
