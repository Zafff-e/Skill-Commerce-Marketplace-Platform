import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Determine default base URL according to host platform
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:5242';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5242'; // Android Emulator alias to host machine
      }
    } catch (_) {}
    return 'http://localhost:5242';
  }

  static const String apiVersion = '/api/v1';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refresh = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String me = '$apiVersion/users/me';

  // Taxonomy & Catalog endpoints
  static const String categories = '$apiVersion/categories';
  static String categorySkills(int categoryId) => '$apiVersion/categories/$categoryId/skills';
  static const String products = '$apiVersion/products';

  // Providers endpoints (Elasticsearch / SQL Server)
  static const String providerOnboard = '$apiVersion/providers';
  static const String providerMe = '$apiVersion/providers/me';
  static const String providerAvailability = '$apiVersion/providers/me/availability';
  static const String providerSkills = '$apiVersion/providers/me/skills';
  static const String providerSearch = '$apiVersion/providers/search';
  static String providerProfile(int profileId) => '$apiVersion/providers/$profileId';

  // Jobs & Bidding endpoints
  static const String jobs = '$apiVersion/jobs';
  static const String myJobs = '$apiVersion/jobs/mine';
  static const String nearbyJobs = '$apiVersion/jobs/nearby';
  static String jobDetails(int jobId) => '$apiVersion/jobs/$jobId';
  static String cancelJob(int jobId) => '$apiVersion/jobs/$jobId/cancel';
  static String acceptDirectJob(int jobId) => '$apiVersion/jobs/$jobId/accept-direct';
  static String jobProposals(int jobId) => '$apiVersion/jobs/$jobId/proposals';
  static String acceptProposal(int proposalId) => '$apiVersion/proposals/$proposalId/accept';

  // Bookings endpoints (SQL Server / Booking State Machine)
  static const String myBookings = '$apiVersion/bookings/mine';
  static String bookingDetails(int bookingId) => '$apiVersion/bookings/$bookingId';
  static String bookingHistory(int bookingId) => '$apiVersion/bookings/$bookingId/history';
  static String startTravel(int bookingId) => '$apiVersion/bookings/$bookingId/start-travel';
  static String arrive(int bookingId) => '$apiVersion/bookings/$bookingId/arrive';
  static String startWork(int bookingId) => '$apiVersion/bookings/$bookingId/start-work';
  static String completeBooking(int bookingId) => '$apiVersion/bookings/$bookingId/complete';
  static String cancelBooking(int bookingId) => '$apiVersion/bookings/$bookingId/cancel';

  // Ad-Hoc Spare Parts endpoints
  static String bookingParts(int bookingId) => '$apiVersion/bookings/$bookingId/parts';
  static String approvePart(int bookingId, int partId) => '$apiVersion/bookings/$bookingId/parts/$partId/approve';
  static String rejectPart(int bookingId, int partId) => '$apiVersion/bookings/$bookingId/parts/$partId/reject';

  // Billing & Payments endpoints
  static String bookingInvoice(int bookingId) => '$apiVersion/bookings/$bookingId/invoice';
  static const String payments = '$apiVersion/payments';
  static String confirmCashPayment(int transactionId) => '$apiVersion/payments/$transactionId/confirm-cash';

  // Realtime SignalR Hub
  static const String signalRBookingHub = '/hubs/bookings';

  // AI & Gemini Endpoints
  static const String aiVoiceIntake = '$apiVersion/ai/voice-intake';
  static const String aiTextIntake = '$apiVersion/ai/text-intake';
  static const String aiDiagnoseImage = '$apiVersion/ai/diagnose-image';
  static const String aiMatchProviders = '$apiVersion/ai/match-providers';
  static const String aiSupportChat = '$apiVersion/ai/support-chat';
}

