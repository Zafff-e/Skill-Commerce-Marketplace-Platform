import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class IncomingRequestModal extends StatefulWidget {
  final String customerName;
  final String serviceName;
  final String address;
  final double distanceKm;
  final double estimatedEarnings;
  final bool isUrgent;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingRequestModal({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.address,
    required this.distanceKm,
    required this.estimatedEarnings,
    this.isUrgent = false,
    required this.onAccept,
    required this.onReject,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String customerName,
    required String serviceName,
    required String address,
    required double distanceKm,
    required double estimatedEarnings,
    bool isUrgent = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => IncomingRequestModal(
        customerName: customerName,
        serviceName: serviceName,
        address: address,
        distanceKm: distanceKm,
        estimatedEarnings: estimatedEarnings,
        isUrgent: isUrgent,
        onAccept: () => Navigator.pop(ctx, true),
        onReject: () => Navigator.pop(ctx, false),
      ),
    );
  }

  @override
  State<IncomingRequestModal> createState() => _IncomingRequestModalState();
}

class _IncomingRequestModalState extends State<IncomingRequestModal> {
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        widget.onReject();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radar Animation & Countdown Ring
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: _secondsLeft / 30.0,
                    strokeWidth: 5,
                    color: AppColors.forestGreen,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                Text(
                  '${strings.formatNumber(_secondsLeft)}s',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Header Banner
            if (widget.isUrgent)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.urgentRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBn
                      ? '⚡ জরুরি কাজের অনুরোধ (+৩০০ টাকা)'
                      : '⚡ URGENT REQUEST (+300 BDT)',
                  style: const TextStyle(
                    color: AppColors.urgentRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            Text(
              isBn ? 'নতুন কাজের অনুরোধ!' : 'New Job Request!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.slateNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.serviceName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.slateMuted),
            ),

            const SizedBox(height: 16),

            // Details Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softOffWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: AppColors.forestGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.urgentRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.address} (${widget.distanceKm} km away)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slateNavy,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn
                            ? 'আপনার আয় (Estimated Earnings)'
                            : 'Your Earnings',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slateMuted,
                        ),
                      ),
                      Text(
                        '৳ ${strings.formatNumber(widget.estimatedEarnings.toInt())}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Accept & Reject Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slateMuted,
                      side: BorderSide(color: Colors.grey.shade300),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(strings.rejectJob),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(strings.acceptJob),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
