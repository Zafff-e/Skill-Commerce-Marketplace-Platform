import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/constants/asset_paths.dart';
import 'package:mobile_app/shared/models/polyglot_models.dart';

void main() {
  group('Polyglot & Backend Contract Tests', () {
    test('BookingModel & PartForRepair JSON serialization and isolated commission math', () {
      final json = {
        'bookingId': 1001,
        'billableEntityId': '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
        'jobId': 501,
        'customerId': 10,
        'customerName': 'জাফির হাসান',
        'customerPhone': '+8801700001122',
        'profileId': 1,
        'providerName': 'মোঃ রফিকুল ইসলাম',
        'providerPhone': '+8801711223344',
        'skillId': 101,
        'skillName': 'AC Servicing & Jet Wash',
        'serviceAddress': 'Banani, Dhaka',
        'latitude': 23.8103,
        'longitude': 90.4125,
        'status': 'Accepted',
        'laborAmount': 1000.0,
        'urgencyFee': 300.0,
        'commissionRate': 0.10,
        'platformFee': 130.0,
        'materialsAmount': 450.0,
        'totalAmount': 1750.0,
        'parts': [
          {
            'partItemId': 1,
            'bookingId': 1001,
            'itemDescription': '45uF Capacitor',
            'quantity': 1,
            'unitPrice': 450.0,
            'lineTotal': 450.0,
            'approvalStatus': 'Approved',
          }
        ],
        'scheduledAtUtc': '2026-11-02T12:00:00.000Z',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.bookingId, 1001);
      expect(booking.laborAmount, 1000.0);
      expect(booking.urgencyFee, 300.0);
      expect(booking.parts.length, 1);
      expect(booking.parts.first.lineTotal, 450.0);

      // Verify strict commission math formula:
      // Commission applies only to Labor + Urgency, NEVER to Materials
      final commissionable = booking.laborAmount + booking.urgencyFee; // 1300.0
      final expectedPlatformFee = commissionable * booking.commissionRate; // 130.0
      final expectedTotal = commissionable + booking.materialsAmount; // 1750.0
      final expectedProviderPayout = (commissionable - expectedPlatformFee) + booking.materialsAmount; // 1620.0

      expect(booking.platformFee, expectedPlatformFee);
      expect(booking.totalAmount, expectedTotal);
      expect(expectedProviderPayout, 1620.0);

      // Verify toJson() roundtrip
      final serialized = booking.toJson();
      expect(serialized['bookingId'], 1001);
      expect(serialized['parts'], isNotEmpty);
    });

    test('ProviderGeoModel maps Elasticsearch geo_point distance and avatar keys', () {
      final json = {
        'profileId': 2,
        'fullName': 'তানভীর আহমেদ',
        'phoneNumber': '+8801819876543',
        'latitude': 23.8155,
        'longitude': 90.4180,
        'maxRadiusKm': 10.0,
        'overallRating': 4.8,
        'ratingCount': 98,
        'isActive': true,
        'primarySkill': 'Electrician & DB Wiring',
        'distanceKm': 1.4,
        'avatarKey': 'electrician',
      };

      final provider = ProviderGeoModel.fromJson(json);

      expect(provider.profileId, 2);
      expect(provider.primarySkill, 'Electrician & DB Wiring');
      expect(provider.distanceKm, 1.4);
      expect(provider.avatarKey, 'electrician');

      final avatarPath = AssetPaths.getPath(provider.avatarKey);
      expect(avatarPath, contains('electrician.jpg'));
    });

    test('AssetPaths has 35 curated avatars and handles fallback gracefully', () {
      expect(AssetPaths.allAvatars.length, 35);

      final acAvatar = AssetPaths.findByKey('ac_technician');
      expect(acAvatar.englishName, 'AC Technician');
      expect(acAvatar.bengaliName, 'এসি মেকানিক');

      final fallback = AssetPaths.findByKey('non_existent_key');
      expect(fallback.key, 'general_technician');
    });

    test('CustomJobModel and JobProposalModel roundtrip JSON serialization', () {
      final json = {
        'jobId': 501,
        'customerId': 10,
        'customerName': 'জাফির হাসান',
        'categoryName': 'Home Maintenance',
        'title': '৩ রুমের ওয়্যারিং মেরামত',
        'description': 'ডিবি বোর্ডে স্পার্ক হচ্ছে',
        'budget': 3500.0,
        'location': 'বনানী, ঢাকা',
        'isUrgent': true,
        'hasVoiceNote': true,
        'voiceDurationSeconds': 14,
        'photoName': 'db_box.jpg',
        'status': 'Open',
        'proposals': [
          {
            'proposalId': 1,
            'jobId': 501,
            'providerId': 2,
            'providerName': 'তানভীর রহমান',
            'providerAvatarKey': 'electrician',
            'rating': 4.85,
            'reviewsCount': 89,
            'proposedAmount': 3200.0,
            'estimatedArrivalMins': 20,
            'proposalNote': '৩ মাসের ফ্রি সার্ভিস ওয়ারেন্টি',
            'phone': '+8801722334455',
            'status': 'Pending',
            'createdAtUtc': '2026-11-05T01:00:00.000Z',
          }
        ],
        'createdAtUtc': '2026-11-05T00:30:00.000Z',
      };

      final job = CustomJobModel.fromJson(json);
      expect(job.jobId, 501);
      expect(job.title, '৩ রুমের ওয়্যারিং মেরামত');
      expect(job.budget, 3500.0);
      expect(job.isUrgent, isTrue);
      expect(job.hasVoiceNote, isTrue);
      expect(job.voiceDurationSeconds, 14);
      expect(job.photoName, 'db_box.jpg');
      expect(job.proposals.length, 1);
      expect(job.proposals.first.proposedAmount, 3200.0);

      final serialized = job.toJson();
      expect(serialized['jobId'], 501);
      expect(serialized['proposals'], isNotEmpty);
    });

    test('AiIntakeResultModel JSON roundtrip and validation', () {
      final json = {
        'detectedLanguage': 'bn',
        'categorySlug': 'home-maintenance',
        'categoryName': 'হোম মেইনটেন্যান্স',
        'skillSlug': 'ac-servicing',
        'skillName': 'এসি সার্ভিসিং ও মেরামত',
        'title': 'এসি সার্ভিসিং ও মেরামত সার্ভিস প্রয়োজন',
        'problemDescription': 'এসি ঠান্ডা বাতাস দিচ্ছে না এবং গ্যাস লিক হচ্ছে',
        'urgency': 'Urgent',
        'isUrgent': true,
        'suggestedBudget': 1200.0,
        'locationArea': 'বনানী, ঢাকা',
        'confidenceScore': 0.94,
        'aiSummary': '✨ এআই ভয়েস অ্যানালাইসিস: এসি সার্ভিসিং ও মেরামত (বনানী, ঢাকা)',
      };

      final result = AiIntakeResultModel.fromJson(json);
      expect(result.detectedLanguage, 'bn');
      expect(result.skillSlug, 'ac-servicing');
      expect(result.isUrgent, isTrue);
      expect(result.suggestedBudget, 1200.0);
      expect(result.confidenceScore, 0.94);

      final serialized = result.toJson();
      expect(serialized['skillSlug'], 'ac-servicing');
      expect(serialized['isUrgent'], isTrue);
    });

    test('AiDiagnosticResultModel & AiDiagnosticPartItemModel JSON roundtrip and validation', () {
      final json = {
        'detectedComponent': 'Main Distribution Board (DB Box) & 32A MCB',
        'bengaliComponentName': 'মেইন ডিস্ট্রিবিউশন বোর্ড (ডিবি বক্স) ও ৩২এ এমসিবি সার্কিট ব্রেকার',
        'failureMode': 'Thermal contact pitting & terminal overheating hazard',
        'bengaliFailureMode': 'টার্মিনালে অতিরিক্ত উত্তাপজনিত স্পার্ক ও কন্টাক্ট পয়েন্ট পুড়ে গেছে',
        'severityLevel': 'Critical',
        'confidenceScore': 0.95,
        'estimatedLaborMin': 500.0,
        'estimatedLaborMax': 900.0,
        'estimatedPartsMin': 650.0,
        'estimatedPartsMax': 1000.0,
        'recommendedParts': [
          {
            'partName': '32A Double-Pole Miniature Circuit Breaker (MCB)',
            'bengaliPartName': '৩২ অ্যাম্পিয়ার ডাবল-পোল এমসিবি ব্রেকার',
            'estimatedUnitPrice': 650.0,
            'quantity': 1,
          },
          {
            'partName': 'Heat-Resistant 2.5mm Copper Connecting Wire (2m)',
            'bengaliPartName': 'উত্তাপরোধী ২.৫ মিমি কপার ওয়্যারিং ক্যাবল',
            'estimatedUnitPrice': 350.0,
            'quantity': 1,
          }
        ],
        'safetyWarning': 'Hazard: High voltage fire risk. Keep hands away from burnt copper terminals and trip main supply switch.',
        'advisoryNotice': 'Advisory AI estimation for customer budgeting. Final labor and parts cost will be verified on-site by certified technician.',
      };

      final diag = AiDiagnosticResultModel.fromJson(json);
      expect(diag.severityLevel, 'Critical');
      expect(diag.confidenceScore, 0.95);
      expect(diag.estimatedLaborMin, 500.0);
      expect(diag.recommendedParts.length, 2);
      expect(diag.recommendedParts.first.estimatedUnitPrice, 650.0);

      final serialized = diag.toJson();
      expect(serialized['severityLevel'], 'Critical');
      expect(serialized['recommendedParts'], isNotEmpty);
    });

    test('AiProviderRecommendationModel JSON roundtrip and ProviderGeo mapping', () {
      final json = {
        'profileId': 1,
        'fullName': 'মোঃ রফিকুল ইসলাম (Rafiqul)',
        'phoneNumber': '+8801711223344',
        'latitude': 23.8120,
        'longitude': 90.4140,
        'overallRating': 4.9,
        'ratingCount': 142,
        'primarySkill': 'AC Servicing & Jet Wash',
        'distanceKm': 0.8,
        'avatarKey': 'ac_technician',
        'matchScore': 0.96,
        'matchReasonEnglish': '⭐ Top rated for AC Servicing in Banani, 0.8 km away (96% Match)',
        'matchReasonBengali': '⭐ বনানীতে AC Servicing হিসেবে শীর্ষ অভিজ্ঞ, মাত্র 0.8 কিমি দূরে (৯৬% ম্যাচ)',
        'isTopRecommendation': true,
      };

      final rec = AiProviderRecommendationModel.fromJson(json);
      expect(rec.profileId, 1);
      expect(rec.matchScore, 0.96);
      expect(rec.isTopRecommendation, isTrue);

      final geo = rec.toProviderGeo();
      expect(geo.profileId, 1);
      expect(geo.avatarKey, 'ac_technician');

      final serialized = rec.toJson();
      expect(serialized['matchScore'], 0.96);
      expect(serialized['isTopRecommendation'], isTrue);
    });

    test('AiSupportChatMessageModel JSON roundtrip with tool metadata', () {
      final json = {
        'sessionId': 'sess-1001',
        'replyTextBengali': 'আপনার বুকিং #১০০১ একটিভ রয়েছে।',
        'replyTextEnglish': 'Your booking #1001 is active.',
        'isUser': false,
        'timestampUtc': '2026-11-05T03:00:00.000Z',
        'suggestedFollowUps': ['টেকনিশিয়ানকে ফোন করুন', 'লাইভ ট্র্যাকিং'],
        'executedToolName': 'GetMyBookingStatus',
        'toolData': {
          'bookingId': 1001,
          'status': 'OnTheWay',
          'provider': 'Rafiqul',
        },
      };

      final msg = AiSupportChatMessageModel.fromJson(json);
      expect(msg.id, 'sess-1001');
      expect(msg.isUser, isFalse);
      expect(msg.executedToolName, 'GetMyBookingStatus');
      expect(msg.suggestedFollowUps.length, 2);
      expect(msg.toolData?['status'], 'OnTheWay');

      final serialized = msg.toJson();
      expect(serialized['executedToolName'], 'GetMyBookingStatus');
      expect(serialized['suggestedFollowUps'], isNotEmpty);
    });
  });
}

