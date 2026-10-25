-- ============================================================================
-- Migration: 005_create_bookings_and_parts.sql
-- Module: Work Orders, Real-Time Service Bookings & Warehouse Parts Deduction
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. SERVICE BOOKINGS (Primary Service Work Orders)
-- Business Rules:
-- 1. Binds 1-to-1 with a unified BillableEntity for clean invoice & payment handling.
-- 2. Emergency booking support with dynamic call-out fee.
-- 3. Supports voice note attachment URL for accessible booking.
-- 4. Optimistic concurrency control via [Version].
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ServiceBookings' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ServiceBookings] (
        [BookingId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [BillableEntityId] UNIQUEIDENTIFIER NOT NULL, -- 1-to-1 link to polymorphic BillableEntity
        [BookingReference] NVARCHAR(32) NOT NULL, -- Human-readable, e.g., 'BK-202610-A9F2'
        [CustomerId] UNIQUEIDENTIFIER NOT NULL,
        [ProviderId] UNIQUEIDENTIFIER NOT NULL,
        [SkillId] INT NOT NULL,
        [ScheduledAt] DATETIMEOFFSET NOT NULL,
        [ServiceAddress] NVARCHAR(300) NOT NULL,
        [AddressLatitude] DECIMAL(9,6) NULL,
        [AddressLongitude] DECIMAL(9,6) NULL,
        [Status] NVARCHAR(40) NOT NULL DEFAULT ('PENDING'), 
        -- Status lifecycle: 'PENDING', 'ACCEPTED', 'EN_ROUTE', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DISPUTED'
        [IsEmergency] BIT NOT NULL DEFAULT (0),
        [EmergencyFee] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [EstimatedHours] DECIMAL(5,2) NOT NULL DEFAULT (1.00),
        [ActualHours] DECIMAL(5,2) NULL,
        [HourlyRateApplied] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [LaborCost] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [PartsTotalCost] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [TotalAmount] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [PlatformCommissionRate] DECIMAL(5,2) NOT NULL DEFAULT (10.00), -- 10% standard platform fee
        [CommissionFee] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [ProviderPayoutAmount] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [CustomerNotes] NVARCHAR(1000) NULL,
        [VoiceNoteUrl] NVARCHAR(500) NULL, -- Voice note option for non-literate/quick booking
        [CancellationReason] NVARCHAR(500) NULL,
        [Version] INT NOT NULL DEFAULT (1), -- Optimistic Concurrency Control
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [UpdatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [CompletedAt] DATETIMEOFFSET NULL,
        CONSTRAINT [PK_ServiceBookings] PRIMARY KEY CLUSTERED ([BookingId] ASC),
        CONSTRAINT [UQ_ServiceBookings_Reference] UNIQUE ([BookingReference]),
        CONSTRAINT [UQ_ServiceBookings_BillableEntity] UNIQUE ([BillableEntityId]),
        CONSTRAINT [FK_ServiceBookings_BillableEntities] FOREIGN KEY ([BillableEntityId]) REFERENCES [dbo].[BillableEntities] ([BillableEntityId]),
        CONSTRAINT [FK_ServiceBookings_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId]),
        CONSTRAINT [FK_ServiceBookings_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[ProviderProfiles] ([ProfileId]),
        CONSTRAINT [FK_ServiceBookings_Skills] FOREIGN KEY ([SkillId]) REFERENCES [dbo].[SkillSets] ([SkillId])
    );

    CREATE NONCLUSTERED INDEX [IX_ServiceBookings_CustomerId] ON [dbo].[ServiceBookings] ([CustomerId] ASC);
    CREATE NONCLUSTERED INDEX [IX_ServiceBookings_ProviderId] ON [dbo].[ServiceBookings] ([ProviderId] ASC);
    CREATE NONCLUSTERED INDEX [IX_ServiceBookings_Status] ON [dbo].[ServiceBookings] ([Status] ASC);
    CREATE NONCLUSTERED INDEX [IX_ServiceBookings_ScheduledAt] ON [dbo].[ServiceBookings] ([ScheduledAt] ASC);
END
GO

-- 2. BOOKING STATUS AUDIT & TIMELINE HISTORY
-- Powers the real-time SignalR status tracker and UI step-progress bar
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BookingStatusHistory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[BookingStatusHistory] (
        [HistoryId] BIGINT IDENTITY(1,1) NOT NULL,
        [BookingId] UNIQUEIDENTIFIER NOT NULL,
        [FromStatus] NVARCHAR(40) NULL,
        [ToStatus] NVARCHAR(40) NOT NULL,
        [TriggeredByUserId] UNIQUEIDENTIFIER NOT NULL,
        [Comments] NVARCHAR(500) NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_BookingStatusHistory] PRIMARY KEY CLUSTERED ([HistoryId] ASC),
        CONSTRAINT [FK_BookingStatusHistory_Bookings] FOREIGN KEY ([BookingId]) REFERENCES [dbo].[ServiceBookings] ([BookingId]) ON DELETE CASCADE,
        CONSTRAINT [FK_BookingStatusHistory_Users] FOREIGN KEY ([TriggeredByUserId]) REFERENCES [dbo].[Users] ([UserId])
    );

    CREATE NONCLUSTERED INDEX [IX_BookingStatusHistory_BookingId] ON [dbo].[BookingStatusHistory] ([BookingId] ASC);
