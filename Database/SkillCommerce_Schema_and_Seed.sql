-- ============================================================================
-- Project: Skill-Commerce Hyperlocal Marketplace Platform
-- Component: 3NF Relational Database Schema & Baseline Seed Data
-- Lead Architect / Database Lead: A.H.M. Zafir Hasan
-- Target Engine: Microsoft SQL Server 2019+ / Azure SQL Database
-- ============================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SkillCommerceDb')
BEGIN
    CREATE DATABASE [SkillCommerceDb];
END
GO

USE [SkillCommerceDb];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Clean existing tables if present in reverse dependency order
DROP TABLE IF EXISTS [dbo].[ReviewsAndRatings];
DROP TABLE IF EXISTS [dbo].[PaymentTransactions];
DROP TABLE IF EXISTS [dbo].[PartsForRepair];
DROP TABLE IF EXISTS [dbo].[ServiceBookings];
DROP TABLE IF EXISTS [dbo].[ProfessionalSkills];
DROP TABLE IF EXISTS [dbo].[ProfessionalProfiles];
DROP TABLE IF EXISTS [dbo].[SkillSets];
DROP TABLE IF EXISTS [dbo].[SkillCategories];
DROP TABLE IF EXISTS [dbo].[Users];
DROP TABLE IF EXISTS [dbo].[UserRoles];
GO

-- ============================================================================
-- 1. SECURITY & IDENTITY (Authentication & Authorization)
-- ============================================================================

CREATE TABLE [dbo].[UserRoles] (
    [RoleId] INT IDENTITY(1,1) NOT NULL,
    [RoleName] NVARCHAR(50) NOT NULL UNIQUE,
    [Description] NVARCHAR(250) NULL,
    CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED ([RoleId] ASC)
);
GO

CREATE TABLE [dbo].[Users] (
    [UserId] INT IDENTITY(1,1) NOT NULL,
    [FullName] NVARCHAR(120) NOT NULL,
    [Email] NVARCHAR(150) NOT NULL UNIQUE,
    [NormalizedEmail] NVARCHAR(150) NOT NULL UNIQUE,
    [PhoneNumber] NVARCHAR(25) NOT NULL,
    [PasswordHash] NVARCHAR(MAX) NOT NULL,
    [SecurityStamp] NVARCHAR(MAX) NULL,
    [RoleId] INT NOT NULL,
    [IsActive] BIT NOT NULL DEFAULT (1),
    [CreatedAt] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserId] ASC),
    CONSTRAINT [FK_Users_UserRoles] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[UserRoles] ([RoleId])
);
GO

CREATE NONCLUSTERED INDEX [IX_Users_RoleId] ON [dbo].[Users] ([RoleId] ASC);
CREATE NONCLUSTERED INDEX [IX_Users_NormalizedEmail] ON [dbo].[Users] ([NormalizedEmail] ASC);
GO

-- ============================================================================
-- 2. SKILL TAXONOMY
-- ============================================================================

CREATE TABLE [dbo].[SkillCategories] (
    [CategoryId] INT IDENTITY(1,1) NOT NULL,
    [CategoryName] NVARCHAR(100) NOT NULL UNIQUE,
    [Description] NVARCHAR(300) NULL,
    [IconUrl] NVARCHAR(250) NULL,
    [IsActive] BIT NOT NULL DEFAULT (1),
    CONSTRAINT [PK_SkillCategories] PRIMARY KEY CLUSTERED ([CategoryId] ASC)
);
GO

CREATE TABLE [dbo].[SkillSets] (
    [SkillId] INT IDENTITY(1,1) NOT NULL,
    [CategoryId] INT NOT NULL,
    [SkillName] NVARCHAR(120) NOT NULL,
    [StandardRatePerHour] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [IsActive] BIT NOT NULL DEFAULT (1),
    CONSTRAINT [PK_SkillSets] PRIMARY KEY CLUSTERED ([SkillId] ASC),
    CONSTRAINT [FK_SkillSets_SkillCategories] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[SkillCategories] ([CategoryId]) ON DELETE CASCADE
);
GO

CREATE NONCLUSTERED INDEX [IX_SkillSets_CategoryId] ON [dbo].[SkillSets] ([CategoryId] ASC);
GO

-- ============================================================================
-- 3. PROFESSIONAL PROFILES & SKILL MATRIX
-- ============================================================================

