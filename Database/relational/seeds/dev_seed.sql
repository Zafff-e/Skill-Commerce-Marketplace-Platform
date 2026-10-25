-- ============================================================================
-- Seed Data: dev_seed.sql
-- Module: Realistic Development Baseline & Localization Seed Data
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- 1. SEED USER ROLES
IF NOT EXISTS (SELECT 1 FROM [dbo].[UserRoles] WHERE [RoleName] = 'SUPER_ADMIN')
BEGIN
    INSERT INTO [dbo].[UserRoles] ([RoleName], [NormalizedName], [Description]) VALUES
    ('SUPER_ADMIN', 'SUPER_ADMIN', 'Platform Owner with full infrastructure controls'),
    ('ADMIN', 'ADMIN', 'Operational Administrator managing provider verification and catalogs'),
    ('PROFESSIONAL', 'PROFESSIONAL', 'Vetted skilled technician offering on-demand trade and technical services'),
    ('CUSTOMER', 'CUSTOMER', 'Consumer purchasing services and hardware spare parts');
END
GO

-- 2. SEED SYSTEM USERS
DECLARE @RoleIdAdmin INT = (SELECT [RoleId] FROM [dbo].[UserRoles] WHERE [RoleName] = 'ADMIN');
DECLARE @RoleIdPro INT = (SELECT [RoleId] FROM [dbo].[UserRoles] WHERE [RoleName] = 'PROFESSIONAL');
DECLARE @RoleIdCust INT = (SELECT [RoleId] FROM [dbo].[UserRoles] WHERE [RoleName] = 'CUSTOMER');

-- System Admin: A.H.M. Zafir Hasan
DECLARE @AdminUserId UNIQUEIDENTIFIER = '11111111-1111-1111-1111-111111111111';
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [UserId] = @AdminUserId)
BEGIN
    INSERT INTO [dbo].[Users] ([UserId], [FullName], [Email], [NormalizedEmail], [PhoneNumber], [PasswordHash], [IsActive], [EmailConfirmed], [PhoneConfirmed])
    VALUES (@AdminUserId, N'A.H.M. Zafir Hasan', 'zafir@skillcommerce.com', 'ZAFIR@SKILLCOMMERCE.COM', '+8801700000001', 'AQAAAAEAACcQAAAAEHashedDefaultAdminPass!', 1, 1, 1);

    INSERT INTO [dbo].[UserRoleAssignments] ([UserId], [RoleId]) VALUES (@AdminUserId, @RoleIdAdmin);
END

-- Professional 1: Rafiqul Islam (AC Specialist, Mirpur, Dhaka)
DECLARE @Pro1UserId UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [UserId] = @Pro1UserId)
BEGIN
    INSERT INTO [dbo].[Users] ([UserId], [FullName], [Email], [NormalizedEmail], [PhoneNumber], [PasswordHash], [IsActive], [EmailConfirmed], [PhoneConfirmed])
    VALUES (@Pro1UserId, N'রফিকুল ইসলাম (Rafiqul Islam)', 'rafiqul.ac@gmail.com', 'RAFIQUL.AC@GMAIL.COM', '+8801711223344', 'AQAAAAEAACcQAAAAEHashedPro1Pass!', 1, 1, 1);

    INSERT INTO [dbo].[UserRoleAssignments] ([UserId], [RoleId]) VALUES (@Pro1UserId, @RoleIdPro);
    INSERT INTO [dbo].[UserRoleAssignments] ([UserId], [RoleId]) VALUES (@Pro1UserId, @RoleIdCust); -- Dual Role!
END

-- Professional 2: Tanvir Rahman (Electrician, Dhanmondi, Dhaka)
DECLARE @Pro2UserId UNIQUEIDENTIFIER = '33333333-3333-3333-3333-333333333333';
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [UserId] = @Pro2UserId)
BEGIN
    INSERT INTO [dbo].[Users] ([UserId], [FullName], [Email], [NormalizedEmail], [PhoneNumber], [PasswordHash], [IsActive], [EmailConfirmed], [PhoneConfirmed])
    VALUES (@Pro2UserId, N'তানভীর রহমান (Tanvir Rahman)', 'tanvir.electric@gmail.com', 'TANVIR.ELECTRIC@GMAIL.COM', '+8801811556677', 'AQAAAAEAACcQAAAAEHashedPro2Pass!', 1, 1, 1);

    INSERT INTO [dbo].[UserRoleAssignments] ([UserId], [RoleId]) VALUES (@Pro2UserId, @RoleIdPro);
