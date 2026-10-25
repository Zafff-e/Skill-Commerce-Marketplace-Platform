-- ============================================================================
-- Migration: 007_create_reviews_and_badges.sql
-- Module: Verified Reviews, Customer Feedback & Provider Gamification Badges
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

-- 1. REVIEWS & RATINGS (Strict 1-per-booking verified customer reviews)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReviewsAndRatings' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ReviewsAndRatings] (
        [ReviewId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [BookingId] UNIQUEIDENTIFIER NOT NULL,
        [CustomerId] UNIQUEIDENTIFIER NOT NULL,
        [ProviderId] UNIQUEIDENTIFIER NOT NULL,
        [Rating] INT NOT NULL,
        [FeedbackText] NVARCHAR(1000) NULL,
        [ProviderResponse] NVARCHAR(1000) NULL,
        [IsPublic] BIT NOT NULL DEFAULT (1),
        [CreatedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        CONSTRAINT [PK_ReviewsAndRatings] PRIMARY KEY CLUSTERED ([ReviewId] ASC),
        CONSTRAINT [UQ_ReviewsAndRatings_BookingId] UNIQUE ([BookingId]),
        CONSTRAINT [FK_ReviewsAndRatings_Bookings] FOREIGN KEY ([BookingId]) REFERENCES [dbo].[ServiceBookings] ([BookingId]),
        CONSTRAINT [FK_ReviewsAndRatings_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Users] ([UserId]),
        CONSTRAINT [FK_ReviewsAndRatings_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[ProviderProfiles] ([ProfileId]),
        CONSTRAINT [CK_ReviewsAndRatings_Rating] CHECK ([Rating] BETWEEN 1 AND 5)
    );

    CREATE NONCLUSTERED INDEX [IX_ReviewsAndRatings_ProviderId] ON [dbo].[ReviewsAndRatings] ([ProviderId] ASC);
    CREATE NONCLUSTERED INDEX [IX_ReviewsAndRatings_CustomerId] ON [dbo].[ReviewsAndRatings] ([CustomerId] ASC);
END
GO

-- 2. GAMIFICATION & TRUST BADGES
-- Business Rules:
-- Competitive Advantage: Badge & Reward System: Top Rated, Quick Responder, Super Dokkho
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProviderBadges' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ProviderBadges] (
        [BadgeAssignmentId] UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        [ProfileId] UNIQUEIDENTIFIER NOT NULL,
        [BadgeType] NVARCHAR(50) NOT NULL, -- 'SUPER_DOKKHO', 'TOP_RATED', 'QUICK_RESPONDER', 'VERIFIED_NID'
        [BadgeTitle] NVARCHAR(100) NOT NULL,
        [BadgeDescription] NVARCHAR(300) NULL,
        [IconUrl] NVARCHAR(250) NULL,
        [AwardedAt] DATETIMEOFFSET NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
        [IsActive] BIT NOT NULL DEFAULT (1),
        CONSTRAINT [PK_ProviderBadges] PRIMARY KEY CLUSTERED ([BadgeAssignmentId] ASC),
        CONSTRAINT [FK_ProviderBadges_Profiles] FOREIGN KEY ([ProfileId]) REFERENCES [dbo].[ProviderProfiles] ([ProfileId]) ON DELETE CASCADE,
        CONSTRAINT [UQ_ProviderBadges_Profile_Badge] UNIQUE ([ProfileId], [BadgeType])
    );

    CREATE NONCLUSTERED INDEX [IX_ProviderBadges_ProfileId] ON [dbo].[ProviderBadges] ([ProfileId] ASC);
END
GO
