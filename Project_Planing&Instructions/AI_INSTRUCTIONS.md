# SkillCommerce AI Architecture & Implementation Guide

> **Document Type:** Consolidated Single Source of Truth for Artificial Intelligence & Automation  
> **Platform:** SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)  
> **Target Framework:** ASP.NET Core (.NET 9/10), C# 13/14, `Microsoft.Extensions.AI`  
> **Status:** Canonical & Deduplicated Specification  

---

## 1. System Vision & Purpose

The AI subsystem in SkillCommerce automates high-volume operational workflows—voice request intake, provider matching, natural language search, NID pre-verification, review synthesis, and tier-1 customer assistance—while keeping human operators in decisive control of high-risk actions.

### 1.1 Target Automation Metric
- **Automation Rate with Human Fallback:** The platform targets auto-handling ~80% of routine cases while routing the uncertain ~20% to an administrative or human review queue with a pre-generated summary. "Zero humans" is explicitly not an architectural goal.

### 1.2 Core Architectural Invariants
| Topic | Architectural Decision |
| :--- | :--- |
| **Budget Policy** | Strictly Free-Tier First (Google Gemini API via Google AI Studio, Groq / local Ollama fallback). |
| **Ownership & Boundaries** | Contained within dedicated AI layers; no model keys or direct LLM SDK calls are ever embedded in frontend (React/Angular) or mobile clients. |
| **Languages Supported** | Standard English, Bengali (বাংলা), and transliterated Banglish. |
| **Datastores** | Zero new unmanaged databases. AI leverages existing SQL Server 2022 (`AiDecisionLogs`), Redis 7.2 (caching & rate limits), and Elasticsearch (vector / hybrid search). |
| **Abstraction Layer** | `Microsoft.Extensions.AI` standard abstractions (`IChatClient`, `IEmbeddingGenerator`). |

---

## 2. Non-Negotiable Operational & Security Boundaries

Every AI feature implementation must strictly adhere to the following 10 invariants. Any proposed deviation must be stopped and escalated:

1. **AI Never Decides Money:** Pricing, commissions, parts totals, refund amounts, and final invoice calculations are strictly computed by deterministic C# code. AI models may only provide informational, non-binding estimated ranges labeled explicitly as `"estimate"`.
2. **Structured Output Only:** All LLM invocations must require JSON schema outputs deserializing into strongly-typed C# records. Every model output is treated as untrusted input and validated via `FluentValidation` before business processing.
3. **Confidence Thresholds & Human-in-the-Loop:** Every feature defines configurable thresholds (`AutoThreshold` e.g., 0.85, and `ReviewThreshold` e.g., 0.60). Outputs falling below `AutoThreshold` are routed to an administrative queue for human approval.
4. **Comprehensive Audit Logging:** Every AI execution is logged into the `AiDecisionLogs` table with feature name, model identifier, sanitized input reference, raw output JSON, confidence score, token consumption, latency, and human override flag.
5. **Prompt Injection Hardening:** Untrusted customer messages, reviews, OCR transcripts, and voice data must be wrapped in strict XML/markdown delimiters with explicit system instructions prohibiting instruction override. LLM outputs must never be executed as SQL, shell commands, or arbitrary URLs.
6. **Scoped Tool-Calling Security:** Autonomous tool calling (e.g., support agent) executes exclusively under the authenticated user's session claims, calling only whitelisted internal functions. Every tool invocation validates entity ownership and state-machine preconditions server-side.
7. **Graceful Degradation:** When an AI provider is unreachable, throttled, or feature-flagged off, the platform falls back seamlessly to standard manual forms and deterministic workflows without throwing 500 errors.
8. **Feature Flagging:** Every individual AI feature must be independently togglable in configuration (`Ai:Features:{FeatureName}:Enabled`).
9. **PII Minimization & Synthetic Data:** Only minimal necessary fields are dispatched to external AI APIs. Real identity cards or live financial credentials must never be sent to public free-tier models during development or testing; use synthetic test data.
10. **Truthful Content Disclosure:** No AI-generated summary or response may be disguised as human-written. AI-generated text must be visually badged (e.g., `"AI Summary"`).

---

## 3. Project Layering & Clean Architecture Structure

AI capabilities follow the project's Clean Architecture structure without circular dependencies:

