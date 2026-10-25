-- ============================================================================
-- Migration: 004_create_billable_entities.sql
-- Module: Unified Polymorphic Billing Contract (Orders & Service Bookings)
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. UNIFIED BILLABLE ENTITIES TABLE
-- Solves the nullable foreign key problem across Invoices and PaymentTransactions.
-- Both ServiceBookings and Orders establish a 1-to-1 relationship with BillableEntities.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BillableEntities' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[BillableEntities] (
        [BillableEntityId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [EntityType] NVARCHAR(30) NOT NULL, -- 'SERVICE_BOOKING', 'ORDER'
        [ReferenceNumber] NVARCHAR(50) NOT NULL, -- Human-readable identifier (e.g., 'BK-202610-A9F2', 'ORD-202610-8821')
        [CustomerId] UNIQUEIDENTIFIER NOT NULL,
        [TotalAmount] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [Currency] NVARCHAR(10) NOT NULL DEFAULT ('BDT'),
        [BillingStatus] NVARCHAR(30) NOT NULL DEFAULT ('PENDING'),
        -- Lifecycle: 'PENDING', 'AUTHORIZED', 'PARTIALLY_PAID', 'PAID', 'CANCELLED', 'REFUNDED'
        [Notes] NVARCHAR(500) NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [UpdatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_BillableEntities] PRIMARY KEY CLUSTERED ([BillableEntityId] ASC),
        CONSTRAINT [UQ_BillableEntities_Reference] UNIQUE ([ReferenceNumber]),
        CONSTRAINT [FK_BillableEntities_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId]),
        CONSTRAINT [CK_BillableEntities_Type] CHECK ([EntityType] IN ('SERVICE_BOOKING', 'ORDER')),
        CONSTRAINT [CK_BillableEntities_Amount] CHECK ([TotalAmount] >= 0.0000)
    );

    CREATE NONCLUSTERED INDEX [IX_BillableEntities_CustomerId] ON [dbo].[BillableEntities] ([CustomerId] ASC);
    CREATE NONCLUSTERED INDEX [IX_BillableEntities_Status] ON [dbo].[BillableEntities] ([BillingStatus] ASC);
    CREATE NONCLUSTERED INDEX [IX_BillableEntities_Type] ON [dbo].[BillableEntities] ([EntityType] ASC);
END
GO
