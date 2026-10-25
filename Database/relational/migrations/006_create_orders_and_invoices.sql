-- ============================================================================
-- Migration: 006_create_orders_and_invoices.sql
-- Module: E-Commerce Product Orders, Historical Snapshots & Invoices
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. E-COMMERCE ORDERS TABLE
-- Binds 1-to-1 with unified BillableEntities.
-- Supports pre-orders, physical handoff QR code, and optimistic concurrency.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Orders] (
        [OrderId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [BillableEntityId] UNIQUEIDENTIFIER NOT NULL, -- 1-to-1 link to polymorphic BillableEntity
        [OrderNumber] NVARCHAR(32) NOT NULL, -- E.g., 'ORD-202610-8821'
        [CustomerId] UNIQUEIDENTIFIER NOT NULL,
        [OrderStatus] NVARCHAR(40) NOT NULL DEFAULT ('PENDING'),
        -- Lifecycle: 'PENDING', 'CONFIRMED', 'PACKAGED', 'SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'REFUNDED'
        [IsPreOrder] BIT NOT NULL DEFAULT (0),
        [SubTotal] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [ShippingFee] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [DiscountAmount] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [TotalAmount] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [PaymentMethod] NVARCHAR(50) NOT NULL DEFAULT ('CASH_ON_DELIVERY'),
        [PaymentStatus] NVARCHAR(40) NOT NULL DEFAULT ('PENDING'),
        [ShippingRecipientName] NVARCHAR(120) NOT NULL,
        [ShippingPhone] NVARCHAR(25) NOT NULL,
        [ShippingAddressLine] NVARCHAR(300) NOT NULL,
        [ShippingCity] NVARCHAR(100) NOT NULL,
        [ShippingDistrict] NVARCHAR(100) NOT NULL,
        [ShippingPostalCode] NVARCHAR(20) NULL,
        [CourierPartnerName] NVARCHAR(100) NULL,
        [CourierTrackingNumber] NVARCHAR(100) NULL,
        [EstimatedDeliveryDate] DATETIMEOFFSET NULL,
        [DeliveredAt] DATETIMEOFFSET NULL,
        [QrVerificationToken] NVARCHAR(100) NOT NULL DEFAULT (NEWID()), -- QR Code for physical handoff confirmation
        [DeliveryConfirmationOtp] NVARCHAR(10) NULL,
        [OrderNotes] NVARCHAR(500) NULL,
        [Version] INT NOT NULL DEFAULT (1), -- Optimistic Concurrency Control
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [UpdatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ([OrderId] ASC),
        CONSTRAINT [UQ_Orders_OrderNumber] UNIQUE ([OrderNumber]),
        CONSTRAINT [UQ_Orders_BillableEntity] UNIQUE ([BillableEntityId]),
        CONSTRAINT [FK_Orders_BillableEntities] FOREIGN KEY ([BillableEntityId]) REFERENCES [dbo].[BillableEntities] ([BillableEntityId]),
        CONSTRAINT [FK_Orders_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId])
    );

    CREATE NONCLUSTERED INDEX [IX_Orders_CustomerId] ON [dbo].[Orders] ([CustomerId] ASC);
    CREATE NONCLUSTERED INDEX [IX_Orders_OrderStatus] ON [dbo].[Orders] ([OrderStatus] ASC);
    CREATE NONCLUSTERED INDEX [IX_Orders_CreatedAt] ON [dbo].[Orders] ([CreatedAt] DESC);
END
GO

-- 2. ORDER ITEMS WITH IMMUTABLE PRICE FREEZES & SNAPSHOTS
-- Freezes exact historical pricing in decimal and minor integer units (cents)
-- Preserves immutable product attributes even if catalog modifies in MongoDB
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderItems' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[OrderItems] (
        [OrderItemId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [OrderId] UNIQUEIDENTIFIER NOT NULL,
        [MongoProductId] NVARCHAR(64) NOT NULL, -- Immutable logical ID referencing MongoDB catalog
        [Sku] NVARCHAR(60) NOT NULL,
        [ItemName] NVARCHAR(200) NOT NULL,
        [Quantity] INT NOT NULL DEFAULT (1),
        [UnitPrice] DECIMAL(18,4) NOT NULL,
        [UnitPriceCents] AS (CAST(ROUND([UnitPrice] * 100, 0) AS BIGINT)) PERSISTED, -- Historical integer cents freeze
        [TotalPrice] AS (CAST([Quantity] * [UnitPrice] AS DECIMAL(18,4))) PERSISTED,
        [IsPreOrder] BIT NOT NULL DEFAULT (0),
        [SnapshotData] NVARCHAR(MAX) NOT NULL DEFAULT ('{}'), -- Frozen immutable product specs and metadata
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_OrderItems] PRIMARY KEY CLUSTERED ([OrderItemId] ASC),
        CONSTRAINT [FK_OrderItems_Orders] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE CASCADE,
        CONSTRAINT [CK_OrderItems_Snapshot_IsJson] CHECK (ISJSON([SnapshotData]) = 1),
        CONSTRAINT [CK_OrderItems_Quantity] CHECK ([Quantity] > 0),
        CONSTRAINT [CK_OrderItems_UnitPrice] CHECK ([UnitPrice] >= 0.0000)
    );

    CREATE NONCLUSTERED INDEX [IX_OrderItems_OrderId] ON [dbo].[OrderItems] ([OrderId] ASC);
    CREATE NONCLUSTERED INDEX [IX_OrderItems_Sku] ON [dbo].[OrderItems] ([Sku] ASC);
END
GO

-- 3. INVOICES / BILLING STATEMENTS
-- Bound strictly to unified BillableEntities (Zero nullable foreign keys)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Invoices' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Invoices] (
        [InvoiceId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [InvoiceNumber] NVARCHAR(40) NOT NULL, -- E.g., 'INV-202610-0012'
        [BillableEntityId] UNIQUEIDENTIFIER NOT NULL, -- Pure non-nullable polymorphic foreign key
        [CustomerId] UNIQUEIDENTIFIER NOT NULL,
        [GrossAmount] DECIMAL(18,4) NOT NULL,
        [TaxOrVatAmount] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [DiscountAmount] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [NetAmount] DECIMAL(18,4) NOT NULL,
        [InvoiceStatus] NVARCHAR(30) NOT NULL DEFAULT ('ISSUED'), -- 'ISSUED', 'PAID', 'VOID', 'REFUNDED'
        [DueDate] DATETIMEOFFSET NOT NULL,
        [PaidAt] DATETIMEOFFSET NULL,
        [PdfStorageUrl] NVARCHAR(500) NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_Invoices] PRIMARY KEY CLUSTERED ([InvoiceId] ASC),
        CONSTRAINT [UQ_Invoices_InvoiceNumber] UNIQUE ([InvoiceNumber]),
        CONSTRAINT [FK_Invoices_BillableEntities] FOREIGN KEY ([BillableEntityId]) REFERENCES [dbo].[BillableEntities] ([BillableEntityId]),
        CONSTRAINT [FK_Invoices_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId])
    );

    CREATE NONCLUSTERED INDEX [IX_Invoices_CustomerId] ON [dbo].[Invoices] ([CustomerId] ASC);
    CREATE NONCLUSTERED INDEX [IX_Invoices_BillableEntityId] ON [dbo].[Invoices] ([BillableEntityId] ASC);
END
GO
