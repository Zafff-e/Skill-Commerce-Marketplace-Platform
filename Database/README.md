# SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
## Enterprise Polyglot Persistence Layer

---

## 1. Architectural Overview

The **SkillCommerce** database infrastructure adopts a cloud-native **Polyglot Persistence** model to achieve high scalability, sub-millisecond cart latencies, strict ACID transaction boundaries, and dynamic e-commerce catalog flexibility.

```mermaid
flowchart TD
    Client["Clients (React Booking App / Angular Admin / MAUI Mobile)"] --> API["ASP.NET Core Web API Gateway"]
    
    subgraph Polyglot_Database_Layer ["SkillCommerce Enterprise Data Layer"]
        SQL[("SQL Server 2022 (ACID Core)<br/>- Identity & Roles<br/>- BillableEntities (Polymorphic Contract)<br/>- Service Bookings & Consumed Parts<br/>- Orders & Invoices (Zero Nullable FKs)<br/>- Double-Entry Inventory Ledger<br/>- OutboxMessages (Async CDC Relay)")]
        Mongo[("MongoDB 7.0 (Document Catalog)<br/>- Dynamic Technical Specs<br/>- Variant Attributes<br/>- Technician Portfolios & Media")]
        Redis[("Redis 7.2 (In-Memory Cache)<br/>- Guest & User Carts<br/>- Atomic Lua Stock Reservation<br/>- JWT Blacklists & Rate Limiting<br/>- Live Geo Tracking")]
        ES[("Elasticsearch 8.13 (Search Engine)<br/>- Bilingual Autocomplete<br/>- Multi-faceted Product Search<br/>- Haversine Geo-radial Discovery")]
    end
    
    API -->|Strict ACID Transactions + Outbox| SQL
    API -->|JSON Documents & Portfolios| Mongo
    API -->|Sub-millisecond State & Locks| Redis
    API -->|Full-Text & Geospatial Queries| ES
    
    SQL -.->|Outbox Messages -> Kafka| ES
    Mongo -.->|Change Streams| ES
```

---

## 2. Workload & Technology Allocation

| Engine | Port | Primary Responsibility | Data Guarantee |
| :--- | :--- | :--- | :--- |
| **Microsoft SQL Server 2022** | `1433` | Financial ledgers, billable contracts, service bookings, orders, users, role permissions, provider NID verification, and transactional outbox. | Strict ACID, Serialized / Snapshot Isolation, Optimistic Concurrency (`Version INT`). |
| **MongoDB 7.0** | `27017` | Hardware spare parts catalog, dynamic electrical/mechanical specifications, rich media portfolios. | Document schema validation (`$jsonSchema`), flexible polymorphism. |
| **Redis 7.2** | `6379` | Ephemeral guest/user shopping carts, atomic stock reservation leases, sliding-window rate limiters. | Sub-millisecond latency, in-memory with AOF persistence. |
| **Elasticsearch 8.13** | `9200` | Full-text catalog search, edge-ngram autocomplete, geospatial technician radius search. | Near real-time inverted index & geo-distance scoring. |

---

## 3. Directory Layout

```
DataBase/
├── docker-compose.yml              # Local multi-container environment (SQL Server, Mongo, Redis, ES)
├── README.md                       # Setup instructions & connection strings
├── Diagram.md                      # Mermaid ERD & Dual-Stream CDC Architecture
│
├── relational/                     # Microsoft SQL Server (Transactional Core)
│   ├── migrations/                 # Idempotent versioned DDL files
│   │   ├── 001_create_identity_and_roles.sql
│   │   ├── 002_create_skills_taxonomy.sql
│   │   ├── 003_create_inventory_ledger.sql
│   │   ├── 004_create_billable_entities.sql
│   │   ├── 005_create_bookings_and_parts.sql
│   │   ├── 006_create_orders_and_invoices.sql
│   │   ├── 007_create_payments_and_settlement.sql
│   │   ├── 008_create_reviews_and_badges.sql
│   │   └── 009_create_outbox_messages.sql
│   └── seeds/                      # Localized development baseline data
│       └── dev_seed.sql
│
├── document/                       # MongoDB (Product Catalog, Portfolios)
│   ├── collections/                # Strict JSON Schema validation definitions
│   │   ├── products.validation.json
│   │   ├── reviews.validation.json
│   │   └── provider_portfolios.validation.json
│   ├── indexes/                    # Compound, text, and unique index definitions
│   │   └── create_indexes.js
│   └── seeds/                      # Product variants & portfolio seeds
│       ├── initial_documents.json
│       └── initial_products.json
│
├── cache/                          # Redis (Carts, Rate Limits, Locks)
│   ├── key-registry.md             # Key namespaces, TTLs, and eviction policy
│   └── scripts/                    # Atomic Lua scripts
│       ├── reserve_stock.lua       # Atomic checkout stock reservation
│       ├── release_stock.lua       # Stock roll-back upon cancellation
│       └── rate_limiter.lua        # Sliding-window rate limiting
│
└── search/                         # Elasticsearch (Full-Text & Geo)
    ├── mappings/                   # Index mapping templates & analyzers
    │   ├── catalog_mapping.json
    │   └── provider_geo_mapping.json
    └── pipelines/                  # Ingestion pipelines
        └── ingest_pipeline.json
```