```text
Backend/src/
├── SkillCommerce.Domain/
│   └── Entities/Ai/
│       ├── AiDecisionLog.cs            # Persistent audit trail of all model calls
│       └── AiInteractionSession.cs     # Multi-turn customer support sessions
│
├── SkillCommerce.Application/
│   └── Common/Interfaces/Ai/
│       ├── IAiProviderService.cs       # Core LLM text & multimodal contract
│       ├── IVoiceIntakeService.cs      # Voice note to service request extraction
│       ├── IProviderMatchingService.cs # Recommendation and ranking engine
│       ├── IDocumentOcrService.cs      # NID and trade certification verification
│       └── IReviewAnalysisService.cs   # Sentiment and review summarization
│
├── SkillCommerce.Infrastructure/
│   └── Services/Ai/
│       ├── GeminiAiProviderService.cs  # Google AI Studio Gemini REST / SDK client
│       ├── GroqAiProviderService.cs    # Secondary fallback provider
│       └── RedisAiRateLimiter.cs       # Sliding window rate limiter for AI calls
│
└── SkillCommerce.Api/
    └── Controllers/v1/
        ├── AiIntakeController.cs       # Voice & text intake endpoints
        ├── AiMatchingController.cs     # Provider recommendations
        └── AiSupportController.cs      # Interactive customer assistance
```

---

## 4. Provider Strategy & Free-Tier Operational Resilience

### 4.1 Recommended Provider Matrix
- **Primary Chat, Extraction & Vision:** Google Gemini API (`gemini-1.5-flash` or `gemini-2.0-flash`) via Google AI Studio free tier. Native support for structured JSON schemas, multimodal image/audio processing, and Bengali/English linguistic nuances.
- **Secondary / Offline Fallback:** Groq free tier (`llama-3.3-70b-versatile`) or local Ollama instances for dev environments.
- **Vector Embeddings:** Google Gemini `text-embedding-004` (768 dimensions). The Elasticsearch index mapping for `dense_vector` must match the model's output dimensions (768).

### 4.2 Rate Limiting & Background Job Handling
- **Redis Rate Limiting:** Enforce a per-user sliding window cap using Redis key `ratelimit:{userId}:ai:{feature}` to prevent free-tier exhaustion.
- **Hangfire Async Queues:** Non-blocking operations (NID OCR pre-checks, review batch summarization, anomaly detection) must be enqueued via Hangfire with exponential backoff and jitter.

### 4.3 Configuration Blueprint (`appsettings.json`)
```json
{
  "Ai": {
    "Provider": "Gemini",
    "ApiKey": "",
    "Models": {
      "Fast": "gemini-1.5-flash",
      "Smart": "gemini-1.5-pro",
      "Embedding": "text-embedding-004"
    },
    "EmbeddingDimensions": 768,
    "Features": {
      "VoiceIntake": { "Enabled": true, "AutoThreshold": 0.85, "ReviewThreshold": 0.60 },
      "ProviderMatching": { "Enabled": true, "AutoThreshold": 0.80 },
      "NidVerification": { "Enabled": true, "AutoThreshold": 0.90, "ReviewThreshold": 0.70 },
      "ReviewSummaries": { "Enabled": true, "AutoThreshold": 0.80 },
      "SupportAgent": { "Enabled": true, "MaxTurns": 10 }
    }
  }
}
```

---

## 5. Concrete Feature Specifications

### 5.1 Bilingual Voice-to-Service-Request Intake
- **Input:** Audio file (WAV, MP3, AAC, WebM, max 10MB, max 120s) recorded from customer browser or mobile device, or raw text in Bengali, English, or Banglish.
- **Processing:** Multimodal Gemini call combining transcription and entity extraction in a single step to minimize API calls.
- **Output Record:**
  ```json
  {
    "detectedLanguage": "bn",
    "categorySlug": "electrician",
    "skillSlug": "circuit-breaker-tripping",
    "problemDescription": "ফ্রিজের লাইন বারবার ট্রিপ করছে। সম্ভবত শর্ট সার্কিট।",
    "urgency": "Urgent",
    "locationArea": "Mirpur-10",
    "extractedDetails": { "deviceType": "Refrigerator", "brand": "Walton" },
    "confidenceScore": 0.92
  }
  ```
