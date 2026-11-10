class SkillAvatarInfo {
  final String key;
  final String englishName;
  final String bengaliName;
  final String assetPath;
  final String category;

  const SkillAvatarInfo({
    required this.key,
    required this.englishName,
    required this.bengaliName,
    required this.assetPath,
    required this.category,
  });
}

class AssetPaths {
  static const String avatarDir = 'assets/avatars/';
  static const String aiChatbot = '${avatarDir}ai_chatbot.jpg';

  // 35 Curated Skill Avatars
  static const List<SkillAvatarInfo> allAvatars = [
    SkillAvatarInfo(
      key: 'ac_technician',
      englishName: 'AC Technician',
      bengaliName: 'এসি মেকানিক',
      assetPath: '${avatarDir}ac_technician.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'electrician',
      englishName: 'Electrician',
      bengaliName: 'ইলেকট্রিশিয়ান',
      assetPath: '${avatarDir}electrician.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'plumber',
      englishName: 'Plumber',
      bengaliName: 'প্লাম্বার / নল মিস্ত্রি',
      assetPath: '${avatarDir}plumber.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'technician_appliance',
      englishName: 'Appliance Repair',
      bengaliName: 'যন্ত্রপাতি মেরামত',
      assetPath: '${avatarDir}technician_appliance.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'carpenter',
      englishName: 'Carpenter',
      bengaliName: 'কাঠমিস্ত্রি',
      assetPath: '${avatarDir}carpenter.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'painter',
      englishName: 'Painter & Polisher',
      bengaliName: 'রং মিস্ত্রি',
      assetPath: '${avatarDir}painter.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'mason',
      englishName: 'Mason & Civil Worker',
      bengaliName: 'রাজমিস্ত্রি',
      assetPath: '${avatarDir}mason.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'locksmith',
      englishName: 'Locksmith',
      bengaliName: 'তালা-চাবি বিশেষজ্ঞ',
      assetPath: '${avatarDir}locksmith.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'mechanic',
      englishName: 'Motorcycle & Car Mechanic',
      bengaliName: 'গাড়ি ও বাইক মেকানিক',
      assetPath: '${avatarDir}mechanic.jpg',
      category: 'Home Maintenance',
    ),
    SkillAvatarInfo(
      key: 'cleaner',
      englishName: 'Deep Cleaner',
      bengaliName: 'পরিচ্ছন্নতাকর্মী',
      assetPath: '${avatarDir}cleaner.jpg',
      category: 'Cleaning & Healthcare',
    ),
    SkillAvatarInfo(
      key: 'pest_control',
      englishName: 'Pest Control Specialist',
      bengaliName: 'কীটপতঙ্গ দমনকারী',
      assetPath: '${avatarDir}pest_control.jpg',
      category: 'Cleaning & Healthcare',
    ),
    SkillAvatarInfo(
      key: 'caregiver',
      englishName: 'Caregiver & Nurse',
      bengaliName: 'সেবিকা / নার্স',
      assetPath: '${avatarDir}caregiver.jpg',
      category: 'Cleaning & Healthcare',
    ),
    SkillAvatarInfo(
      key: 'babysitter',
      englishName: 'Babysitter',
      bengaliName: 'শিশু পরিচারিকা',
      assetPath: '${avatarDir}babysitter.jpg',
      category: 'Cleaning & Healthcare',
    ),
    SkillAvatarInfo(
      key: 'gardener',
      englishName: 'Gardener',
      bengaliName: 'মালী',
      assetPath: '${avatarDir}gardener.jpg',
      category: 'Cleaning & Healthcare',
    ),
    SkillAvatarInfo(
      key: 'cctv_technician',
      englishName: 'CCTV & Smart Security',
      bengaliName: 'সিসিটিভি টেকনিশিয়ান',
      assetPath: '${avatarDir}cctv_technician.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'network_specialist',
      englishName: 'Network & Wi-Fi Engineer',
      bengaliName: 'নেটওয়ার্ক স্পেশালিস্ট',
      assetPath: '${avatarDir}network_specialist.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'smart_security',
      englishName: 'Smart Lock & Security',
      bengaliName: 'স্মার্ট সিকিউরিটি',
      assetPath: '${avatarDir}smart_security.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'software_engineer',
      englishName: 'Software Engineer',
      bengaliName: 'সফটওয়্যার ইঞ্জিনিয়ার',
      assetPath: '${avatarDir}software_engineer.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'web_developer',
      englishName: 'Web Developer',
      bengaliName: 'ওয়েব ডেভেলপার',
      assetPath: '${avatarDir}web_developer.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'ui_ux_designer',
      englishName: 'UI/UX Designer',
      bengaliName: 'ইউআই/ইউএক্স ডিজাইনার',
      assetPath: '${avatarDir}ui_ux_designer.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'seo_expert',
      englishName: 'SEO & Growth Expert',
      bengaliName: 'এসইও বিশেষজ্ঞ',
      assetPath: '${avatarDir}seo_expert.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'digital_marketer',
      englishName: 'Digital Marketer',
      bengaliName: 'ডিজিটাল মার্কেটার',
      assetPath: '${avatarDir}digital_marketer.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'virtual_assistant',
      englishName: 'Virtual Assistant',
      bengaliName: 'ভার্চুয়াল সহকারী',
      assetPath: '${avatarDir}virtual_assistant.jpg',
      category: 'Tech & Electronics',
    ),
    SkillAvatarInfo(
      key: 'packer_mover',
      englishName: 'Packer & Mover',
      bengaliName: 'বাসা বদল ও প্যাকিং',
      assetPath: '${avatarDir}packer_mover.jpg',
      category: 'Logistics & Moving',
    ),
    SkillAvatarInfo(
      key: 'driver',
      englishName: 'Chauffeur / Driver',
      bengaliName: 'ড্রাইভার',
      assetPath: '${avatarDir}driver.jpg',
      category: 'Logistics & Moving',
    ),
    SkillAvatarInfo(
      key: 'food_delivery',
      englishName: 'Food Delivery Rider',
      bengaliName: 'খাবার ডেলিভারিম্যান',
      assetPath: '${avatarDir}food_delivery.jpg',
      category: 'Logistics & Moving',
    ),
    SkillAvatarInfo(
      key: 'parcel_delivery',
      englishName: 'Parcel Courier',
      bengaliName: 'পার্সেল ডেলিভারি রাইডার',
      assetPath: '${avatarDir}parcel_delivery.jpg',
      category: 'Logistics & Moving',
    ),
    SkillAvatarInfo(
      key: 'home_chef',
      englishName: 'Home Chef & Caterer',
      bengaliName: 'বাবুর্চি / রাঁধুনি',
      assetPath: '${avatarDir}home_chef.jpg',
      category: 'Personal & Care',
    ),
    SkillAvatarInfo(
      key: 'beautician',
      englishName: 'Beautician & Salon',
      bengaliName: 'বিউটিশিয়ান',
      assetPath: '${avatarDir}beautician.jpg',
      category: 'Personal & Care',
    ),
    SkillAvatarInfo(
      key: 'tailor',
      englishName: 'Tailor & Dressmaker',
      bengaliName: 'দর্জি',
      assetPath: '${avatarDir}tailor.jpg',
      category: 'Personal & Care',
    ),
    SkillAvatarInfo(
      key: 'photographer',
      englishName: 'Photographer',
      bengaliName: 'ফটোগ্রাফার',
      assetPath: '${avatarDir}photographer.jpg',
      category: 'Personal & Care',
    ),
    SkillAvatarInfo(
      key: 'videographer',
      englishName: 'Videographer',
      bengaliName: 'ভিডিওগ্রাফার',
      assetPath: '${avatarDir}videographer.jpg',
      category: 'Personal & Care',
    ),
    SkillAvatarInfo(
      key: 'home_tutor',
      englishName: 'Home Tutor',
      bengaliName: 'গৃহশিক্ষক',
      assetPath: '${avatarDir}home_tutor.jpg',
      category: 'Personal & Care',
    ),
    SkillAvatarInfo(
      key: 'event_planner',
      englishName: 'Event Planner',
      bengaliName: 'অনুষ্ঠান পরিকল্পনাকারী',
      assetPath: '${avatarDir}event_planner.jpg',
      category: 'Personal & Care',
    ),
    SkillAvatarInfo(
      key: 'general_technician',
      englishName: 'General Technician',
      bengaliName: 'দক্ষ কারিগর',
      assetPath: '${avatarDir}general_technician.jpg',
      category: 'Home Maintenance',
    ),
  ];

  static SkillAvatarInfo findByKey(String key) {
    return allAvatars.firstWhere(
      (a) => a.key == key,
      orElse: () => allAvatars.last, // general_technician fallback
    );
  }

  static String getPath(String key) {
    return findByKey(key).assetPath;
  }
}

