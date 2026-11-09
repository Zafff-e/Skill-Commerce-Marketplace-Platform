# Design and validation notes

## Requirement decisions

| Earlier requirement | Replacement approach |
|---|---|
| Two doors: hire / register | Prominent service search alongside a distinct provider invitation. |
| React + Angular | Two independent applications with shared design and business primitives. |
| Silk navbar | Restrained animated green/ochre silk lines; stationary navigation. |
| Bangladesh landscape | Original local vector river/boat/trees as a quiet landscape layer. |
| Worker-avatar browsing | Horizontal, user-controlled trade dock with original replaceable local portraits. |
| Zero-typing area selection | Selects plus keyboard-accessible clickable SVG neighbourhoods. |
| Floating worker avatars on map | Sample profile pins at area level, never precise homes. |
| Legal / hospital / document assistance | Three differentiated specialist cards and specific catalog tasks. |
| Fixed-price task cart | Quantities, labour subtotal, optional urgency, compatible provider selection or per-trade automatic assignment. |
| Court milestone tracking | Four labels with only Requested set until a server confirms further states. |
| CandidateForce registration reference | Portrait/form split and generous form card, used only for provider signup. Original branding and vector art. |
| Identity / skills / territory / price onboarding | Four stages; standardized task rates are shown in skills; identity files are local-only. |
| AI robot | Small original Jontu helper, explicitly labelled as an offline keyword guide. |
| Living day/night theme | Shared local-time dayparts with Light / Dark / Auto; no astronomy or precise location collection. |
| Continuous auto-marquee / tilting cards | Changed to manual scrolling and restrained hover feedback to make choices easier to select. |

## Checks actually completed

- React TypeScript check and production Vite build.
- Angular production compilation with strict template checks.
- Five business-rule tests: multi-task and urgent totals; invalid quantities; valid forward/terminal job states; Bangladesh phone formats; bounded allowed file formats.
- Browser customer journey: home search → worker results → map area selection → profile → task → quantity increase → urgency → checkout → sample request → Requested tracker.
- Browser provider journey: empty form rejection → sample account fields → skill selection → territory step → verification-required rejection.
- Browser provider completed job: labour 200 BDT updates completed labour to 200 and estimated net to 180 BDT.
- English and Bengali render review; Light / Auto theme behavior reviewed.
- Both portals reviewed in 390-pixel browser iframe viewports. Bengali headline wrapping was reduced and mobile inputs enlarged after that review.
- Direct customer routes changed to hash routing after static-preview refresh exposed a 404. Provider hash navigation is retained.

## Limits of validation

No real API, authentication, uploads, payments, verification, SignalR events or production worker data were available. The final document-upload success path was not submitted through the browser; upload type/size rules have unit coverage, and the form's required-document rejection was observed. The mobile check uses a narrow browser viewport, not physical Android hardware. Lighthouse scores, 4G timing, throttled frame rates, cross-browser compatibility and all daypart contrast combinations were not measured. They remain release checks for the real application.
