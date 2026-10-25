-- ============================================================================
-- Migration: 009_create_outbox_messages.sql
-- Module: Transactional Outbox Pattern for Resilient Event Streaming & CDC
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. TRANSACTIONAL OUTBOX MESSAGES TABLE
-- Enables guaranteed at-least-once asynchronous event publishing to Message Brokers (Kafka/RabbitMQ)
-- Synchronizes Provider Locations & Bookings to Elasticsearch and downstream microservices.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OutboxMessages' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[OutboxMessages] (
        [Id] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [AggregateType] NVARCHAR(100) NOT NULL, -- E.g., 'ServiceBooking', 'Order', 'ProviderLocation', 'InventoryItem'
        [AggregateId] NVARCHAR(100) NOT NULL, -- ID of the modified aggregate
        [Type] NVARCHAR(150) NOT NULL, -- E.g., 'BookingConfirmed', 'TechnicianDispatched', 'StockDeducted', 'ProviderGeoUpdated'
        [Payload] NVARCHAR(MAX) NOT NULL, -- JSON serialized domain event payload
        [CreatedAtUtc] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [ProcessedAtUtc] DATETIMEOFFSET NULL, -- NULL indicates message awaiting dispatch
        [RetryCount] INT NOT NULL DEFAULT (0),
        [Error] NVARCHAR(MAX) NULL,
        CONSTRAINT [PK_OutboxMessages] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [CK_OutboxMessages_Payload_IsJson] CHECK (ISJSON([Payload]) = 1)
    );

    -- Optimized covering index for relay worker polling unprocessed messages
    CREATE NONCLUSTERED INDEX [IX_OutboxMessages_PendingQueue] 
    ON [dbo].[OutboxMessages] ([ProcessedAtUtc] ASC, [CreatedAtUtc] ASC)
    INCLUDE ([Id], [AggregateType], [AggregateId], [Type], [RetryCount]);
END
GO
