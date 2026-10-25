-- ============================================================================
-- Migration: 001_create_identity_and_roles.sql
-- Module: Security, Identity & Provider Onboarding
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SkillCommerceDb')
BEGIN
    CREATE DATABASE [SkillCommerceDb];
END
GO

USE [SkillCommerceDb];
GO

-- 1. USER ROLES
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRoles' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[UserRoles] (
        [RoleId] INT IDENTITY(1,1) NOT NULL,
        [RoleName] NVARCHAR(50) NOT NULL,
        [NormalizedName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(250) NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED ([RoleId] ASC),
        CONSTRAINT [UQ_UserRoles_RoleName] UNIQUE ([RoleName]),
        CONSTRAINT [UQ_UserRoles_NormalizedName] UNIQUE ([NormalizedName])
    );
END
GO

-- 2. CORE USERS TABLE
-- Conforms to enterprise distributed architecture: uses UNIQUEIDENTIFIER with NEWSEQUENTIALID()
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Users] (
        [UserId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [FullName] NVARCHAR(120) NOT NULL,
        [Email] NVARCHAR(150) NOT NULL,
        [NormalizedEmail] NVARCHAR(150) NOT NULL,
        [PhoneNumber] NVARCHAR(25) NOT NULL,
        [PasswordHash] NVARCHAR(MAX) NOT NULL,
        [SecurityStamp] NVARCHAR(128) NOT NULL DEFAULT (NEWID()),
        [ProfileImageUrl] NVARCHAR(500) NULL,
        [IsActive] BIT NOT NULL DEFAULT (1),
        [EmailConfirmed] BIT NOT NULL DEFAULT (0),
        [PhoneConfirmed] BIT NOT NULL DEFAULT (0),
        [IsDeleted] BIT NOT NULL DEFAULT (0),
        [DeletedAt] DATETIMEOFFSET NULL,
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [UpdatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserId] ASC),
        CONSTRAINT [UQ_Users_Email] UNIQUE ([Email]),
        CONSTRAINT [UQ_Users_NormalizedEmail] UNIQUE ([NormalizedEmail])
    );

    CREATE NONCLUSTERED INDEX [IX_Users_PhoneNumber] ON [dbo].[Users] ([PhoneNumber] ASC);
    CREATE NONCLUSTERED INDEX [IX_Users_IsActive] ON [dbo].[Users] ([IsActive] ASC) WHERE [IsDeleted] = 0;
END
GO

-- 3. USER ROLE ASSIGNMENTS (Enables a User to be BOTH a Customer and a Professional)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRoleAssignments' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[UserRoleAssignments] (
        [AssignmentId] INT IDENTITY(1,1) NOT NULL,
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [RoleId] INT NOT NULL,
        [AssignedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_UserRoleAssignments] PRIMARY KEY CLUSTERED ([AssignmentId] ASC),
        CONSTRAINT [FK_UserRoleAssignments_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId]) ON DELETE CASCADE,
        CONSTRAINT [FK_UserRoleAssignments_UserRoles] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[UserRoles] ([RoleId]) ON DELETE CASCADE,
        CONSTRAINT [UQ_UserRoleAssignments_User_Role] UNIQUE ([UserId], [RoleId])
    );

    CREATE NONCLUSTERED INDEX [IX_UserRoleAssignments_RoleId] ON [dbo].[UserRoleAssignments] ([RoleId] ASC);
END
GO

-- 4. PROFESSIONAL / PROVIDER PROFILES
-- Business Rules: Anyone can register, but requires NID & proof before getting bookings.
-- Admin reviews & approves. 'IsActive' is controlled by provider's own decision.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProviderProfiles' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ProviderProfiles] (
        [ProfileId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [NIDNumber] NVARCHAR(30) NOT NULL,
        [NIDDocumentUrl] NVARCHAR(500) NULL,
        [TradeLicenseOrCertUrl] NVARCHAR(500) NULL,
        [Bio] NVARCHAR(1000) NULL,
        [ExperienceYears] INT NOT NULL DEFAULT (0),
        [BaseVisitingCharge] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [EmergencyVisitingCharge] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [OverallRating] DECIMAL(3,2) NOT NULL DEFAULT (0.00),
        [TotalReviewsCount] INT NOT NULL DEFAULT (0),
        [VerificationStatus] NVARCHAR(30) NOT NULL DEFAULT ('PENDING'), -- 'PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'
        [VerificationNotes] NVARCHAR(500) NULL,
        [VerifiedByAdminId] UNIQUEIDENTIFIER NULL,
        [VerifiedAt] DATETIMEOFFSET NULL,
        [IsActive] BIT NOT NULL DEFAULT (1), -- Controlled by provider's own toggle
        [IsEmergencyAvailable] BIT NOT NULL DEFAULT (0),
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [UpdatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_ProviderProfiles] PRIMARY KEY CLUSTERED ([ProfileId] ASC),
        CONSTRAINT [FK_ProviderProfiles_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId]) ON DELETE CASCADE,
        CONSTRAINT [FK_ProviderProfiles_AdminUsers] FOREIGN KEY ([VerifiedByAdminId]) REFERENCES [dbo].[Users] ([UserId]),
        CONSTRAINT [UQ_ProviderProfiles_UserId] UNIQUE ([UserId]),
        CONSTRAINT [UQ_ProviderProfiles_NID] UNIQUE ([NIDNumber])
    );

    CREATE NONCLUSTERED INDEX [IX_ProviderProfiles_VerificationStatus] ON [dbo].[ProviderProfiles] ([VerificationStatus] ASC);
    CREATE NONCLUSTERED INDEX [IX_ProviderProfiles_IsActive] ON [dbo].[ProviderProfiles] ([IsActive] ASC);
END
GO

-- 5. PROVIDER SERVICE LOCATIONS & GEO RADIUS
-- Used for geo-matching via coordinates (latitude, longitude, radius in km)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProviderLocations' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ProviderLocations] (
        [LocationId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [ProfileId] UNIQUEIDENTIFIER NOT NULL,
        [AddressLine] NVARCHAR(250) NOT NULL,
        [City] NVARCHAR(100) NOT NULL,
        [District] NVARCHAR(100) NOT NULL,
        [PostalCode] NVARCHAR(20) NULL,
        [Latitude] DECIMAL(9,6) NOT NULL,
        [Longitude] DECIMAL(9,6) NOT NULL,
        [ServiceRadiusKm] DECIMAL(5,2) NOT NULL DEFAULT (10.00),
        [IsPrimary] BIT NOT NULL DEFAULT (1),
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_ProviderLocations] PRIMARY KEY CLUSTERED ([LocationId] ASC),
        CONSTRAINT [FK_ProviderLocations_Profiles] FOREIGN KEY ([ProfileId]) REFERENCES [dbo].[ProviderProfiles] ([ProfileId]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_ProviderLocations_ProfileId] ON [dbo].[ProviderLocations] ([ProfileId] ASC);
    CREATE NONCLUSTERED INDEX [IX_ProviderLocations_Coordinates] ON [dbo].[ProviderLocations] ([Latitude] ASC, [Longitude] ASC);
END
GO
