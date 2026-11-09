-- ============================================================================
-- Seed Data: 010_seed_all_35_skill_categories.sql
-- Module: Complete 35-Domain Skill Taxonomy & Localization Mapping
-- Platform: SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)
-- Target Database: Microsoft SQL Server 2019+ / 2022
-- ============================================================================

USE [SkillCommerceDb];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Helper table for batch category ingestion
DECLARE @NewCategories TABLE (
    [CategoryName] NVARCHAR(120),
    [CategorySlug] NVARCHAR(150),
    [Description] NVARCHAR(500),
    [IconUrl] NVARCHAR(250),
    [DisplayOrder] INT
);

INSERT INTO @NewCategories ([CategoryName], [CategorySlug], [Description], [IconUrl], [DisplayOrder]) VALUES
(N'হোম ক্লিনিং ও জীবাণুমুক্তকরণ (Home Cleaning & Disinfection)', 'home-cleaning', 'Deep home cleaning, kitchen degreasing, bathroom wash, sofa shampooing', 'cleaner.jpg', 5),
(N'রংমিস্ত্রি ও দেয়াল ডেকোর (Painting & Wall Decor)', 'painting-decor', 'Interior/exterior painting, damp wall repair, wallpaper and texture coating', 'painter.jpg', 6),
(N'কাঠমিস্ত্রি ও ফার্নিচার (Carpentry & Furniture)', 'carpentry-furniture', 'Custom furniture build, door lock repair, cabinet assembly and polish', 'carpenter.jpg', 7),
(N'রাজমিস্ত্রি ও কনস্ট্রাকশন (Masonry & Civil Repair)', 'masonry-civil', 'Brickwork, tile setting, concrete chipping, roof damp proofing', 'mason.jpg', 8),
(N'বাগান পরিচর্যা ও ল্যান্ডস্কেপিং (Gardening & Landscaping)', 'gardening-landscaping', 'Rooftop garden maintenance, lawn trimming, plant potting and fertilizers', 'gardener.jpg', 9),
(N'তালা-চাবি ও সিকিউরিটি সার্ভিস (Locksmith & Security)', 'locksmith-security', 'Emergency door unlocking, master key cut, smart lock install', 'locksmith.jpg', 10),
(N'কীটপতঙ্গ ও পোকা দমন (Pest Control & Fumigation)', 'pest-control', 'Cockroach gel treatment, termite control, bed bug heat disinfection', 'exterminator.jpg', 11),
(N'বাসার বাবুর্চি ও ক্যাটারিং (Home Chef & Catering)', 'home-chef-catering', 'Daily family cooking, special party catering, traditional feast cooking', 'home_chef.jpg', 12),
(N'নার্সিং ও রোগী সেবা (Caregiving & Patient Care)', 'caregiving-nursing', 'Elderly care, post-surgery patient care, injection & IV fluid assist', 'caregiver.jpg', 13),
(N'বেবিসিটিং ও চাইল্ড কেয়ার (Babysitting & Childcare)', 'babysitting-childcare', 'Certified infant care, toddler playtime supervision, after-school care', 'babysitter.jpg', 14),
(N'হোম টিউটর ও পড়াশোনা (Home Tutoring & Academic)', 'home-tutoring', 'Primary & high-school tutoring, math/science coaching, English language', 'home_tutor.jpg', 15),
(N'দর্জি ও সেলাই সার্ভিস (Tailoring & Alterations)', 'tailoring-alteration', 'Custom dress stitching, curtains & sofa cover fitting, suit alterations', 'tailor.jpg', 16),
(N'বিউটিশিয়ান ও পার্লার (Beauty & Salon at Home)', 'beauty-salon', 'Bridal makeup, hair spa, facial, manicure & pedicure at your doorstep', 'beautician.jpg', 17),
(N'গাড়ি ও মোটরসাইকেল মেকানিক (Automobile & Bike Repair)', 'auto-mechanic', 'Motorcycle servicing, car battery jumpstart, brake pad change, engine tune', 'mechanic.jpg', 18),
(N'ফটোগ্রাফি ও ভিডিওগ্রাফি (Photography & Media)', 'photography-media', 'Wedding photography, product catalog shoot, drone 4K videography', 'photographer.jpg', 19),
(N'ইভেন্ট ম্যানেজমেন্ট (Event Planning & Decor)', 'event-planning', 'Birthday party stage decor, sound system setup, lighting and logistics', 'event_planner.jpg', 20),
(N'ডিজিটাল মার্কেটিং ও এসইও (Digital Marketing & SEO)', 'digital-marketing', 'Local SEO ranking, Facebook ad campaigns, social media management', 'digital_marketer.jpg', 21),
(N'ওয়েব ও সফটওয়্যার তৈরি (Web & Software Development)', 'web-software-dev', 'Responsive e-commerce site, Flutter mobile apps, custom database setup', 'software_engineer.jpg', 22),
(N'বাসা বদল ও প্যাকিং (Packers & Movers Logistics)', 'packers-movers', 'Full house shifting, bubble wrapping, truck hire and safe unloading', 'packer_mover.jpg', 23),
(N'পার্সেল ও খাবার ডেলিভারি (Parcel & Food Dispatch)', 'courier-delivery', 'Express bicycle/motorcycle document courier and food delivery', 'food_delivery.jpg', 24);