---

## 4. Connection Strings & Credentials

### Local Docker Environment Credentials

```ini
# Microsoft SQL Server 2022
Server=localhost,1433;Database=SkillCommerceDb;User Id=sa;Password=SkillCommerce@Pass2026!;TrustServerCertificate=True;MultipleActiveResultSets=True;

# MongoDB 7.0
mongodb://mongoadmin:MongoSkillCommerce2026!@localhost:27017/skillcommerce_catalog?authSource=admin

# Redis 7.2
localhost:6379,password=RedisSkillCommerce2026!,abortConnect=false

# Elasticsearch 8.13
http://localhost:9200
```

---

## 5. Quickstart & Initialization Runbook

### Step 1: Boot All Services via Docker Compose
From the `Database/` folder:
```bash
docker compose up -d
```

Verify service health:
```bash
docker compose ps
```

### Step 2: Apply SQL Server Migrations
Execute the migrations in sequential order:
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

### Step 3: Initialize MongoDB Validation, Indexes & Seeds
```bash
# Apply indexes and collections
docker exec -i skillcommerce_mongodb mongosh -u mongoadmin -p MongoSkillCommerce2026! --authenticationDatabase admin /docker-entrypoint-initdb.d/indexes/create_indexes.js

# Import initial product catalog seeds
docker exec -i skillcommerce_mongodb mongoimport -u mongoadmin -p MongoSkillCommerce2026! --authenticationDatabase admin --db skillcommerce_catalog --collection products --file /docker-entrypoint-initdb.d/collections/../seeds/initial_products.json --jsonArray
```

### Step 4: Register Elasticsearch Mappings & Ingest Pipeline
```bash
# Ingest pipeline
curl -X PUT "http://localhost:9200/_ingest/pipeline/catalog_ingest_pipeline" -H "Content-Type: application/json" -d @search/pipelines/ingest_pipeline.json

# Catalog index mapping
curl -X PUT "http://localhost:9200/catalog_products" -H "Content-Type: application/json" -d @search/mappings/catalog_mapping.json

# Provider geo index mapping
curl -X PUT "http://localhost:9200/providers_geo" -H "Content-Type: application/json" -d @search/mappings/provider_geo_mapping.json
```

---

## 6. Enterprise Rules for Polyglot Integration

1. **Clean Foreign Keys:** Never attempt cross-database foreign key constraints. Use immutable logical IDs (e.g., `MongoProductId` stored as string UUID/SKU in SQL Server `OrderItems` and `PartsForRepair`).
2. **Unified Billable Contract:** Invoices and PaymentTransactions link strictly to `BillableEntities(BillableEntityId)`, avoiding mutually exclusive nullable foreign keys between orders and service bookings.
3. **Double-Entry Stock Audit:** Never update inventory with bare `UPDATE items SET stock = stock - 1`. Every stock modification (including repair consumption) must append an immutable ledger line to `InventoryLedger` with its corresponding `TransactionType`.
4. **Historical Price Freezes:** `OrderItems` and `PartsForRepair` compute and persist `UnitPriceCents` alongside frozen `SnapshotData` JSON blobs, preserving historical pricing integrity regardless of future catalog changes.
5. **Transactional Outbox:** Write domain events to `OutboxMessages` within the same ACID transaction to guarantee reliable downstream streaming to Kafka and Elasticsearch.
