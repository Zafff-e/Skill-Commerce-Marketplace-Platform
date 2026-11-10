import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';

class LiveTrackingScreen extends StatefulWidget {
  final BookingModel initialBooking;
  final VoidCallback onBackToHome;

  const LiveTrackingScreen({
    super.key,
    required this.initialBooking,
    required this.onBackToHome,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late BookingModel _booking;
  final MapController _mapController = MapController();
  late LatLng _customerLocation;
  late LatLng _providerLocation;

  StreamSubscription<LocationUpdateEvent>? _locationSub;
  StreamSubscription<BookingStatusEvent>? _statusSub;
  StreamSubscription<Map<String, dynamic>>? _partSub;

  final int _estimatedMinutesAway = 8;

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking;
    _customerLocation = LatLng(_booking.latitude, _booking.longitude);
    // Initial simulated technician position ~1km away
    _providerLocation = LatLng(
      _booking.latitude + 0.007,
      _booking.longitude + 0.005,
    );

    _listenToSignalR();
  }

  void _listenToSignalR() {
    final signalR = context.read<SignalRService>();

    _locationSub = signalR.onLocationUpdate.listen((event) {
      if (event.bookingId == _booking.bookingId && mounted) {
        setState(() {
          _providerLocation = LatLng(event.latitude, event.longitude);
        });
      }
    });

    _statusSub = signalR.onBookingStatusChanged.listen((event) {
      if (event.bookingId == _booking.bookingId && mounted) {
        setState(() {
          _booking = BookingModel(
            bookingId: _booking.bookingId,
            billableEntityId: _booking.billableEntityId,
            jobId: _booking.jobId,
            customerId: _booking.customerId,
            customerName: _booking.customerName,
            customerPhone: _booking.customerPhone,
            profileId: _booking.profileId,
            providerName: _booking.providerName,
            providerPhone: _booking.providerPhone,
            skillId: _booking.skillId,
            skillName: _booking.skillName,
            serviceAddress: _booking.serviceAddress,
            latitude: _booking.latitude,
            longitude: _booking.longitude,
            status: event.status,
            laborAmount: _booking.laborAmount,
            urgencyFee: _booking.urgencyFee,
            commissionRate: _booking.commissionRate,
            platformFee: _booking.platformFee,
            materialsAmount: _booking.materialsAmount,
            totalAmount: _booking.totalAmount,
            parts: _booking.parts,
            scheduledAtUtc: _booking.scheduledAtUtc,
            completedAtUtc: event.status == 'Completed'
                ? DateTime.now()
                : _booking.completedAtUtc,
          );
        });
      }
    });

    _partSub = signalR.onPartUpdate.listen((event) {
      _refreshBooking();
    });
  }

  Future<void> _refreshBooking() async {
    final repo = context.read<SkillCommerceRepository>();
    final bookings = await repo.getMyBookings(asRole: 'customer');
    final match = bookings.where((b) => b.bookingId == _booking.bookingId);
    if (match.isNotEmpty && mounted) {
      setState(() => _booking = match.first);
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _statusSub?.cancel();
    _partSub?.cancel();
    super.dispose();
  }

  int _getStatusStepIndex(String status) {
    switch (status) {
      case 'Accepted':
        return 0;
      case 'OnTheWay':
        return 1;
      case 'Arrived':
        return 2;
      case 'InProgress':
        return 3;
      case 'Completed':
        return 4;
      default:
        return 0;
    }
  }

  String _getStatusText(BuildContext context, String status) {
    final strings = AppStrings.of(context);
    switch (status) {
      case 'Accepted':
        return strings.statusAccepted;
      case 'OnTheWay':
        return strings.statusOnTheWay;
      case 'Arrived':
        return strings.statusArrived;
      case 'InProgress':
        return strings.statusInProgress;
      case 'Completed':
        return strings.statusCompleted;
      case 'Cancelled':
        return strings.statusCancelled;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;
    final stepIndex = _getStatusStepIndex(_booking.status);

    return Scaffold(
      body: Stack(
        children: [
          // FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _customerLocation,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skillcommerce.mobile_app',
              ),

              // Polyline connecting customer & technician
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_providerLocation, _customerLocation],
                    strokeWidth: 4.0,
                    color: AppColors.forestGreen,
                    isDotted: true,
                  ),
                ],
              ),

              MarkerLayer(
                markers: [
                  // Customer Marker
                  Marker(
                    point: _customerLocation,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_filled,
                        color: AppColors.urgentRed,
                        size: 24,
                      ),
                    ),
                  ),

                  // Technician Vehicle Marker (Motorcycle Icon)
                  Marker(
                    point: _providerLocation,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🏍️', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top Header Floating Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.slateNavy,
                    ),
                    onPressed: widget.onBackToHome,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(context, _booking.status),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        Text(
                          _booking.status == 'OnTheWay'
                              ? (isBn
                                    ? 'আনুমানিক $_estimatedMinutesAway মিনিটে পৌঁছাবেন'
                                    : 'Est. $_estimatedMinutesAway mins away')
                              : _booking.serviceAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slateMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${_booking.bookingId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet: Status Stepper, Technician Info & Consumed Parts
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Stepper Dots
                  Row(
                    children: [
                      _StepDot(
                        label: isBn ? 'গৃহীত' : 'Accepted',
                        isActive: stepIndex >= 0,
                      ),
                      _StepLine(isActive: stepIndex >= 1),
                      _StepDot(
                        label: isBn ? 'রওনা' : 'En Route',
                        isActive: stepIndex >= 1,
                      ),
                      _StepLine(isActive: stepIndex >= 2),
                      _StepDot(
                        label: isBn ? 'উপস্থিত' : 'Arrived',
                        isActive: stepIndex >= 2,
                      ),
                      _StepLine(isActive: stepIndex >= 3),
                      _StepDot(
                        label: isBn ? 'কাজ চলছে' : 'Working',
                        isActive: stepIndex >= 3,
                      ),
                      _StepLine(isActive: stepIndex >= 4),
                      _StepDot(
                        label: isBn ? 'সম্পন্ন' : 'Done',
                        isActive: stepIndex >= 4,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Technician Profile Card
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              AssetPaths.getPath('ac_technician'),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _booking.providerName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slateNavy,
                              ),
                            ),
                            Text(
                              '🏍️ হোন্ডা সাইন ১২৫ • ${_booking.skillName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.slateMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: AppColors.forestGreen.withValues(
                          alpha: 0.12,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.call,
                            color: AppColors.forestGreen,
                            size: 20,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Calling ${_booking.providerPhone}...',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Ad-Hoc Parts List (if any parts were added)
                  if (_booking.parts.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softOffWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                strings.materialsCharge,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.slateNavy,
                                ),
                              ),
                              Text(
                                '৳ ${strings.formatNumber(_booking.materialsAmount.toInt())}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ..._booking.parts.map(
                            (p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '• ${p.itemDescription} (${p.quantity}x)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.slateMuted,
                                    ),
                                  ),
                                  Text(
                                    '৳ ${strings.formatNumber(p.lineTotal.toInt())}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Total Bill Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.totalPayable,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.slateMuted,
                            ),
                          ),
                          Text(
                            '৳ ${strings.formatNumber(_booking.totalAmount.toInt())}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ],
                      ),
                      if (_booking.status == 'Completed')
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isBn
                                      ? 'পেমেন্ট সম্পন্ন হয়েছে! রসিদ ইমেইল করা হয়েছে।'
                                      : 'Payment verified! Receipt emailed.',
                                ),
                              ),
                            );
                            widget.onBackToHome();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestGreen,
                            minimumSize: const Size(140, 44),
                          ),
                          child: Text(isBn ? 'রসিদ দেখুন' : 'View Receipt'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StepDot({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isActive ? AppColors.forestGreen : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.forestGreen : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? AppColors.forestGreen : Colors.grey.shade200,
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
}
