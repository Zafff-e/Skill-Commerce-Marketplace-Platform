-- ============================================================================
-- Migration: 003_create_inventory_ledger.sql
-- Module: Double-Entry Inventory Ledger & Stock Balances
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. INVENTORY MASTER STOCK BALANCES
-- Tracks physical, reserved, and sellable stock per SKU per warehouse location
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InventoryItems' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[InventoryItems] (
        [InventoryItemId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [Sku] NVARCHAR(60) NOT NULL,
        [MongoProductId] NVARCHAR(64) NOT NULL, -- Polyglot reference to MongoDB document catalog
        [ItemName] NVARCHAR(200) NOT NULL,
        [WarehouseLocation] NVARCHAR(80) NOT NULL DEFAULT ('CENTRAL-DHAKA-WH01'),
        [StockOnHand] INT NOT NULL DEFAULT (0),
        [StockReserved] INT NOT NULL DEFAULT (0),
        [StockAvailable] AS ([StockOnHand] - [StockReserved]) PERSISTED,
        [ReorderThreshold] INT NOT NULL DEFAULT (5),
        [AllowPreOrder] BIT NOT NULL DEFAULT (0),
        [UnitCost] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [Version] INT NOT NULL DEFAULT (1), -- Optimistic Concurrency Control for atomic stock updates
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [UpdatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_InventoryItems] PRIMARY KEY CLUSTERED ([InventoryItemId] ASC),
        CONSTRAINT [UQ_InventoryItems_Sku_Warehouse] UNIQUE ([Sku], [WarehouseLocation]),
        CONSTRAINT [CK_InventoryItems_NonNegative] CHECK ([StockOnHand] >= 0 AND [StockReserved] >= 0)
    );

    CREATE NONCLUSTERED INDEX [IX_InventoryItems_Sku] ON [dbo].[InventoryItems] ([Sku] ASC);
    CREATE NONCLUSTERED INDEX [IX_InventoryItems_MongoProductId] ON [dbo].[InventoryItems] ([MongoProductId] ASC);
END
GO

-- 2. DOUBLE-ENTRY TRANSACTIONAL INVENTORY LEDGER
-- Immutable financial and quantity audit trail for every single stock movement
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InventoryLedger' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[InventoryLedger] (
        [LedgerId] BIGINT IDENTITY(1,1) NOT NULL,
        [InventoryItemId] UNIQUEIDENTIFIER NOT NULL,
        [TransactionType] NVARCHAR(40) NOT NULL,
        -- Allowed types: 'PURCHASE_RECEIPT', 'ORDER_RESERVED', 'ORDER_FULFILLED', 'REPAIR_CONSUMED', 'ORDER_CANCELLED_RELEASE', 'RETURN_RESTOCK', 'AUDIT_ADJUSTMENT'
        [QuantityChange] INT NOT NULL, -- Positive for additions, negative for reductions
        [ReferenceType] NVARCHAR(40) NOT NULL, -- 'ORDER', 'SERVICE_BOOKING', 'PURCHASE_ORDER', 'SYSTEM'
        [ReferenceId] NVARCHAR(64) NOT NULL, -- Linking OrderId or BookingId
        [RunningBalanceOnHand] INT NOT NULL,
        [RunningBalanceReserved] INT NOT NULL,
        [Notes] NVARCHAR(500) NULL,
        [RecordedByUserId] UNIQUEIDENTIFIER NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_InventoryLedger] PRIMARY KEY CLUSTERED ([LedgerId] ASC),
        CONSTRAINT [FK_InventoryLedger_InventoryItems] FOREIGN KEY ([InventoryItemId]) REFERENCES [dbo].[InventoryItems] ([InventoryItemId]),
        CONSTRAINT [FK_InventoryLedger_Users] FOREIGN KEY ([RecordedByUserId]) REFERENCES [dbo].[Users] ([UserId])
    );

    CREATE NONCLUSTERED INDEX [IX_InventoryLedger_InventoryItemId] ON [dbo].[InventoryLedger] ([InventoryItemId] ASC);
    CREATE NONCLUSTERED INDEX [IX_InventoryLedger_Reference] ON [dbo].[InventoryLedger] ([ReferenceType] ASC, [ReferenceId] ASC);
    CREATE NONCLUSTERED INDEX [IX_InventoryLedger_CreatedAt] ON [dbo].[InventoryLedger] ([CreatedAt] DESC);
END
GO
