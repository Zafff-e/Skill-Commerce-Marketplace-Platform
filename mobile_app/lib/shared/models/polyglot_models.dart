class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String? description;
  final String? iconUrl;
  final int skillsCount;
  final List<SkillModel> skills;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.iconUrl,
    this.skillsCount = 0,
    this.skills = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      description: json['description'],
      iconUrl: json['iconUrl'],
      skillsCount: json['skillsCount'] ?? (json['skills'] as List?)?.length ?? 0,
      skills: (json['skills'] as List?)
              ?.map((s) => SkillModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'description': description,
        'iconUrl': iconUrl,
        'skillsCount': skillsCount,
        'skills': skills.map((s) => s.toJson()).toList(),
      };
}

class SkillModel {
  final int skillId;
  final int categoryId;
  final String skillName;
  final double basicPrice;
  final String serviceUnit;
  final bool isApproved;

  SkillModel({
    required this.skillId,
    required this.categoryId,
    required this.skillName,
    required this.basicPrice,
    this.serviceUnit = 'PerHour',
    this.isApproved = true,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      skillId: json['skillId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      skillName: json['skillName'] ?? '',
      basicPrice: (json['basicPrice'] as num?)?.toDouble() ?? 300.0,
      serviceUnit: json['serviceUnit'] ?? 'PerHour',
      isApproved: json['isApproved'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'skillId': skillId,
        'categoryId': categoryId,
        'skillName': skillName,
        'basicPrice': basicPrice,
        'serviceUnit': serviceUnit,
        'isApproved': isApproved,
      };
}

class ProviderGeoModel {
  final int profileId;
  final String fullName;
  final String phoneNumber;
  final String bio;
  final int experienceYears;
  final double latitude;
  final double longitude;
  final double maxRadiusKm;
  final double overallRating;
  final int ratingCount;
  final bool isActive;
  final String primarySkill;
  final double distanceKm;
  final String avatarKey;

  ProviderGeoModel({
    required this.profileId,
    required this.fullName,
    required this.phoneNumber,
    this.bio = '',
    this.experienceYears = 2,
    required this.latitude,
    required this.longitude,
    this.maxRadiusKm = 10.0,
    this.overallRating = 4.8,
    this.ratingCount = 12,
    this.isActive = true,
    required this.primarySkill,
    this.distanceKm = 1.5,
    this.avatarKey = 'general_technician',
  });

  factory ProviderGeoModel.fromJson(Map<String, dynamic> json) {
    return ProviderGeoModel(
      profileId: json['profileId'] ?? 0,
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      bio: json['bio'] ?? '',
      experienceYears: json['experienceYears'] ?? 1,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 90.4125,
      maxRadiusKm: (json['maxRadiusKm'] as num?)?.toDouble() ?? 10.0,
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 4.8,
      ratingCount: json['ratingCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      primarySkill: json['primarySkill'] ?? 'General Service',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.2,
      avatarKey: json['avatarKey'] ?? 'general_technician',
    );
  }

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'bio': bio,
        'experienceYears': experienceYears,
        'latitude': latitude,
        'longitude': longitude,
        'maxRadiusKm': maxRadiusKm,
        'overallRating': overallRating,
        'ratingCount': ratingCount,
        'isActive': isActive,
        'primarySkill': primarySkill,
        'distanceKm': distanceKm,
        'avatarKey': avatarKey,
      };
}

class BookingPartModel {
  final int partItemId;
  final int bookingId;
  final String itemDescription;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String approvalStatus; // Pending, Approved, Rejected

  BookingPartModel({
    required this.partItemId,
    required this.bookingId,
    required this.itemDescription,
    this.quantity = 1,
    required this.unitPrice,
    required this.lineTotal,
    this.approvalStatus = 'Pending',
  });

  factory BookingPartModel.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] ?? 1;
    final price = (json['unitPrice'] as num?)?.toDouble() ?? 0.0;
    return BookingPartModel(
      partItemId: json['partItemId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      itemDescription: json['itemDescription'] ?? '',
      quantity: qty,
      unitPrice: price,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? (qty * price),
      approvalStatus: json['approvalStatus'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'partItemId': partItemId,
        'bookingId': bookingId,
        'itemDescription': itemDescription,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
        'approvalStatus': approvalStatus,
      };
}

class BookingModel {
  final int bookingId;
  final String billableEntityId;
  final int jobId;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final int profileId;
  final String providerName;
  final String providerPhone;
  final int skillId;
  final String skillName;
  final String serviceAddress;
  final double latitude;
  final double longitude;
  final String status; // Accepted, OnTheWay, Arrived, InProgress, Completed, Cancelled
  final double laborAmount;
  final double urgencyFee;
  final double commissionRate;
  final double platformFee;
  final double materialsAmount;
  final double totalAmount;
  final List<BookingPartModel> parts;
  final DateTime scheduledAtUtc;
  final DateTime? completedAtUtc;

  BookingModel({
    required this.bookingId,
    required this.billableEntityId,
    required this.jobId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.profileId,
    required this.providerName,
    required this.providerPhone,
    required this.skillId,
    required this.skillName,
    required this.serviceAddress,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.laborAmount,
    this.urgencyFee = 0.0,
    this.commissionRate = 0.10,
    required this.platformFee,
    this.materialsAmount = 0.0,
    required this.totalAmount,
    this.parts = const [],
    required this.scheduledAtUtc,
    this.completedAtUtc,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'] ?? 0,
      billableEntityId: json['billableEntityId'] ?? '',
      jobId: json['jobId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      profileId: json['profileId'] ?? 0,
      providerName: json['providerName'] ?? '',
      providerPhone: json['providerPhone'] ?? '',
      skillId: json['skillId'] ?? 0,
      skillName: json['skillName'] ?? '',
      serviceAddress: json['serviceAddress'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 90.4125,
      status: json['status'] ?? 'Accepted',
      laborAmount: (json['laborAmount'] as num?)?.toDouble() ?? 0.0,
      urgencyFee: (json['urgencyFee'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.10,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      materialsAmount: (json['materialsAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      parts: (json['parts'] as List?)
              ?.map((p) => BookingPartModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      scheduledAtUtc: json['scheduledAtUtc'] != null
          ? DateTime.parse(json['scheduledAtUtc'])
          : DateTime.now(),
      completedAtUtc: json['completedAtUtc'] != null
          ? DateTime.parse(json['completedAtUtc'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'billableEntityId': billableEntityId,
        'jobId': jobId,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'profileId': profileId,
        'providerName': providerName,
        'providerPhone': providerPhone,
        'skillId': skillId,
        'skillName': skillName,
        'serviceAddress': serviceAddress,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'laborAmount': laborAmount,
        'urgencyFee': urgencyFee,
        'commissionRate': commissionRate,
        'platformFee': platformFee,
        'materialsAmount': materialsAmount,
        'totalAmount': totalAmount,
        'parts': parts.map((p) => p.toJson()).toList(),
        'scheduledAtUtc': scheduledAtUtc.toIso8601String(),
        'completedAtUtc': completedAtUtc?.toIso8601String(),
      };
}

class InvoiceModel {
  final String invoiceNumber;
  final String billableEntityId;
  final double laborAmount;
  final double urgencyFee;
  final double materialsAmount;
  final double platformFee;
  final double totalPayable;
  final double providerPayout;
  final String paidStatus;
  final DateTime issuedAtUtc;

  InvoiceModel({
    required this.invoiceNumber,
    required this.billableEntityId,
    required this.laborAmount,
    required this.urgencyFee,
    required this.materialsAmount,
    required this.platformFee,
    required this.totalPayable,
    required this.providerPayout,
    required this.paidStatus,
    required this.issuedAtUtc,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceNumber: json['invoiceNumber'] ?? '',
      billableEntityId: json['billableEntityId'] ?? '',
      laborAmount: (json['laborAmount'] as num?)?.toDouble() ?? 0.0,
      urgencyFee: (json['urgencyFee'] as num?)?.toDouble() ?? 0.0,
      materialsAmount: (json['materialsAmount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      totalPayable: (json['totalPayable'] as num?)?.toDouble() ?? 0.0,
      providerPayout: (json['providerPayout'] as num?)?.toDouble() ?? 0.0,
      paidStatus: json['paidStatus'] ?? 'Unpaid',
      issuedAtUtc: json['issuedAtUtc'] != null
          ? DateTime.parse(json['issuedAtUtc'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'invoiceNumber': invoiceNumber,
        'billableEntityId': billableEntityId,
        'laborAmount': laborAmount,
        'urgencyFee': urgencyFee,
        'materialsAmount': materialsAmount,
        'platformFee': platformFee,
        'totalPayable': totalPayable,
        'providerPayout': providerPayout,
        'paidStatus': paidStatus,
        'issuedAtUtc': issuedAtUtc.toIso8601String(),
      };
}

class JobProposalModel {
  final int proposalId;
  final int jobId;
  final int providerId;
  final String providerName;
  final String providerAvatarKey;
  final double rating;
  final int reviewsCount;
  final double proposedAmount;
  final int estimatedArrivalMins;
  final String proposalNote;
  final String phone;
  final String status; // Pending, Accepted, Rejected
  final DateTime createdAtUtc;

  JobProposalModel({
    required this.proposalId,
    required this.jobId,
    required this.providerId,
    required this.providerName,
    required this.providerAvatarKey,
    required this.rating,
    this.reviewsCount = 10,
    required this.proposedAmount,
    required this.estimatedArrivalMins,
    required this.proposalNote,
    required this.phone,
    this.status = 'Pending',
    required this.createdAtUtc,
  });

  factory JobProposalModel.fromJson(Map<String, dynamic> json) {
    return JobProposalModel(
      proposalId: json['proposalId'] ?? 0,
      jobId: json['jobId'] ?? 0,
      providerId: json['providerId'] ?? 0,
      providerName: json['providerName'] ?? '',
      providerAvatarKey: json['providerAvatarKey'] ?? 'general_technician',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: json['reviewsCount'] ?? 10,
      proposedAmount: (json['proposedAmount'] as num?)?.toDouble() ?? 0.0,
      estimatedArrivalMins: json['estimatedArrivalMins'] ?? 20,
      proposalNote: json['proposalNote'] ?? '',
      phone: json['phone'] ?? '+8801700000000',
      status: json['status'] ?? 'Pending',
      createdAtUtc: json['createdAtUtc'] != null
          ? DateTime.parse(json['createdAtUtc'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'proposalId': proposalId,
        'jobId': jobId,
        'providerId': providerId,
        'providerName': providerName,
        'providerAvatarKey': providerAvatarKey,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'proposedAmount': proposedAmount,
        'estimatedArrivalMins': estimatedArrivalMins,
        'proposalNote': proposalNote,
        'phone': phone,
        'status': status,
        'createdAtUtc': createdAtUtc.toIso8601String(),
      };
}

class CustomJobModel {
  final int jobId;
  final int customerId;
  final String customerName;
  final String categoryName;
  final String title;
  final String description;
  final double budget;
  final String location;
  final bool isUrgent;
  final bool hasVoiceNote;
  final int voiceDurationSeconds;
  final String? photoName;
  final String status; // Open, Assigned, Completed, Cancelled
  final List<JobProposalModel> proposals;
  final DateTime createdAtUtc;

  CustomJobModel({
    required this.jobId,
    required this.customerId,
    required this.customerName,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.budget,
    required this.location,
    this.isUrgent = false,
    this.hasVoiceNote = false,
    this.voiceDurationSeconds = 0,
    this.photoName,
    this.status = 'Open',
    this.proposals = const [],
    required this.createdAtUtc,
  });

  factory CustomJobModel.fromJson(Map<String, dynamic> json) {
    return CustomJobModel(
      jobId: json['jobId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      categoryName: json['categoryName'] ?? 'General',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
      isUrgent: json['isUrgent'] ?? false,
      hasVoiceNote: json['hasVoiceNote'] ?? false,
      voiceDurationSeconds: json['voiceDurationSeconds'] ?? 0,
      photoName: json['photoName'],
      status: json['status'] ?? 'Open',
      proposals: (json['proposals'] as List?)
              ?.map((p) => JobProposalModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAtUtc: json['createdAtUtc'] != null
          ? DateTime.parse(json['createdAtUtc'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'customerId': customerId,
        'customerName': customerName,
        'categoryName': categoryName,
        'title': title,
        'description': description,
        'budget': budget,
        'location': location,
        'isUrgent': isUrgent,
        'hasVoiceNote': hasVoiceNote,
        'voiceDurationSeconds': voiceDurationSeconds,
        'photoName': photoName,
        'status': status,
        'proposals': proposals.map((p) => p.toJson()).toList(),
        'createdAtUtc': createdAtUtc.toIso8601String(),
      };

  CustomJobModel copyWith({
    int? jobId,
    int? customerId,
    String? customerName,
    String? categoryName,
    String? title,
    String? description,
    double? budget,
    String? location,
    bool? isUrgent,
    bool? hasVoiceNote,
    int? voiceDurationSeconds,
    String? photoName,
    String? status,
    List<JobProposalModel>? proposals,
    DateTime? createdAtUtc,
  }) {
    return CustomJobModel(
      jobId: jobId ?? this.jobId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      location: location ?? this.location,
      isUrgent: isUrgent ?? this.isUrgent,
      hasVoiceNote: hasVoiceNote ?? this.hasVoiceNote,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
      photoName: photoName ?? this.photoName,
      status: status ?? this.status,
      proposals: proposals ?? this.proposals,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }
}

class AiIntakeResultModel {
  final String detectedLanguage;
  final String categorySlug;
  final String categoryName;
  final String skillSlug;
  final String skillName;
  final String title;
  final String problemDescription;
  final String urgency;
  final bool isUrgent;
  final double suggestedBudget;
  final String locationArea;
  final double confidenceScore;
  final String aiSummary;

  AiIntakeResultModel({
    required this.detectedLanguage,
    required this.categorySlug,
    required this.categoryName,
    required this.skillSlug,
    required this.skillName,
    required this.title,
    required this.problemDescription,
    required this.urgency,
    required this.isUrgent,
    required this.suggestedBudget,
    required this.locationArea,
    required this.confidenceScore,
    required this.aiSummary,
  });

  factory AiIntakeResultModel.fromJson(Map<String, dynamic> json) {
    return AiIntakeResultModel(
      detectedLanguage: json['detectedLanguage'] ?? 'bn',
      categorySlug: json['categorySlug'] ?? 'home-maintenance',
      categoryName: json['categoryName'] ?? 'Home Maintenance',
      skillSlug: json['skillSlug'] ?? 'general-service',
      skillName: json['skillName'] ?? 'General Service',
      title: json['title'] ?? 'Service Request',
      problemDescription: json['problemDescription'] ?? '',
      urgency: json['urgency'] ?? 'Standard',
      isUrgent: json['isUrgent'] ?? false,
      suggestedBudget: (json['suggestedBudget'] as num?)?.toDouble() ?? 1000.0,
      locationArea: json['locationArea'] ?? 'Banani, Dhaka',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.90,
      aiSummary: json['aiSummary'] ?? '✨ AI Auto-Filled',
    );
  }

  Map<String, dynamic> toJson() => {
        'detectedLanguage': detectedLanguage,
        'categorySlug': categorySlug,
        'categoryName': categoryName,
        'skillSlug': skillSlug,
        'skillName': skillName,
        'title': title,
        'problemDescription': problemDescription,
        'urgency': urgency,
        'isUrgent': isUrgent,
        'suggestedBudget': suggestedBudget,
        'locationArea': locationArea,
        'confidenceScore': confidenceScore,
        'aiSummary': aiSummary,
      };
}

class AiDiagnosticPartItemModel {
  final String partName;
  final String bengaliPartName;
  final double estimatedUnitPrice;
  final int quantity;

  AiDiagnosticPartItemModel({
    required this.partName,
    required this.bengaliPartName,
    required this.estimatedUnitPrice,
    this.quantity = 1,
  });

  factory AiDiagnosticPartItemModel.fromJson(Map<String, dynamic> json) {
    return AiDiagnosticPartItemModel(
      partName: json['partName'] ?? '',
      bengaliPartName: json['bengaliPartName'] ?? '',
      estimatedUnitPrice: (json['estimatedUnitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'partName': partName,
        'bengaliPartName': bengaliPartName,
        'estimatedUnitPrice': estimatedUnitPrice,
        'quantity': quantity,
      };
}

class AiDiagnosticResultModel {
  final String detectedComponent;
  final String bengaliComponentName;
  final String failureMode;
  final String bengaliFailureMode;
  final String severityLevel; // Mild, Moderate, Critical
  final double confidenceScore;
  final double estimatedLaborMin;
  final double estimatedLaborMax;
  final double estimatedPartsMin;
  final double estimatedPartsMax;
  final List<AiDiagnosticPartItemModel> recommendedParts;
  final String safetyWarning;
  final String advisoryNotice;

  AiDiagnosticResultModel({
    required this.detectedComponent,
    required this.bengaliComponentName,
    required this.failureMode,
    required this.bengaliFailureMode,
    required this.severityLevel,
    required this.confidenceScore,
    required this.estimatedLaborMin,
    required this.estimatedLaborMax,
    required this.estimatedPartsMin,
    required this.estimatedPartsMax,
    this.recommendedParts = const [],
    required this.safetyWarning,
    required this.advisoryNotice,
  });

  factory AiDiagnosticResultModel.fromJson(Map<String, dynamic> json) {
    var rawParts = json['recommendedParts'] as List? ?? [];
    var parts = rawParts
        .map((p) => AiDiagnosticPartItemModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return AiDiagnosticResultModel(
      detectedComponent: json['detectedComponent'] ?? 'Appliance Component',
      bengaliComponentName: json['bengaliComponentName'] ?? 'যন্ত্রাংশ',
      failureMode: json['failureMode'] ?? 'Operational Issue',
      bengaliFailureMode: json['bengaliFailureMode'] ?? 'কার্যক্ষমতার সমস্যা',
      severityLevel: json['severityLevel'] ?? 'Moderate',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.90,
      estimatedLaborMin: (json['estimatedLaborMin'] as num?)?.toDouble() ?? 400.0,
      estimatedLaborMax: (json['estimatedLaborMax'] as num?)?.toDouble() ?? 800.0,
      estimatedPartsMin: (json['estimatedPartsMin'] as num?)?.toDouble() ?? 300.0,
      estimatedPartsMax: (json['estimatedPartsMax'] as num?)?.toDouble() ?? 1000.0,
      recommendedParts: parts,
      safetyWarning: json['safetyWarning'] ?? 'Turn off power before inspecting.',
      advisoryNotice: json['advisoryNotice'] ??
          'Advisory AI estimation only. Certified technician will verify on-site.',
    );
  }

  Map<String, dynamic> toJson() => {
        'detectedComponent': detectedComponent,
        'bengaliComponentName': bengaliComponentName,
        'failureMode': failureMode,
        'bengaliFailureMode': bengaliFailureMode,
        'severityLevel': severityLevel,
        'confidenceScore': confidenceScore,
        'estimatedLaborMin': estimatedLaborMin,
        'estimatedLaborMax': estimatedLaborMax,
        'estimatedPartsMin': estimatedPartsMin,
        'estimatedPartsMax': estimatedPartsMax,
        'recommendedParts': recommendedParts.map((p) => p.toJson()).toList(),
        'safetyWarning': safetyWarning,
        'advisoryNotice': advisoryNotice,
      };
}

class AiProviderRecommendationModel {
  final int profileId;
  final String fullName;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final double overallRating;
  final int ratingCount;
  final String primarySkill;
  final double distanceKm;
  final String avatarKey;
  final double matchScore;
  final String matchReasonEnglish;
  final String matchReasonBengali;
  final bool isTopRecommendation;

  AiProviderRecommendationModel({
    required this.profileId,
    required this.fullName,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.overallRating,
    required this.ratingCount,
    required this.primarySkill,
    required this.distanceKm,
    required this.avatarKey,
    required this.matchScore,
    required this.matchReasonEnglish,
    required this.matchReasonBengali,
    this.isTopRecommendation = false,
  });

  factory AiProviderRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiProviderRecommendationModel(
      profileId: json['profileId'] ?? 0,
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 90.4125,
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 4.8,
      ratingCount: json['ratingCount'] ?? 50,
      primarySkill: json['primarySkill'] ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.0,
      avatarKey: json['avatarKey'] ?? 'general_technician',
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.90,
      matchReasonEnglish: json['matchReasonEnglish'] ?? 'Top rated nearby technician',
      matchReasonBengali: json['matchReasonBengali'] ?? 'নিকটস্থ শীর্ষ অভিজ্ঞ কারিগর',
      isTopRecommendation: json['isTopRecommendation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
        'overallRating': overallRating,
        'ratingCount': ratingCount,
        'primarySkill': primarySkill,
        'distanceKm': distanceKm,
        'avatarKey': avatarKey,
        'matchScore': matchScore,
        'matchReasonEnglish': matchReasonEnglish,
        'matchReasonBengali': matchReasonBengali,
        'isTopRecommendation': isTopRecommendation,
      };

  ProviderGeoModel toProviderGeo() {
    return ProviderGeoModel(
      profileId: profileId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      latitude: latitude,
      longitude: longitude,
      overallRating: overallRating,
      ratingCount: ratingCount,
      primarySkill: primarySkill,
      distanceKm: distanceKm,
      avatarKey: avatarKey,
    );
  }
}

class AiSupportChatMessageModel {
  final String id;
  final String textBengali;
  final String textEnglish;
  final bool isUser;
  final DateTime timestamp;
  final List<String> suggestedFollowUps;
  final String? executedToolName;
  final Map<String, dynamic>? toolData;

  AiSupportChatMessageModel({
    required this.id,
    required this.textBengali,
    required this.textEnglish,
    required this.isUser,
    required this.timestamp,
    this.suggestedFollowUps = const [],
    this.executedToolName,
    this.toolData,
  });

  factory AiSupportChatMessageModel.fromJson(Map<String, dynamic> json) {
    return AiSupportChatMessageModel(
      id: json['sessionId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      textBengali: json['replyTextBengali'] ?? json['textBengali'] ?? '',
      textEnglish: json['replyTextEnglish'] ?? json['textEnglish'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestampUtc'] != null
          ? DateTime.tryParse(json['timestampUtc']) ?? DateTime.now()
          : DateTime.now(),
      suggestedFollowUps: (json['suggestedFollowUps'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      executedToolName: json['executedToolName'],
      toolData: json['toolData'] is Map<String, dynamic> ? json['toolData'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'replyTextBengali': textBengali,
        'replyTextEnglish': textEnglish,
        'isUser': isUser,
        'timestampUtc': timestamp.toIso8601String(),
        'suggestedFollowUps': suggestedFollowUps,
        'executedToolName': executedToolName,
        'toolData': toolData,
      };
}



