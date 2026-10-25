-- ============================================================================
-- Migration: 007_create_payments_and_settlement.sql
-- Module: Payments, Escrow Accounting & Technician Payout Settlements
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. PAYMENT TRANSACTIONS
-- Tracks payments for both Service Bookings and E-Commerce Orders via unified BillableEntities
-- Pure relational model: zero nullable foreign keys for billable targets
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentTransactions' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[PaymentTransactions] (
        [TransactionId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [TransactionReference] NVARCHAR(64) NOT NULL, -- Unique Gateway/System Ref (e.g., 'TXN-BKASH-892301')
        [BillableEntityId] UNIQUEIDENTIFIER NOT NULL, -- Pure non-nullable polymorphic foreign key
        [CustomerId] UNIQUEIDENTIFIER NOT NULL,
        [PaymentMethod] NVARCHAR(50) NOT NULL, -- 'BKASH', 'NAGAD', 'ROCKET', 'CARD', 'CASH_ON_DELIVERY', 'CASH_ON_SERVICE'
        [Currency] NVARCHAR(10) NOT NULL DEFAULT ('BDT'),
        [GrossAmount] DECIMAL(18,4) NOT NULL,
        [PlatformCommission] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [GatewayFee] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [NetAmountPayable] DECIMAL(18,4) NOT NULL DEFAULT (0.0000), -- Amount intended for technician or merchant
        [PaymentStatus] NVARCHAR(40) NOT NULL DEFAULT ('PENDING'), -- 'PENDING', 'AUTHORIZED', 'SUCCESS', 'FAILED', 'REFUNDED'
        [GatewayTransactionId] NVARCHAR(120) NULL,
        [GatewayResponsePayload] NVARCHAR(MAX) NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [SettledAt] DATETIMEOFFSET NULL,
        CONSTRAINT [PK_PaymentTransactions] PRIMARY KEY CLUSTERED ([TransactionId] ASC),
        CONSTRAINT [UQ_PaymentTransactions_Reference] UNIQUE ([TransactionReference]),
        CONSTRAINT [FK_PaymentTransactions_BillableEntities] FOREIGN KEY ([BillableEntityId]) REFERENCES [dbo].[BillableEntities] ([BillableEntityId]),
        CONSTRAINT [FK_PaymentTransactions_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId]),
        CONSTRAINT [CK_PaymentTransactions_Payload_IsJson] CHECK ([GatewayResponsePayload] IS NULL OR ISJSON([GatewayResponsePayload]) = 1),
        CONSTRAINT [CK_PaymentTransactions_Amount] CHECK ([GrossAmount] >= 0.0000)
    );

    CREATE NONCLUSTERED INDEX [IX_PaymentTransactions_BillableEntityId] ON [dbo].[PaymentTransactions] ([BillableEntityId] ASC);
    CREATE NONCLUSTERED INDEX [IX_PaymentTransactions_CustomerId] ON [dbo].[PaymentTransactions] ([CustomerId] ASC);
    CREATE NONCLUSTERED INDEX [IX_PaymentTransactions_Status] ON [dbo].[PaymentTransactions] ([PaymentStatus] ASC);
END
GO

-- 2. PROVIDER PAYOUT DISBURSEMENTS
-- Tracks periodic payouts to technicians via bKash / Bank transfer
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProviderPayouts' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ProviderPayouts] (
        [PayoutId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [PayoutReference] NVARCHAR(64) NOT NULL, -- E.g., 'PO-202610-0012'
        [ProfileId] UNIQUEIDENTIFIER NOT NULL,
        [GrossEarnings] DECIMAL(18,4) NOT NULL,
        [CommissionDeducted] DECIMAL(18,4) NOT NULL,
        [NetDisbursementAmount] DECIMAL(18,4) NOT NULL,
        [PayoutMethod] NVARCHAR(50) NOT NULL, -- 'BKASH_PERSONAL', 'BKASH_MERCHANT', 'NAGAD', 'BANK_TRANSFER'
        [AccountDetails] NVARCHAR(250) NOT NULL,
        [Status] NVARCHAR(40) NOT NULL DEFAULT ('PENDING'), -- 'PENDING', 'PROCESSING', 'SETTLED', 'FAILED'
        [DisbursementReference] NVARCHAR(100) NULL,
        [ProcessedByAdminId] UNIQUEIDENTIFIER NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [SettledAt] DATETIMEOFFSET NULL,
        CONSTRAINT [PK_ProviderPayouts] PRIMARY KEY CLUSTERED ([PayoutId] ASC),
        CONSTRAINT [UQ_ProviderPayouts_Reference] UNIQUE ([PayoutReference]),
        CONSTRAINT [FK_ProviderPayouts_Profiles] FOREIGN KEY ([ProfileId]) REFERENCES [dbo].[ProviderProfiles] ([ProfileId]),
        CONSTRAINT [FK_ProviderPayouts_Admin] FOREIGN KEY ([ProcessedByAdminId]) REFERENCES [dbo].[Users] ([UserId]),
        CONSTRAINT [CK_ProviderPayouts_Disbursement] CHECK ([NetDisbursementAmount] >= 0.0000)
    );

    CREATE NONCLUSTERED INDEX [IX_ProviderPayouts_ProfileId] ON [dbo].[ProviderPayouts] ([ProfileId] ASC);
    CREATE NONCLUSTERED INDEX [IX_ProviderPayouts_Status] ON [dbo].[ProviderPayouts] ([Status] ASC);
END
GO
