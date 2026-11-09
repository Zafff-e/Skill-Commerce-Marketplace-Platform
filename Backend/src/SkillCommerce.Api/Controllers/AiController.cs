using Microsoft.AspNetCore.Mvc;

namespace SkillCommerce.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class AiController : ControllerBase
{
    [HttpPost("voice-intake")]
    public IActionResult VoiceIntake([FromBody] VoiceIntakeRequest request)
    {
        var text = request.TranscribedText ?? "";
        var result = AnalyzeIntakeText(text);
        return Ok(result);
    }

    [HttpPost("text-intake")]
    public IActionResult TextIntake([FromBody] TextIntakeRequest request)
    {
        var text = request.Prompt ?? "";
        var result = AnalyzeIntakeText(text);
        return Ok(result);
    }

    [HttpPost("diagnose-image")]
    public IActionResult DiagnoseImage([FromBody] DiagnoseImageRequest request)
    {
        var result = AnalyzeDiagnosticImage(request.ImageName, request.TradeCategory, request.ImageBase64);
        return Ok(result);
    }

    [HttpPost("match-providers")]
    public IActionResult MatchProviders([FromBody] MatchProvidersRequest request)
    {
        var recommendations = GenerateProviderRecommendations(request.SkillId, request.SkillName, request.Latitude, request.Longitude);
        return Ok(recommendations);
    }

    [HttpPost("support-chat")]
    public IActionResult SupportChat([FromBody] SupportChatRequest request)
    {
        var response = ProcessSupportChat(request);
        return Ok(response);
    }

