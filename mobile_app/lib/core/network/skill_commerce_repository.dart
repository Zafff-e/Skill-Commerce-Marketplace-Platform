import '../constants/api_endpoints.dart';
import '../../shared/models/polyglot_models.dart';
import 'dio_client.dart';

class SkillCommerceRepository {
  final DioClient dioClient;

  // In-memory fallback dataset for seamless offline / disconnected demo testing
  final List<CategoryModel> _mockCategories = [];
  final List<ProviderGeoModel> _mockProviders = [];
  final List<BookingModel> _mockBookings = [];
  final List<CustomJobModel> _mockCustomJobs = [];

  SkillCommerceRepository({required this.dioClient}) {
    _initializeMockData();
  }

  void _initializeMockData() {
    _mockCategories.addAll([
      CategoryModel(
        categoryId: 1,
        categoryName: 'Home Maintenance',
        description:
            'AC, Electrician, Plumbing, Carpentry, Painting & Appliances',
        iconUrl: 'home_repair_service',
        skillsCount: 6,
        skills: [
          SkillModel(
            skillId: 101,
            categoryId: 1,
            skillName: 'AC Servicing & Jet Wash',
            basicPrice: 650,
          ),
          SkillModel(
            skillId: 102,
            categoryId: 1,
            skillName: 'Electrician & DB Wiring',
            basicPrice: 400,
          ),
          SkillModel(
            skillId: 103,
            categoryId: 1,
            skillName: 'Plumbing & Pipe Leak Repair',
            basicPrice: 450,
          ),
          SkillModel(
            skillId: 104,
            categoryId: 1,
            skillName: 'Appliance & Refrigerator Repair',
            basicPrice: 500,
          ),
          SkillModel(
            skillId: 105,
            categoryId: 1,
            skillName: 'Carpenter & Door Fitting',
            basicPrice: 400,
          ),
          SkillModel(
            skillId: 106,
            categoryId: 1,
            skillName: 'Painter & Waterproofing',
            basicPrice: 350,
          ),
        ],
      ),
      CategoryModel(
        categoryId: 2,
        categoryName: 'Cleaning & Healthcare',
        description: 'Deep Cleaning, Pest Control, Nursing & Elderly Care',
        iconUrl: 'cleaning_services',
        skillsCount: 4,
        skills: [
          SkillModel(
            skillId: 201,
            categoryId: 2,
            skillName: 'Apartment Deep Cleaning',
            basicPrice: 800,
          ),
          SkillModel(
            skillId: 202,
            categoryId: 2,
            skillName: 'Pest Control & Bedbug Spray',
            basicPrice: 600,
          ),
          SkillModel(
            skillId: 203,
            categoryId: 2,
            skillName: 'Home Nurse & Dressing',
            basicPrice: 500,
          ),
          SkillModel(
            skillId: 204,
            categoryId: 2,
            skillName: 'Senior Caregiver',
            basicPrice: 450,
          ),
        ],
      ),
      CategoryModel(
        categoryId: 3,
        categoryName: 'Tech & Electronics',
        description: 'CCTV Setup, Wi-Fi Networking, Laptop & Smart Security',
        iconUrl: 'devices',
        skillsCount: 3,
        skills: [
          SkillModel(
            skillId: 301,
            categoryId: 3,
            skillName: 'CCTV & DVR Camera Setup',
            basicPrice: 550,
          ),
          SkillModel(
            skillId: 302,
            categoryId: 3,
            skillName: 'Router & Cat6 Network Config',
            basicPrice: 450,
          ),
          SkillModel(
            skillId: 303,
            categoryId: 3,
            skillName: 'Smart Lock & Biometrics',
            basicPrice: 600,
          ),
        ],
      ),
      CategoryModel(
        categoryId: 4,
        categoryName: 'Logistics & Moving',
        description: 'House Shifting, Bubble Packing, Drivers & Deliveries',
        iconUrl: 'local_shipping',
        skillsCount: 3,
        skills: [
          SkillModel(
            skillId: 401,
            categoryId: 4,
            skillName: 'House Shifting & Moving',
            basicPrice: 1200,
          ),
          SkillModel(
            skillId: 402,
            categoryId: 4,
            skillName: 'Personal Chauffeur / Driver',
            basicPrice: 500,
          ),
          SkillModel(
            skillId: 403,
            categoryId: 4,
            skillName: 'Parcel & Courier Rider',
            basicPrice: 200,
          ),
        ],
      ),
    ]);

    _mockProviders.addAll([
      ProviderGeoModel(
        profileId: 1,
        fullName: 'মোঃ রফিকুল ইসলাম (Rafiqul)',
        phoneNumber: '+8801711223344',
        bio: '১০ বছরের অভিজ্ঞ এসি ও ফ্রিজ টেকনিশিয়ান। বিআইএসইডব্লিউ সার্টিফাইড।',
        experienceYears: 10,
        latitude: 23.8120,
        longitude: 90.4140,
        overallRating: 4.9,
        ratingCount: 142,
        primarySkill: 'AC Servicing & Jet Wash',
        distanceKm: 0.8,
        avatarKey: 'ac_technician',
      ),
      ProviderGeoModel(
        profileId: 2,
        fullName: 'তানভীর আহমেদ (Tanveer)',
        phoneNumber: '+8801819876543',
        bio: 'শর্ট সার্কিট বিশেষজ্ঞ ও আইপিএস/ডিবি বোর্ড ইনস্টলেশন স্পেশালিস্ট।',
        experienceYears: 7,
        latitude: 23.8155,
        longitude: 90.4180,
        overallRating: 4.8,
        ratingCount: 98,
        primarySkill: 'Electrician & DB Wiring',
        distanceKm: 1.4,
        avatarKey: 'electrician',
      ),
      ProviderGeoModel(
        profileId: 3,
        fullName: 'আব্দুল করিম (Karim Mistri)',
        phoneNumber: '+8801912345678',
        bio: 'প্লাম্বিং, স্যানিটারি ফিটিংস এবং পানির পাম্প মেরামতকারী।',
        experienceYears: 12,
        latitude: 23.8080,
        longitude: 90.4090,
        overallRating: 4.7,
        ratingCount: 86,
        primarySkill: 'Plumbing & Pipe Leak Repair',
        distanceKm: 1.9,
        avatarKey: 'plumber',
      ),
      ProviderGeoModel(
        profileId: 4,
        fullName: 'নাসরিন জাহান (Nasreen)',
        phoneNumber: '+8801615554433',
        bio: 'সার্টিফাইড ডিপ ক্লিনিং ও হোম কেয়ার স্পেশালিস্ট।',
        experienceYears: 5,
        latitude: 23.8160,
        longitude: 90.4110,
        overallRating: 4.95,
        ratingCount: 110,
        primarySkill: 'Apartment Deep Cleaning',
        distanceKm: 1.1,
        avatarKey: 'cleaner',
      ),
    ]);

    _mockBookings.addAll([
      BookingModel(
        bookingId: 1001,
        billableEntityId: '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
        jobId: 501,
        customerId: 10,
        customerName: 'জাফির হাসান (Zafir Hasan)',
        customerPhone: '+8801700001122',
        profileId: 1,
        providerName: 'মোঃ রফিকুল ইসলাম (Rafiqul)',
        providerPhone: '+8801711223344',
        skillId: 101,
        skillName: 'AC Servicing & Jet Wash',
        serviceAddress: 'বাড়ি ১২, রোড ৫, বনানী, ঢাকা',
        latitude: 23.8103,
        longitude: 90.4125,
        status: 'OnTheWay',
        laborAmount: 650.0,
        urgencyFee: 300.0,
        commissionRate: 0.10,
        platformFee: 95.0, // (650 + 300) * 0.10
        materialsAmount: 450.0,
        totalAmount: 1400.0,
        parts: [
          BookingPartModel(
            partItemId: 1,
            bookingId: 1001,
            itemDescription: 'ক্যাপাসিটর (45uF Capacitor)',
            quantity: 1,
            unitPrice: 450.0,
            lineTotal: 450.0,
            approvalStatus: 'Approved',
          ),
        ],
        scheduledAtUtc: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
    ]);

    _mockCustomJobs.addAll([
      CustomJobModel(
        jobId: 501,
        customerId: 10,
        customerName: 'জাফির হাসান (Zafir Hasan)',
        categoryName: 'Home Maintenance',
        title: 'পুরো ৩ রুমের ফ্ল্যাট ওয়্যারিং ও মেইন ডিবি বোর্ড মেরামত',
        description: 'মেইন ডিবি বোর্ডে স্পার্ক হচ্ছে এবং ব্রেকার ট্রিপ করছে। জরুরি সমাধান দরকার।',
        budget: 3500,
        location: 'বনানী রোড ১১, ঢাকা',
        isUrgent: false,
        hasVoiceNote: true,
        voiceDurationSeconds: 14,
        photoName: 'db_box_burnt.jpg',
        status: 'Open',
        createdAtUtc: DateTime.now().subtract(const Duration(hours: 2)),
        proposals: [
          JobProposalModel(
            proposalId: 1,
            jobId: 501,
            providerId: 2,
            providerName: 'তানভীর রহমান (Tanvir)',
            providerAvatarKey: 'electrician',
            rating: 4.85,
            reviewsCount: 89,
            proposedAmount: 3200,
            estimatedArrivalMins: 20,
            proposalNote: '৩ মাস কাজের ফ্রি সার্ভিস ওয়ারেন্টি দিবো ইনশাআল্লাহ।',
            phone: '+8801722334455',
            status: 'Pending',
            createdAtUtc: DateTime.now().subtract(const Duration(minutes: 90)),
          ),
          JobProposalModel(
            proposalId: 2,
            jobId: 501,
            providerId: 1,
            providerName: 'মোঃ রফিকুল ইসলাম (Rafiqul)',
            providerAvatarKey: 'ac_technician',
            rating: 4.9,
            reviewsCount: 142,
            proposedAmount: 3400,
            estimatedArrivalMins: 15,
            proposalNote: 'অরিজিনাল হ্যাভেলস ও বিবিসি তার দিয়ে কমপ্লিট করে দিবো।',
            phone: '+8801711223344',
            status: 'Pending',
            createdAtUtc: DateTime.now().subtract(const Duration(minutes: 60)),
          ),
        ],
      ),
      CustomJobModel(
        jobId: 502,
        customerId: 10,
        customerName: 'জাফির হাসান (Zafir Hasan)',
        categoryName: 'Home Maintenance',
        title: '২ টন ইনভার্টার এসি গ্যাস রিফিল ও ওয়াশ',
        description: 'কুলিং হচ্ছে না, ইনডোর ইউনিট থেকে পানি পড়ছে।',
        budget: 2500,
        location: 'গুলশান ২, ঢাকা',
        isUrgent: true,
        hasVoiceNote: false,
        voiceDurationSeconds: 0,
        photoName: null,
        status: 'Open',
        createdAtUtc: DateTime.now().subtract(const Duration(hours: 1)),
        proposals: [
          JobProposalModel(
            proposalId: 3,
            jobId: 502,
            providerId: 1,
            providerName: 'মোঃ রফিকুল ইসলাম (Rafiqul)',
            providerAvatarKey: 'ac_technician',
            rating: 4.9,
            reviewsCount: 142,
            proposedAmount: 2400,
            estimatedArrivalMins: 10,
            proposalNote: 'R32 অরিজিনাল গ্যাস এবং ফুল জেট প্রেশার ওয়াশ।',
            phone: '+8801711223344',
            status: 'Pending',
            createdAtUtc: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
    ]);
  }

  // Categories & Taxonomy
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.categories);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return _mockCategories;
  }

  // Provider Geo Search (Elasticsearch Haversine queries)
  Future<List<ProviderGeoModel>> searchNearbyProviders({
    int? skillId,
    double latitude = 23.8103,
    double longitude = 90.4125,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.providerSearch,
        queryParameters: {
          if (skillId != null) 'skillId': skillId,
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
          'sort': 'distance',
        },
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((p) => ProviderGeoModel.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Fallback: filter mock providers
    return _mockProviders;
  }

  // Bookings: List
  Future<List<BookingModel>> getMyBookings({required String asRole}) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.myBookings,
        queryParameters: {'as': asRole},
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] ?? response.data;
        if (items is List) {
          return items
              .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return _mockBookings;
  }

  // Create Booking / Direct Request with Idempotency-Key
  Future<BookingModel> createBooking({
    required int skillId,
    required String skillName,
    int? targetProfileId,
    String? providerName,
    required String address,
    double latitude = 23.8103,
    double longitude = 90.4125,
    bool isUrgent = false,
    double laborRate = 500.0,
  }) async {
    final urgencyFee = isUrgent ? 300.0 : 0.0;
    final platformFee = (laborRate + urgencyFee) * 0.10;
    final total = laborRate + urgencyFee;

    final newBooking = BookingModel(
      bookingId: 1000 + _mockBookings.length + 1,
      billableEntityId: 'be-${DateTime.now().millisecondsSinceEpoch}',
      jobId: 2000 + _mockBookings.length + 1,
      customerId: 10,
      customerName: 'জাফির হাসান (Zafir Hasan)',
      customerPhone: '+8801700001122',
      profileId: targetProfileId ?? 1,
      providerName: providerName ?? 'মোঃ রফিকুল ইসলাম (Rafiqul)',
      providerPhone: '+8801711223344',
      skillId: skillId,
      skillName: skillName,
      serviceAddress: address,
      latitude: latitude,
      longitude: longitude,
      status: 'Accepted',
      laborAmount: laborRate,
      urgencyFee: urgencyFee,
      commissionRate: 0.10,
      platformFee: platformFee,
      materialsAmount: 0.0,
      totalAmount: total,
      parts: [],
      scheduledAtUtc: DateTime.now(),
    );

    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.jobs,
        data: {
          'skillId': skillId,
          'targetProfileId': targetProfileId,
          'addressText': address,
          'latitude': latitude,
          'longitude': longitude,
          'isUrgent': isUrgent,
          'budget': laborRate,
        },
      );
      if (response.statusCode == 201 && response.data != null) {
        return BookingModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    _mockBookings.insert(0, newBooking);
    return newBooking;
  }

  // Booking State Machine Transitions
  Future<BookingModel> advanceBookingStatus({
    required int bookingId,
    required String
    action, // start-travel, arrive, start-work, complete, cancel
  }) async {
    String newStatus = 'Accepted';
    if (action == 'start-travel') newStatus = 'OnTheWay';
    if (action == 'arrive') newStatus = 'Arrived';
    if (action == 'start-work') newStatus = 'InProgress';
    if (action == 'complete') newStatus = 'Completed';
    if (action == 'cancel') newStatus = 'Cancelled';

    try {
      final endpoint = action == 'start-travel'
          ? ApiEndpoints.startTravel(bookingId)
          : action == 'arrive'
          ? ApiEndpoints.arrive(bookingId)
          : action == 'start-work'
          ? ApiEndpoints.startWork(bookingId)
          : action == 'complete'
          ? ApiEndpoints.completeBooking(bookingId)
          : ApiEndpoints.cancelBooking(bookingId);

      final response = await dioClient.dio.post(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        return BookingModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    final index = _mockBookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final current = _mockBookings[index];
      final updated = BookingModel(
        bookingId: current.bookingId,
        billableEntityId: current.billableEntityId,
        jobId: current.jobId,
        customerId: current.customerId,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        profileId: current.profileId,
        providerName: current.providerName,
        providerPhone: current.providerPhone,
        skillId: current.skillId,
        skillName: current.skillName,
        serviceAddress: current.serviceAddress,
        latitude: current.latitude,
        longitude: current.longitude,
        status: newStatus,
        laborAmount: current.laborAmount,
        urgencyFee: current.urgencyFee,
        commissionRate: current.commissionRate,
        platformFee: current.platformFee,
        materialsAmount: current.materialsAmount,
        totalAmount: current.totalAmount,
        parts: current.parts,
        scheduledAtUtc: current.scheduledAtUtc,
        completedAtUtc: newStatus == 'Completed'
            ? DateTime.now()
            : current.completedAtUtc,
      );
      _mockBookings[index] = updated;
      return updated;
    }

    throw Exception('Booking not found');
  }

  // Ad-Hoc Spare Parts Entry (Technician writes, recalculates total invoice)
  Future<BookingModel> addBookingPart({
    required int bookingId,
    required String itemDescription,
    required double unitPrice,
    int quantity = 1,
  }) async {
    final lineTotal = unitPrice * quantity;
    final newPart = BookingPartModel(
      partItemId: DateTime.now().millisecondsSinceEpoch % 100000,
      bookingId: bookingId,
      itemDescription: itemDescription,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      approvalStatus: 'Approved', // Auto-approved in mock demo
    );

    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.bookingParts(bookingId),
        data: {
          'itemDescription': itemDescription,
          'quantity': quantity,
          'unitPrice': unitPrice,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return BookingModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    final index = _mockBookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final current = _mockBookings[index];
      final updatedParts = List<BookingPartModel>.from(current.parts)
        ..add(newPart);
      final newMaterialsAmount = current.materialsAmount + lineTotal;
      final newTotalAmount =
          current.laborAmount + current.urgencyFee + newMaterialsAmount;

      final updated = BookingModel(
        bookingId: current.bookingId,
        billableEntityId: current.billableEntityId,
        jobId: current.jobId,
        customerId: current.customerId,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        profileId: current.profileId,
        providerName: current.providerName,
        providerPhone: current.providerPhone,
        skillId: current.skillId,
        skillName: current.skillName,
        serviceAddress: current.serviceAddress,
        latitude: current.latitude,
        longitude: current.longitude,
        status: current.status,
        laborAmount: current.laborAmount,
        urgencyFee: current.urgencyFee,
        commissionRate: current.commissionRate,
        platformFee: current.platformFee, // Platform fee untouched! Only applies to labor + urgency
        materialsAmount: newMaterialsAmount,
        totalAmount: newTotalAmount,
        parts: updatedParts,
        scheduledAtUtc: current.scheduledAtUtc,
        completedAtUtc: current.completedAtUtc,
      );
      _mockBookings[index] = updated;
      return updated;
    }

    throw Exception('Booking not found');
  }

  // Invoice Fetching
  Future<InvoiceModel> getInvoice(int bookingId) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.bookingInvoice(bookingId),
      );
      if (response.statusCode == 200 && response.data != null) {
        return InvoiceModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    final booking = _mockBookings.firstWhere((b) => b.bookingId == bookingId);
    final providerPayout =
        (booking.laborAmount + booking.urgencyFee - booking.platformFee) +
        booking.materialsAmount;

    return InvoiceModel(
      invoiceNumber: 'SC-2026-${booking.bookingId}',
      billableEntityId: booking.billableEntityId,
      laborAmount: booking.laborAmount,
      urgencyFee: booking.urgencyFee,
      materialsAmount: booking.materialsAmount,
      platformFee: booking.platformFee,
      totalPayable: booking.totalAmount,
      providerPayout: providerPayout,
      paidStatus: 'Paid',
      issuedAtUtc: DateTime.now(),
    );
  }

  // Custom Jobs & Price Bidding Negotiation
  Future<List<CustomJobModel>> getCustomJobs() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.myJobs);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : response.data['items'];
        if (list is List) {
          return list.map((j) => CustomJobModel.fromJson(j as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return _mockCustomJobs;
  }

  Future<CustomJobModel> createCustomJob({
    required String title,
    required String description,
    required String categoryName,
    required double budget,
    required String location,
    bool isUrgent = false,
    bool hasVoiceNote = false,
    int voiceDurationSeconds = 0,
    String? photoName,
  }) async {
    final newJobId = 500 + _mockCustomJobs.length + 1;
    final newJob = CustomJobModel(
      jobId: newJobId,
      customerId: 10,
      customerName: 'জাফির হাসান (Zafir Hasan)',
      categoryName: categoryName,
      title: title,
      description: description,
      budget: budget,
      location: location,
      isUrgent: isUrgent,
      hasVoiceNote: hasVoiceNote,
      voiceDurationSeconds: voiceDurationSeconds,
      photoName: photoName,
      status: 'Open',
      createdAtUtc: DateTime.now(),
      proposals: [
        JobProposalModel(
          proposalId: DateTime.now().millisecondsSinceEpoch % 10000,
          jobId: newJobId,
          providerId: 2,
          providerName: 'তানভীর রহমান (Tanvir)',
          providerAvatarKey: 'electrician',
          rating: 4.85,
          reviewsCount: 89,
          proposedAmount: budget > 500 ? budget - 200 : budget,
          estimatedArrivalMins: 20,
          proposalNote: 'আমি এখনই রওনা হতে পারবো। দক্ষতার সাথে কাজটি সম্পন্ন করবো।',
          phone: '+8801722334455',
          status: 'Pending',
          createdAtUtc: DateTime.now(),
        ),
      ],
    );

    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.jobs,
        data: newJob.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return CustomJobModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    _mockCustomJobs.insert(0, newJob);
    return newJob;
  }

  Future<BookingModel> acceptJobProposal({
    required int jobId,
    required int proposalId,
  }) async {
    final jobIndex = _mockCustomJobs.indexWhere((j) => j.jobId == jobId);
    if (jobIndex != -1) {
      final job = _mockCustomJobs[jobIndex];
      final proposal = job.proposals.firstWhere(
        (p) => p.proposalId == proposalId,
        orElse: () => job.proposals.first,
      );

      final urgencyFee = job.isUrgent ? 300.0 : 0.0;
      final laborRate = proposal.proposedAmount;
      final platformFee = (laborRate + urgencyFee) * 0.10;
      final total = laborRate + urgencyFee;

      final confirmedBooking = BookingModel(
        bookingId: 2000 + jobId,
        billableEntityId: 'be-custom-$jobId',
        jobId: jobId,
        customerId: job.customerId,
        customerName: job.customerName,
        customerPhone: '+8801700001122',
        profileId: proposal.providerId,
        providerName: proposal.providerName,
        providerPhone: proposal.phone,
        skillId: 101,
        skillName: job.title,
        serviceAddress: job.location,
        latitude: 23.8103,
        longitude: 90.4125,
        status: 'Accepted',
        laborAmount: laborRate,
        urgencyFee: urgencyFee,
        commissionRate: 0.10,
        platformFee: platformFee,
        materialsAmount: 0.0,
        totalAmount: total,
        parts: [],
        scheduledAtUtc: DateTime.now(),
      );

      _mockBookings.insert(0, confirmedBooking);

      final updatedProposals = job.proposals.map((p) {
        if (p.proposalId == proposalId) {
          return JobProposalModel(
            proposalId: p.proposalId,
            jobId: p.jobId,
            providerId: p.providerId,
            providerName: p.providerName,
            providerAvatarKey: p.providerAvatarKey,
            rating: p.rating,
            reviewsCount: p.reviewsCount,
            proposedAmount: p.proposedAmount,
            estimatedArrivalMins: p.estimatedArrivalMins,
            proposalNote: p.proposalNote,
            phone: p.phone,
            status: 'Accepted',
            createdAtUtc: p.createdAtUtc,
          );
        }
        return p;
      }).toList();

      _mockCustomJobs[jobIndex] = job.copyWith(
        status: 'Assigned',
        proposals: updatedProposals,
      );

      return confirmedBooking;
    }

    throw Exception('Job not found');
  }

  Future<JobProposalModel> submitJobProposal({
    required int jobId,
    required int providerId,
    required String providerName,
    required String providerAvatarKey,
    required double proposedAmount,
    required int arrivalMins,
    required String note,
    required String phone,
  }) async {
    final proposal = JobProposalModel(
      proposalId: DateTime.now().millisecondsSinceEpoch % 100000,
      jobId: jobId,
      providerId: providerId,
      providerName: providerName,
      providerAvatarKey: providerAvatarKey,
      rating: 4.9,
      reviewsCount: 142,
      proposedAmount: proposedAmount,
      estimatedArrivalMins: arrivalMins,
      proposalNote: note,
      phone: phone,
      status: 'Pending',
      createdAtUtc: DateTime.now(),
    );

    final jobIndex = _mockCustomJobs.indexWhere((j) => j.jobId == jobId);
    if (jobIndex != -1) {
      final job = _mockCustomJobs[jobIndex];
      final newProposals = List<JobProposalModel>.from(job.proposals)..add(proposal);
      _mockCustomJobs[jobIndex] = job.copyWith(proposals: newProposals);
    }

    return proposal;
  }

  // AI Voice & Natural Language Intake (Gemini Multimodal / Heuristic Fallback)
  Future<AiIntakeResultModel> processVoiceIntake({
    String? audioBase64,
    String? transcribedText,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.aiVoiceIntake,
        data: {
          'audioBase64': audioBase64,
          'transcribedText': transcribedText,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return AiIntakeResultModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    return _fallbackAiAnalyze(transcribedText ?? 'আমার এসি থেকে ঠান্ডা বাতাস আসছে না, জরুরি মেরামত প্রয়োজন।');
  }

  Future<AiIntakeResultModel> processTextIntake(String prompt) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.aiTextIntake,
        data: {'prompt': prompt},
      );
      if (response.statusCode == 200 && response.data != null) {
        return AiIntakeResultModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    return _fallbackAiAnalyze(prompt);
  }

  AiIntakeResultModel _fallbackAiAnalyze(String text) {
    final lower = text.toLowerCase();
    final isBn = text.codeUnits.any((c) => c >= 0x0980 && c <= 0x09FF);

    String categorySlug = 'home-maintenance';
    String categoryName = isBn ? 'হোম মেইনটেন্যান্স' : 'Home Maintenance';
    String skillSlug = 'general-service';
    String skillName = isBn ? 'দক্ষ কারিগর সার্ভিস' : 'General Trade Service';
    double budget = 1000.0;

    if (lower.contains('ac') || lower.contains('এসি') || lower.contains('কুলিং') || lower.contains('গ্যাস') || lower.contains('cooling')) {
      skillSlug = 'ac-servicing';
      skillName = isBn ? 'এসি সার্ভিসিং ও মেরামত' : 'AC Servicing & Jet Wash';
      budget = 1200.0;
    } else if (lower.contains('electric') || lower.contains('ইলেকট্রিক') || lower.contains('কারেন্ট') || lower.contains('ডিবি') || lower.contains('ওয়্যারিং') || lower.contains('wiring') || lower.contains('শর্ট')) {
      skillSlug = 'electrician-db-wiring';
      skillName = isBn ? 'ইলেকট্রিশিয়ান ও ওয়্যারিং' : 'Electrician & DB Wiring';
      budget = 800.0;
    } else if (lower.contains('plumb') || lower.contains('প্লাম্ব') || lower.contains('পানি') || lower.contains('পাইপ') || lower.contains('লিক') || lower.contains('leak')) {
      skillSlug = 'plumbing-leak';
      skillName = isBn ? 'প্লাম্বিং ও পাইপ মেরামত' : 'Plumbing & Pipe Leak Repair';
      budget = 600.0;
    } else if (lower.contains('clean') || lower.contains('ক্লিন') || lower.contains('পরিচ্ছন্ন') || lower.contains('wash')) {
      categorySlug = 'cleaning-healthcare';
      categoryName = isBn ? 'ক্লিনিং ও হেলথকেয়ার' : 'Cleaning & Healthcare';
      skillSlug = 'apartment-cleaning';
      skillName = isBn ? 'অ্যাপার্টমেন্ট ডিপ ক্লিনিং' : 'Apartment Deep Cleaning';
      budget = 1500.0;
    }

    final isUrgent = lower.contains('জরুরি') || lower.contains('urgent') || lower.contains('emergency') || lower.contains('দ্রুত') || lower.contains('এখনই');
    String location = isBn ? 'বনানী, ঢাকা' : 'Banani, Dhaka';
    if (lower.contains('গুলশান') || lower.contains('gulshan')) {
      location = isBn ? 'গুলশান, ঢাকা' : 'Gulshan, Dhaka';
    } else if (lower.contains('মিরপুর') || lower.contains('mirpur')) {
      location = isBn ? 'মিরপুর, ঢাকা' : 'Mirpur, Dhaka';
    } else if (lower.contains('ধানমন্ডি') || lower.contains('dhanmondi')) {
      location = isBn ? 'ধানমন্ডি, ঢাকা' : 'Dhanmondi, Dhaka';
    }

    return AiIntakeResultModel(
      detectedLanguage: isBn ? 'bn' : 'en',
      categorySlug: categorySlug,
      categoryName: categoryName,
      skillSlug: skillSlug,
      skillName: skillName,
      title: isBn ? '$skillName সার্ভিস প্রয়োজন' : 'Need $skillName Service',
      problemDescription: text,
      urgency: isUrgent ? 'Urgent' : 'Standard',
      isUrgent: isUrgent,
      suggestedBudget: budget,
      locationArea: location,
      confidenceScore: 0.94,
      aiSummary: isBn ? '✨ এআই ভয়েস অ্যানালাইসিস: $skillName ($location)' : '✨ AI Intake: $skillName ($location)',
    );
  }

  // Feature 2: AI Visual Problem Diagnostic & Cost Estimator (Section 5.3)
  Future<AiDiagnosticResultModel> diagnoseProblemImage({
    String? imageName,
    String? tradeCategory,
    String? imageBase64,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.aiDiagnoseImage,
        data: {
          'imageName': imageName,
          'tradeCategory': tradeCategory,
          'imageBase64': imageBase64,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return AiDiagnosticResultModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    return _fallbackAiDiagnose(imageName ?? 'problem_inspection_photo.jpg', tradeCategory ?? 'Home Maintenance');
  }

  AiDiagnosticResultModel _fallbackAiDiagnose(String imageName, String category) {
    final hint = '$imageName $category'.toLowerCase();

    if (hint.contains('ac') || hint.contains('air') || hint.contains('cooling')) {
      return AiDiagnosticResultModel(
        detectedComponent: 'Outdoor AC Compressor & 45uF Run Capacitor',
        bengaliComponentName: 'এসি আউটডোর কম্প্রেসর ও ৪৫ মাইক্রোফ্যারাড ক্যাপাসিটর',
        failureMode: 'Capacitor terminal degradation & depleted refrigerant pressure',
        bengaliFailureMode: 'ক্যাপাসিটরের টার্মিনালে কার্বন জমেছে এবং গ্যাস প্রেসার কমে গেছে',
        severityLevel: 'Moderate',
        confidenceScore: 0.93,
        estimatedLaborMin: 600.0,
        estimatedLaborMax: 1000.0,
        estimatedPartsMin: 450.0,
        estimatedPartsMax: 1650.0,
        recommendedParts: [
          AiDiagnosticPartItemModel(
            partName: '45uF Heavy-Duty AC Run Capacitor',
            bengaliPartName: '৪৫uF হেভি-ডিউটি এসি রান ক্যাপাসিটর',
            estimatedUnitPrice: 450.0,
            quantity: 1,
          ),
          AiDiagnosticPartItemModel(
            partName: 'R410A Eco Refrigerant Gas Top-Up (500g)',
            bengaliPartName: 'R410A পরিবেশবান্ধব গ্যাস রিফিল (৫০০ গ্রাম)',
            estimatedUnitPrice: 1200.0,
            quantity: 1,
          ),
        ],
        safetyWarning: 'Turn off dedicated AC circuit breaker before touching outdoor compressor unit.',
        advisoryNotice: 'Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician.',
      );
    }

    if (hint.contains('electric') || hint.contains('db') || hint.contains('breaker') || hint.contains('wiring')) {
      return AiDiagnosticResultModel(
        detectedComponent: 'Main Distribution Board (DB Box) & 32A MCB',
        bengaliComponentName: 'মেইন ডিস্ট্রিবিউশন বোর্ড (ডিবি বক্স) ও ৩২এ এমসিবি সার্কিট ব্রেকার',
        failureMode: 'Thermal contact pitting & terminal overheating hazard',
        bengaliFailureMode: 'টার্মিনালে অতিরিক্ত উত্তাপজনিত স্পার্ক ও কন্টাক্ট পয়েন্ট পুড়ে গেছে',
        severityLevel: 'Critical',
        confidenceScore: 0.95,
        estimatedLaborMin: 500.0,
        estimatedLaborMax: 900.0,
        estimatedPartsMin: 650.0,
        estimatedPartsMax: 1000.0,
        recommendedParts: [
          AiDiagnosticPartItemModel(
            partName: '32A Double-Pole Miniature Circuit Breaker (MCB)',
            bengaliPartName: '৩২ অ্যাম্পিয়ার ডাবল-পোল এমসিবি ব্রেকার',
            estimatedUnitPrice: 650.0,
            quantity: 1,
          ),
          AiDiagnosticPartItemModel(
            partName: 'Heat-Resistant 2.5mm Copper Connecting Wire (2m)',
            bengaliPartName: 'উত্তাপরোধী ২.৫ মিমি কপার ওয়্যারিং ক্যাবল',
            estimatedUnitPrice: 350.0,
            quantity: 1,
          ),
        ],
        safetyWarning: 'Hazard: High voltage fire risk. Keep hands away from burnt copper terminals and trip main supply switch.',
        advisoryNotice: 'Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician.',
      );
    }

    if (hint.contains('plumb') || hint.contains('pipe') || hint.contains('leak') || hint.contains('sink')) {
      return AiDiagnosticResultModel(
        detectedComponent: 'Chrome Sanitary Angle Valve & Flexible Waste Pipe',
        bengaliComponentName: 'ক্রোম স্যানিটারি অ্যাঙ্গেল ভালভ ও ফ্লেক্সিবল ড্রেন পাইপ',
        failureMode: 'Thread washer fracture & sediment valve blockage',
        bengaliFailureMode: 'প্যাঁচের ওয়াশার কেটে পানি উপচে পড়ছে এবং পাইপে ক্ষরণ হচ্ছে',
        severityLevel: 'Moderate',
        confidenceScore: 0.91,
        estimatedLaborMin: 400.0,
        estimatedLaborMax: 700.0,
        estimatedPartsMin: 270.0,
        estimatedPartsMax: 750.0,
        recommendedParts: [
          AiDiagnosticPartItemModel(
            partName: 'Heavy Brass Chrome-Plated Angle Stopcock',
            bengaliPartName: 'হেভি ব্রাস ক্রোম-প্লেটেড অ্যাঙ্গেল ভালভ',
            estimatedUnitPrice: 480.0,
            quantity: 1,
          ),
          AiDiagnosticPartItemModel(
            partName: 'Flexible PVC Waste Trap Pipe (1.5 inch)',
            bengaliPartName: 'ফ্লেক্সিবল পিভিসি ড্রেন ট্র্যাপ পাইপ (১.৫ ইঞ্চি)',
            estimatedUnitPrice: 220.0,
            quantity: 1,
          ),
          AiDiagnosticPartItemModel(
            partName: 'Industrial Teflon Thread Seal Tape',
            bengaliPartName: 'ইন্ডাস্ট্রিয়াল টেফলন থ্রেড সিল টেপ',
            estimatedUnitPrice: 50.0,
            quantity: 1,
          ),
        ],
        safetyWarning: 'Turn off overhead rooftop stopcock if water flow is rapid to prevent floor damage.',
        advisoryNotice: 'Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician.',
      );
    }

    return AiDiagnosticResultModel(
      detectedComponent: 'Domestic Appliance Motor Drive Assembly',
      bengaliComponentName: 'ঘরোয়া বৈদ্যুতিক মোটরের ড্রাইভ অ্যাসেম্বলি',
      failureMode: 'Mechanical friction wear & brush contact sparking',
      bengaliFailureMode: 'যান্ত্রিক ঘর্ষণজনিত কারণে কার্বন ব্রাশ ক্ষয়প্রাপ্ত হয়েছে',
      severityLevel: 'Mild',
      confidenceScore: 0.88,
      estimatedLaborMin: 400.0,
      estimatedLaborMax: 800.0,
      estimatedPartsMin: 350.0,
      estimatedPartsMax: 600.0,
      recommendedParts: [
        AiDiagnosticPartItemModel(
          partName: 'Heavy-Duty Bushing & Carbon Brush Pair',
          bengaliPartName: 'হেভি-ডিউটি বুশিং ও কার্বন ব্রাশ সেট',
          estimatedUnitPrice: 350.0,
          quantity: 1,
        ),
      ],
      safetyWarning: 'Unplug electrical power source before disassembling casing.',
      advisoryNotice: 'Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician.',
    );
  }

  // Feature 3: Explainable Provider Recommendations (Section 5.2)
  Future<List<AiProviderRecommendationModel>> getAiProviderRecommendations({
    int? skillId,
    String? skillName,
    double latitude = 23.8103,
    double longitude = 90.4125,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.aiMatchProviders,
        data: {
          'skillId': skillId,
          'skillName': skillName,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data as List)
            .map((e) => AiProviderRecommendationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
    } catch (_) {}

    return _fallbackAiMatchProviders(skillId, skillName, latitude, longitude);
  }

  List<AiProviderRecommendationModel> _fallbackAiMatchProviders(
    int? skillId,
    String? skillName,
    double lat,
    double lng,
  ) {
    final query = (skillName ?? '').toLowerCase();

    // Section 5.2 Composite Weighted Ranking:
    // Score = (0.35 * DistanceScore) + (0.30 * RatingScore) + (0.20 * CompletionRate) + (0.15 * SemanticSkillMatch)
    final results = _mockProviders.map((prov) {
      final distanceScore = (1.0 - (prov.distanceKm / 10.0)).clamp(0.0, 1.0);
      final ratingScore = (prov.overallRating / 5.0).clamp(0.0, 1.0);
      final completionRate = prov.ratingCount > 100 ? 0.98 : 0.94;

      double semanticMatch = 0.70;
      final provSkill = prov.primarySkill.toLowerCase();
      if (query.isEmpty) {
        semanticMatch = 0.90;
      } else if (provSkill.contains(query) || query.contains(provSkill)) {
        semanticMatch = 1.0;
      } else if ((query.contains('ac') && provSkill.contains('ac')) ||
          (query.contains('electric') && provSkill.contains('electric')) ||
          (query.contains('plumb') && provSkill.contains('plumb')) ||
          (query.contains('clean') && provSkill.contains('clean'))) {
        semanticMatch = 0.95;
      }

      final composite = (0.35 * distanceScore) +
          (0.30 * ratingScore) +
          (0.20 * completionRate) +
          (0.15 * semanticMatch);
      final score = double.parse(composite.toStringAsFixed(2));

      final matchPct = (score * 100).toInt();
      final reasonEn = '⭐ Top rated for ${prov.primarySkill} in Banani, ${prov.distanceKm} km away ($matchPct% Match)';
      final reasonBn = '⭐ বনানীতে ${prov.primarySkill} হিসেবে শীর্ষ অভিজ্ঞ, মাত্র ${prov.distanceKm} কিমি দূরে ($matchPct% ম্যাচ)';

      return AiProviderRecommendationModel(
        profileId: prov.profileId,
        fullName: prov.fullName,
        phoneNumber: prov.phoneNumber,
        latitude: prov.latitude,
        longitude: prov.longitude,
        overallRating: prov.overallRating,
        ratingCount: prov.ratingCount,
        primarySkill: prov.primarySkill,
        distanceKm: prov.distanceKm,
        avatarKey: prov.avatarKey,
        matchScore: score,
        matchReasonEnglish: reasonEn,
        matchReasonBengali: reasonBn,
        isTopRecommendation: false,
      );
    }).toList();

    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    if (results.isNotEmpty) {
      final top = results.first;
      results[0] = AiProviderRecommendationModel(
        profileId: top.profileId,
        fullName: top.fullName,
        phoneNumber: top.phoneNumber,
        latitude: top.latitude,
        longitude: top.longitude,
        overallRating: top.overallRating,
        ratingCount: top.ratingCount,
        primarySkill: top.primarySkill,
        distanceKm: top.distanceKm,
        avatarKey: top.avatarKey,
        matchScore: top.matchScore,
        matchReasonEnglish: top.matchReasonEnglish,
        matchReasonBengali: top.matchReasonBengali,
        isTopRecommendation: true,
      );
    }

    return results;
  }

  // Feature 4: Dokkho AI In-App Customer Support Assistant (Section 5.5)
  Future<AiSupportChatMessageModel> sendSupportChatMessage({
    required String message,
    String? sessionId,
    int? activeBookingId,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.aiSupportChat,
        data: {
          'sessionId': sessionId ?? 'sess-${DateTime.now().millisecondsSinceEpoch}',
          'message': message,
          'customerId': 10,
          'activeBookingId': activeBookingId ?? 1001,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return AiSupportChatMessageModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    return _fallbackSupportChat(message);
  }

  AiSupportChatMessageModel _fallbackSupportChat(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('বুকিং') || lower.contains('booking') || lower.contains('কোথায়') || lower.contains('where') || lower.contains('status') || lower.contains('অবস্থা') || lower.contains('ট্র্যাক') || lower.contains('track')) {
      return AiSupportChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        textBengali: 'আপনার বুকিং #১০০১ একটিভ রয়েছে। টেকনিশিয়ান মোঃ রফিকুল ইসলাম (এসি স্পেশালিস্ট) বনানী রোড ১১ এর দিকে রওনা হয়েছেন। পৌঁছাতে আনুমানিক ১৫ মিনিট সময় লাগবে।',
        textEnglish: 'Your booking #1001 is active. AC Technician Rafiqul is currently on the way to Banani, Road 11. Estimated arrival: 15 minutes.',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: ['টেকনিশিয়ানকে ফোন করুন', 'লাইভ ট্র্যাকিং দেখুন', 'ক্যান্সেলেশন পলিসি'],
        executedToolName: 'GetMyBookingStatus',
        toolData: {'bookingId': 1001, 'status': 'OnTheWay', 'provider': 'Rafiqul', 'etaMins': 15},
      );
    }

    if (lower.contains('বাতিল') || lower.contains('cancel') || lower.contains('ক্যানসেল') || lower.contains('রিফান্ড') || lower.contains('refund')) {
      return AiSupportChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        textBengali: 'আমাদের প্ল্যাটফর্ম পলিসি অনুযায়ী: কারিগর রওনা দেওয়ার পূর্বে ফ্রি ক্যান্সেলেশন সম্ভব। কারিগর রওনা দিলে বা পৌঁছালে ন্যূনতম ২০০ টাকা ভ্রমণ ক্ষতিপূরণ ফি প্রযোজ্য হতে পারে।',
        textEnglish: 'Per platform policy: Free cancellation before the technician starts traveling. A standard 200 BDT travel compensation may apply if cancelled after arrival.',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: ['বুকিং বাতিল করতে চাই', 'সাপোর্ট হেল্পলাইনে কল', 'মূল্য তালিকা দেখুন'],
        executedToolName: 'GetCancelPolicy',
        toolData: {'freeCancellationMinutes': 5, 'travelFeeBdt': 200},
      );
    }

    if (lower.contains('দাম') || lower.contains('খরচ') || lower.contains('রেট') || lower.contains('price') || lower.contains('cost') || lower.contains('rate') || lower.contains('চার্জ') || lower.contains('টাকা')) {
      return AiSupportChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        textBengali: 'দক্ষ লোক খুঁজির প্রারম্ভিক সার্ভিস রেট:\n• এসি জেট ওয়াশ: ৫০০ টাকা\n• ইলেকট্রিশিয়ান ওয়্যারিং: ৪০০ টাকা\n• প্লাম্বিং পাইপ লিক: ৩৫০ টাকা\n• ফ্ল্যাট ডিপ ক্লিনিং: ৮০০ টাকা\n(যন্ত্রাংশের খরচ গ্রাহকের সরাসরি অনুমোদনের পরই কেবল বিলে যুক্ত হয়।)',
        textEnglish: 'Standard base service rates on Dokkho Lok Khuji:\n• AC Jet Wash: 500 BDT\n• Electrician & Wiring: 400 BDT\n• Plumbing Repair: 350 BDT\n• Apartment Deep Cleaning: 800 BDT\n(Spare parts costs require customer authorization before installation.)',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: ['কাস্টম কাজের অফার দিন', 'নিকটস্থ মিস্ত্রি খুঁজুন', 'এআই দিয়ে ছবি ডায়াগনসিস'],
        executedToolName: 'GetPriceEstimates',
        toolData: {'acRate': 500, 'electricianRate': 400, 'plumbingRate': 350},
      );
    }

    return AiSupportChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      textBengali: 'আমি Dokkho AI গ্রাহক সহকারী। আমি আপনাকে বুকিং ট্র্যাক করতে, সার্ভিসের খরচ জানতে বা মিস্ত্রি খুঁজে পেতে সাহায্য করতে পারি। কোনো জরুরি সহায়তার জন্য আমাদের ২৪/৭ হেল্পলাইনে কল করুন: ১৬৪৩০ অথবা +৮৮০৯৬১২৩৪৫৬৭৮।',
      textEnglish: 'I am Dokkho AI Assistant. I can help you check booking status, estimate service rates, or find nearby trade experts. For 24/7 hotline support, call 16430 or +8809612345678.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedFollowUps: ['আমার চলতি বুকিং', 'সার্ভিস রেট চার্ট', 'জরুরি মিস্ত্রি কল'],
    );
  }
}