CREATE TABLE [dbo].[ProfessionalProfiles] (
    [ProfileId] INT IDENTITY(1,1) NOT NULL,
    [UserId] INT NOT NULL UNIQUE,
    [Bio] NVARCHAR(1000) NULL,
    [ExperienceYears] INT NOT NULL DEFAULT (0),
    [ServiceAreaCity] NVARCHAR(100) NOT NULL,
    [BaseVisitingCharge] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [AverageRating] DECIMAL(3,2) NOT NULL DEFAULT (0.00),
    [TotalReviewsCount] INT NOT NULL DEFAULT (0),
    [IsVerified] BIT NOT NULL DEFAULT (0),
    [IsAvailable] BIT NOT NULL DEFAULT (1),
    CONSTRAINT [PK_ProfessionalProfiles] PRIMARY KEY CLUSTERED ([ProfileId] ASC),
    CONSTRAINT [FK_ProfessionalProfiles_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId]) ON DELETE CASCADE
);
GO

CREATE TABLE [dbo].[ProfessionalSkills] (
    [ProfessionalSkillId] INT IDENTITY(1,1) NOT NULL,
    [ProfileId] INT NOT NULL,
    [SkillId] INT NOT NULL,
    [HourlyRate] DECIMAL(18,2) NOT NULL,
    [YearsOfExperience] INT NOT NULL DEFAULT (1),
    CONSTRAINT [PK_ProfessionalSkills] PRIMARY KEY CLUSTERED ([ProfessionalSkillId] ASC),
    CONSTRAINT [FK_ProfessionalSkills_Profiles] FOREIGN KEY ([ProfileId]) REFERENCES [dbo].[ProfessionalProfiles] ([ProfileId]) ON DELETE CASCADE,
    CONSTRAINT [FK_ProfessionalSkills_SkillSets] FOREIGN KEY ([SkillId]) REFERENCES [dbo].[SkillSets] ([SkillId]) ON DELETE CASCADE,
    CONSTRAINT [UQ_Professional_Skill] UNIQUE ([ProfileId], [SkillId])
);
GO

CREATE NONCLUSTERED INDEX [IX_ProfessionalSkills_ProfileId] ON [dbo].[ProfessionalSkills] ([ProfileId] ASC);
CREATE NONCLUSTERED INDEX [IX_ProfessionalSkills_SkillId] ON [dbo].[ProfessionalSkills] ([SkillId] ASC);
GO

-- ============================================================================
-- 4. SERVICE BOOKINGS & REPAIR WORK ORDERS
-- ============================================================================

CREATE TABLE [dbo].[ServiceBookings] (
    [BookingId] INT IDENTITY(1,1) NOT NULL,
    [BookingReference] NVARCHAR(30) NOT NULL UNIQUE,
    [CustomerId] INT NOT NULL,
    [ProfessionalId] INT NOT NULL,
    [SkillId] INT NOT NULL,
    [ScheduledDate] DATETIME2(7) NOT NULL,
    [ServiceAddress] NVARCHAR(300) NOT NULL,
    [Status] NVARCHAR(40) NOT NULL DEFAULT ('PENDING'),
    [CustomerNotes] NVARCHAR(1000) NULL,
    [EstimatedHours] DECIMAL(4,2) NOT NULL DEFAULT (1.00),
    [LaborCost] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [PartsTotalCost] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [TotalBillAmount] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [CreatedAt] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    [CompletedAt] DATETIME2(7) NULL,
    CONSTRAINT [PK_ServiceBookings] PRIMARY KEY CLUSTERED ([BookingId] ASC),
    CONSTRAINT [FK_ServiceBookings_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId]),
    CONSTRAINT [FK_ServiceBookings_Professionals] FOREIGN KEY ([ProfessionalId]) REFERENCES [dbo].[ProfessionalProfiles] ([ProfileId]),
    CONSTRAINT [FK_ServiceBookings_SkillSets] FOREIGN KEY ([SkillId]) REFERENCES [dbo].[SkillSets] ([SkillId])
);
GO

CREATE NONCLUSTERED INDEX [IX_ServiceBookings_CustomerId] ON [dbo].[ServiceBookings] ([CustomerId] ASC);
CREATE NONCLUSTERED INDEX [IX_ServiceBookings_ProfessionalId] ON [dbo].[ServiceBookings] ([ProfessionalId] ASC);
CREATE NONCLUSTERED INDEX [IX_ServiceBookings_Status] ON [dbo].[ServiceBookings] ([Status] ASC);
GO

-- ============================================================================
-- 5. PARTS FOR REPAIR (Inventory Line Items consumed in service)
-- ============================================================================