    private static SupportChatResponse ProcessSupportChat(SupportChatRequest request)
    {
        var msg = (request.Message ?? "").ToLowerInvariant();
        var sessionId = string.IsNullOrWhiteSpace(request.SessionId) ? Guid.NewGuid().ToString("N")[..8] : request.SessionId;

        // 1. Booking Status Tool
        if (msg.Contains("বুকিং") || msg.Contains("booking") || msg.Contains("কোথায়") || msg.Contains("where") || msg.Contains("status") || msg.Contains("অবস্থা") || msg.Contains("ট্র্যাক") || msg.Contains("track"))
        {
            return new SupportChatResponse(
                SessionId: sessionId,
                ReplyTextBengali: "আপনার বুকিং #১০০১ একটিভ রয়েছে। টেকনিশিয়ান মোঃ রফিকুল ইসলাম (এসি স্পেশালিস্ট) বনানী রোড ১১ এর দিকে রওনা হয়েছেন। পৌঁছাতে আনুমানিক ১৫ মিনিট সময় লাগবে।",
                ReplyTextEnglish: "Your booking #1001 is active. AC Technician Rafiqul is currently on the way to Banani, Road 11. Estimated arrival: 15 minutes.",
                SuggestedFollowUps: new List<string> { "টেকনিশিয়ানকে ফোন করুন", "লাইভ ট্র্যাকিং দেখুন", "ক্যান্সেলেশন পলিসি" },
                ExecutedToolName: "GetMyBookingStatus",
                ToolData: new { BookingId = 1001, Status = "OnTheWay", Provider = "Rafiqul", EtaMins = 15 },
                TimestampUtc: DateTime.UtcNow.ToString("o")
            );
        }

        // 2. Cancellation Policy Tool
        if (msg.Contains("বাতিল") || msg.Contains("cancel") || msg.Contains("ক্যানসেল") || msg.Contains("রিফান্ড") || msg.Contains("refund"))
        {
            return new SupportChatResponse(
                SessionId: sessionId,
                ReplyTextBengali: "আমাদের প্ল্যাটফর্ম পলিসি অনুযায়ী: কারিগর রওনা দেওয়ার পূর্বে ফ্রি ক্যান্সেলেশন সম্ভব। কারিগর রওনা দিলে বা পৌঁছালে ন্যূনতম ২০০ টাকা ভ্রমণ ক্ষতিপূরণ ফি প্রযোজ্য হতে পারে।",
                ReplyTextEnglish: "Per platform policy: Free cancellation before the technician starts traveling. A standard 200 BDT travel compensation may apply if cancelled after arrival.",
                SuggestedFollowUps: new List<string> { "বুকিং বাতিল করতে চাই", "সাপোর্ট হেল্পলাইনে কল", "মূল্য তালিকা দেখুন" },
                ExecutedToolName: "GetCancelPolicy",
                ToolData: new { FreeCancellationMinutes = 5, TravelFeeBdt = 200 },
                TimestampUtc: DateTime.UtcNow.ToString("o")
            );
        }

        // 3. Price Estimates Tool
        if (msg.Contains("দাম") || msg.Contains("খরচ") || msg.Contains("রেট") || msg.Contains("price") || msg.Contains("cost") || msg.Contains("rate") || msg.Contains("চার্জ") || msg.Contains("টাকা"))
        {
            return new SupportChatResponse(
                SessionId: sessionId,
                ReplyTextBengali: "দক্ষ লোক খুঁজির প্রারম্ভিক সার্ভিস রেট:\n• এসি জেট ওয়াশ: ৫০০ টাকা\n• ইলেকট্রিশিয়ান ওয়্যারিং: ৪০০ টাকা\n• প্লাম্বিং পাইপ লিক: ৩৫০ টাকা\n• ফ্ল্যাট ডিপ ক্লিনিং: ৮০০ টাকা\n(যন্ত্রাংশের খরচ গ্রাহকের সরাসরি অনুমোদনের পরই কেবল বিলে যুক্ত হয়।)",
                ReplyTextEnglish: "Standard base service rates on Dokkho Lok Khuji:\n• AC Jet Wash: 500 BDT\n• Electrician & Wiring: 400 BDT\n• Plumbing Repair: 350 BDT\n• Apartment Deep Cleaning: 800 BDT\n(Spare parts costs require customer authorization before installation.)",
                SuggestedFollowUps: new List<string> { "কাস্টম কাজের অফার দিন", "নিকটস্থ মিস্ত্রি খুঁজুন", "এআই দিয়ে ছবি ডায়াগনসিস" },
                ExecutedToolName: "GetPriceEstimates",
                ToolData: new { AcRate = 500, ElectricianRate = 400, PlumbingRate = 350 },
                TimestampUtc: DateTime.UtcNow.ToString("o")
            );
        }

        // 4. General Assistant Response
        return new SupportChatResponse(
            SessionId: sessionId,
            ReplyTextBengali: "আমি Dokkho AI গ্রাহক সহকারী। আমি আপনাকে বুকিং ট্র্যাক করতে, সার্ভিসের খরচ জানতে বা মিস্ত্রি খুঁজে পেতে সাহায্য করতে পারি। কোনো জরুরি সহায়তার জন্য আমাদের ২৪/৭ হেল্পলাইনে কল করুন: ১৬৪৩০ অথবা +৮৮০৯৬১২৩৪৫৬৭৮।",
            ReplyTextEnglish: "I am Dokkho AI Assistant. I can help you check booking status, estimate service rates, or find nearby trade experts. For 24/7 hotline support, call 16430 or +8809612345678.",
            SuggestedFollowUps: new List<string> { "আমার চলতি বুকিং", "সার্ভিস রেট চার্ট", "জরুরি মিস্ত্রি কল" },
            ExecutedToolName: null,
            ToolData: null,
            TimestampUtc: DateTime.UtcNow.ToString("o")
        );
    }