END

-- Customer 1: Nadia Karim (Gulshan, Dhaka)
DECLARE @Cust1UserId UNIQUEIDENTIFIER = '44444444-4444-4444-4444-444444444444';
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [UserId] = @Cust1UserId)
BEGIN
    INSERT INTO [dbo].[Users] ([UserId], [FullName], [Email], [NormalizedEmail], [PhoneNumber], [PasswordHash], [IsActive], [EmailConfirmed], [PhoneConfirmed])
    VALUES (@Cust1UserId, N'নাদিয়া করিম (Nadia Karim)', 'nadia.karim@outlook.com', 'NADIA.KARIM@OUTLOOK.COM', '+8801911998877', 'AQAAAAEAACcQAAAAEHashedCust1Pass!', 1, 1, 1);

    INSERT INTO [dbo].[UserRoleAssignments] ([UserId], [RoleId]) VALUES (@Cust1UserId, @RoleIdCust);
END
GO

-- 3. SEED PROVIDER PROFILES & LOCATIONS
DECLARE @Pro1UserId UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';
DECLARE @Pro2UserId UNIQUEIDENTIFIER = '33333333-3333-3333-3333-333333333333';
DECLARE @Pro1ProfileId UNIQUEIDENTIFIER = 'A1A1A1A1-A1A1-A1A1-A1A1-A1A1A1A1A1A1';
DECLARE @Pro2ProfileId UNIQUEIDENTIFIER = 'B2B2B2B2-B2B2-B2B2-B2B2-B2B2B2B2B2B2';

IF NOT EXISTS (SELECT 1 FROM [dbo].[ProviderProfiles] WHERE [ProfileId] = @Pro1ProfileId)
BEGIN
    INSERT INTO [dbo].[ProviderProfiles] 
    ([ProfileId], [UserId], [NIDNumber], [Bio], [ExperienceYears], [BaseVisitingCharge], [EmergencyVisitingCharge], [OverallRating], [TotalReviewsCount], [VerificationStatus], [IsActive], [IsEmergencyAvailable])
    VALUES 
    (@Pro1ProfileId, @Pro1UserId, '19872691234567890', N'১০ বছরের অভিজ্ঞ ইনভার্টার এসি ও রেফ্রিজারেটর টেকনিশিয়ান। ঢাকা মিরপুর ও তৎসংলগ্ন এলাকায় দ্রুত সেবা প্রদান করি।', 10, 300.0000, 600.0000, 4.90, 48, 'APPROVED', 1, 1);

    INSERT INTO [dbo].[ProviderLocations]
    ([ProfileId], [AddressLine], [City], [District], [PostalCode], [Latitude], [Longitude], [ServiceRadiusKm], [IsPrimary])
    VALUES
    (@Pro1ProfileId, N'House 14, Road 5, Block C, Mirpur-2', N'Dhaka', N'Dhaka', '1216', 23.804100, 90.366500, 12.50, 1);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[ProviderProfiles] WHERE [ProfileId] = @Pro2ProfileId)
BEGIN
    INSERT INTO [dbo].[ProviderProfiles] 
    ([ProfileId], [UserId], [NIDNumber], [Bio], [ExperienceYears], [BaseVisitingCharge], [EmergencyVisitingCharge], [OverallRating], [TotalReviewsCount], [VerificationStatus], [IsActive], [IsEmergencyAvailable])
    VALUES 
    (@Pro2ProfileId, @Pro2UserId, '19922699876543210', N'বাসাবাড়ি ও বাণিজ্যিক ভবনের সার্কিট ব্রেকার, ডিবি বোর্ড ওয়্যারিং ও শর্ট সার্কিট ফল্ট ট্রেসিং বিশেষজ্ঞ।', 7, 250.0000, 500.0000, 4.85, 32, 'APPROVED', 1, 1);

    INSERT INTO [dbo].[ProviderLocations]
    ([ProfileId], [AddressLine], [City], [District], [PostalCode], [Latitude], [Longitude], [ServiceRadiusKm], [IsPrimary])
    VALUES
    (@Pro2ProfileId, N'Road 8A, Dhanmondi R/A', N'Dhaka', N'Dhaka', '1209', 23.746500, 90.376000, 10.00, 1);