-- Insert missing categories
INSERT INTO [dbo].[SkillCategories] ([CategoryName], [CategorySlug], [Description], [IconUrl], [DisplayOrder])
SELECT nc.[CategoryName], nc.[CategorySlug], nc.[Description], nc.[IconUrl], nc.[DisplayOrder]
FROM @NewCategories nc
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[SkillCategories] c WHERE c.[CategorySlug] = nc.[CategorySlug]);

-- Helper table for batch skills ingestion
DECLARE @NewSkills TABLE (
    [CategorySlug] NVARCHAR(150),
    [SkillName] NVARCHAR(150),
    [SkillSlug] NVARCHAR(180),
    [Description] NVARCHAR(1000),
    [BasicPrice] DECIMAL(18,4),
    [ServiceUnit] NVARCHAR(30),
    [EstimatedDurationMins] INT
);

INSERT INTO @NewSkills ([CategorySlug], [SkillName], [SkillSlug], [Description], [BasicPrice], [ServiceUnit], [EstimatedDurationMins]) VALUES
('home-cleaning', N'ফুল হোম ডিপ ক্লিনিং (Full Home Deep Cleaning)', 'full-home-deep-cleaning', 'Comprehensive vacuuming, floor scrub, kitchen & toilet disinfection', 1500.0000, 'PER_JOB', 180),
('home-cleaning', N'সোফা ও কার্পেট শ্যাম্পু ওয়াশ (Sofa & Carpet Shampoo)', 'sofa-carpet-shampoo', 'Hot foam extraction wash removing dirt, stains and odors', 600.0000, 'PER_JOB', 60),
('painting-decor', N'রুম ও ফ্ল্যাট পেইন্টিং (Room & Wall Painting)', 'room-wall-painting', 'Plastic emulsion, distemper, or luxury silk finish application', 12.0000, 'PER_SQFT', 240),
('carpentry-furniture', N'দরজা ও লকের সমাধান (Door & Lock Repairs)', 'door-lock-repair', 'Wood hinge adjustment, sliding door alignment, mortise lock installation', 450.0000, 'PER_JOB', 60),
('carpentry-furniture', N'নতুন ফার্নিচার অ্যাসেম্বলি (Furniture Assembly)', 'furniture-assembly', 'Flat-pack wardrobe, bed, desk and modular shelf fitting', 500.0000, 'PER_JOB', 90),
('masonry-civil', N'টাইলস ফিটিং ও গ্রাউটিং (Tiles Fitting & Grouting)', 'tiles-fitting-grouting', 'Floor & wall tile placement, waterproofing, damaged tile replacement', 25.0000, 'PER_SQFT', 180),
('gardening-landscaping', N'ছাদবাগান ও বারান্দা পরিচর্যা (Rooftop Gardening)', 'rooftop-gardening', 'Soil replacement, trimming, organic pest spray and drip irrigation', 600.0000, 'PER_JOB', 90),
('locksmith-security', N'ইমার্জেন্সি তালা খোলা (Emergency Lock Opening)', 'emergency-lock-opening', 'Non-destructive door lock opening, pad lock replacement, latch repair', 400.0000, 'PER_JOB', 30),
('pest-control', N'তেলাপোকা ও ছারপোকা দমন (Cockroach & Bed Bug Control)', 'cockroach-bed-bug-control', 'Eco-friendly odorless gel and micro-droplet spray treatment', 800.0000, 'PER_JOB', 60),
('home-chef-catering', N'স্পেশাল ইভেন্ট কুকিং (Special Feast Cooking)', 'special-feast-cooking', 'Biryani, roast, korma and dessert preparation for 10-30 guests', 2500.0000, 'PER_JOB', 240),
('caregiving-nursing', N'বয়োজ্যেষ্ঠ ও রোগীর যত্ন (Elderly & Patient Nursing)', 'elderly-patient-care', 'Vital signs check, mobility support, medication management and dressing', 1000.0000, 'PER_DAY', 480),
('babysitting-childcare', N'শিশু তত্ত্বাবধান (Childcare & Babysitting)', 'childcare-babysitting', 'Interactive educational playtime, feeding, safety monitoring', 400.0000, 'PER_HOUR', 120),
('home-tutoring', N'গণিত ও বিজ্ঞান টিউটরিং (Math & Science Tutoring)', 'math-science-tutoring', 'One-on-one structured tutoring for Class 6-10 syllabus', 500.0000, 'PER_HOUR', 90),
('tailoring-alteration', N'ড্রেস ও স্যুট অল্টারেশন (Dress Fitting & Alteration)', 'dress-fitting-alteration', 'Measurements, hem shortening, zipper replacement, waist resize', 350.0000, 'PER_JOB', 45),
('beauty-salon', N'ফেসিয়াল ও স্কিন কেয়ার (Facial & Skin Care at Home)', 'facial-skincare-home', 'Fruit facial, gold brightening massage, blackhead extraction', 900.0000, 'PER_JOB', 60),
('auto-mechanic', N'মোটরসাইকেল ফুল সার্ভিসিং (Motorcycle Master Tuning)', 'motorcycle-master-tuning', 'Carburetor wash, chain lubrication, brake shoe change, engine oil flush', 650.0000, 'PER_JOB', 90),
('auto-mechanic', N'গাড়ি ব্যাটারি ও ইলেকট্রিক ফল্ট (Car Battery & Auto Electric)', 'car-battery-auto-electric', 'Alternator test, emergency battery jumpstart, fuse replacement', 700.0000, 'PER_JOB', 45),
('photography-media', N'ইভেন্ট ফটোগ্রাফি (Event Photography Session)', 'event-photography-session', 'High-res digital portraits, color-graded delivery, candid coverage', 3000.0000, 'PER_JOB', 180),
('digital-marketing', N'ফেসবুক ও গুগল অ্যাড ক্যাম্পেইন (Digital Ads Setup)', 'digital-ads-setup', 'Conversion pixel tracking, budget optimization, banner creatives', 2000.0000, 'PER_JOB', 120),
('web-software-dev', N'ওয়েবসাইট ও ই-কমার্স সাইট তৈরি (Web Development)', 'web-ecommerce-development', 'Next.js / WordPress online store with payment gateway integration', 8000.0000, 'PER_JOB', 600),
('packers-movers', N'বাসা বদল ও ট্রাক সার্ভিস (House Shifting & Logistics)', 'house-shifting-logistics', 'Furniture disassembling, packing blankets, loading and transport', 3500.0000, 'PER_JOB', 300),
('courier-delivery', N'দ্রুত পার্সেল ও চিঠি ডেলিভারি (Express Courier Delivery)', 'express-courier-delivery', 'Same-day urgent document and package drop-off across city zones', 180.0000, 'PER_JOB', 60);

-- Insert missing skills linked to their respective categories
INSERT INTO [dbo].[SkillSets] ([CategoryId], [SkillName], [SkillSlug], [Description], [BasicPrice], [ServiceUnit], [EstimatedDurationMins])
SELECT c.[CategoryId], ns.[SkillName], ns.[SkillSlug], ns.[Description], ns.[BasicPrice], ns.[ServiceUnit], ns.[EstimatedDurationMins]
FROM @NewSkills ns
INNER JOIN [dbo].[SkillCategories] c ON c.[CategorySlug] = ns.[CategorySlug]
WHERE NOT EXISTS (SELECT 1 FROM [dbo].[SkillSets] s WHERE s.[SkillSlug] = ns.[SkillSlug]);

COMMIT TRANSACTION;
GO
PRINT '010_seed_all_35_skill_categories completed successfully.';
GO

