import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/network/dio_client.dart';
import 'package:mobile_app/core/network/skill_commerce_repository.dart';

void main() {
  group('AI Intake Repository Heuristic & Fallback Tests', () {
    late SkillCommerceRepository repo;

    setUp(() {
      repo = SkillCommerceRepository(dioClient: DioClient());
    });

    test('Bilingual AC problem text intake detects AC skill, budget and urgency', () async {
      final bnResult = await repo.processVoiceIntake(
        transcribedText: 'আমার এসি থেকে পানি পড়ছে আর ঠান্ডা হচ্ছে না, জরুরি মিস্ত্রি পাঠান বনানী ১১ রোড।',
      );

      expect(bnResult.detectedLanguage, 'bn');
      expect(bnResult.skillSlug, 'ac-servicing');
      expect(bnResult.isUrgent, isTrue);
      expect(bnResult.suggestedBudget, 1200.0);
      expect(bnResult.locationArea, contains('বনানী'));
      expect(bnResult.confidenceScore, greaterThan(0.90));

      final enResult = await repo.processTextIntake(
        'Urgent AC cooling issue and gas leak in Gulshan.',
      );

      expect(enResult.skillSlug, 'ac-servicing');
      expect(enResult.isUrgent, isTrue);
      expect(enResult.locationArea, contains('Gulshan'));
    });

    test('Electrical short circuit detection extracts electrician skill and urgent flag', () async {
      final result = await repo.processTextIntake(
        'মেইন সুইচে শর্ট সার্কিট হয়েছে ধোঁয়া বের হচ্ছে, দ্রুত জরুরি ইলেকট্রিশিয়ান পাঠান।',
      );

      expect(bnText(result.skillName), contains('ইলেকট্রিশিয়ান'));
      expect(result.skillSlug, 'electrician-db-wiring');
      expect(result.isUrgent, isTrue);
      expect(result.suggestedBudget, 800.0);
    });

    test('Plumbing leak intake in Mirpur detects plumbing category and budget', () async {
      final result = await repo.processVoiceIntake(
        transcribedText: 'বাথরুমের কল ভেঙে পানি উপচে পড়ছে মিরপুর ১০ এ প্লাম্বার চাই।',
      );

      expect(result.skillSlug, 'plumbing-leak');
      expect(result.suggestedBudget, 600.0);
      expect(result.locationArea, contains('মিরপুর'));
    });

    test('Visual problem diagnostic recognizes Electrical DB hazard and parts', () async {
      final result = await repo.diagnoseProblemImage(
        imageName: 'burnt_db_box.jpg',
        tradeCategory: 'electrician',
      );

      expect(result.severityLevel, 'Critical');
      expect(result.detectedComponent, contains('DB Box'));
      expect(result.confidenceScore, greaterThanOrEqualTo(0.90));
      expect(result.recommendedParts, isNotEmpty);
      expect(result.estimatedLaborMin, 500.0);
      expect(result.safetyWarning, contains('High voltage fire risk'));
    });

    test('Visual problem diagnostic recognizes AC compressor capacitor failure', () async {
      final result = await repo.diagnoseProblemImage(
        imageName: 'ac_compressor_unit.jpg',
        tradeCategory: 'ac-servicing',
      );

      expect(result.severityLevel, 'Moderate');
      expect(result.detectedComponent, contains('AC Compressor'));
      expect(result.recommendedParts.any((p) => p.partName.contains('Capacitor')), isTrue);
    });

    test('Explainable AI provider matchmaker ranks providers and sets top recommendation', () async {
      final recs = await repo.getAiProviderRecommendations(
        skillName: 'AC Servicing & Jet Wash',
      );

      expect(recs, isNotEmpty);
      expect(recs.first.isTopRecommendation, isTrue);
      expect(recs.first.primarySkill, contains('AC'));
      expect(recs.first.matchScore, greaterThanOrEqualTo(0.90));
      expect(recs.first.matchReasonEnglish, contains('Top rated'));
      expect(recs.first.matchReasonBengali, contains('শীর্ষ অভিজ্ঞ'));

      // Verify descending order of match scores
      for (int i = 0; i < recs.length - 1; i++) {
        expect(recs[i].matchScore, greaterThanOrEqualTo(recs[i + 1].matchScore));
      }
    });

    test('Explainable AI provider matchmaker prioritizes electrician for electrical queries', () async {
      final recs = await repo.getAiProviderRecommendations(
        skillName: 'Electrician & DB Wiring',
      );

      expect(recs, isNotEmpty);
      expect(recs.first.primarySkill, contains('Electric'));
      expect(recs.first.isTopRecommendation, isTrue);
    });

    test('Dokkho AI customer support assistant handles booking status tool inquiry', () async {
      final reply = await repo.sendSupportChatMessage(
        message: 'আমার বুকিং এর অবস্থা কী? মিস্ত্রি কোথায়?',
      );

      expect(reply.isUser, isFalse);
      expect(reply.executedToolName, 'GetMyBookingStatus');
      expect(reply.textBengali, contains('১০০১'));
      expect(reply.textBengali, contains('রফিকুল'));
      expect(reply.suggestedFollowUps, isNotEmpty);
      expect(reply.toolData?['status'], 'OnTheWay');
    });

    test('Dokkho AI customer support assistant answers cancellation and price inquiries', () async {
      final cancelReply = await repo.sendSupportChatMessage(
        message: 'ক্যান্সেলেশন ও রিফান্ড পলিসি কী?',
      );

      expect(cancelReply.executedToolName, 'GetCancelPolicy');
      expect(cancelReply.textBengali, contains('ক্যান্সেলেশন'));

      final priceReply = await repo.sendSupportChatMessage(
        message: 'এসি সার্ভিসিং এর দাম ও রেট কত?',
      );

      expect(priceReply.executedToolName, 'GetPriceEstimates');
      expect(priceReply.textBengali, contains('সার্ভিস রেট'));
    });
  });
}

String bnText(String s) => s;

