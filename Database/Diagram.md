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
    
    Users ||--o{ ServiceBookings : requests
    ProviderProfiles ||--o{ ServiceBookings : delivers
    SkillSets ||--o{ ServiceBookings : under_skill
    ServiceBookings ||--o{ BookingStatusHistory : audits
    ServiceBookings ||--o{ PartsForRepair : consumes
    
    Users ||--o{ Orders : places
    Orders ||--o{ OrderItems : contains
    
    InventoryItems ||--o{ InventoryLedger : tracks_history
    
    Orders ||--o| Invoices : billed_via
    ServiceBookings ||--o| Invoices : billed_via
    Orders ||--o{ PaymentTransactions : settled_with
    ServiceBookings ||--o{ PaymentTransactions : settled_with
    ProviderProfiles ||--o{ ProviderPayouts : receives
    
    ServiceBookings ||--o| ReviewsAndRatings : receives_review
    Users ||--o{ ReviewsAndRatings : author
    ProviderProfiles ||--o{ ReviewsAndRatings : subject
    ProviderProfiles ||--o{ ProviderBadges : earns
```

---

## 2. Polyglot Persistence Architecture & Data Flow

```mermaid
graph TD
    Client["Client Frontends (Angular Admin, React Customer Web, MAUI Mobile)"] --> Gateway["ASP.NET Core Web API Gateway"]
    
    subgraph Storage_Tiers ["Polyglot Data Stores"]
        SQL["SQL Server 2022 (ACID Core)<br/>Users, Bookings, Orders, Ledger, Payments"]
        Mongo["MongoDB 7.0 (Catalogs & Dynamic Specs)<br/>Products, Dynamic Attributes, Portfolios"]
        Redis["Redis 7.2 (Cache & In-Memory)<br/>Carts, Stock Reservations, Sessions, Rate Limits"]
        ES["Elasticsearch 8.13 (Search & Discovery)<br/>Full-text Autocomplete, Geo-matching"]
    end
    
    Gateway -->|ACID Transactions| SQL
    Gateway -->|Document Queries| Mongo
    Gateway -->|Sub-millisecond Operations| Redis
    Gateway -->|Fuzzy & Geo Search| ES
    
    SQL -.->|Domain Events / Outbox| ES
```

---

## 3. Polyglot Entity Reference Mapping

| Relational Table | Relational Column | Target Store | Target Collection / Key | Reference Type | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `OrderItems` | `MongoProductId` | **MongoDB** | `products._id` | Logical String ID | Immutable link to rich product attributes & catalog variants without cross-database FKs. |
| `PartsForRepair` | `MongoCatalogProductId` | **MongoDB** | `products._id` | Logical String ID | Identifies replacement parts pulled from physical warehouse catalog. |
| `InventoryItems` | `MongoProductId` | **MongoDB** | `products._id` | Logical String ID | Associates stock inventory ledger with MongoDB product catalog metadata. |
| `ProviderProfiles` | `ProfileId` | **MongoDB** | `provider_portfolios.providerId` | UUID String | Maps technician profile to rich media, certifications, and project portfolio. |
| `Orders` / `Cart` | `Sku` | **Redis** | `stock:available:{sku}` | String Key | Real-time atomic decrements and locks before committing to SQL Server ledger. |
| `ProviderLocations`| `Latitude, Longitude` | **Elasticsearch**| `providers_geo.location` | Geo Point | Index for fast bounding-box and Haversine geo-distance technician search. |