- **UX Invariant:** Never automatically post a booking. The extracted parameters pre-fill the customer's request form, requiring explicit user review and confirmation before submission.

### 5.2 Explainable Provider Recommendations
- **Approach:** Hybrid multi-stage filtering:
  1. *Hard Database Filtering:* Active verified status (`IsVerified == true`), geographical service zone coverage (within radius via SQL Server spatial or Redis Geo), and matching trade skill.
  2. *Score Ranking:* Composite weighted ranking:
     $$\text{Score} = (0.35 \times \text{DistanceScore}) + (0.30 \times \text{RatingScore}) + (0.20 \times \text{CompletionRate}) + (0.15 \times \text{SemanticSkillMatch})$$
  3. *Advisory Explanation Generation:* Short human-readable reasoning badge (e.g., `"Top rated for AC leak repair in Dhanmondi, 1.2 km away"`).

### 5.3 Automated NID & Trade Certificate Pre-Verification
- **Input:** Front and back images of Bangladeshi National ID (NID) or technical certification card submitted by onboarding provider.
- **Processing:** Vision OCR extracts NID Number, Full Name (Bangla & English), Date of Birth, and visual artifact integrity.
- **Safety Gate:** AI never activates a provider. If `confidenceScore >= 0.90` and extracted name matches the registered profile name, the system flags the profile as `PreChecked` for human admin review. If below threshold, flags for manual verification.

### 5.4 Verified Review Sentiment & Digest Summaries
- **Input:** Aggregated reviews of a provider (minimum 5 verified customer reviews).
- **Processing:** Summarizes common strengths, recurrent issues, and punctuality patterns into a concise 3-bullet summary with sentiment categorization (`Positive`, `Neutral`, `Mixed`, `Negative`).
- **Rule:** Displayed with an explicit `"AI-Generated Summary from {N} verified reviews"` attribution.

### 5.5 Scoped Customer Support Assistant
- **Mode:** Stateless or Redis-cached multi-turn chat assistant.
- **Tools Available to Model:**
  - `GetMyBookingStatus(Guid bookingId)`
  - `GetCancelPolicy(Guid bookingId)`
  - `FindServiceCategories(string keyword)`
- **Safety Constraint:** Before invoking any tool function, the server asserts that the `bookingId` belongs strictly to the authenticated caller's `UserId`. The model cannot initiate cancellations or refund payouts autonomously.

---

## 6. Audit Logging Data Model (`AiDecisionLogs`)

All AI operations must persist to the transactional database table `AiDecisionLogs`:

```sql
CREATE TABLE [dbo].[AiDecisionLogs] (
    [Id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    [FeatureName] NVARCHAR(64) NOT NULL,
    [ModelIdentifier] NVARCHAR(128) NOT NULL,
    [UserId] NVARCHAR(450) NULL,
    [EntityReferenceId] NVARCHAR(128) NULL,
    [InputContextSummary] NVARCHAR(MAX) NOT NULL,
    [RawOutputPayload] NVARCHAR(MAX) NOT NULL,
    [ConfidenceScore] DECIMAL(5,4) NOT NULL,
    [LatencyMilliseconds] INT NOT NULL,
    [PromptTokens] INT NOT NULL DEFAULT 0,
    [CompletionTokens] INT NOT NULL DEFAULT 0,
    [RoutingOutcome] NVARCHAR(32) NOT NULL, -- 'AutoApproved', 'HumanReviewQueued', 'Rejected'
    [WasHumanOverridden] BIT NOT NULL DEFAULT 0,
    [HumanReviewerId] NVARCHAR(450) NULL,
    [HumanFeedbackNotes] NVARCHAR(1000) NULL,
    [CreatedAtUtc] DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX [IX_AiDecisionLogs_Feature_Created] ON [dbo].[AiDecisionLogs]([FeatureName], [CreatedAtUtc] DESC);
```

---

## 7. Verification & Testing Standards

- **Unit Tests:** Mock `IChatClient` using `NSubstitute` to verify that invalid JSON payloads gracefully trigger the fallback mechanism without crashing.
- **Schema Validation Tests:** Ensure `FluentValidation` rejects incomplete or malformed LLM responses.
- **Degradation Tests:** Simulate 429 Too Many Requests and 503 Service Unavailable responses from Gemini to assert that customer flows continue manually.

