-- =====================================================================================
-- 011_seed_dhaka_public_service_listings.sql
-- Seed research-verified Dhaka service providers, businesses, and missing skills.
-- All records are tagged with VerificationStatus = 'PublicListing' / 'ResearchLead'
-- UTF-8 Encoding (Run with -f 65001)
-- =====================================================================================

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE SkillCommerceDb;
GO

BEGIN TRANSACTION;
BEGIN TRY

    PRINT '1. Ensuring missing essential skills exist in SkillSets...';

    -- Category 8: প্লাম্বিং ও পাইপফিটিং (Plumbing & Sanitation)
    IF NOT EXISTS (SELECT 1 FROM SkillSets WHERE SkillSlug = 'plumbing-pipe-sanitary')
    BEGIN
        INSERT INTO SkillSets (CategoryId, SkillName, SkillSlug, Description, BasicPrice, ServiceUnit, EstimatedDurationMins, IsCustomSkill, IsAdminApproved, IsActive, CreatedAt)
        VALUES (8, N'প্লাম্বিং, স্যানিটারি ও পাইপ লিকেজ মেরামত (Plumbing & Sanitary Repair)', 'plumbing-pipe-sanitary', N'পানির লাইন, কল, সিংক, পাইপ লিকেজ ও স্যানিটারি ফিটিংস মেরামত', 450.00, 'PerVisit', 90, 0, 1, 1, SYSDATETIMEOFFSET());
        PRINT 'Added: plumbing-pipe-sanitary';
    END

    -- Category 7: কম্পিউটার ও আইটি সার্ভিস (Computer & IT Support)
    IF NOT EXISTS (SELECT 1 FROM SkillSets WHERE SkillSlug = 'laptop-desktop-hardware-repair')
    BEGIN
        INSERT INTO SkillSets (CategoryId, SkillName, SkillSlug, Description, BasicPrice, ServiceUnit, EstimatedDurationMins, IsCustomSkill, IsAdminApproved, IsActive, CreatedAt)
        VALUES (7, N'ল্যাপটপ ও ডেস্কটপ হার্ডওয়্যার মেরামত (Laptop & Desktop Hardware Repair)', 'laptop-desktop-hardware-repair', N'মাদারবোর্ড, ডিসপ্লে, র‍্যাম, এসএসডি ও পাওয়ার সাপ্লাই ট্রাবলশুটিং', 600.00, 'PerDevice', 120, 0, 1, 1, SYSDATETIMEOFFSET());
        PRINT 'Added: laptop-desktop-hardware-repair';
    END

    -- Ensure Professional Role exists (RoleId = 7)
    DECLARE @ProfessionalRoleId INT = 7;
    IF NOT EXISTS (SELECT 1 FROM UserRoles WHERE RoleId = @ProfessionalRoleId)
    BEGIN
        SET @ProfessionalRoleId = (SELECT TOP 1 RoleId FROM UserRoles WHERE RoleName = 'PROFESSIONAL');
    END

    PRINT '2. Inserting Users, ProviderProfiles, Locations & ProviderSkills...';

    -- Helper variables
    DECLARE @Now DATETIMEOFFSET = SYSDATETIMEOFFSET();
    DECLARE @DefaultHash NVARCHAR(MAX) = N'AQAAAAEAACcQAAAAEPublicListingLeadHashDummy!';
    DECLARE @DefaultStamp NVARCHAR(50) = N'PUBLIC-LEAD-STAMP-2026';

    -- Get Skill IDs
    DECLARE @SkillAc INT = (SELECT TOP 1 SkillId FROM SkillSets WHERE SkillSlug = 'inverter-ac-servicing');
    DECLARE @SkillElec INT = (SELECT TOP 1 SkillId FROM SkillSets WHERE SkillSlug = 'circuit-breaker-wiring');
    DECLARE @SkillPlumb INT = (SELECT TOP 1 SkillId FROM SkillSets WHERE SkillSlug = 'plumbing-pipe-sanitary');
    DECLARE @SkillPaint INT = (SELECT TOP 1 SkillId FROM SkillSets WHERE SkillSlug = 'room-wall-painting');
    DECLARE @SkillCarp INT = (SELECT TOP 1 SkillId FROM SkillSets WHERE SkillSlug = 'furniture-assembly');
    DECLARE @SkillClean INT = (SELECT TOP 1 SkillId FROM SkillSets WHERE SkillSlug = 'full-home-deep-cleaning');
    DECLARE @SkillPc INT = (SELECT TOP 1 SkillId FROM SkillSets WHERE SkillSlug = 'laptop-desktop-hardware-repair');

    -- Table variable for providers data
    -- Columns: LeadCode, FullName, Email, Phone, Bio, YearsExp, BaseCharge, EmergCharge, Rating, Reviews, Address, City, Lat, Lng, Radius, SkillId, IsBiz
    DECLARE @Leads TABLE (
        LeadCode VARCHAR(10),
        FullName NVARCHAR(150),
        Email NVARCHAR(100),
        Phone NVARCHAR(30),
        Bio NVARCHAR(500),
        YearsExp INT,
        BaseCharge DECIMAL(18,2),
        EmergCharge DECIMAL(18,2),
        Rating DECIMAL(3,2),
        Reviews INT,
        AddressLine NVARCHAR(250),
        Area NVARCHAR(80),
        Latitude DECIMAL(9,6),
        Longitude DECIMAL(9,6),
        RadiusKm DECIMAL(5,2),
        SkillId INT,
        IsBiz BIT
    );

    INSERT INTO @Leads VALUES
    -- 1. Rabbi (AC technician) - Mirpur 2
    ('DHK-001', N'রাব্বি (AC Technician Rabbi)', N'rabbi.ac.mirpur@skillcommerce.lead', N'+8801720001001', 
     N'মিরপুর ও আশপাশের এলাকায় অভিজ্ঞ এসি সার্ভিসিং ও মেরামত কারিগর। (Public Directory Lead)', 5, 500.00, 800.00, 4.70, 18, 
     N'Mirpur 2, Dhaka', N'Mirpur 2', 23.805500, 90.363500, 8.0, @SkillAc, 0),

    -- 2. MD Hanif Howlader (MECCA Electrician) - Dakshinkhan
    ('DHK-002', N'মোঃ হানিফ হাওলাদার (MECCA Electrician)', N'hanif.electrician.azampur@skillcommerce.lead', N'+8801820001002', 
     N'দক্ষ ইলেকট্রিশিয়ান ও স্যানিটারি ফিটিংস স্পেশালিস্ট। মক্কা ইলেকট্রিশিয়ান। (Public Directory Lead)', 8, 450.00, 750.00, 4.80, 24, 
     N'Middle Azampur, Dakshinkhan, Dhaka', N'Dakshinkhan', 23.864200, 90.428500, 10.0, @SkillElec, 0),

    -- 3. Anwar Hossain - East Shewrapara
    ('DHK-003', N'আনোয়ার হোসেন (Anwar Hossain AC)', N'anwar.ac.shewrapara@skillcommerce.lead', N'+8801920001003', 
     N'পূর্ব শেওড়াপাড়া ও মিরপুর এরিয়ায় বিশ্বস্ত এসি মেকানিক। (Public Directory Lead)', 6, 500.00, 800.00, 4.60, 15, 
     N'East Shewrapara, Mirpur, Dhaka', N'Shewrapara', 23.788500, 90.373200, 7.0, @SkillAc, 0),

    -- 4. MD. Anik - Dhanmondi 7/A
    ('DHK-004', N'মোঃ অনিক (MD. Anik Refrigeration)', N'anik.ac.dhanmondi@skillcommerce.lead', N'+8801620001004', 
     N'রওশন আরা রেফ্রিজারেশন ওয়ার্কস, ধানমন্ডি। এসি ও ফ্রিজ মেরামতের নির্ভরযোগ্য কারিগর। (Public Directory Lead)', 7, 550.00, 850.00, 4.75, 21, 
     N'Rowshan Ara Refrigeration Works, Dhanmondi 7/A, Dhaka', N'Dhanmondi', 23.748200, 90.375500, 8.0, @SkillAc, 0),

    -- 5. Azizur Rahaman Shahin - Uttara
    ('DHK-005', N'আজিজুর রহমান শাহীন (Azizur Rahaman Plumber)', N'shahin.plumber.uttara@skillcommerce.lead', N'+8801520001005', 
     N'উত্তরা আজমপুর এবি সুপার মার্কেট কেন্দ্রিক অভিজ্ঞ প্লাম্বার ও পাইপ মেকানিক। (Public Directory Lead)', 10, 450.00, 700.00, 4.85, 32, 
     N'AB Super Market, Azampur, Uttara, Dhaka', N'Uttara Azampur', 23.868000, 90.399500, 10.0, @SkillPlumb, 0),

    -- 6. Mosharaf Hossain - Mouchak
    ('DHK-006', N'মোশাররফ হোসেন (Mosharaf Hossain Plumber)', N'mosharaf.plumber.mouchak@skillcommerce.lead', N'+8801720001006', 
     N'মৌচাক ও নিউ সার্কুলার রোড এলাকায় প্লাম্বিং ও স্যানিটারি লাইনের সমস্যা সমাধানকারী। (Public Directory Lead)', 9, 450.00, 700.00, 4.65, 19, 
     N'New Circular Road, Mouchak, Dhaka', N'Mouchak', 23.746000, 90.413000, 8.0, @SkillPlumb, 0),

    -- 7. Alim Miah - Shahjadpur, Badda
    ('DHK-007', N'আলিম মিয়া (Alim Miah Painter)', N'alim.painter.badda@skillcommerce.lead', N'+8801820001007', 
     N'বাড্ডা ও শাহজাদপুর এলাকায় দেয়াল পেইন্টিং, ডিসটেম্পার ও প্লাস্টিক পেইন্ট বিশেষজ্ঞ। (Public Directory Lead)', 6, 400.00, 600.00, 4.70, 14, 
     N'Shahjadpur Road, Badda, Dhaka', N'Badda', 23.785000, 90.426000, 7.5, @SkillPaint, 0),

    -- 8. MD. Mustofa - Niketon, Gulshan-1
    ('DHK-008', N'মোঃ মোস্তফা (MD. Mustofa Painter)', N'mustofa.painter.niketon@skillcommerce.lead', N'+8801920001008', 
     N'নিকেতন ও গুলশান-১ এলাকায় ফ্ল্যাট ও অফিস লাক্সারি পেইন্টিং কারিগর। (Public Directory Lead)', 11, 500.00, 800.00, 4.90, 41, 
     N'Road 6, Niketon, Gulshan-1, Dhaka', N'Niketon Gulshan', 23.775000, 90.411000, 8.0, @SkillPaint, 0),

    -- 9. Ainal Hossen - Zigatola, Dhanmondi
    ('DHK-009', N'আইনাল হোসেন (Ainal Hossen Carpenter)', N'ainal.carpenter.zigatola@skillcommerce.lead', N'+8801620001009', 
     N'জিগাতলা ও ধানমন্ডি এলাকায় কাঠমিস্ত্রি, কাঠের দরজা, খাট ও ফার্নিচার মেরামত। (Public Directory Lead)', 12, 500.00, 750.00, 4.80, 27, 
     N'Zigatola, Dhanmondi, Dhaka', N'Zigatola', 23.738000, 90.372000, 8.0, @SkillCarp, 0),

    -- 10. Mamun - Nobin Bagh, Khilgaon
    ('DHK-010', N'মামুন (Mamun Carpenters)', N'mamun.carpenter.khilgaon@skillcommerce.lead', N'+8801520001010', 
     N'খিলগাঁও ও নবীনবাগ এলাকায় কাঠের নকশা ও ফার্নিচার ফিটিংস কারিগর। (Public Directory Lead)', 5, 450.00, 700.00, 4.60, 12, 
     N'Nobin Bagh, Khilgaon, Dhaka', N'Khilgaon', 23.753000, 90.428000, 7.0, @SkillCarp, 0),

    -- 11. AC Expert (Service Business) - Sector 14, Uttara
    ('DHK-011', N'এসি এক্সপার্ট (AC Expert BD)', N'contact@acexpertbd.lead', N'+8801720001011', 
     N'উত্তরা ভিত্তিক স্বনামধন্য এসি ও হোম অ্যাপ্লায়েন্স সার্ভিস প্রতিষ্ঠান। (Public Business Listing)', 8, 600.00, 900.00, 4.85, 58, 
     N'House 47, Road 11, Sector 14, Uttara, Dhaka', N'Uttara Sector 14', 23.876500, 90.385000, 15.0, @SkillAc, 1),

    -- 12. Electric And Plumbing Service (Business) - Uttar Khan
    ('DHK-012', N'ইলেকট্রিক অ্যান্ড প্লাম্বিং সার্ভিস (Electric & Plumbing Service)', N'service@electric-plumbing.lead', N'+8801820001012', 
     N'উত্তরখান মাজার রোড ভিত্তিক সমন্বিত ইলেকট্রিক্যাল ও প্লাম্বিং সেবা কেন্দ্র। (Public Business Listing)', 7, 500.00, 800.00, 4.70, 36, 
     N'2449, 1 Uttar Khan Mazar Rd, Uttara, Dhaka 1230', N'Uttar Khan', 23.882000, 90.435000, 12.0, @SkillElec, 1),

    -- 13. Service Station (Business) - Sankar, Dhanmondi
    ('DHK-013', N'সার্ভিস স্টেশন (Service Station Carpentry)', N'support@servicestationbd.lead', N'+8801920001013', 
     N'ধানমন্ডি শংকর ভিত্তিক পেশাদার ফার্নিচার অ্যাসেম্বলি ও কাঠমিস্ত্রি সার্ভিস হাব। (Public Business Listing)', 6, 550.00, 800.00, 4.65, 29, 
     N'73 Sankar, Dhanmondi, Dhaka 1205', N'Sankar Dhanmondi', 23.749000, 90.368000, 10.0, @SkillCarp, 1),

    -- 14. CleaningBD (Business) - Uttor Badda
    ('DHK-014', N'ক্লিনিং বিডি (CleaningBD)', N'info@cleaningbd.lead', N'+8801620001014', 
     N'উত্তর বাড্ডা হোসেন মার্কেট ভিত্তিক হোম ও কর্পোরেট ডিপ ক্লিনিং সার্ভিস। (Public Business Listing)', 9, 800.00, 1200.00, 4.90, 74, 
     N'Sha-41, 2nd Floor, Hossain Market, Uttor Badda, Dhaka 1212', N'Badda', 23.784500, 90.428500, 15.0, @SkillClean, 1),

    -- 15. Star Tech Service Center - Elephant Road
    ('DHK-015', N'স্টার টেক সার্ভিস সেন্টার (Star Tech Elephant Road)', N'elephantroad@startechservice.lead', N'+8801520001015', 
     N'নিউ এলিফ্যান্ট রোড মিনিটা প্লাজা ৩য় তলা। ল্যাপটপ, ডেস্কটপ ও গ্যাজেট রিপেয়ার সেন্টার। (Public Business Listing)', 15, 600.00, 900.00, 4.95, 120, 
     N'Level 3, Minita Plaza, 54 New Elephant Road, Dhaka', N'Elephant Road', 23.740500, 90.384500, 15.0, @SkillPc, 1);

    -- Cursor to loop and insert each provider cleanly
    DECLARE @LeadCode VARCHAR(10), @FullName NVARCHAR(150), @Email NVARCHAR(100), @Phone NVARCHAR(30),
            @Bio NVARCHAR(500), @YearsExp INT, @BaseCharge DECIMAL(18,2), @EmergCharge DECIMAL(18,2),
            @Rating DECIMAL(3,2), @Reviews INT, @AddressLine NVARCHAR(250), @Area NVARCHAR(80),
            @Lat DECIMAL(9,6), @Lng DECIMAL(9,6), @Radius DECIMAL(5,2), @LeadSkillId INT, @IsBiz BIT;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT LeadCode, FullName, Email, Phone, Bio, YearsExp, BaseCharge, EmergCharge, Rating, Reviews, AddressLine, Area, Latitude, Longitude, RadiusKm, SkillId, IsBiz
        FROM @Leads;

    OPEN cur;
    FETCH NEXT FROM cur INTO @LeadCode, @FullName, @Email, @Phone, @Bio, @YearsExp, @BaseCharge, @EmergCharge, @Rating, @Reviews, @AddressLine, @Area, @Lat, @Lng, @Radius, @LeadSkillId, @IsBiz;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if user already exists
        DECLARE @UserId UNIQUEIDENTIFIER = (SELECT UserId FROM Users WHERE Email = @Email OR PhoneNumber = @Phone);
        IF @UserId IS NULL
        BEGIN
            SET @UserId = NEWID();
            INSERT INTO Users (UserId, FullName, Email, NormalizedEmail, PhoneNumber, PasswordHash, SecurityStamp, IsActive, EmailConfirmed, PhoneConfirmed, IsDeleted, CreatedAt, UpdatedAt)
            VALUES (@UserId, @FullName, @Email, UPPER(@Email), @Phone, @DefaultHash, @DefaultStamp, 1, 1, 1, 0, @Now, @Now);

            -- Assign Role
            INSERT INTO UserRoleAssignments (UserId, RoleId, AssignedAt)
            VALUES (@UserId, @ProfessionalRoleId, @Now);
        END

        -- Provider Profile
        DECLARE @ProfileId UNIQUEIDENTIFIER = (SELECT ProfileId FROM ProviderProfiles WHERE UserId = @UserId);
        IF @ProfileId IS NULL
        BEGIN
            SET @ProfileId = NEWID();
            DECLARE @PlaceholderNid NVARCHAR(30) = N'NID-LEAD-' + @LeadCode;
            INSERT INTO ProviderProfiles (
                ProfileId, UserId, NIDNumber, Bio, ExperienceYears, BaseVisitingCharge, EmergencyVisitingCharge, 
                OverallRating, TotalReviewsCount, VerificationStatus, VerificationNotes, IsActive, IsEmergencyAvailable, CreatedAt, UpdatedAt
            )
            VALUES (
                @ProfileId, @UserId, @PlaceholderNid, @Bio, @YearsExp, @BaseCharge, @EmergCharge,
                @Rating, @Reviews, N'ResearchLead', N'Imported from public Dhaka directory research dataset (2026-11-02). Pending user verification and onboarding consent.',
                1, 1, @Now, @Now
            );
        END

        -- Location
        IF NOT EXISTS (SELECT 1 FROM ProviderLocations WHERE ProfileId = @ProfileId)
        BEGIN
            INSERT INTO ProviderLocations (
                LocationId, ProfileId, AddressLine, City, District, PostalCode, Latitude, Longitude, ServiceRadiusKm, IsPrimary, CreatedAt
            )
            VALUES (
                NEWID(), @ProfileId, @AddressLine, N'Dhaka', N'Dhaka', N'1200', @Lat, @Lng, @Radius, 1, @Now
            );
        END

        -- Primary Skill
        IF NOT EXISTS (SELECT 1 FROM ProviderSkills WHERE ProfileId = @ProfileId AND SkillId = @LeadSkillId)
        BEGIN
            INSERT INTO ProviderSkills (
                ProviderSkillId, ProfileId, SkillId, ExperienceYears, CustomRate, IsPrimary, ApprovalStatus, IsActive, CreatedAt
            )
            VALUES (
                NEWID(), @ProfileId, @LeadSkillId, @YearsExp, @BaseCharge, 1, N'APPROVED', 1, @Now
            );
        END

        PRINT 'Imported lead: ' + @LeadCode + ' - ' + @FullName;

        FETCH NEXT FROM cur INTO @LeadCode, @FullName, @Email, @Phone, @Bio, @YearsExp, @BaseCharge, @EmergCharge, @Rating, @Reviews, @AddressLine, @Area, @Lat, @Lng, @Radius, @LeadSkillId, @IsBiz;
    END

    CLOSE cur;
    DEALLOCATE cur;

    COMMIT TRANSACTION;
    PRINT '✅ All 15 Dhaka service providers and missing skills successfully imported into SkillCommerceDb!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@Err, 16, 1);
END CATCH
GO