    private static List<AiProviderRecommendation> GenerateProviderRecommendations(int? skillId, string? skillName, double? lat, double? lng)
    {
        // Active verified providers
        var baseProviders = new List<(int Id, string Name, string Phone, double Lat, double Lng, double Rating, int Count, string Skill, double DistanceKm, string Avatar)>
        {
            (1, "মোঃ রফিকুল ইসলাম (Rafiqul)", "+8801711223344", 23.8120, 90.4140, 4.90, 142, "AC Servicing & Jet Wash", 0.8, "ac_technician"),
            (2, "তানভীর আহমেদ (Tanveer)", "+8801819876543", 23.8155, 90.4180, 4.80, 98, "Electrician & DB Wiring", 1.4, "electrician"),
            (3, "আব্দুল করিম (Karim Mistri)", "+8801912345678", 23.8080, 90.4090, 4.70, 86, "Plumbing & Pipe Leak Repair", 1.9, "plumber"),
            (4, "নাসরিন জাহান (Nasreen)", "+8801615554433", 23.8160, 90.4110, 4.95, 110, "Apartment Deep Cleaning", 1.1, "cleaner")
        };

        var targetSkill = (skillName ?? "").ToLowerInvariant();

        // Section 5.2 composite weighted ranking formula:
        // Score = (0.35 * DistanceScore) + (0.30 * RatingScore) + (0.20 * CompletionRate) + (0.15 * SemanticSkillMatch)
        var ranked = baseProviders.Select(p =>
        {
            double distanceScore = Math.Clamp(1.0 - (p.DistanceKm / 10.0), 0.0, 1.0);
            double ratingScore = Math.Clamp(p.Rating / 5.0, 0.0, 1.0);
            double completionRate = p.Count > 100 ? 0.98 : 0.94;

            double semanticMatch = 0.70;
            if (string.IsNullOrWhiteSpace(targetSkill))
            {
                semanticMatch = 0.90;
            }
            else if (p.Skill.ToLowerInvariant().Contains(targetSkill) || targetSkill.Contains(p.Skill.ToLowerInvariant()))
            {
                semanticMatch = 1.00;
            }
            else if ((targetSkill.Contains("ac") && p.Skill.Contains("AC")) ||
                     (targetSkill.Contains("electr") && p.Skill.Contains("Electric")) ||
                     (targetSkill.Contains("plumb") && p.Skill.Contains("Plumb")) ||
                     (targetSkill.Contains("clean") && p.Skill.Contains("Cleaning")))
            {
                semanticMatch = 0.95;
            }

            double compositeScore = (0.35 * distanceScore) + (0.30 * ratingScore) + (0.20 * completionRate) + (0.15 * semanticMatch);
            double finalScore = Math.Round(compositeScore, 2);

            string reasonEn = $"⭐ Top rated for {p.Skill} in Banani, {p.DistanceKm} km away ({(int)(finalScore * 100)}% Match)";
            string reasonBn = $"⭐ বনানীতে {p.Skill} হিসেবে শীর্ষ অভিজ্ঞ, মাত্র {p.DistanceKm} কিমি দূরে ({(int)(finalScore * 100)}% ম্যাচ)";

            return new AiProviderRecommendation(
                ProfileId: p.Id,
                FullName: p.Name,
                PhoneNumber: p.Phone,
                Latitude: p.Lat,
                Longitude: p.Lng,
                OverallRating: p.Rating,
                RatingCount: p.Count,
                PrimarySkill: p.Skill,
                DistanceKm: p.DistanceKm,
                AvatarKey: p.Avatar,
                MatchScore: finalScore,
                MatchReasonEnglish: reasonEn,
                MatchReasonBengali: reasonBn,
                IsTopRecommendation: false
            );
        })
        .OrderByDescending(r => r.MatchScore)
        .ToList();

        if (ranked.Count > 0)
        {
            var top = ranked[0];
            ranked[0] = top with { IsTopRecommendation = true };
        }

        return ranked;
    }

