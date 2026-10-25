# SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
## Database Architecture & Entity Relationship Diagrams

---

## 1. Relational Core Entity Relationship Diagram (SQL Server 3NF)

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

## 2. Dual-Stream Search Sync & Event Streaming Architecture

```mermaid
flowchart TD
    subgraph Client_Applications ["Client Applications"]
        ReactCustomer["React Customer Portal & Web App"]
        AngularAdmin["Angular Provider & Admin Console"]
        MauiClient[".NET MAUI Cross-Platform App"]
    end

    subgraph API_Tier ["Application Gateway (ASP.NET Core Web API)"]
        API["CoreApi Controllers & Services"]
        OutboxRelay["Background Outbox Relay Worker (Hangfire / HostedService)"]
    end

    subgraph Relational_Core ["Relational Core (SQL Server 2022)"]
        SQL_Core[("ACID Master Tables<br/>- Users & Provider Profiles<br/>- BillableEntities, Bookings & Orders<br/>- Double-Entry Inventory Ledger<br/>- Invoices & Split Payments")]
        OutboxTable[("OutboxMessages Table<br/>Id, AggregateType, Payload, ProcessedAtUtc")]
    end

    subgraph Document_Store ["Document Catalog (MongoDB 7.0)"]
        MongoCatalog[("skillcommerce_catalog<br/>- products (Variants, Dynamic Specs)<br/>- provider_portfolios (Photos, Certs)")]
    end

    subgraph Cache_Store ["In-Memory Cache (Redis 7.2)"]
        RedisStore[("Caches & High-Concurrency Locks<br/>- Guest & User Carts<br/>- Atomic Stock Reservations (Lua)<br/>- Rate Limiting & Live Geo Coordinates")]
    end

    subgraph Search_Store ["Search & Discovery (Elasticsearch 8.13)"]
        ES_Catalog[("catalog_products Index<br/>Autocomplete, Facets, Full-Text")]
        ES_Providers[("provider_locations Index<br/>Geo-radial Queries & Skill Matching")]
    end

    subgraph Event_Brokers ["CDC & Message Streaming"]
        KafkaBroker["Message Broker (Kafka / RabbitMQ)"]
        MongoStream["MongoDB Change Streams"]
    end

    %% Client Interactions
    Client_Applications --> API
    API -->|ACID Transactions & Outbox Commit| Relational_Core
    API -->|Dynamic Catalog & Portfolio Specs| Document_Store
    API -->|Sub-millisecond Session & Cart State| Cache_Store
    API -->|Fast Autocomplete & Radial Geo Search| Search_Store

    %% Dual Stream Search Sync
    %% Stream 1: SQL Server -> Outbox -> Kafka -> Elasticsearch
    SQL_Core -.->|Atomic Insert in Same Transaction| OutboxTable
    OutboxTable -->|Polled / CDC by Relay| OutboxRelay
    OutboxRelay -->|Publish Domain Events| KafkaBroker
    KafkaBroker -->|Sync Technicians & Geo Coordinates| ES_Providers

    %% Stream 2: MongoDB -> Change Streams -> Elasticsearch
    MongoCatalog -->|Watch Insert/Update/Delete| MongoStream
    MongoStream -->|Sync Catalog Products & Variants| ES_Catalog
```

---

## 3. Polyglot Entity Reference Mapping & Contract Matrix

| Relational Table | Relational Column | Target Store | Target Collection / Key | Reference Type | Architecture Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`BillableEntities`** | `BillableEntityId` | **SQL Server** | `Orders` / `ServiceBookings` | 1-to-1 Shared Contract | Eliminates nullable foreign keys in Invoices & PaymentTransactions. |
| **`PartsForRepair`** | `InventoryItemId` | **SQL Server** | `InventoryItems.InventoryItemId` | 1-to-N FK | Deducts physical inventory upon repair completion and logs debit into ledger. |
| **`PartsForRepair`** | `SnapshotData` | **JSON Column** | *In-table JSON* | Immutable Snapshot | Freezes exact part specifications and historical unit price at moment of job. |
| **`OrderItems`** | `MongoProductId` | **MongoDB** | `products._id` | Immutable Logical ID | Preserves decoupled link to rich product attributes without cross-store FKs. |
| **`OrderItems`** | `SnapshotData` | **JSON Column** | *In-table JSON* | Immutable Snapshot | Preserves frozen price, SKU, title, and tax at exact second of checkout. |
| **`ProviderProfiles`**| `ProfileId` | **MongoDB** | `provider_portfolios.providerId`| Logical UUID | Binds technician profile to rich certifications, before/after media, and awards. |
| **`Orders` / `Cart`** | `Sku` | **Redis** | `stock:available:{sku}` | String Counter | Atomic stock verification and leasehold reservation before relational commit. |
| **`ProviderLocations`**| `Latitude`, `Longitude`| **Elasticsearch**| `provider_locations.location` | `geo_point` | Enables fast Haversine radial queries (e.g., locate technicians within 5km radius). |
| **`OutboxMessages`** | `AggregateId` | **Message Broker**| `Kafka Topic / Queue` | Event Message | Guarantees at-least-once delivery for asynchronous search syncing and notifications. |