END
GO

-- 3. PARTS CONSUMED IN REPAIR / SERVICE
-- Itemized line items of hardware or replacement parts supplied on-site
-- Linked directly to warehouse InventoryItems; freezes price & snapshot data
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PartsForRepair' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[PartsForRepair] (
        [PartItemId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [BookingId] UNIQUEIDENTIFIER NOT NULL,
        [InventoryItemId] UNIQUEIDENTIFIER NULL, -- Direct warehouse inventory linkage for stock deduction
        [PartName] NVARCHAR(180) NOT NULL,
        [PartSku] NVARCHAR(60) NULL,
        [MongoCatalogProductId] NVARCHAR(64) NULL, -- Polyglot cross-reference to MongoDB Product Catalog
        [Quantity] INT NOT NULL DEFAULT (1),
        [UnitPrice] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [UnitPriceCents] AS (CAST(ROUND([UnitPrice] * 100, 0) AS BIGINT)) PERSISTED, -- Historical integer cents freeze
        [TotalPrice] AS (CAST([Quantity] * [UnitPrice] AS DECIMAL(18,4))) PERSISTED,
        [SnapshotData] NVARCHAR(MAX) NOT NULL DEFAULT ('{}'), -- Frozen immutable part specs and pricing metadata
        [WarrantyMonths] INT NOT NULL DEFAULT (0),
        [SerialNumber] NVARCHAR(100) NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_PartsForRepair] PRIMARY KEY CLUSTERED ([PartItemId] ASC),
        CONSTRAINT [FK_PartsForRepair_Bookings] FOREIGN KEY ([BookingId]) REFERENCES [dbo].[ServiceBookings] ([BookingId]) ON DELETE CASCADE,
        CONSTRAINT [FK_PartsForRepair_InventoryItems] FOREIGN KEY ([InventoryItemId]) REFERENCES [dbo].[InventoryItems] ([InventoryItemId]),
        CONSTRAINT [CK_PartsForRepair_Snapshot_IsJson] CHECK (ISJSON([SnapshotData]) = 1),
        CONSTRAINT [CK_PartsForRepair_Quantity] CHECK ([Quantity] > 0),
        CONSTRAINT [CK_PartsForRepair_UnitPrice] CHECK ([UnitPrice] >= 0.0000)
    );

    CREATE NONCLUSTERED INDEX [IX_PartsForRepair_BookingId] ON [dbo].[PartsForRepair] ([BookingId] ASC);
    CREATE NONCLUSTERED INDEX [IX_PartsForRepair_InventoryItemId] ON [dbo].[PartsForRepair] ([InventoryItemId] ASC);
END
GO