    private static AiDiagnosticResult AnalyzeDiagnosticImage(string? imageName, string? category, string? imageBase64)
    {
        var hint = $"{imageName} {category}".ToLowerInvariant();

        if (hint.Contains("ac") || hint.Contains("air") || hint.Contains("cooling") || hint.Contains("কম্প্রেসর") || hint.Contains("ক্যাপাসিটর"))
        {
            return new AiDiagnosticResult(
                DetectedComponent: "Outdoor AC Compressor & 45uF Run Capacitor",
                BengaliComponentName: "এসি আউটডোর কম্প্রেসর ও ৪৫ মাইক্রোফ্যারাড ক্যাপাসিটর",
                FailureMode: "Capacitor terminal degradation & depleted refrigerant pressure",
                BengaliFailureMode: "ক্যাপাসিটরের টার্মিনালে কার্বন জমেছে এবং গ্যাস প্রেসার কমে গেছে",
                SeverityLevel: "Moderate",
                ConfidenceScore: 0.93,
                EstimatedLaborMin: 600m,
                EstimatedLaborMax: 1000m,
                EstimatedPartsMin: 450m,
                EstimatedPartsMax: 1650m,
                RecommendedParts: new List<AiDiagnosticPartItem>
                {
                    new("45uF Heavy-Duty AC Run Capacitor", "৪৫uF হেভি-ডিউটি এসি রান ক্যাপাসিটর", 450m, 1),
                    new("R410A Eco Refrigerant Gas Top-Up (500g)", "R410A পরিবেশবান্ধব গ্যাস রিফিল (৫০০ গ্রাম)", 1200m, 1)
                },
                SafetyWarning: "Turn off dedicated AC circuit breaker before touching outdoor compressor unit.",
                AdvisoryNotice: "Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician."
            );
        }

        if (hint.Contains("electric") || hint.Contains("db") || hint.Contains("breaker") || hint.Contains("বোর্ড") || hint.Contains("ইলেকট্রিক") || hint.Contains("wiring") || hint.Contains("switch"))
        {
            return new AiDiagnosticResult(
                DetectedComponent: "Main Distribution Board (DB Box) & 32A MCB",
                BengaliComponentName: "মেইন ডিস্ট্রিবিউশন বোর্ড (ডিবি বক্স) ও ৩২এ এমসিবি সার্কিট ব্রেকার",
                FailureMode: "Thermal contact pitting & terminal overheating hazard",
                BengaliFailureMode: "টার্মিনালে অতিরিক্ত উত্তাপজনিত স্পার্ক ও কন্টাক্ট পয়েন্ট পুড়ে গেছে",
                SeverityLevel: "Critical",
                ConfidenceScore: 0.95,
                EstimatedLaborMin: 500m,
                EstimatedLaborMax: 900m,
                EstimatedPartsMin: 650m,
                EstimatedPartsMax: 1000m,
                RecommendedParts: new List<AiDiagnosticPartItem>
                {
                    new("32A Double-Pole Miniature Circuit Breaker (MCB)", "৩২ অ্যাম্পিয়ার ডাবল-পোল এমসিবি ব্রেকার", 650m, 1),
                    new("Heat-Resistant 2.5mm Copper Connecting Wire (2m)", "উত্তাপরোধী ২.৫ মিমি কপার ওয়্যারিং ক্যাবল", 350m, 1)
                },
                SafetyWarning: "Hazard: High voltage fire risk. Keep hands away from burnt copper terminals and trip main supply switch.",
                AdvisoryNotice: "Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician."
            );
        }

        if (hint.Contains("plumb") || hint.Contains("pipe") || hint.Contains("leak") || hint.Contains("পানি") || hint.Contains("কল") || hint.Contains("প্লাম্ব") || hint.Contains("sink"))
        {
            return new AiDiagnosticResult(
                DetectedComponent: "Chrome Sanitary Angle Valve & Flexible Waste Pipe",
                BengaliComponentName: "ক্রোম স্যানিটারি অ্যাঙ্গেল ভালভ ও ফ্লেক্সিবল ড্রেন পাইপ",
                FailureMode: "Thread washer fracture & sediment valve blockage",
                BengaliFailureMode: "প্যাঁচের ওয়াশার কেটে পানি উপচে পড়ছে এবং পাইপে ক্ষরণ হচ্ছে",
                SeverityLevel: "Moderate",
                ConfidenceScore: 0.91,
                EstimatedLaborMin: 400m,
                EstimatedLaborMax: 700m,
                EstimatedPartsMin: 270m,
                EstimatedPartsMax: 750m,
                RecommendedParts: new List<AiDiagnosticPartItem>
                {
                    new("Heavy Brass Chrome-Plated Angle Stopcock", "হেভি ব্রাস ক্রোম-প্লেটেড অ্যাঙ্গেল ভালভ", 480m, 1),
                    new("Flexible PVC Waste Trap Pipe (1.5 inch)", "ফ্লেক্সিবল পিভিসি ড্রেন ট্র্যাপ পাইপ (১.৫ ইঞ্চি)", 220m, 1),
                    new("Industrial Teflon Thread Seal Tape", "ইন্ডাস্ট্রিয়াল টেফলন থ্রেড সিল টেপ", 50m, 1)
                },
                SafetyWarning: "Turn off overhead rooftop stopcock if water flow is rapid to prevent floor damage.",
                AdvisoryNotice: "Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician."
            );
        }

        return new AiDiagnosticResult(
            DetectedComponent: "Domestic Appliance Motor Drive Assembly",
            BengaliComponentName: "ঘরোয়া বৈদ্যুতিক মোটরের ড্রাইভ অ্যাসেম্বলি",
            FailureMode: "Mechanical friction wear & brush contact sparking",
            BengaliFailureMode: "যান্ত্রিক ঘর্ষণজনিত কারণে কার্বন ব্রাশ ক্ষয়প্রাপ্ত হয়েছে",
            SeverityLevel: "Mild",
            ConfidenceScore: 0.88,
            EstimatedLaborMin: 400m,
            EstimatedLaborMax: 800m,
            EstimatedPartsMin: 350m,
            EstimatedPartsMax: 600m,
            RecommendedParts: new List<AiDiagnosticPartItem>
            {
                new("Heavy-Duty Bushing & Carbon Brush Pair", "হেভি-ডিউটি বুশিং ও কার্বন ব্রাশ সেট", 350m, 1)
            },
            SafetyWarning: "Unplug electrical power source before disassembling casing.",
            AdvisoryNotice: "Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician."
        );
    }

