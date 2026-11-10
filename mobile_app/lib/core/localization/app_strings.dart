import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings(locale);
  }

  bool get isBengali => locale.languageCode == 'bn';

  String get appName => isBengali ? 'দক্ষ লোক খুঁজি' : 'Dokkho Lok Khuji';
  String get tagline => isBengali ? 'আপনার এলাকায়, অভিজ্ঞ লোক' : 'Trusted professionals in your neighborhood';
  String get needService => isBengali ? 'সেবা নিতে চাই' : 'I Need Service';
  String get needServiceSub => isBengali ? 'কাছের ইলেকট্রিশিয়ান, প্লাম্বার, এসি মেকানিক খুঁজুন' : 'Find nearby electrician, plumber, AC repair & more';
  String get provideService => isBengali ? 'কাজ করতে চাই' : 'I Want to Work';
  String get provideServiceSub => isBengali ? 'দক্ষ লোক হিসেবে রেজিস্টার করে এলাকায় কাজ পান' : 'Register your skills, earn money & get jobs nearby';
  String get switchRole => isBengali ? 'মোড পরিবর্তন' : 'Switch Mode';
  String get currentModeSeeker => isBengali ? 'গ্রাহক মোড' : 'Customer Mode';
  String get currentModeProvider => isBengali ? 'কারিগর মোড' : 'Provider Mode';
  String get searchPlaceholder => isBengali ? 'আপনার কী ধরনের সার্ভিস প্রয়োজন?' : 'What service do you need?';
  String get nearbyTechnicians => isBengali ? 'নিকটস্থ অভিজ্ঞ কারিগরবৃন্দ' : 'Nearby Active Technicians';
  String get emergencyService => isBengali ? 'জরুরি সার্ভিস' : 'Emergency Service';
  String get urgentSurcharge => isBengali ? 'জরুরি ফি (+৩০০ টাকা)' : 'Urgent Surcharge (+300 BDT)';
  String get bookNow => isBengali ? 'এখনই বুক করুন' : 'Book Now';
  String get directRequest => isBengali ? 'সরাসরি বুকিং' : 'Direct Request';
  String get estimatedArrival => isBengali ? 'পৌঁছানোর সময়' : 'Est. Arrival';
  String get baseRate => isBengali ? 'শুরুর রেট' : 'Base Rate';
  String get laborCharge => isBengali ? 'মজুরি / পারিশ্রমিক' : 'Labor Charge';
  String get materialsCharge => isBengali ? 'যন্ত্রাংশের খরচ' : 'Materials & Parts';
  String get platformFee => isBengali ? 'প্ল্যাটফর্ম ফি' : 'Platform Fee';
  String get totalPayable => isBengali ? 'মোট প্রদেয় বিল' : 'Total Payable';
  String get statusRequested => isBengali ? 'অনুরোধ পাঠানো হয়েছে' : 'Requested';
  String get statusAccepted => isBengali ? 'গৃহীত হয়েছে' : 'Accepted';
  String get statusOnTheWay => isBengali ? 'কারিগর রওনা হয়েছেন' : 'On The Way';
  String get statusArrived => isBengali ? 'পৌঁছে গেছেন' : 'Arrived';
  String get statusInProgress => isBengali ? 'কাজ চলছে' : 'In Progress';
  String get statusCompleted => isBengali ? 'কাজ সম্পন্ন' : 'Completed';
  String get statusCancelled => isBengali ? 'বাতিল' : 'Cancelled';
  String get acceptJob => isBengali ? 'কাজ গ্রহণ করুন' : 'Accept Job';
  String get rejectJob => isBengali ? 'প্রত্যাখ্যান' : 'Decline';
  String get startTravel => isBengali ? 'রওনা দিয়েছি' : 'Start Travel';
  String get markArrived => isBengali ? 'পৌঁছে গেছি' : 'I Have Arrived';
  String get startWork => isBengali ? 'কাজ শুরু করলাম' : 'Start Service';
  String get completeJob => isBengali ? 'কাজ সম্পন্ন ও বিল প্রদান' : 'Complete & Issue Bill';
  String get addParts => isBengali ? 'যন্ত্রাংশ যোগ করুন' : 'Add Spare Parts';
  String get partDescription => isBengali ? 'যন্ত্রাংশের নাম / বিবরণ' : 'Part Name / Description';
  String get partUnitPrice => isBengali ? 'মূল্য (টাকা)' : 'Unit Price (BDT)';
  String get waitingCustomerApproval => isBengali ? 'গ্রাহকের অনুমোদনের অপেক্ষায়' : 'Waiting for customer approval';
  String get cashOnDelivery => isBengali ? 'ক্যাশ অন ডেলিভারি' : 'Cash on Delivery';
  String get bKash => isBengali ? 'বিকাশ' : 'bKash';
  String get nagad => isBengali ? 'নগদ' : 'Nagad';
  String get card => isBengali ? 'কার্ড' : 'Card';

  // Custom Jobs & Bidding
  String get postCustomJob => isBengali ? 'কাস্টম কাজের বিবরণ পোস্ট করুন ও দরদাম করুন' : 'Post Custom Job & Bidding';
  String get postCustomJobSub => isBengali ? 'বাজেট নির্ধারণ করুন এবং অভিজ্ঞ কারিগরদের সেরা প্রস্তাব তুলনা করুন' : 'Set your budget and compare proposals from experts';
  String get biddingModalTitle => isBengali ? 'প্রস্তাব ও দরদাম তুলনা' : 'Proposals & Price Comparison';
  String get acceptProposal => isBengali ? 'প্রস্তাব গ্রহণ করুন' : 'Accept Proposal';
  String get createJobTitle => isBengali ? 'নতুন কাস্টম কাজ পোস্ট করুন' : 'Post New Custom Job';
  String get jobTitle => isBengali ? 'কাজের শিরোনাম' : 'Job Title';
  String get jobBudget => isBengali ? 'আপনার বাজেট (টাকা)' : 'Your Budget (BDT)';
  String get jobAddress => isBengali ? 'কাজের এলাকা / ঠিকানা' : 'Job Location / Address';
  String get voiceRecord => isBengali ? 'ভয়েস নোট রেকর্ড করুন' : 'Record Voice Note';
  String get recordingNow => isBengali ? 'রেকর্ডিং হচ্ছে...' : 'Recording...';
  String get photoAttach => isBengali ? 'সমস্যার ছবি সংযুক্ত করুন' : 'Attach Problem Photo';
  String get myBookings => isBengali ? 'আমার বুকিং ও ইতিহাস' : 'My Bookings & History';
  String get activeBookings => isBengali ? 'চলতি বুকিং' : 'Active Bookings';
  String get completedBookings => isBengali ? 'পূর্বের কাজ' : 'Completed';
  String get customJobs => isBengali ? 'কাস্টম রিকোয়েস্ট' : 'Custom Jobs';
  String get noBookings => isBengali ? 'কোনো সক্রিয় বুকিং নেই' : 'No active bookings';
  String get bKashNumberHint => isBengali ? 'বিকাশ অ্যাকাউন্ট নম্বর (যেমন: ০১৭...)' : 'bKash Account Number (e.g. 017...)';
  String get bKashInstruction => isBengali ? 'বিকাশ মার্চেন্ট: ০১৭২২৩৩৪৪৭৭' : 'bKash Merchant: 01722334477';
  String get providerCustomJobs => isBengali ? 'নিকটস্থ কাস্টম কাজের অফার' : 'Available Custom Jobs Nearby';
  String get submitProposal => isBengali ? 'প্রস্তাব পাঠান' : 'Submit Proposal';
  String get proposalSuccess => isBengali ? 'প্রস্তাব সফলভাবে পাঠানো হয়েছে!' : 'Proposal submitted successfully!';
  String get bookingConfirmed => isBengali ? 'বুকিং নিশ্চিত হয়েছে!' : 'Booking confirmed!';

  // AI Features (Section 5.1 Bilingual Voice Intake)
  String get aiVoiceIntake => isBengali ? 'এআই ভয়েস অটো-ফিল' : 'AI Voice Auto-Fill';
  String get aiVoiceIntakeSub => isBengali ? 'কথা বলে সমস্যা বলুন, এআই পুরো ফর্মটি স্বয়ংক্রিয়ভাবে পূরণ করে দিবে' : 'Speak your problem, AI will analyze and pre-fill the form';
  String get aiAnalyzing => isBengali ? 'Gemini AI বিশ্লেষণ করছে...' : 'Gemini AI is analyzing voice request...';
  String get aiFilledBadge => isBengali ? '✨ এআই দিয়ে পূরণকৃত (যাচাই করুন)' : '✨ AI Auto-Filled (Please Review)';
  String get aiVoiceButton => isBengali ? '🎙️ এআই ভয়েস রিকোয়েস্ট' : '🎙️ AI Voice Request';

  // AI Feature 2: Visual Problem Diagnostic & Cost Estimator (Section 5.3)
  String get aiDiagnosisTitle => isBengali ? '✨ এআই সমস্যা নির্ণয় ও সম্ভাব্য খরচ' : '✨ AI Problem Diagnosis & Cost Estimator';
  String get aiDiagnosisSub => isBengali ? 'ছবি বিশ্লেষণ করে যন্ত্রাংশের ত্রুটি ও বাজারমূল্য প্রাক্কলন' : 'Component diagnostics & estimated repair cost';
  String get componentIdentified => isBengali ? 'সনাক্তকৃত যন্ত্রাংশ' : 'Component Identified';
  String get failureCause => isBengali ? 'সম্ভাব্য ত্রুটি / কারণ' : 'Failure Mode';
  String get severityLabel => isBengali ? 'ঝুঁকির মাত্রা' : 'Severity';
  String get estimatedLaborRange => isBengali ? 'সম্ভাব্য মজুরি পরিসীমা' : 'Est. Labor Range';
  String get estimatedPartsRange => isBengali ? 'সম্ভাব্য যন্ত্রাংশের মূল্য' : 'Est. Parts Range';
  String get recommendedPartsList => isBengali ? 'প্রয়োজনীয় সম্ভাব্য যন্ত্রাংশ' : 'Probable Spare Parts';
  String get safetyWarningTitle => isBengali ? 'নিরাপত্তা সতর্কতা' : 'Safety Warning';
  String get advisoryDisclaimer => isBengali
      ? '⚠️ এটি এআই-ভিত্তিক পরামর্শমূলক প্রাক্কলন। চূড়ান্ত বিল মিস্ত্রি সরাসরি পরিদর্শন করে নির্ধারণ করবেন।'
      : '⚠️ Advisory AI estimation for budgeting. Final parts & labor verified on-site by certified technician.';
  String get applyDiagnosisToJob => isBengali ? 'ফর্মের বিবরণ ও বাজেটে যুক্ত করুন' : 'Apply to Budget & Description';

  // AI Feature 3: Explainable Provider Recommendations (Section 5.2)
  String get aiRecommendedChoice => isBengali ? '✨ এআই সেরা পছন্দ' : '✨ AI Top Match';
  String get aiMatchmakerTitle => isBengali ? 'এআই ম্যাচমেকার রেকমেন্ডেশন' : 'AI Matchmaker Recommendation';
  String get aiMatchScore => isBengali ? 'ম্যাচ স্কোর' : 'Match Score';

  // AI Feature 4: Customer Support Assistant (Section 5.5)
  String get dokkhoAiAssistant => isBengali ? 'দক্ষ এআই সহকারী' : 'Dokkho AI Assistant';
  String get dokkhoAiTagline => isBengali ? '২৪/৭ গ্রাহক সেবা ও তাৎক্ষণিক সহায়তা' : '24/7 Customer Care & Instant Assistance';
  String get chatInputPlaceholder => isBengali ? 'প্রশ্ন বা সমস্যা লিখুন...' : 'Type your question or query...';
  String get emergencyHelpline => isBengali ? 'হটলাইন: ১৬৪৩০' : 'Hotline: 16430';

  // Number translation helper: 123 -> ১২৩
  String formatNumber(num number) {
    if (!isBengali) return number.toString();
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((char) {
      final code = char.codeUnitAt(0);
      if (code >= 48 && code <= 57) {
        return bnDigits[code - 48];
      }
      return char;
    }).join('');
  }
}