CREATE TABLE [dbo].[PartsForRepair] (
    [PartItemId] INT IDENTITY(1,1) NOT NULL,
    [BookingId] INT NOT NULL,
    [PartName] NVARCHAR(150) NOT NULL,
    [Quantity] INT NOT NULL DEFAULT (1),
    [UnitPrice] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [TotalPrice] AS ([Quantity] * [UnitPrice]) PERSISTED,
    [WarrantyMonths] INT NOT NULL DEFAULT (0),
    CONSTRAINT [PK_PartsForRepair] PRIMARY KEY CLUSTERED ([PartItemId] ASC),
    CONSTRAINT [FK_PartsForRepair_Bookings] FOREIGN KEY ([BookingId]) REFERENCES [dbo].[ServiceBookings] ([BookingId]) ON DELETE CASCADE
);
GO

CREATE NONCLUSTERED INDEX [IX_PartsForRepair_BookingId] ON [dbo].[PartsForRepair] ([BookingId] ASC);
GO

-- ============================================================================
-- 6. TRANSACTIONS & PAYMENTS
-- ============================================================================

CREATE TABLE [dbo].[PaymentTransactions] (
    [TransactionId] INT IDENTITY(1,1) NOT NULL,
    [BookingId] INT NOT NULL,
    [TransactionReference] NVARCHAR(60) NOT NULL UNIQUE,
    [PaymentMethod] NVARCHAR(50) NOT NULL, -- e.g., 'BKASH', 'NAGAD', 'CREDIT_CARD', 'CASH_ON_SERVICE'
    [AmountPaid] DECIMAL(18,2) NOT NULL,
    [PlatformCommission] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [ProfessionalPayout] DECIMAL(18,2) NOT NULL DEFAULT (0.00),
    [PaymentStatus] NVARCHAR(40) NOT NULL DEFAULT ('PENDING'),
    [TransactionDate] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_PaymentTransactions] PRIMARY KEY CLUSTERED ([TransactionId] ASC),
    CONSTRAINT [FK_PaymentTransactions_Bookings] FOREIGN KEY ([BookingId]) REFERENCES [dbo].[ServiceBookings] ([BookingId])
);
GO

CREATE NONCLUSTERED INDEX [IX_PaymentTransactions_BookingId] ON [dbo].[PaymentTransactions] ([BookingId] ASC);
GO

-- ============================================================================
-- 7. REVIEWS & RATINGS
-- ============================================================================

CREATE TABLE [dbo].[ReviewsAndRatings] (
    [ReviewId] INT IDENTITY(1,1) NOT NULL,
    [BookingId] INT NOT NULL UNIQUE,
    [CustomerId] INT NOT NULL,
    [ProfessionalId] INT NOT NULL,
    [Rating] INT NOT NULL CHECK ([Rating] BETWEEN 1 AND 5),
    [FeedbackText] NVARCHAR(1000) NULL,
    [ReviewDate] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_ReviewsAndRatings] PRIMARY KEY CLUSTERED ([ReviewId] ASC),
    CONSTRAINT [FK_ReviewsAndRatings_Bookings] FOREIGN KEY ([BookingId]) REFERENCES [dbo].[ServiceBookings] ([BookingId]),
    CONSTRAINT [FK_ReviewsAndRatings_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId]),
    CONSTRAINT [FK_ReviewsAndRatings_Professionals] FOREIGN KEY ([ProfessionalId]) REFERENCES [dbo].[ProfessionalProfiles] ([ProfileId])
);
GO

-- ============================================================================
-- BASELINE SEED DATA
-- ============================================================================

INSERT INTO [dbo].[UserRoles] ([RoleName], [Description]) VALUES
('ADMIN', 'Platform Administrator'),
('CUSTOMER', 'Consumer requesting technical and trade services'),
('PROFESSIONAL', 'Vetted skilled technician offering on-demand services');
GO

INSERT INTO [dbo].[SkillCategories] ([CategoryName], [Description], [IconUrl]) VALUES
('Electronics & Appliances', 'Household and commercial electronics repair', 'appliances.svg'),
('Computer & IT Support', 'Hardware diagnostic, laptop repair, OS reinstall, networking', 'computer.svg'),
('Electrical & Wiring', 'Residential and industrial electrical installations', 'electrical.svg'),
('Plumbing & Pipefitting', 'Water supply, leak fixes, sanitary fittings', 'plumbing.svg');
GO

INSERT INTO [dbo].[SkillSets] ([CategoryId], [SkillName], [StandardRatePerHour]) VALUES
(1, 'Inverter AC Servicing & Gas Refill', 800.00),
(1, 'Refrigerator Compressor Repair', 1200.00),
(2, 'Laptop Motherboard Chip-Level Repair', 1500.00),
(2, 'Custom PC Assembly & Cable Management', 600.00),
(2, 'Windows & Software Troubleshooting', 500.00),
(3, 'Circuit Breaker & DB Board Wiring', 900.00),
(4, 'Concealed Pipe Leakage Detection', 1000.00);
GO