END
GO

-- 4. SEED SKILL TAXONOMY
IF NOT EXISTS (SELECT 1 FROM [dbo].[SkillCategories] WHERE [CategorySlug] = 'electronics-appliances')
BEGIN
    INSERT INTO [dbo].[SkillCategories] ([CategoryName], [CategorySlug], [Description], [IconUrl], [DisplayOrder]) VALUES
    (N'ইলেকট্রনিক্স ও গৃহস্থালি সরঞ্জাম (Electronics & Appliances)', 'electronics-appliances', 'AC, Refrigerator, Washing Machine, Microwave oven diagnostics and repair', 'appliances.svg', 1),
    (N'ইলেকট্রিক্যাল ও ওয়্যারিং (Electrical & Wiring)', 'electrical-wiring', 'Home wiring, DB breaker fixes, industrial wiring, generator maintenance', 'electrical.svg', 2),
    (N'কম্পিউটার ও আইটি সার্ভিস (Computer & IT Support)', 'computer-it-support', 'Laptop chip repair, desktop assembly, networking, OS and security recovery', 'computer.svg', 3),
    (N'প্লাম্বিং ও পাইপফিটিং (Plumbing & Sanitation)', 'plumbing-sanitation', 'Water line leak detection, concealed pipe repair, bathroom fittings', 'plumbing.svg', 4);
END
GO

-- 5. SEED MASTER SKILLS
DECLARE @CatAppliances INT = (SELECT [CategoryId] FROM [dbo].[SkillCategories] WHERE [CategorySlug] = 'electronics-appliances');
DECLARE @CatElectrical INT = (SELECT [CategoryId] FROM [dbo].[SkillCategories] WHERE [CategorySlug] = 'electrical-wiring');

IF NOT EXISTS (SELECT 1 FROM [dbo].[SkillSets] WHERE [SkillSlug] = 'inverter-ac-servicing')
BEGIN
    INSERT INTO [dbo].[SkillSets] ([CategoryId], [SkillName], [SkillSlug], [Description], [BasicPrice], [ServiceUnit], [EstimatedDurationMins]) VALUES
    (@CatAppliances, N'ইনভার্টার এসি মাস্টার সার্ভিসিং ও গ্যাস রিফিল (Inverter AC Servicing & Gas Refill)', 'inverter-ac-servicing', 'Complete jet wash, outdoor coil cleaning, pressure test, R32/R410 gas charge', 800.0000, 'PER_JOB', 90),
    (@CatAppliances, N'রেফ্রিজারেটর কুলিং ও গ্যাস লিকেজ মেরামত (Refrigerator Cooling Repair)', 'refrigerator-cooling-repair', 'Compressor testing, filter replacement, concealed cooling loop repair', 1200.0000, 'PER_JOB', 120),
    (@CatElectrical, N'সার্কিট ব্রেকার ও ডিবি বোর্ড ওয়্যারিং (Circuit Breaker & DB Wiring)', 'circuit-breaker-wiring', 'Main DB board installation, RCCB / MCB setup, earthing load testing', 900.0000, 'PER_JOB', 60);
END
GO

-- 6. MAP PROVIDER SKILLS
DECLARE @Pro1ProfileId UNIQUEIDENTIFIER = 'A1A1A1A1-A1A1-A1A1-A1A1-A1A1A1A1A1A1';
DECLARE @SkillAcId INT = (SELECT [SkillId] FROM [dbo].[SkillSets] WHERE [SkillSlug] = 'inverter-ac-servicing');
DECLARE @SkillFridgeId INT = (SELECT [SkillId] FROM [dbo].[SkillSets] WHERE [SkillSlug] = 'refrigerator-cooling-repair');

