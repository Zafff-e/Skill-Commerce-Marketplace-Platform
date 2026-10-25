-- ============================================================================
-- Migration: 002_create_skills_taxonomy.sql
-- Module: Skills Catalog & Professional Skill Matrix
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. SKILL CATEGORIES
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SkillCategories' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[SkillCategories] (
        [CategoryId] INT IDENTITY(1,1) NOT NULL,
        [CategoryName] NVARCHAR(120) NOT NULL,
        [CategorySlug] NVARCHAR(150) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [IconUrl] NVARCHAR(250) NULL,
        [DisplayOrder] INT NOT NULL DEFAULT (0),
        [IsActive] BIT NOT NULL DEFAULT (1),
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_SkillCategories] PRIMARY KEY CLUSTERED ([CategoryId] ASC),
        CONSTRAINT [UQ_SkillCategories_Name] UNIQUE ([CategoryName]),
        CONSTRAINT [UQ_SkillCategories_Slug] UNIQUE ([CategorySlug])
    );
END
GO

-- 2. SKILL SETS (Master technical skills catalogue)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SkillSets' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[SkillSets] (
        [SkillId] INT IDENTITY(1,1) NOT NULL,
        [CategoryId] INT NOT NULL,
        [SkillName] NVARCHAR(150) NOT NULL,
        [SkillSlug] NVARCHAR(180) NOT NULL,
        [Description] NVARCHAR(1000) NULL,
        [BasicPrice] DECIMAL(18,4) NOT NULL DEFAULT (0.0000),
        [ServiceUnit] NVARCHAR(30) NOT NULL DEFAULT ('PER_HOUR'), -- 'PER_HOUR', 'PER_JOB', 'PER_SQFT'
        [EstimatedDurationMins] INT NOT NULL DEFAULT (60),
        [IsCustomSkill] BIT NOT NULL DEFAULT (0),
        [CreatedByUserId] UNIQUEIDENTIFIER NULL,
        [IsAdminApproved] BIT NOT NULL DEFAULT (1),
        [IsActive] BIT NOT NULL DEFAULT (1),
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_SkillSets] PRIMARY KEY CLUSTERED ([SkillId] ASC),
        CONSTRAINT [FK_SkillSets_Categories] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[SkillCategories] ([CategoryId]) ON DELETE CASCADE,
        CONSTRAINT [FK_SkillSets_CreatedByUser] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[Users] ([UserId]),
        CONSTRAINT [UQ_SkillSets_Name_Category] UNIQUE ([CategoryId], [SkillName])
    );

    CREATE NONCLUSTERED INDEX [IX_SkillSets_CategoryId] ON [dbo].[SkillSets] ([CategoryId] ASC);
    CREATE NONCLUSTERED INDEX [IX_SkillSets_IsActive] ON [dbo].[SkillSets] ([IsActive] ASC);
END
GO

-- 3. PROVIDER SKILL MATRIX (Junction mapping provider to offered skills)
-- Business Rules:
-- 1. One user can have multiple skills.
-- 2. One can mark "1" Skill as Primary.
-- 3. Provider can create their own custom skills but admin must approve.
-- 4. Different skills have different prices.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProviderSkills' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ProviderSkills] (
        [ProviderSkillId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [ProfileId] UNIQUEIDENTIFIER NOT NULL,
        [SkillId] INT NOT NULL,
        [ExperienceYears] INT NOT NULL DEFAULT (1),
        [CustomRate] DECIMAL(18,4) NOT NULL,
        [PortfolioUrl] NVARCHAR(500) NULL,
        [IsPrimary] BIT NOT NULL DEFAULT (0),
        [ApprovalStatus] NVARCHAR(30) NOT NULL DEFAULT ('APPROVED'), -- 'PENDING', 'APPROVED', 'REJECTED'
        [IsActive] BIT NOT NULL DEFAULT (1),
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_ProviderSkills] PRIMARY KEY CLUSTERED ([ProviderSkillId] ASC),
        CONSTRAINT [FK_ProviderSkills_Profiles] FOREIGN KEY ([ProfileId]) REFERENCES [dbo].[ProviderProfiles] ([ProfileId]) ON DELETE CASCADE,
        CONSTRAINT [FK_ProviderSkills_SkillSets] FOREIGN KEY ([SkillId]) REFERENCES [dbo].[SkillSets] ([SkillId]) ON DELETE CASCADE,
        CONSTRAINT [UQ_ProviderSkills_Profile_Skill] UNIQUE ([ProfileId], [SkillId])
    );

    CREATE NONCLUSTERED INDEX [IX_ProviderSkills_ProfileId] ON [dbo].[ProviderSkills] ([ProfileId] ASC);
    CREATE NONCLUSTERED INDEX [IX_ProviderSkills_SkillId] ON [dbo].[ProviderSkills] ([SkillId] ASC);
    CREATE NONCLUSTERED INDEX [IX_ProviderSkills_IsPrimary] ON [dbo].[ProviderSkills] ([ProfileId] ASC, [IsPrimary] ASC) WHERE [IsPrimary] = 1;
END
GO