    private static AiIntakeResult AnalyzeIntakeText(string text)
    {
        var lower = text.ToLowerInvariant();
        var isBn = text.Any(c => c >= 0x0980 && c <= 0x09FF);

        // Category & Skill detection
        string categorySlug = "home-maintenance";
        string categoryName = isBn ? "হোম মেইনটেন্যান্স" : "Home Maintenance";
        string skillSlug = "general-service";
        string skillName = isBn ? "দক্ষ কারিগর সার্ভিস" : "General Trade Service";
        decimal suggestedBudget = 1000m;

        if (lower.Contains("ac") || lower.Contains("এসি") || lower.Contains("কুলিং") || lower.Contains("cooling") || lower.Contains("গ্যাস"))
        {
            categorySlug = "home-maintenance";
            categoryName = isBn ? "হোম মেইনটেন্যান্স" : "Home Maintenance";
            skillSlug = "ac-servicing";
            skillName = isBn ? "এসি সার্ভিসিং ও মেরামত" : "AC Servicing & Jet Wash";
            suggestedBudget = 1200m;
        }
        else if (lower.Contains("electric") || lower.Contains("ইলেকট্রিক") || lower.Contains("কারেন্ট") || lower.Contains("ডিবি") || lower.Contains("বোর্ড") || lower.Contains("তার") || lower.Contains("wiring") || lower.Contains("short circuit") || lower.Contains("শর্ট"))
        {
            categorySlug = "home-maintenance";
            categoryName = isBn ? "হোম মেইনটেন্যান্স" : "Home Maintenance";
            skillSlug = "electrician-db-wiring";
            skillName = isBn ? "ইলেকট্রিশিয়ান ও ওয়্যারিং" : "Electrician & DB Wiring";
            suggestedBudget = 800m;
        }
        else if (lower.Contains("plumb") || lower.Contains("প্লাম্ব") || lower.Contains("পানি") || lower.Contains("পাইপ") || lower.Contains("লিক") || lower.Contains("কল") || lower.Contains("leak"))
        {
            categorySlug = "home-maintenance";
            categoryName = isBn ? "হোম মেইনটেন্যান্স" : "Home Maintenance";
            skillSlug = "plumbing-leak";
            skillName = isBn ? "প্লাম্বিং ও পাইপ মেরামত" : "Plumbing & Pipe Leak Repair";
            suggestedBudget = 600m;
        }
        else if (lower.Contains("clean") || lower.Contains("ক্লিনিং") || lower.Contains("পরিচ্ছন্ন") || lower.Contains("জীবাণু") || lower.Contains("wash"))
        {
            categorySlug = "cleaning-healthcare";
            categoryName = isBn ? "ক্লিনিং ও হেলথকেয়ার" : "Cleaning & Healthcare";
            skillSlug = "apartment-cleaning";
            skillName = isBn ? "অ্যাপার্টমেন্ট ডিপ ক্লিনিং" : "Apartment Deep Cleaning";
            suggestedBudget = 1500m;
        }
        else if (lower.Contains("cctv") || lower.Contains("সিসিটিভি") || lower.Contains("ক্যামেরা") || lower.Contains("wifi") || lower.Contains("router") || lower.Contains("রাউটার"))
        {
            categorySlug = "tech-electronics";
            categoryName = isBn ? "টেক ও ইলেকট্রনিক্স" : "Tech & Electronics";
            skillSlug = "cctv-setup";
            skillName = isBn ? "সিসিটিভি ও নেটওয়ার্ক সেটআপ" : "CCTV & DVR Camera Setup";
            suggestedBudget = 900m;
        }
        else if (lower.Contains("shift") || lower.Contains("বাসা বদল") || lower.Contains("পরিবহন") || lower.Contains("mover"))
        {
            categorySlug = "logistics-moving";
            categoryName = isBn ? "বাসা বদল ও পরিবহন" : "Logistics & Moving";
            skillSlug = "house-shifting";
            skillName = isBn ? "বাসা বদল ও শিফটিং" : "House Shifting & Moving";
            suggestedBudget = 2500m;
        }

        // Urgency detection
        bool isUrgent = lower.Contains("জরুরি") || lower.Contains("urgent") || lower.Contains("emergency") || lower.Contains("দ্রুত") || lower.Contains("এখনই") || lower.Contains("danger");
        string urgency = isUrgent ? "Urgent" : "Standard";

        // Location detection
        string location = isBn ? "বনানী, ঢাকা" : "Banani, Dhaka";
        if (lower.Contains("গুলশান") || lower.Contains("gulshan")) location = isBn ? "গুলশান, ঢাকা" : "Gulshan, Dhaka";
        else if (lower.Contains("মিরপুর") || lower.Contains("mirpur")) location = isBn ? "মিরপুর, ঢাকা" : "Mirpur, Dhaka";
        else if (lower.Contains("ধানমন্ডি") || lower.Contains("dhanmondi")) location = isBn ? "ধানমন্ডি, ঢাকা" : "Dhanmondi, Dhaka";
        else if (lower.Contains("উত্তরা") || lower.Contains("uttara")) location = isBn ? "উত্তরা, ঢাকা" : "Uttara, Dhaka";

        // Title and description
        string title = isBn
            ? $"{skillName} সার্ভিস প্রয়োজন"
            : $"Need {skillName} Service";

        string description = string.IsNullOrWhiteSpace(text)
            ? (isBn ? "ভয়েস নোট থেকে এক্সট্র্যাক্ট করা বিবরণ।" : "Extracted from voice intake audio.")
            : text;

        return new AiIntakeResult(
            DetectedLanguage: isBn ? "bn" : "en",
            CategorySlug: categorySlug,
            CategoryName: categoryName,
            SkillSlug: skillSlug,
            SkillName: skillName,
            Title: title,
            ProblemDescription: description,
            Urgency: urgency,
            IsUrgent: isUrgent,
            SuggestedBudget: suggestedBudget,
            LocationArea: location,
            ConfidenceScore: 0.94,
            AiSummary: isBn ? $"✨ এআই বিশ্লেষণ: {skillName} ({location})" : $"✨ AI Intake: {skillName} ({location})"
        );
    }
}

