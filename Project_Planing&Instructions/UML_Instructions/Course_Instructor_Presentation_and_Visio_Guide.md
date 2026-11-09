# SkillCommerce ("Dokkho Lok Khuji" / "Kaarigor")
# Course Instructor Presentation & Microsoft Visio Visual Blueprint

> **Academic Project:** Capstone Enterprise Systems Engineering  
> **Programme:** IsDB-BISEW IT Scholarship Programme (Round 62 / Enterprise Systems)  
> **Architect & Lead Author:** A.H.M. Zafir Hasan  
> **Document Purpose:** Presentation script, slide-by-slide defense guide, and exact Microsoft Visio diagramming blueprint explaining the 4-Database Polyglot Architecture, ASP.NET Core 9 Backend, and Dual-Frontend (React + Angular) Ecosystem.

---

## 📑 Presentation Structure
1. [Part 1: Project Objective & Real-World Interaction Brief](#part"../UML"-1-project-objective--real-world-interaction-brief)
2. [Part 2: Visio Visual Design System (Colors, Stencils & Layout)](#part"../UML"-2-visio-visual-design-system-colors-stencils--layout)
3. [Part 3: The 4 Polyglot Databases in One Visual Illustration](#part"../UML"-3-the-4-polyglot-databases-in-one-visual-illustration)
4. [Part 4: The Application Gateway & ASP.NET Core 9 API Tier](#part"../UML"-4-the-application-gateway--aspnet-core-9-api-tier)
5. [Part 5: Dual-Frontend Web Architecture (React vs. Angular vs. MAUI)](#part"../UML"-5-dual-frontend-web-architecture-react-vs-angular-vs-maui)
6. [Part 6: Master End-to-End System Orchestration](#part"../UML"-6-master-end-to-end-system-orchestration)
7. [Part 7: Instructor Defense Q&A Cheatsheet](#part"../UML"-7-instructor-defense-qa-cheatsheet)

---

## Part 1: Project Objective & Real-World Interaction Brief

### 1.1 What to Say to Your Course Instructor (Verbal Pitch)
> *"Respected Instructor, today I present **SkillCommerce** (branded locally as **Dokkho Lok Khuji / দক্ষ লোক খুঁজি** or **Kaarigor / কারিগর**).*  
>  
> *In Bangladesh, finding reliable electricians, AC repairmen, plumbers, and mechanics relies heavily on unverified word-of-mouth or informal Facebook groups. Customers face three major pain points:*
> 1. *Zero identity verification and security risks.*
> 2. *Completely opaque pricing, especially when replacement hardware or spare parts are required.*
> 3. *Technicians arriving late with no real-time ETA or tracking.*
>  
> ***SkillCommerce** solves this by engineering a high-performance, enterprise-grade on-demand service and physical repair marketplace tailored for emerging economies. It is powered by a **Polyglot Database Architecture (4 specialized databases)**, a high-throughput **ASP.NET Core 9 Web API**, and a **Dual-Frontend Web Architecture** pairing React with Angular."*

---

### 1.2 User Personas & How People Interact with the Platform

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                   PLATFORM ACTORS                                      │
├──────────────────────────┬─────────────────────────────┬───────────────────────────────┤
│ 1. The Customer          │ 2. The Skilled Professional │ 3. The Platform Administrator │
│ (Homeowner / Consumer)   │ (Technician / Mistri)       │ (Auditor / Operations)        │
├──────────────────────────┼─────────────────────────────┼───────────────────────────────┤
│ • Uses: React Web Portal │ • Uses: .NET MAUI Field App │ • Uses: Angular Admin Console │
│ • Searches local skills  │   & Angular Provider Portal │ • Audits NID & trade licenses │
│ • Views verified badges  │ • Submits NID & credentials │ • Approves/rejects providers  │
│ • Adds repair parts cart │ • Sets base GPS & radius    │ • Moderates custom skills     │
│ • Real-time GPS tracking │ • Receives dispatch alerts  │ • Inspects double-entry audit │
│ • Approves on-site parts │ • Adds spare parts on-site  │ • Manages platform fee rates  │
│ • Settles split invoices │ • Receives labor payouts    │ • Generates payout batches    │
└──────────────────────────┴─────────────────────────────┴───────────────────────────────┘
```

---

### 1.3 Core Business Innovations to Highlight
1. **Strict Identity Verification (KYC):** Providers cannot accept bookings until an administrator verifies their National ID (NID) card and qualifications.
2. **Isolation of Platform Commission:**
   $$\text{Platform Commission} = \text{Labor Charge} \times 15\%$$
   $$\text{Physical Replacement Parts} = 0\% \text{ Commission (100\% Reimbursed to Parts Supplier/Technician)}$$
   *Technicians are never penalized when a job requires an expensive replacement compressor or motor capacitor.*
3. **Real-Time Technician Telemetry:** WebSockets (SignalR) continuously push GPS coordinates from the technician's mobile device to the customer's live tracking map.
4. **Frozen Parts Snapshots:** When replacement materials are added during diagnosis, a JSON snapshot freezes the exact specifications, warranty, and price into the relational ledger to prevent price tampering.

---

## Part 2: Visio Visual Design System (Colors, Stencils & Layout)

When building your slides or drawing your canvas in **Microsoft Visio**, use this color palette and stencil set to keep the design professional and distinct.

### 2.1 Visio Color Palette (Hex Codes)
| Component Group | Shape Accent Color | Visio Fill Color | Border Color | Text Color |
| :--- | :--- | :--- | :--- | :--- |
| **SQL Server 2022** | Microsoft Blue | `#0078D4` (Light: `#EBF3FC`) | `#004578` | `#002050` |
| **MongoDB 7.0** | Leaf Green | `#13AA52` (Light: `#E8F8EE`) | `#0E6F35` | `#043419` |
| **Redis 7.2** | Crimson Red | `#DC382D` (Light: `#FDECEA`) | `#9E2018` | `#5A0E08` |
| **Elasticsearch 8.13** | Amber / Gold | `#F5A623` (Light: `#FEF6E9`) | `#B77407` | `#593600` |
| **ASP.NET Core API** | Purple | `#512BD4` (Light: `#F1EDFD`) | `#36168F` | `#210A5B` |
| **React Customer Portal** | Cyan | `#087EA4` (Light: `#E6F7FF`) | `#05546D` | `#022936` |
| **Angular Admin Console**| Ruby Red | `#DD0031` (Light: `#FDEDF0`) | `#9B0022` | `#520012` |
| **.NET MAUI Mobile App** | Violet | `#68217A` (Light: `#F6EEF8`) | `#441450` | `#220729` |
| **Kafka Message Broker** | Dark Charcoal | `#231F20` (Light: `#EAEAEA`) | `#000000` | `#FFFFFF` |

---

### 2.2 Recommended Visio Stencils
- **Databases:** Use the standard **"Database" (Cylinder)** shape from *Software and Database > Database Software*.
- **Services / Applications:** Use **"Rounded Rectangle"** with a 2pt solid border and top accent band.
- **Microfrontends / Portals:** Use **"Desktop Client" / "Web Component"** shapes.
- **Message Queues:** Use **"Message Queue / Storage"** (horizontal cylinder or rounded pipeline).
- **Connectors:** Use **"Dynamic Connector" (Right-Angle / Orthogonal)** with arrowheads:
  - *Solid Line (2pt):* Synchronous REST / HTTPS calls.
  - *Double-headed Solid Line:* Bi-directional WebSockets (SignalR).
  - *Dashed Line:* Asynchronous Event Streaming / CDC polling.

---

## Part 3: The 4 Polyglot Databases in One Visual Illustration

### 3.1 Why 4 Databases? (The Architectural Rationale)
> *"Instructor, rather than forcing a single database engine to handle conflicting workloads, SkillCommerce implements a **Polyglot Persistence Architecture**. We match each data requirement to the specialized engine that solves it best."*

---

### 3.2 Visio Illustration Blueprint: The 4-Database Cluster

Draw a large container labeled **"Polyglot Persistence Layer"** divided into 4 distinct quadrants:

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              POLYGLOT PERSISTENCE ARCHITECTURE (4 ENGINES)                             │
├──────────────────────────────────────────────────┬─────────────────────────────────────────────────────┤
│ 🔵 1. Microsoft SQL Server 2022                  │ 🟢 2. MongoDB 7.0                                   │
│    Role: Transactional ACID Master Ledger        │    Role: Dynamic Catalog & Rich Portfolios          │
│    Port: 1433 | Engine: Relational 3NF           │    Port: 27017 | Engine: Document Store (WiredTiger)│
├──────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ • User Accounts, Identity & Roles (RBAC)         │ • Dynamic Product Specs (Volts, Watts, Dimensions)  │
│ • Service Bookings & Work Order Billing          │ • Hardware Variant Hierarchies (SKU, Brand, Models) │
│ • Provider Spatial Base Locations (Geography)    │ • Rich Technician Portfolios & Work Galleries       │
│ • Double-Entry Financial Ledger & Split Payouts  │ • Trade License & NID Scanned Document Metadata     │
│ • Immutable Parts Snapshots (JSON Column)        │ • Schema-less Field Attributes & Inspection Guides  │
│ • Transactional Outbox Messages Table            │                                                     │
│ ──────────────────────────────────────────────── │ ─────────────────────────────────────────────────── │
│ 🔑 Key Value: Zero Financial Inconsistency (ACID)│ 🔑 Key Value: Rapid Schema Evolution Without DDL    │
├──────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ 🔴 3. Redis 7.2                                  │ 🟡 4. Elasticsearch 8.13                            │
│    Role: In-Memory Cache & Distributed Lock      │    Role: Search, Discovery & Geo-Radius Scoring     │
│    Port: 6379 | Engine: In-Memory Key-Value / Lua│    Port: 9200 | Engine: Distributed Inverted Index  │
├──────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
│ • Sub-millisecond Guest & User Shopping Carts    │ • Bilingual Autocomplete (Bangla + English)         │
│ • Atomic Slot Reservation Locks (reserve_slot.lua│ • Haversine Radial Distance Scoring (<= 10km radius)│
│ • Real-time Provider Online Status (Heartbeats)  │ • Multi-Faceted Category & Skill Filtering          │
│ • Active Technician GPS Coordinates (GEOADD)     │ • Hybrid Dense Vector Search (HNSW Embeddings)      │
│ • Sliding-Window API Rate Limiters (ZSet)        │ • Product Catalog Full-Text Search                  │
│ ──────────────────────────────────────────────── │ ─────────────────────────────────────────────────── │
│ 🔑 Key Value: Zero Double-Booking Race Conditions│ 🔑 Key Value: Sub-50ms Discovery Across Thousands   │
└──────────────────────────────────────────────────┴─────────────────────────────────────────────────────┘
```

---

### 3.3 How the 4 Databases Cross-Reference Each Other (Zero FK Anomalies)
Explain to your instructor how these databases stay loosely coupled without fragile cross-database joins:
1. **`PartsForRepair.MongoProductId` (in SQL Server):** Stores the string `_id` of the MongoDB product. SQL Server does not enforce a foreign key, keeping databases decoupled.
2. **`PartsForRepair.SnapshotData` (in SQL Server):** Freezes the exact price, warranty, and title as an immutable JSON string at the exact moment the customer approves the repair.
3. **`lock:provider:{id}:slot:{time}` (in Redis):** Fast in-memory key held for 10 minutes during checkout. Once SQL Server writes the booking row, the Redis lock is cleanly released.
4. **`provider_locations.location` (in Elasticsearch):** Synchronized from SQL Server's `BaseLocation` via the Transactional Outbox pattern so geo-queries never overload the transactional SQL database.

---

## Part 4: The Application Gateway & ASP.NET Core 9 API Tier

### 4.1 What to Say to Your Course Instructor
> *"Our backend is built on **.NET 9 (ASP.NET Core Web API)** using **Clean Architecture** and **CQRS (Command Query Responsibility Segregation)** with MediatR. It isolates business domain rules from database infrastructure and presentation protocols."*

---

### 4.2 Visio Illustration Blueprint: Clean Architecture & Backend Tier

In Visio, draw an outer container for the **Application Tier** showing the clean onion/layered architecture:

```text
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                    ASP.NET CORE 9 APPLICATION TIER (CLEAN ARCHITECTURE)                 │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                API & PRESENTATION LAYER                                 │
│  ┌─────────────────────────┐  ┌───────────────────────────┐  ┌───────────────────────┐  │
│  │ REST Controllers        │  │ SignalR Real-Time Hubs    │  │ YARP Reverse Proxy    │  │
│  │ (/api/v1/bookings, etc) │  │ (/hubs/location, /booking)│  │ (Path-based Routing)  │  │
│  └────────────┬────────────┘  └─────────────┬─────────────┘  └───────────┬───────────┘  │
│               └──────────────────────┐      │      ┌─────────────────────┘              │
├──────────────────────────────────────▼──────▼──────▼────────────────────────────────────┤
│                               APPLICATION LAYER (CQRS)                                  │
│  ┌───────────────────────────────────────────────────────────────────────────────────┐  │
│  │ MediatR Pipeline: Logging -> Validation (FluentValidation) -> Concurrency Lock   │  │
│  ├─────────────────────────────────────────┬─────────────────────────────────────────┤  │
│  │ Commands (State Mutations)              │ Queries (Read Operations)               │  │
│  │ • CreateBookingCommand                  │ • GetNearbyProvidersQuery               │  │
│  │ • AddPartToBookingCommand               │ • GetCustomerActiveBookingsQuery        │  │
│  │ • ApproveVerificationDocCommand         │ • SearchCatalogProductsQuery            │  │
│  └─────────────────────────────────────────┴─────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                   DOMAIN LAYER (CORE)                                   │
│  ┌───────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Entities: ApplicationUser, ProviderProfile, ServiceBooking, BillableEntity, Order │  │
│  │ Value Objects: Money, GeoCoordinates, Address | Domain Events: BookingCreatedEvent│  │
│  └───────────────────────────────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                  INFRASTRUCTURE LAYER                                   │
│  ┌────────────────────┐ ┌────────────────────┐ ┌───────────────────┐ ┌───────────────┐  │
│  │ EF Core 9 (SQL)    │ │ MongoDB Driver     │ │ StackExchange.    │ │ Nest / Elastic│  │
│  │ NetTopologySuite   │ │ Catalog Repository │ │ Redis Multiplexer │ │ Search Client │  │
│  └────────────────────┘ └────────────────────┘ └───────────────────┘ └───────────────┘  │
│  ┌───────────────────────────────────────────┐ ┌─────────────────────────────────────┐  │
│  │ Hangfire Background Outbox Worker         │ │ Kafka / RabbitMQ Event Publisher    │  │
│  └───────────────────────────────────────────┘ └─────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Part 5: Dual-Frontend Web Architecture (React vs. Angular vs. MAUI)

### 5.1 Why Mix React and Angular in One Project? (Crucial Defense Topic)
Your instructor will likely ask: *"Why did you use both React and Angular instead of picking just one?"*

Here is the architectural defense:
> *"Instructor, enterprise applications frequently adopt specialized frontends for different personas. A customer's needs are fundamentally opposite to an administrator's needs:*
>  
> 1. ***React (Customer Web Portal):*** *Customers need extreme speed, responsive mobile-first UI, lightweight bundles, rich micro-animations, and fast interactive maps. React + Vite excels at client-side consumer discovery and e-commerce shopping carts.*
> 2. ***Angular (Admin & Provider Back-Office):*** *Administrators and operations staff manage complex workflows: auditing multi-page NID documents, KYC verification, complex reactive data tables, and financial reconciliations. Angular provides an enterprise framework out of the box with strict TypeScript, reactive RxJS observables, and built-in form validation.*
> 3. ***.NET MAUI (Technician Mobile Client):*** *Field technicians are on motorcycles or in transit. They need a native mobile app with direct access to hardware GPS sensors, background location heartbeats, and offline-resilient work orders."*

---

### 5.2 Frontend Comparison Matrix for Your Presentation Slide

| Capability | React Customer Portal | Angular Admin & Provider Console | .NET MAUI Field App |
| :--- | :--- | :--- | :--- |
| **Primary Audience** | End Customers / Homeowners | Platform Admins & Verified Providers | Skilled Technicians / Mistris |
| **Framework Version**| React 19 + Vite | Angular 18+ (Standalone Components) | .NET 9 MAUI (C# / XAML) |
| **Key Responsibilities**| • Category browsing<br/>• Hardware parts shopping cart<br/>• Live technician tracking map<br/>• Split payment checkout | • KYC / NID document audit queue<br/>• Skill catalog moderation<br/>• Financial payout ledger<br/>• Provider suspension/activation | • Live GPS telemetry streaming<br/>• Job acceptance toggle<br/>• On-site parts catalog picker<br/>• Customer sign-off capture |
| **State Management** | TanStack Query + Zustand | RxJS BehaviorSubjects + Signals | MVVM (CommunityToolkit.Mvvm) |
| **Communication** | Axios REST + SignalR JS Client | HttpClient + SignalR JS Client | Refit / HttpClient + SignalR Client |

---

## Part 6: Master End-to-End System Orchestration

In Visio, this is your **Master Slide** connecting everything together with numbered workflow arrows.

### 6.1 Visio Master System Diagram

```text
  ┌───────────────────────────────────────────────────────────────────────────────────────┐
  │                               CLIENT APPLICATIONS LAYER                               │
  │   [React Customer Portal]        [Angular Admin Console]        [.NET MAUI Mobile App]│
  └───────────────┬─────────────────────────────┬──────────────────────────────▲──────────┘
                  │ [1] Browse & Book           │ [10] Audit & Payout          │ [5] Push GPS
                  ▼                             ▼                              │ [6] Add Parts
  ┌────────────────────────────────────────────────────────────────────────────┴──────────┐
  │                         INGRESS & API GATEWAY TIER (YARP)                             │
  │     Routes: / -> React  |  /admin -> Angular  |  /api -> Web API  |  /hubs -> SignalR │
  └───────────────┬────────────────────────────────────────────────────────────▲──────────┘
                  │ [2] Route REST Request                                     │ [7] Telemetry
                  ▼                                                            │
  ┌────────────────────────────────────────────────────────────────────────────┴──────────┐
  │                       APPLICATION BACKEND (ASP.NET CORE 9)                            │
  │   ┌─────────────────────────────────────────┐  ┌───────────────────────────────────┐  │
  │   │ CoreApi Controllers & MediatR Handlers │  │ SignalR Real-Time Telemetry Hub   │  │
  │   └───────┬──────────────┬───────────────┬──┘  └─────────────────▲─────────────────┘  │
  └───────────┼──────────────┼───────────────┼───────────────────────┼────────────────────┘
              │ [3] Lock     │ [4] ACID      │ Dynamic               │ Broadcast
              │ Slot         │ Commit        │ Specs                 │ Live Map
              ▼              ▼               ▼                       │
  ┌──────────────────────┐ ┌─────────────┐ ┌─────────────┐           │
  │ Redis 7.2            │ │ SQL Server  │ │ MongoDB 7.0 │           │
  │ In-Memory Store      │ │ 2022 Core   │ │ Catalog DB  │           │
  │ • Cart:user:123      │ │ • Bookings  │ │ • Products  │           │
  │ • lock:provider:slot │ │ • Invoices  │ │ • Portfolios│           │
  │ • geo:providers      │ │ • Outbox    │ └─────────────┘           │
  └───────────┬──────────┘ └──────┬──────┘                           │
              │                   │                                  │
              └───────────────────┼──────────────────────────────────┘
                                  │ [8] Polled CDC (Hangfire)
                                  ▼
                     ┌───────────────────────────┐
                     │ Outbox Relay Worker       │
                     └────────────┬──────────────┘
                                  │ Publish Events
                                  ▼
                     ┌───────────────────────────┐
                     │ Message Broker (Kafka)    │
                     └────────────┬──────────────┘
                                  │ [9] Sync Geo & Skills
                                  ▼
                     ┌───────────────────────────┐
                     │ Elasticsearch 8.13        │
                     │ • provider_locations      │
                     │ • catalog_products        │
                     └───────────────────────────┘
```

---

### 6.2 The 10-Step Customer Booking Walkthrough (Explain This Step-by-Step)
1. **Discovery:** Customer opens the **React Portal**. React calls Elasticsearch to query verified providers within 10km offering "AC Servicing".
2. **Slot Locking:** Customer selects 3:00 PM tomorrow. Web API runs Lua script `reserve_slot.lua` in **Redis** (`lock:provider:42:slot:2026110315`). This prevents race conditions.
3. **Booking Commit:** Web API opens a local transaction in **SQL Server 2022**, inserts `BillableEntities`, `ServiceBookings` (`Status = 'Pending'`), and writes an `OutboxMessages` record. Transaction commits atomically.
4. **Technician Dispatch:** SignalR pushes a real-time job offer notification to the technician's **.NET MAUI mobile app**.
5. **Live GPS Streaming:** Technician accepts and clicks "On The Way". MAUI streams GPS coordinates every 5 seconds to `LocationHub` in **SignalR**.
6. **Live Map Rendering:** SignalR writes coordinates to **Redis** (`geo:providers`) and broadcasts the latitude/longitude to the customer's **React Portal Leaflet Map**.
7. **On-Site Parts Consumption:** Technician inspects AC and finds a blown capacitor. Technician searches catalog on MAUI app and adds *"SHIZUKI 45uF Capacitor - 650 BDT"*.
8. **Customer Instant Approval:** Customer receives an instant prompt on React to approve the 650 BDT part. Upon customer approval, SQL Server updates `PartsForRepair` and freezes a JSON snapshot.
9. **Commission Isolation Billing:** Service completes. System calculates:
   $$\text{Labor} = 1000 \text{ BDT (15\% Commission = 150 BDT Platform Fee)}$$
   $$\text{Parts} = 650 \text{ BDT (0\% Commission)}$$
   $$\text{Total Invoice} = 1650 \text{ BDT} \quad\longrightarrow\quad \text{Provider Net Payout} = 850 + 650 = 1500 \text{ BDT}$$
10. **CDC Search Index Sync:** SQL Server outbox messages are polled by **Hangfire**, published to **Kafka**, and automatically update provider rating scores in **Elasticsearch**.

---

## Part 7: Instructor Defense Q&A Cheatsheet

Prepare for these exact technical questions during your evaluation:

### Q1: "Why did you use 4 databases instead of just SQL Server?"
- **Defense Answer:**  
  *"SQL Server is phenomenal for ACID transactions, financial ledgers, and 3NF relational data. However, forcing it to handle high-frequency 5-second GPS updates from hundreds of mobile apps would cause lock escalation and disk I/O bottlenecks.  
  - We use **Redis** in-memory for sub-millisecond slot locks, ephemeral carts, and live GPS coordinates.  
  - We use **MongoDB** for unstructured hardware specs and photo portfolios that vary widely across brands without running costly SQL `ALTER TABLE` migrations.  
  - We use **Elasticsearch** for Haversine radial geo-queries and bilingual autocomplete. This keeps our core SQL Server focused purely on billing and data integrity."*

### Q2: "How do you guarantee data consistency between SQL Server and Elasticsearch without Distributed Transactions (2PC)?"
- **Defense Answer:**  
  *"Two-Phase Commit (2PC) is slow and creates tight coupling. Instead, we use the **Transactional Outbox Pattern**:  
  When a booking or provider update occurs, EF Core writes both the business entity and an `OutboxMessage` row into SQL Server in the **exact same local ACID transaction**.  
  A background Hangfire worker polls the Outbox table and publishes events to **Kafka**, which feeds **Elasticsearch**. This guarantees **at-least-once delivery** and eventual consistency with zero loss of transaction speed."*

### Q3: "What prevents two customers from booking the same technician at the same time?"
- **Defense Answer:**  
  *"We use an atomic Redis Lua script (`reserve_slot.lua`). Redis is single-threaded for command execution. When customer A requests the slot, Redis executes `SET NX PX` with a 10-minute expiry. If customer B tries to book the same slot 5 milliseconds later, Redis returns `0` immediately. Customer B is told the slot is taken before any heavy database queries occur."*

### Q4: "Why did you separate Labor and Material costs in your database schema?"
- **Defense Answer:**  
  *"In Bangladesh, mistris often mark up hardware parts secretly because existing platforms take a flat 20% cut from the entire invoice. If a technician buys a 5,000 BDT motor and the platform takes 20%, the technician loses 1,000 BDT of their own money.  
  In SkillCommerce, our SQL ledger isolates the platform commission strictly to labor charges ($ \text{Labor} \times 15\% $). Hardware parts are charged at zero commission with frozen price snapshots. This protects the technician and eliminates dishonest parts markups."*

---

## 🎨 Visio Drawing Quick-Reference Checklist

When sitting down in Microsoft Visio to draw:
- [ ] **Slide 1:** Project Vision, Problems in Bangladesh, 3 Personas (Customer, Provider, Admin).
- [ ] **Slide 2:** The 4-Database Quadrant Container (SQL Server Blue, Mongo Green, Redis Red, ES Gold).
- [ ] **Slide 3:** ASP.NET Core 9 Clean Architecture & CQRS Layers.
- [ ] **Slide 4:** Frontend Showcase (React Customer Portal vs. Angular Admin Console vs. MAUI App).
- [ ] **Slide 5:** Master Orchestration Diagram with the 10-Step Workflow Arrows.