IF NOT EXISTS (SELECT 1 FROM [dbo].[ProviderSkills] WHERE [ProfileId] = @Pro1ProfileId AND [SkillId] = @SkillAcId)
BEGIN
    INSERT INTO [dbo].[ProviderSkills] ([ProfileId], [SkillId], [ExperienceYears], [CustomRate], [IsPrimary], [ApprovalStatus])
    VALUES (@Pro1ProfileId, @SkillAcId, 10, 850.0000, 1, 'APPROVED'); -- Primary Skill
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[ProviderSkills] WHERE [ProfileId] = @Pro1ProfileId AND [SkillId] = @SkillFridgeId)
BEGIN
    INSERT INTO [dbo].[ProviderSkills] ([ProfileId], [SkillId], [ExperienceYears], [CustomRate], [IsPrimary], [ApprovalStatus])
    VALUES (@Pro1ProfileId, @SkillFridgeId, 8, 1200.0000, 0, 'APPROVED');
END
GO

-- 7. SEED INVENTORY & SPARE PARTS
DECLARE @InvAcCapId UNIQUEIDENTIFIER = 'C1C1C1C1-C1C1-C1C1-C1C1-C1C1C1C1C1C1';
DECLARE @InvGasR32Id UNIQUEIDENTIFIER = 'C2C2C2C2-C2C2-C2C2-C2C2-C2C2C2C2C2C2';

IF NOT EXISTS (SELECT 1 FROM [dbo].[InventoryItems] WHERE [InventoryItemId] = @InvAcCapId)
BEGIN
    INSERT INTO [dbo].[InventoryItems] 
    ([InventoryItemId], [Sku], [MongoProductId], [ItemName], [WarehouseLocation], [StockOnHand], [StockReserved], [ReorderThreshold], [UnitCost])
    VALUES 
    (@InvAcCapId, 'CAP-AC-45UF', 'MONGO_PROD_AC_CAP_001', N'SHIZUKI 45uF AC Dual Run Capacitor', 'CENTRAL-DHAKA-WH01', 50, 2, 10, 450.0000),
    (@InvGasR32Id, 'GAS-R32-CYL', 'MONGO_PROD_R32_GAS_002', N'Honeywell Genetron R32 Refrigerant Gas (Canister)', 'CENTRAL-DHAKA-WH01', 30, 1, 5, 1800.0000);

    INSERT INTO [dbo].[InventoryLedger]
    ([InventoryItemId], [TransactionType], [QuantityChange], [ReferenceType], [ReferenceId], [RunningBalanceOnHand], [RunningBalanceReserved], [Notes])
    VALUES
    (@InvAcCapId, 'PURCHASE_RECEIPT', 50, 'PURCHASE_ORDER', 'PO-DHAKA-2026-001', 50, 0, 'Initial wholesale shipment receipt'),
    (@InvGasR32Id, 'PURCHASE_RECEIPT', 30, 'PURCHASE_ORDER', 'PO-DHAKA-2026-001', 30, 0, 'Initial wholesale shipment receipt');
END
GO

-- 8. SEED PROVIDER BADGES
DECLARE @Pro1ProfileId UNIQUEIDENTIFIER = 'A1A1A1A1-A1A1-A1A1-A1A1-A1A1A1A1A1A1';
IF NOT EXISTS (SELECT 1 FROM [dbo].[ProviderBadges] WHERE [ProfileId] = @Pro1ProfileId AND [BadgeType] = 'SUPER_DOKKHO')
BEGIN
    INSERT INTO [dbo].[ProviderBadges] ([ProfileId], [BadgeType], [BadgeTitle], [BadgeDescription], [IconUrl])
    VALUES 
    (@Pro1ProfileId, 'SUPER_DOKKHO', N'সুপার দক্ষ (Super Dokkho)', N'Completed 40+ verified jobs with average rating above 4.80', 'badge_super_dokkho.svg'),
    (@Pro1ProfileId, 'TOP_RATED', N'টপ রেটেড (Top Rated)', N'Consistent 5-star customer reviews over 90 days', 'badge_top_rated.svg');
END
GO

COMMIT TRANSACTION;
GO
PRINT 'SkillCommerceDb seed deployment executed successfully.';
GO