public sealed record VoiceIntakeRequest(string? AudioBase64, string? TranscribedText, string? Format);
public sealed record TextIntakeRequest(string? Prompt);
public sealed record DiagnoseImageRequest(string? ImageBase64, string? ImageName, string? TradeCategory);

public sealed record AiDiagnosticResult(
    string DetectedComponent,
    string BengaliComponentName,
    string FailureMode,
    string BengaliFailureMode,
    string SeverityLevel,
    double ConfidenceScore,
    decimal EstimatedLaborMin,
    decimal EstimatedLaborMax,
    decimal EstimatedPartsMin,
    decimal EstimatedPartsMax,
    List<AiDiagnosticPartItem> RecommendedParts,
    string SafetyWarning,
    string AdvisoryNotice
);

public sealed record AiDiagnosticPartItem(
    string PartName,
    string BengaliPartName,
    decimal EstimatedUnitPrice,
    int Quantity
);

public sealed record AiIntakeResult(
    string DetectedLanguage,
    string CategorySlug,
    string CategoryName,
    string SkillSlug,
    string SkillName,
    string Title,
    string ProblemDescription,
    string Urgency,
    bool IsUrgent,
    decimal SuggestedBudget,
    string LocationArea,
    double ConfidenceScore,
    string AiSummary
);

public sealed record MatchProvidersRequest(int? SkillId, string? SkillName, double? Latitude, double? Longitude, double? RadiusKm);

public sealed record SupportChatRequest(
    string? SessionId,
    string? Message,
    int? CustomerId,
    int? ActiveBookingId
);

public sealed record SupportChatResponse(
    string SessionId,
    string ReplyTextBengali,
    string ReplyTextEnglish,
    List<string> SuggestedFollowUps,
    string? ExecutedToolName,
    object? ToolData,
    string TimestampUtc
);

public sealed record AiProviderRecommendation(
    int ProfileId,
    string FullName,
    string PhoneNumber,
    double Latitude,
    double Longitude,
    double OverallRating,
    int RatingCount,
    string PrimarySkill,
    double DistanceKm,
    string AvatarKey,
    double MatchScore,
    string MatchReasonEnglish,
    string MatchReasonBengali,
    bool IsTopRecommendation
);

