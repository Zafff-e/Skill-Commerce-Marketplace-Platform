# SkillCommerce ("Dokkho Lok Khuji" / "Kaarigor")
## Master Project Instructions, Requirements & Architecture Guide
> **Unified Single Source of Truth**  
> *Consolidated from all planning notes, database specifications, architecture guidelines, and AI research briefs.*

---

## 📑 Table of Contents
1. [Executive Summary & Project Identity](#1-executive-summary--project-identity)
2. [Technology Stack & Architecture Matrix](#2-technology-stack--architecture-matrix)
3. [Core Business Logic & Operational Rules](#3-core-business-logic--operational-rules)
4. [System Architecture & Visual Diagrams](#4-system-architecture--visual-diagrams)
5. [Database Architecture & Data Models](#5-database-architecture--data-models)
   - 5.1 [SQL Server Relational 3NF Schema (T-SQL)](#51-sql-server-relational-3nf-schema-t-sql)
   - 5.2 [C# Entity Framework Core Domain Models](#52-c-entity-framework-core-domain-models)
   - 5.3 [Redis Key Registry & Lua Concurrency Scripts](#53-redis-key-registry--lua-concurrency-scripts)
   - 5.4 [Elasticsearch Mappings (Geo & Hybrid Vector)](#54-elasticsearch-mappings-geo--hybrid-vector)
   - 5.5 [Polyglot Integration & Entity Reference Matrix](#55-polyglot-integration--entity-reference-matrix)
6. [Comprehensive Skills Taxonomy (40+ Skills)](#6-comprehensive-skills-taxonomy-40-skills)
7. [Workspace Directory Layout & Docker Runbook](#7-workspace-directory-layout--docker-runbook)
8. [Phased Development Roadmap & Autonomous AI Prompt](#8-phased-development-roadmap--autonomous-ai-prompt)

---

## 1. Executive Summary & Project Identity

### 1.1 Project Overview & The Core Problem
In Bangladesh, hiring a trusted mistri (technician), electrician, AC repairman, plumber, appliance mechanic, or tutor is predominantly managed through word-of-mouth, unverified neighborhood directories, or informal social media groups. There is no unified platform offering verified identity badges, transparent pricing, live GPS tracking, and itemized physical spare parts costing.

**SkillCommerce** (Working Titles: **Dokkho Lok Khuji / দক্ষ লোক খুঁজি** | **Kaarigor / কারিগর** | **Sheba Now / সেবা**) solves this problem by providing a modern, hyper-local, on-demand skilled service and repair marketplace designed specifically for emerging markets.

### 1.2 Academic & Project Context
- **Project Type:** Capstone Engineering Project under the **IsDB-BISEW IT Scholarship Programme (Round 62 / Enterprise Systems)**.
- **Backend & Database Architecture Lead:** **A.H.M. Zafir Hasan** ([GitHub: @Zafff-e](https://github.com/Zafff-e)).
- **Primary Goal:** Deliver a portfolio-grade, production-quality enterprise system demonstrating advanced distributed persistence, real-time event streaming, spatial geo-matching, and dual-frontend web architecture.

### 1.3 Branding & Localized Identity
- **Primary Names:** 
  - English: `SkillCommerce`
  - Bengali: `দক্ষ লোক খুঁজি` (*Dokkho Lok Khuji*) / `কারিগর` (*Kaarigor*) / `সেবা` (*Sheba Now*)
- **Tagline Ideas:** 
  - *"আপনার এলাকায়, অভিজ্ঞ লোক"* (Experienced professionals in your neighborhood)
  - *"প্রয়োজনে দক্ষ লোক, হাতের নাগালেই।"* (Skilled professionals right at your fingertips when you need them.)
- **Bilingual Interface Snippets:**
  - `APP_NAME`: `"দক্ষ লোক খুঁজি"`
  - `SEARCH_PLACEHOLDER`: `"আপনার কী ধরনের সার্ভিস প্রয়োজন?"`
  - `SELECT_LOCATION`: `"আপনার এলাকা নির্বাচন করুন"`
  - `BOOK_NOW`: `"এখনই বুক করুন"`
  - `BECOME_A_PROVIDER`: `"দক্ষ লোক হিসেবে যোগ দিন"`

### 1.4 Key Differentiators & Competitive Advantages
1. **Real-Time Technician Tracking:** Live "technician en-route" status and coordinates pushed via SignalR (WebSockets) rather than client-side polling.
2. **Strict Identity & Skill Verification:** Providers upload NID cards, trade licenses, and certificates. Admin review gates booking eligibility, displaying verified badges to consumers.
3. **Combined Labor & Parts Costing:** Work orders itemize both service labor and physical replacement parts used on the job with immutable historical price freezes.
4. **Isolated Commission Engine:** Platform commission fees are deducted strictly from labor charges; physical hardware and replacement materials bypass platform commissions completely.
5. **Dynamic & Urgency Pricing:** Automated server-side calculations for emergency call-out fees vs scheduled bookings.
6. **Value-Add Features:**
   - **Emergency Booking Flow:** Immediate dispatch with urgency surcharges.
   - **Voice Note Description:** Customers can record audio notes explaining mechanical/electrical faults.
   - **Badge & Reward System:** `Top Rated`, `Quick Responder`, `Super Dokkho` badges earned through verified reviews and completion milestones.
   - **Dual-Frontend Architecture:** Clean separation between customer booking experience (React) and administrative/technician management (Angular).
   - **E-Commerce Hardware Catalog & Carts:** Standalone or repair-attached parts purchasing with guest shopping carts, pre-orders, and cash-on-delivery options.

---

## 2. Technology Stack & Architecture Matrix

| Layer / Responsibility | Technology Chosen | Architecture Decision & Rationale |
| :--- | :--- | :--- |
| **Backend Framework** | **ASP.NET Core Web API (.NET 9)** | Clean Architecture / Domain-Driven Design (Domain, Application, Infrastructure, API). |
| **ORM & Data Access** | **Entity Framework Core 9** | Code-First migrations with `NetTopologySuite` for high-performance spatial queries (`Point`, `Polygon`). |
| **Identity & Security** | **ASP.NET Core Identity + JWT** | Role-Based Access Control (RBAC), refresh tokens, claims-based authorization, and BCrypt/PBKDF2 hashing. |
| **Real-Time Communication** | **ASP.NET Core SignalR** | Bi-directional WebSocket channels for live booking status changes and technician en-route telemetry. |
| **Background Processing** | **Hangfire / .NET Hosted Services** | Asynchronous outbox dispatching, email/SMS notifications, and scheduled reminder workers. |
| **Customer Web Frontend** | **React (Vite / Next.js)** | Responsive, fast, light customer discovery, interactive cart, and seamless booking checkout. |
| **Admin & Provider Web Portal**| **Angular (v18+)** | Enterprise dashboard with strict TypeScript, reactive RxJS forms, and complex role-management workflows. |
| **Mobile Client App** | **.NET MAUI** *(or Flutter + Firebase)* | Cross-platform native field app for technicians (GPS telemetry, work order updates, offline sync). |
| **Relational ACID Core** | **Microsoft SQL Server 2022** | Port `1433`. Third Normal Form (3NF) master ledger, user identity, billable contracts, bookings, and outbox messages. |
| **Document Store** | **MongoDB 7.0** | Port `27017`. Dynamic product specifications, rich technician portfolios, before/after media, and unstructured specs. |
| **In-Memory Cache & Locks**| **Redis 7.2** | Port `6379`. Sub-millisecond guest/user carts, distributed provider slot locks (`SET NX PX`), and rate limiters. |
| **Search & Discovery Engine**| **Elasticsearch 8.13** | Port `9200`. Bilingual autocomplete, multi-faceted filtering, Haversine geo-distance scoring, and dense vector search. |
| **Event Streaming / CDC** | **Kafka / RabbitMQ + Outbox** | Transactional Outbox pattern guarantees at-least-once event delivery for search indexing and analytics without 2PC. |

---

## 3. Core Business Logic & Operational Rules

### 3.1 User Roles & Account Architecture
- **Standard Roles:** `SuperAdmin`, `Admin`, `Customer`, `Professional` (Provider), `Employee`.
- **System Bootstrapping:** The first registered SuperAdmin account has full authority to configure roles and promote other users to Admin status.
- **Dual-Role Capability:** One user account can seamlessly operate as both a Customer and a Professional. A registered professional can hire other skilled professionals on the platform.

### 3.2 Professional Onboarding & Verification Workflow
- **Mandatory Onboarding Fields:** Full Legal Name, NID (National Identification Number), NID Document Photo/Scan, Bio, Contact Phone, Base Location GPS (`Latitude`, `Longitude`), Service Radius (`MaxRadiusKm`), Profile Photo.
- **Verification Gate:** Anyone can register as a professional, but their profile remains in `Pending` status until an Admin reviews and approves their NID and credentials. **Unverified professionals cannot receive or accept customer bookings.**
- **Account Control:**
  - `IsActive` (Daily Availability): Controlled entirely by the professional to indicate whether they are open for new bookings today.
  - Account Status (`Approved`, `Suspended`, `Deactivated`): Admin-controlled. Admins can deactivate or suspend any account violating safety guidelines.

### 3.3 Skill Taxonomy & Custom Skill Offerings
- **Predefined Categories:** High-level classifications managed strictly by administrators (e.g., *Air Conditioning*, *Electrical*, *Plumbing*, *Electronics*).
- **Custom / Crowd-Sourced Skills:** Professionals can submit custom skills (`IsUserGenerated = 1`). User-generated skills are flagged with `IsApproved = 0` until vetted by an administrator.
- **Multi-Skill Allocation:** A professional can register multiple distinct skills, define custom hourly or base rates for each, and mark exactly **one skill as their Primary Skill**.

### 3.4 Booking Lifecycle & State Machine
Every booking follows a strict, server-side validated state transition flow:
```text
Requested (PENDING)
   ├── Cancelled (by Customer / System Timeout)
   └── Accepted (by Professional)
         ├── Cancelled (with penalty rules if applicable)
         └── OnTheWay (Live GPS telemetry active)
               └── Arrived (Technician physically on-site)
                     └── InProgress (Diagnosis & service initiated)
                           └── Completed (Work order finalized & billed)
```
- **Audit Logging:** Every state transition is recorded in `BookingStatusHistory` with the actor ID, timestamp (UTC), and optional notes.
- **Real-Time Push:** Every transition automatically emits a SignalR event to the customer and technician clients.

### 3.5 Geo-Matching Engine
- Matching checks:
  1. Professional offers the requested `SkillId`.
  2. Professional profile is `Approved` and `IsActive = 1`.
  3. The distance between the Customer's `ServiceLocation` and Provider's `BaseLocation` is $\le \text{MaxRadiusKm}$ (calculated via Haversine / NetTopologySuite spatial distance).
  4. Professional has no overlapping slot lock in Redis.

### 3.6 Financial Settlement & Fee Isolation Formula
The platform cleanly isolates platform commission fees to labor only, ensuring technicians are not penalized for costly hardware parts replaced on the job:
$$\text{Total Invoice Amount} = \text{LaborAmount} + \text{MaterialsAmount}$$
$$\text{PlatformFee} = \text{LaborAmount} \times \text{CommissionRate}$$
$$\text{Provider Payout} = (\text{LaborAmount} - \text{PlatformFee}) + \text{MaterialsAmount}$$

- **Parts Pricing Snapshots:** Unit prices and quantities for consumed materials are permanently frozen on the line items upon work order completion.
- **Payment Flows:**
  - **Pre-Paid:** Upfront labor deposit required before dispatch.
  - **Post-Paid:** Full labor and consumed materials settled upon completion.
  - **Supported Gateways:** Cash on Delivery, bKash, Nagad, Credit/Debit Cards.

---

## 4. System Architecture & Visual Diagrams

### 4.1 Master System Architecture (Polyglot & Event-Driven)

```mermaid
flowchart TD
    subgraph Client_Applications ["Client Applications"]
        ReactCustomer["React Customer Web Portal"]
        AngularAdmin["Angular Admin & Provider Console"]
        MauiClient[".NET MAUI Cross-Platform App"]
    end

    subgraph API_Gateway ["Application Tier (ASP.NET Core 9 Web API)"]
        API["CoreApi Controllers & Services (CQRS / MediatR)"]
        OutboxRelay["Background Outbox Relay Worker (Hangfire / HostedService)"]
    end

    subgraph Relational_Core ["Relational Core (SQL Server 2022)"]
        SQL_Core[("ACID Master Tables<br/>- Users & Provider Profiles<br/>- BillableEntities, Bookings & Orders<br/>- Double-Entry Inventory Ledger<br/>- Invoices & Split Payments")]
        OutboxTable[("OutboxMessages Table<br/>Id, AggregateType, Payload, ProcessedAtUtc")]
    end

    subgraph Document_Store ["Dynamic Catalog (MongoDB 7.0)"]
        MongoCatalog[("skillcommerce_catalog<br/>- products (Variants, Dynamic Specs)<br/>- provider_portfolios (Photos, Certs)")]
    end

    subgraph Cache_Store ["In-Memory Cache (Redis 7.2)"]
        RedisStore[("Caches & High-Concurrency Locks<br/>- Guest & User Carts<br/>- Atomic Stock/Slot Locks (Lua)<br/>- Live Geo Tracking & Rate Limits")]
    end

    subgraph Search_Store ["Search & Discovery (Elasticsearch 8.13)"]
        ES_Catalog[("catalog_products Index<br/>Autocomplete, Facets, Hybrid Vectors")]
        ES_Providers[("provider_locations Index<br/>Haversine Radial Queries & Skills")]
    end

    subgraph Event_Brokers ["CDC & Message Streaming"]
        KafkaBroker["Message Broker (Kafka / RabbitMQ)"]
        MongoStream["MongoDB Change Streams"]
    end

    %% Client Interactions
    Client_Applications --> API
    API -->|ACID Transactions & Outbox Commit| Relational_Core
    API -->|Dynamic Catalog & Portfolio Specs| Document_Store
    API -->|Sub-millisecond State & Slot Locks| Cache_Store
    API -->|Fast Autocomplete & Radial Geo Search| Search_Store

    %% Dual Stream Search Sync
    SQL_Core -.->|Atomic Insert in Same Transaction| OutboxTable
    OutboxTable -->|Polled / CDC by Relay| OutboxRelay
    OutboxRelay -->|Publish Domain Events| KafkaBroker
    KafkaBroker -->|Sync Technicians & Geo Coordinates| ES_Providers

    MongoCatalog -->|Watch Insert/Update/Delete| MongoStream
    MongoStream -->|Sync Catalog Products & Variants| ES_Catalog
```

---

### 4.2 Relational Core Entity-Relationship Diagram (SQL Server 3NF)

```mermaid
erDiagram
    UserRoles ||--o{ UserRoleAssignments : defines
    Users ||--o{ UserRoleAssignments : holds
    Users ||--o| ProviderProfiles : extends
    ProviderProfiles ||--o{ ProviderLocations : operates_at
    
    SkillCategories ||--o{ SkillSets : classifies
    ProviderProfiles ||--o{ ProviderSkills : provides
    SkillSets ||--o{ ProviderSkills : mapped_in
    
    Users ||--o{ BillableEntities : customer_of
    BillableEntities ||--|| ServiceBookings : binds_booking
    BillableEntities ||--|| Orders : binds_order
    
    ProviderProfiles ||--o{ ServiceBookings : fulfills
    SkillSets ||--o{ ServiceBookings : categorized_as
    ServiceBookings ||--o{ BookingStatusHistory : audits
    ServiceBookings ||--o{ PartsForRepair : consumes
    
    InventoryItems ||--o{ PartsForRepair : stocks
    InventoryItems ||--o{ InventoryLedger : tracks_history
    Users ||--o{ InventoryLedger : records
    
    Orders ||--o{ OrderItems : contains
    
    BillableEntities ||--o{ Invoices : billed_through
    BillableEntities ||--o{ PaymentTransactions : settled_with
    ProviderProfiles ||--o{ ProviderPayouts : receives
    
    ServiceBookings ||--o| ReviewsAndRatings : receives_review
    Users ||--o{ ReviewsAndRatings : authored_by
    ProviderProfiles ||--o{ ReviewsAndRatings : received_by
    ProviderProfiles ||--o{ ProviderBadges : earns
    
    Users ||--o{ OutboxMessages : triggers_event
```

---

### 4.3 End-to-End User Journeys

#### Customer Booking Journey
```text
Register / Sign In
      ↓
Browse Categories or Search by Skill & Location
      ↓
View Filtered & Ranked Verified Professionals
      ↓
Configure Booking (Scheduled Date/Time or Emergency Dispatch)
      ↓
Booking Created (PENDING) -> Distributed Slot Lock Acquired in Redis
      ↓
Provider Accepts -> Status Updated to ACCEPTED
      ↓
Provider En-Route -> Live GPS Coordinates Broadcast via SignalR
      ↓
Arrival & On-Site Inspection -> Additional Replacement Parts Added if Needed
      ↓
Customer Approves Additional Parts on Mobile/Web Portal
      ↓
Service Completed -> Immutable Invoice Generated (Labor + Approved Parts)
      ↓
Payment Recorded (Cash / bKash / Nagad / Card)
      ↓
Customer Submits Star Rating (1-5) and Written Review
```

#### Provider Onboarding & Verification Journey
```text
Register User Account
      ↓
Submit Professional Profile (Bio, Phone, Base Location, Radius)
      ↓
Select Skills Offered & Define Custom Rates
      ↓
Upload Identification Documents (NID, Trade License, Certificates)
      ↓
Account Marked as PENDING
      ↓
Admin Back-Office Audits Submitted NID & Documents
      ↓
Admin Approves Profile -> Profile Status becomes APPROVED
      ↓
Provider Toggles IsActive = 1 -> Ready to Receive Nearby Bookings
```

---

## 5. Database Architecture & Data Models

### 5.1 SQL Server Relational 3NF Schema (T-SQL)

```sql
-- =========================================================================
-- SkillCommerce Relational Core DDL (Microsoft SQL Server 2022)
-- Strict 3NF, Zero Nullable Polymorphic Keys, Immutable Financial Snapshots
-- =========================================================================

-- 1. Identity & RBAC
CREATE TABLE UserRoles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);

CREATE TABLE Users (
    UserId NVARCHAR(450) PRIMARY KEY, -- ASP.NET Core Identity GUID
    FullName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(256) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(50) NOT NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    IsVerified BIT NOT NULL DEFAULT 0,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE UserRoleAssignments (
    UserId NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES Users(UserId) ON DELETE CASCADE,
    RoleId INT NOT NULL FOREIGN KEY REFERENCES UserRoles(RoleId) ON DELETE CASCADE,
    AssignedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (UserId, RoleId)
);

-- 2. Professional Profiles & Spatial Index
CREATE TABLE ProviderProfiles (
    ProfileId INT IDENTITY(1,1) PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL UNIQUE FOREIGN KEY REFERENCES Users(UserId) ON DELETE CASCADE,
    NIDNumber NVARCHAR(50) NOT NULL UNIQUE,
    NIDDocumentUrl NVARCHAR(500) NULL,
    Bio NVARCHAR(MAX) NULL,
    ExperienceYears INT NOT NULL DEFAULT 1,
    OverallRating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Approved', 'Suspended'
    PayoutAccount NVARCHAR(100) NULL,
    BaseLocation GEOGRAPHY NOT NULL,
    MaxRadiusKm FLOAT NOT NULL DEFAULT 10.0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE SPATIAL INDEX SIX_ProviderProfiles_BaseLocation 
ON ProviderProfiles(BaseLocation);

-- 3. Skills Taxonomy & Custom Rates
CREATE TABLE SkillCategories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    IconUrl NVARCHAR(500) NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE SkillSets (
    SkillId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId INT NOT NULL FOREIGN KEY REFERENCES SkillCategories(CategoryId),
    SkillName NVARCHAR(100) NOT NULL,
    BasicPrice DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    ServiceUnit NVARCHAR(50) NOT NULL DEFAULT 'per hr', -- 'per hr', 'per job'
    IsUserGenerated BIT NOT NULL DEFAULT 0,
    CreatedByUserId NVARCHAR(450) NULL FOREIGN KEY REFERENCES Users(UserId),
    IsApproved BIT NOT NULL DEFAULT 1
);

CREATE TABLE ProviderSkills (
    ProviderSkillId INT IDENTITY(1,1) PRIMARY KEY,
    ProfileId INT NOT NULL FOREIGN KEY REFERENCES ProviderProfiles(ProfileId) ON DELETE CASCADE,
    SkillId INT NOT NULL FOREIGN KEY REFERENCES SkillSets(SkillId),
    ExperienceYears INT NOT NULL DEFAULT 1,
    CustomRate DECIMAL(18,2) NOT NULL,
    IsPrimary BIT NOT NULL DEFAULT 0,
    PortfolioUrl NVARCHAR(500) NULL,
    CONSTRAINT UQ_Provider_Skill UNIQUE (ProfileId, SkillId)
);

-- 4. Polymorphic Billable Contract
CREATE TABLE BillableEntities (
    BillableEntityId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    EntityType NVARCHAR(50) NOT NULL, -- 'ServiceBooking', 'Order'
    CustomerId NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- 5. Service Bookings & Physical Parts
CREATE TABLE ServiceBookings (
    BookingId INT IDENTITY(1,1) PRIMARY KEY,
    BillableEntityId UNIQUEIDENTIFIER NOT NULL UNIQUE FOREIGN KEY REFERENCES BillableEntities(BillableEntityId),
    CustomerId NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    ProfileId INT NOT NULL FOREIGN KEY REFERENCES ProviderProfiles(ProfileId),
    SkillId INT NOT NULL FOREIGN KEY REFERENCES SkillSets(SkillId),
    ServiceLocation GEOGRAPHY NOT NULL,
    ScheduledAt DATETIME2 NOT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Pending', -- 'Pending','Accepted','OnTheWay','Arrived','InProgress','Completed','Cancelled'
    LaborAmount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    PlatformFee DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    MaterialsAmount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    TotalAmount AS (LaborAmount + MaterialsAmount) PERSISTED,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE BookingStatusHistory (
    HistoryId INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL FOREIGN KEY REFERENCES ServiceBookings(BookingId) ON DELETE CASCADE,
    Status NVARCHAR(30) NOT NULL,
    ChangedByUserId NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    Notes NVARCHAR(500) NULL,
    ChangedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE PartsForRepair (
    PartItemId INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL FOREIGN KEY REFERENCES ServiceBookings(BookingId) ON DELETE CASCADE,
    MongoProductId NVARCHAR(100) NULL, -- Logical reference to MongoDB catalog
    ItemDescription NVARCHAR(200) NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(18,2) NOT NULL,
    LineTotal AS (Quantity * UnitPrice) PERSISTED,
    CustomerApproved BIT NOT NULL DEFAULT 0,
    SnapshotData NVARCHAR(MAX) NULL, -- Frozen JSON specification
    AddedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- 6. Financial Transactions & Ledger
CREATE TABLE PaymentTransactions (
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    BillableEntityId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES BillableEntities(BillableEntityId),
    Amount DECIMAL(18,2) NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL, -- 'UPFRONT_LABOR', 'FINAL_MATERIALS', 'FULL_SETTLEMENT'
    PaymentMethod NVARCHAR(50) NOT NULL,   -- 'Cash', 'bKash', 'Nagad', 'Card'
    GatewayReference NVARCHAR(100) NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Success', 'Failed'
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Invoices (
    InvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    BillableEntityId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES BillableEntities(BillableEntityId),
    InvoiceNumber NVARCHAR(100) NOT NULL UNIQUE,
    SubTotal DECIMAL(18,2) NOT NULL,
    PlatformCommission DECIMAL(18,2) NOT NULL,
    TotalPayable DECIMAL(18,2) NOT NULL,
    PaidStatus NVARCHAR(30) NOT NULL DEFAULT 'Unpaid',
    IssuedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- 7. Reviews & Ratings
CREATE TABLE ReviewsAndRatings (
    ReviewId INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES ServiceBookings(BookingId),
    CustomerId NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    ProfileId INT NOT NULL FOREIGN KEY REFERENCES ProviderProfiles(ProfileId),
    Rating TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(MAX) NULL,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

-- 8. Transactional Outbox Pattern
CREATE TABLE OutboxMessages (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    AggregateType NVARCHAR(100) NOT NULL,
    AggregateId NVARCHAR(100) NOT NULL,
    Type NVARCHAR(100) NOT NULL,
    Payload NVARCHAR(MAX) NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ProcessedAtUtc DATETIME2 NULL,
    Error NVARCHAR(MAX) NULL
);
```

---

### 5.2 C# Entity Framework Core Domain Models

```csharp
using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Identity;
using NetTopologySuite.Geometries;

namespace SkillCommerce.Domain.Entities
{
    public class ApplicationUser : IdentityUser
    {
        public string FullName { get; set; } = string.Empty;
        public bool IsVerified { get; set; }
        public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

        public ProviderProfile? ProviderProfile { get; set; }
        public ICollection<ServiceBooking> CustomerBookings { get; set; } = new List<ServiceBooking>();
    }

    public class ProviderProfile
    {
        public int ProfileId { get; set; }
        public string UserId { get; set; } = null!;
        public string NIDNumber { get; set; } = null!;
        public string? NIDDocumentUrl { get; set; }
        public string? Bio { get; set; }
        public int ExperienceYears { get; set; } = 1;
        public decimal OverallRating { get; set; }
        public string Status { get; set; } = "Pending";
        public string? PayoutAccount { get; set; }
        public Point BaseLocation { get; set; } = null!;
        public double MaxRadiusKm { get; set; } = 10.0;
        public bool IsActive { get; set; } = true;

        public ApplicationUser User { get; set; } = null!;
        public ICollection<ProviderSkill> ProviderSkills { get; set; } = new List<ProviderSkill>();
        public ICollection<ServiceBooking> AssignedBookings { get; set; } = new List<ServiceBooking>();
    }

    public class SkillSet
    {
        public int SkillId { get; set; }
        public int CategoryId { get; set; }
        public string SkillName { get; set; } = null!;
        public decimal BasicPrice { get; set; }
        public string ServiceUnit { get; set; } = "per hr";
        public bool IsUserGenerated { get; set; }
        public bool IsApproved { get; set; } = true;

        public ICollection<ProviderSkill> ProviderSkills { get; set; } = new List<ProviderSkill>();
    }

    public class ProviderSkill
    {
        public int ProviderSkillId { get; set; }
        public int ProfileId { get; set; }
        public int SkillId { get; set; }
        public int ExperienceYears { get; set; }
        public decimal CustomRate { get; set; }
        public bool IsPrimary { get; set; }
        public string? PortfolioUrl { get; set; }

        public ProviderProfile Profile { get; set; } = null!;
        public SkillSet Skill { get; set; } = null!;
    }

    public class ServiceBooking
    {
        public int BookingId { get; set; }
        public Guid BillableEntityId { get; set; }
        public string CustomerId { get; set; } = null!;
        public int ProfileId { get; set; }
        public int SkillId { get; set; }
        public Point ServiceLocation { get; set; } = null!;
        public DateTime ScheduledAt { get; set; }
        public string Status { get; set; } = "Pending";
        public decimal LaborAmount { get; set; }
        public decimal PlatformFee { get; set; }
        public decimal MaterialsAmount { get; set; }
        public decimal TotalAmount { get; private set; } // Computed in SQL

        public ProviderProfile Profile { get; set; } = null!;
        public SkillSet Skill { get; set; } = null!;
        public ICollection<PartForRepair> ConsumedParts { get; set; } = new List<PartForRepair>();
        public ICollection<BookingStatusHistory> StatusHistory { get; set; } = new List<BookingStatusHistory>();
    }

    public class PartForRepair
    {
        public int PartItemId { get; set; }
        public int BookingId { get; set; }
        public string? MongoProductId { get; set; }
        public string ItemDescription { get; set; } = null!;
        public int Quantity { get; set; } = 1;
        public decimal UnitPrice { get; set; }
        public decimal LineTotal { get; private set; } // Computed in SQL
        public bool CustomerApproved { get; set; }
        public string? SnapshotData { get; set; }

        public ServiceBooking Booking { get; set; } = null!;
    }
}
```

---

### 5.3 Redis Key Registry & Lua Concurrency Scripts

#### Redis Key Namespaces
- **Provider Slot Lock:** `lock:provider:{profileId}:slot:{yyyyMMdd}:{hourSlot}` (TTL: 10 mins).
- **Ephemeral Guest/User Cart:** `cart:{userIdOrGuestId}` (TTL: 7 days).
- **Provider Online Status Heartbeat:** `provider:online:{profileId}` (TTL: 90 secs).
- **Sliding-Window Rate Limiter:** `ratelimit:{ip}:{endpoint}` (TTL: 1 min).

#### Atomic Slot / Stock Reservation Script (`reserve_stock.lua`)
```lua
-- KEYS[1]: lock key, ARGV[1]: holder token (e.g., booking ID/cart ID), ARGV[2]: TTL in milliseconds
if redis.call("EXISTS", KEYS[1]) == 1 then
    return 0 -- Slot or stock already reserved
else
    redis.call("SET", KEYS[1], ARGV[1], "PX", ARGV[2])
    return 1 -- Successfully reserved lock
end
```

#### Atomic Slot Release Script (`release_stock.lua`)
```lua
-- KEYS[1]: lock key, ARGV[1]: holder token
if redis.call("GET", KEYS[1]) == ARGV[1] then
    return redis.call("DEL", KEYS[1])
else
    return 0
end
```

---

### 5.4 Elasticsearch Mappings (Geo & Hybrid Vector)

Index: `provider_locations`
```json
{
  "mappings": {
    "properties": {
      "profile_id": { "type": "integer" },
      "full_name": { "type": "text", "analyzer": "standard" },
      "skills": { "type": "keyword" },
      "overall_rating": { "type": "float" },
      "location": { "type": "geo_point" },
      "max_radius_km": { "type": "float" },
      "is_active": { "type": "boolean" },
      "bio_vector": {
        "type": "dense_vector",
        "dims": 1536,
        "index": true,
        "similarity": "cosine",
        "index_options": { "type": "int8_hnsw" }
      }
    }
  }
}
```

---

### 5.5 Polyglot Integration & Entity Reference Matrix

| Relational Table (SQL Server) | Column | Target Store | Target Key / Collection | Reference Type | Architecture Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`BillableEntities`** | `BillableEntityId` | **SQL Server** | `ServiceBookings` / `Orders` | 1-to-1 Shared Contract | Eliminates nullable foreign keys in `Invoices` & `PaymentTransactions`. |
| **`PartsForRepair`** | `MongoProductId` | **MongoDB** | `products._id` | Immutable Logical ID | Decoupled link to hardware catalog attributes without cross-store foreign keys. |
| **`PartsForRepair`** | `SnapshotData` | **JSON Column** | *In-table JSON* | Immutable Snapshot | Freezes exact part specifications and unit price at moment of job completion. |
| **`ProviderProfiles`** | `ProfileId` | **MongoDB** | `provider_portfolios.providerId` | Logical UUID | Binds technician profile to rich certifications, before/after media, and awards. |
| **`ServiceBookings`** | `ProfileId` + Slot | **Redis** | `lock:provider:{id}:slot:{time}` | String Lock | Prevents slot double-booking during checkout. |
| **`ProviderProfiles`** | `BaseLocation` | **Elasticsearch**| `provider_locations.location` | `geo_point` | Enables fast Haversine radial queries (find technicians within $X$ km radius). |
| **`OutboxMessages`** | `AggregateId` | **Message Broker**| `Kafka Topic / Queue` | Event Message | Guarantees at-least-once delivery for asynchronous search syncing and notifications. |

---

## 6. Comprehensive Skills Taxonomy (40+ Skills)

### 6.1 Home Maintenance, Trades & Mechanical
- **AC Technicians:** Jet wash servicing, VRF maintenance, compressor replacement, gas refills.
- **Electricians & Wiring Specialists:** Short-circuit diagnostics, IPS/generator setup, DB board wiring.
- **Plumbers & Sanitary Mechanics:** Pipe leak repairs, bathroom fittings, water pump installations.
- **Appliance Repair:** Refrigerator cooling repair, microwave ovens, geysers, washing machines.
- **Carpenters & Woodworkers:** Custom furniture fabrication, modular kitchen assembly, door fitting.
- **Painters & Polishers:** Interior/exterior wall painting, waterproofing, wood lacquer polish.
- **Masons & Civil Contractors:** Tile laying, wall plastering, concrete repairs.
- **Thai Aluminum & SS Workers:** Sliding windows, glass partitions, stainless steel railings.
- **Locksmiths:** High-security lock installation, emergency lock picking, master key duplication.
- **Automotive & Motorcycle Mechanics:** On-demand bike servicing, car breakdown diagnostics, battery jump-starts.

### 6.2 Cleaning, Pest Control & Healthcare
- **Deep Cleaning Specialists:** Full-apartment deep clean, kitchen degreasing, water tank cleaning.
- **Pest Control Exterminators:** Termite treatments, cockroach extermination, bedbug eradication.
- **Senior Caregivers & Attendants:** Elderly patient assistance, mobility support.
- **Certified Home Nurses:** Post-operative dressing, IV administration, catheter maintenance.
- **Babysitters & Child Caretakers:** On-demand verified childcare.
- **Physiotherapists (Home Visits):** Stroke recovery, orthopedic physical therapy, posture therapy.
- **Medical Sample Collectors:** Home blood collection and diagnostic pathology transport.

### 6.3 Tech, Freelance & Enterprise Support
- **IT & Electronics Technicians:** Laptop motherboard repair, desktop troubleshooting, printer repairs.
- **Network Engineers:** Enterprise Wi-Fi setup, Cat6 cabling, Mikrotik/Cisco router configuration.
- **CCTV & Smart Security Specialists:** IP camera installations, DVR/NVR setup, biometric access control.
- **Software Developers & Web Consultants:** ASP.NET Core, React, Node.js solutions, API development.
- **UI/UX Designers & Graphics:** Figma prototypes, branding identity, promotional banners.
- **Data Entry & Virtual Assistants:** Office document management, catalog data entry.

### 6.4 Logistics, Moving & Personal Services
- **Packers & Movers:** Residential shifting, office relocation, bubble wrapping.
- **Professional Chauffeurs:** On-demand daily car drivers, inter-district highway chauffeurs.
- **Home Chefs & Event Caterers:** Party catering, daily chef assistance.
- **Beauticians & Salon Experts:** Bridal makeup, mehendi artistry, waxing, hair styling.
- **Men's Grooming:** Home haircutting, beard grooming, facial massage.
- **Photographers & Videographers:** Event photography, product catalog photoshoots.
- **Home Tutors & Academic Trainers:** STEM subject tutors, language coaches, coding mentors.

---

## 7. Workspace Directory Layout & Docker Runbook

### 7.1 Unified Repository Layout
```text
Project_SkillCommerce/
├── DataBase/
│   ├── docker-compose.yml              # Local multi-container environment (SQL, Mongo, Redis, ES)
│   ├── README.md                       # Setup instructions & connection strings
│   ├── Diagram.md                      # Mermaid ERD & Dual-Stream CDC Architecture
│   ├── DBInstructionsToFollow.md       # Multi-database folder structure specification
│   ├── relational/                     # Microsoft SQL Server (Transactional Core)
│   │   ├── migrations/                 # Idempotent versioned DDL files (001 to 009)
│   │   └── seeds/                      # dev_seed.sql localized baseline test data
│   ├── document/                       # MongoDB 7.0 (Product Catalog, Portfolios)
│   │   ├── collections/                # Strict JSON Schema validation definitions
│   │   ├── indexes/                    # Compound, text, and unique index definitions
│   │   └── seeds/                      # initial_products.json
│   ├── cache/                          # Redis 7.2 (Carts, Rate Limits, Locks)
│   │   ├── key-registry.md             # Key namespaces, TTLs, and eviction policy
│   │   └── scripts/                    # reserve_stock.lua, release_stock.lua
│   └── search/                         # Elasticsearch 8.13 (Search & Discovery)
│       ├── mappings/                   # catalog_mapping.json, provider_geo_mapping.json
│       └── pipelines/                  # ingest_pipeline.json
├── Skill-Based_E-Commerce_Platform-Project/
│   ├── Backend/                        # ASP.NET Core 9 Web API (Clean Architecture)
│   │   ├── SkillCommerce.Domain/
│   │   ├── SkillCommerce.Application/
│   │   ├── SkillCommerce.Infrastructure/
│   │   └── SkillCommerce.Api/
│   └── Frontend/
│       ├── react-customer-portal/      # React + Vite customer booking app
│       └── angular-admin-console/      # Angular provider & back-office dashboard
├── MauiMobileApp_SkillServicePlatform/ # .NET MAUI cross-platform technician mobile app
└── Project_Planing&Instructions/       # Master specifications and planning documentation
    └── InstructionsGuide.md            # (This Document) Single Source of Truth
```

### 7.2 Connection Strings & Local Docker Credentials
```ini
# Microsoft SQL Server 2022 (Port 1433)
Server=localhost,1433;Database=SkillCommerceDb;User Id=sa;Password=SkillCommerce@Pass2026!;TrustServerCertificate=True;MultipleActiveResultSets=True;

# MongoDB 7.0 (Port 27017)
mongodb://mongoadmin:MongoSkillCommerce2026!@localhost:27017/skillcommerce_catalog?authSource=admin

# Redis 7.2 (Port 6379)
localhost:6379,password=RedisSkillCommerce2026!,abortConnect=false

# Elasticsearch 8.13 (Port 9200)
http://localhost:9200
```

### 7.3 Multi-Database Initialization Runbook

#### Step 1: Boot Multi-Container Environment
```bash
cd DataBase
docker compose up -d
docker compose ps
```

#### Step 2: Apply SQL Server Migrations (PowerShell)
```powershell
$saPass = "SkillCommerce@Pass2026!"
$scripts = Get-ChildItem -Path ./relational/migrations/*.sql | Sort-Object Name

foreach ($script in $scripts) {
    Write-Host "Applying $($script.Name)..."
    docker exec -i skillcommerce_sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $saPass -C -i "/docker-migrations/$($script.Name)"
}

# Run seed data:
docker exec -i skillcommerce_sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $saPass -C -i "/docker-seeds/dev_seed.sql"
```

#### Step 3: Initialize MongoDB Collections & Indexes
```bash
docker exec -i skillcommerce_mongodb mongosh -u mongoadmin -p MongoSkillCommerce2026! --authenticationDatabase admin /docker-entrypoint-initdb.d/indexes/create_indexes.js
```

#### Step 4: Register Elasticsearch Mappings
```bash
curl -X PUT "http://localhost:9200/provider_locations" -H "Content-Type: application/json" -d @search/mappings/provider_geo_mapping.json
curl -X PUT "http://localhost:9200/catalog_products" -H "Content-Type: application/json" -d @search/mappings/catalog_mapping.json
```

---

## 8. Phased Development Roadmap & Autonomous AI Prompt

### 8.1 Phased Implementation Roadmap
- **Phase 1: Persistence Layer & Foundations**
  - Launch Docker Compose data stores.
  - Verify SQL Server 3NF migrations, spatial indexes, and seed records.
  - Register Redis Lua scripts and Elasticsearch templates.
- **Phase 2: ASP.NET Core 9 Web API Core**
  - Scaffold Clean Architecture layers (`Domain`, `Application`, `Infrastructure`, `API`).
  - Configure EF Core DbContext with `NetTopologySuite`.
  - Implement Identity authentication and JWT issuance with RBAC.
  - Configure Transactional Outbox background relay.
- **Phase 3: Booking Engine & Geo-Matching**
  - Create CQRS booking commands (`CreateBookingCommand`, `AcceptBookingCommand`).
  - Implement Redis slot lock check to prevent concurrent booking conflicts.
  - Build `GET /api/v1/providers/nearby` spatial endpoint using distance queries.
- **Phase 4: Materials Invoicing & Split Payments**
  - Implement ad-hoc replacement parts appendage (`AddBookingMaterialCommand`).
  - Create invoice generation isolating platform commission to labor amounts.
  - Implement mock payment webhook for bKash, Nagad, and Cash on Delivery.
- **Phase 5: Real-Time SignalR & Background Jobs**
  - Build `BookingHub` for live status broadcasts and technician GPS coordinate streaming.
  - Configure Hangfire for email/SMS notifications and booking timeout expirations.
- **Phase 6: Frontends & Dashboards**
  - Build the React customer portal (search, provider card, booking modal, tracking).
  - Build the Angular back-office console (NID verification, skill approval, revenue charts).
  - Build or connect the .NET MAUI field mobile app for technicians.

---

### 8.2 Master Execution Prompt for Autonomous AI Coding Agents
When directing autonomous coding agents (Google Antigravity, Claude Code, Cursor) to execute code in this repository, provide this prompt:

```text
/plan You are the lead enterprise software architect and full-stack engineer implementing the "SkillCommerce" platform following @InstructionsGuide.md.

Execute the following implementation phases sequentially:
1. Adhere strictly to the polyglot data boundaries: SQL Server for ACID transactions, MongoDB for dynamic catalog/portfolios, Redis for slots and carts, and Elasticsearch for search.
2. Implement ASP.NET Core 9 Clean Architecture with Entity Framework Core and NetTopologySuite for spatial calculations.
3. Isolate platform commission fees strictly to service labor; physical replacement parts must bypass commission deductions.
4. Use SignalR for real-time booking lifecycle updates and en-route tracking.
5. Provide a step-by-step implementation plan before generating or modifying code files.
```
