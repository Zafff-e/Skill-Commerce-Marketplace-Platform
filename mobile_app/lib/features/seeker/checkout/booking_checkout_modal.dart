import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';
import '../../../shared/widgets/ai_problem_diagnostic_card.dart';

class BookingCheckoutModal extends StatefulWidget {
  final SkillModel? skill;
  final ProviderGeoModel? provider;
  final bool isUrgent;
  final Function(BookingModel booking) onBookingConfirmed;

  const BookingCheckoutModal({
    super.key,
    this.skill,
    this.provider,
    this.isUrgent = false,
    required this.onBookingConfirmed,
  });

  static Future<BookingModel?> show(
    BuildContext context, {
    SkillModel? skill,
    ProviderGeoModel? provider,
    bool isUrgent = false,
  }) {
    return showModalBottomSheet<BookingModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: BookingCheckoutModal(
            skill: skill,
            provider: provider,
            isUrgent: isUrgent,
            onBookingConfirmed: (b) => Navigator.pop(ctx, b),
          ),
        ),
      ),
    );
  }

  @override
  State<BookingCheckoutModal> createState() => _BookingCheckoutModalState();
}

class _BookingCheckoutModalState extends State<BookingCheckoutModal> {
  final TextEditingController _addressController = TextEditingController(text: 'বাড়ি ১২, রোড ৫, বনানী, ঢাকা');
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _mfsPhoneController = TextEditingController(text: '01711223344');

  String _selectedPaymentMethod = 'Cash'; // Cash, bKash, Nagad, Card
  bool _isSubmitting = false;

  // Voice Note states
  bool _isRecordingVoice = false;
  int _voiceSeconds = 0;
  bool _hasVoiceNote = false;
  bool _isPlayingVoice = false;
  Timer? _voiceTimer;

  // Photo Attachment states
  String? _attachedPhotoName;
  bool _isDiagnosingPhoto = false;
  AiDiagnosticResultModel? _activeDiagnostic;

  @override
  void dispose() {
    _voiceTimer?.cancel();
    _addressController.dispose();
    _notesController.dispose();
    _mfsPhoneController.dispose();
    super.dispose();
  }

  void _toggleVoiceRecording() {
    if (!_isRecordingVoice) {
      setState(() {
        _isRecordingVoice = true;
        _voiceSeconds = 0;
        _hasVoiceNote = false;
      });
      _voiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_voiceSeconds < 30) {
          setState(() => _voiceSeconds++);
        } else {
          _stopVoiceRecording();
        }
      });
    } else {
      _stopVoiceRecording();
    }
  }

  void _stopVoiceRecording() {
    _voiceTimer?.cancel();
    setState(() {
      _isRecordingVoice = false;
      _hasVoiceNote = _voiceSeconds > 0;
    });
  }

  void _playSimulatedVoice() {
    if (_isPlayingVoice) return;
    setState(() => _isPlayingVoice = true);
    Future.delayed(Duration(seconds: _voiceSeconds > 0 ? _voiceSeconds : 3), () {
      if (mounted) setState(() => _isPlayingVoice = false);
    });
  }

  void _deleteVoiceNote() {
    _voiceTimer?.cancel();
    setState(() {
      _isRecordingVoice = false;
      _hasVoiceNote = false;
      _voiceSeconds = 0;
      _isPlayingVoice = false;
    });
  }

  void _pickSamplePhoto() async {
    setState(() {
      _attachedPhotoName = 'problem_snapshot.jpg';
      _isDiagnosingPhoto = true;
    });

    try {
      final repo = context.read<SkillCommerceRepository>();
      final diag = await repo.diagnoseProblemImage(
        imageName: 'problem_snapshot.jpg',
        tradeCategory: widget.skill?.skillName ?? 'home-maintenance',
      );
      if (mounted) {
        setState(() {
          _activeDiagnostic = diag;
          _isDiagnosingPhoto = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isDiagnosingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    final laborRate = widget.skill?.basicPrice ?? 500.0;
    final urgencyFee = widget.isUrgent ? 300.0 : 0.0;
    final total = laborRate + urgencyFee;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'বুকিং ও পেমেন্ট বিবরণ' : 'Booking & Payment Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slateNavy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Selected Provider Card
                if (widget.provider != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softOffWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(
                            AssetPaths.getPath(widget.provider!.avatarKey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.provider!.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.provider!.primarySkill,
                                style: const TextStyle(
                                  color: AppColors.slateMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '⭐ ${widget.provider!.overallRating}',
                            style: const TextStyle(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Service Address Input
                Text(
                  isBn ? 'সেবার ঠিকানা (Service Address)' : 'Service Address',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: AppColors.forestGreen,
                    ),
                    hintText: isBn
                        ? 'বাড়ি, রোড, এলাকা (যেমন: বনানী, ঢাকা)'
                        : 'House, Road, Area (e.g. Banani, Dhaka)',
                  ),
                ),

                const SizedBox(height: 16),

                // Voice Note / Problem Description
                Text(
                  isBn
                      ? 'সমস্যার বিবরণ বা ভয়েস নোট'
                      : 'Problem Note or Voice Clip',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: isBn
                        ? 'যেমন: এসি থেকে ঠান্ডা বাতাস আসছে না'
                        : 'e.g., AC not cooling properly',
                  ),
                ),

                const SizedBox(height: 10),

                // Voice Recording & Audio Waveform Widget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isRecordingVoice
                        ? AppColors.urgentRed.withValues(alpha: 0.08)
                        : AppColors.softOffWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isRecordingVoice ? AppColors.urgentRed : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _toggleVoiceRecording,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isRecordingVoice ? AppColors.urgentRed : AppColors.forestGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isRecordingVoice ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isRecordingVoice
                              ? '${strings.recordingNow} (${strings.formatNumber(_voiceSeconds)}s)'
                              : (_hasVoiceNote
                                  ? (isBn
                                      ? 'ভয়েস নোট রেকর্ড হয়েছে (${strings.formatNumber(_voiceSeconds)}s)'
                                      : 'Voice note attached (${_voiceSeconds}s)')
                                  : (isBn ? 'কথা বলে সমস্যা রেকর্ড করুন' : 'Tap mic to record voice note')),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isRecordingVoice ? AppColors.urgentRed : AppColors.slateNavy,
                          ),
                        ),
                      ),
                      if (_hasVoiceNote && !_isRecordingVoice) ...[
                        IconButton(
                          icon: Icon(
                            _isPlayingVoice ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: AppColors.forestGreen,
                            size: 24,
                          ),
                          onPressed: _playSimulatedVoice,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.urgentRed, size: 20),
                          onPressed: _deleteVoiceNote,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Problem Photo Attachment Tile
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.softOffWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_camera, color: AppColors.forestGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _attachedPhotoName != null
                              ? (isBn ? 'ছবি যুক্ত করা হয়েছে (photo.jpg)' : 'Photo attached: photo.jpg')
                              : (isBn ? 'সমস্যার ছবি তুলুন বা যোগ করুন' : 'Attach problem photo'),
                          style: const TextStyle(fontSize: 12, color: AppColors.slateNavy),
                        ),
                      ),
                      if (_attachedPhotoName == null)
                        TextButton(
                          onPressed: _pickSamplePhoto,
                          child: Text(isBn ? 'ছবি তুলুন' : 'Attach'),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.urgentRed, size: 18),
                          onPressed: () => setState(() {
                            _attachedPhotoName = null;
                            _activeDiagnostic = null;
                          }),
                        ),
                    ],
                  ),
                ),

                // AI Visual Diagnostic Card
                if (_isDiagnosingPhoto)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isBn ? 'Gemini AI ছবি বিশ্লেষণ করছে...' : 'Gemini AI is analyzing photo...',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_activeDiagnostic != null && _attachedPhotoName != null)
                  AiProblemDiagnosticCard(
                    diagnostic: _activeDiagnostic!,
                    showApplyButton: false,
                  ),

                const SizedBox(height: 20),

                // Payment Method Selector
                Text(
                  isBn ? 'পেমেন্ট মাধ্যম (Payment Method)' : 'Payment Method',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PaymentMethodTile(
                      label: strings.cashOnDelivery,
                      icon: Icons.money_rounded,
                      color: AppColors.forestGreen,
                      isSelected: _selectedPaymentMethod == 'Cash',
                      onTap: () => setState(() => _selectedPaymentMethod = 'Cash'),
                    ),
                    const SizedBox(width: 8),
                    _PaymentMethodTile(
                      label: strings.bKash,
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.bKashPink,
                      isSelected: _selectedPaymentMethod == 'bKash',
                      onTap: () => setState(() => _selectedPaymentMethod = 'bKash'),
                    ),
                    const SizedBox(width: 8),
                    _PaymentMethodTile(
                      label: strings.nagad,
                      icon: Icons.credit_card_rounded,
                      color: AppColors.nagadOrange,
                      isSelected: _selectedPaymentMethod == 'Nagad',
                      onTap: () => setState(() => _selectedPaymentMethod = 'Nagad'),
                    ),
                    const SizedBox(width: 8),
                    _PaymentMethodTile(
                      label: strings.card,
                      icon: Icons.payment_rounded,
                      color: Colors.blue.shade700,
                      isSelected: _selectedPaymentMethod == 'Card',
                      onTap: () => setState(() => _selectedPaymentMethod = 'Card'),
                    ),
                  ],
                ),

                // bKash / Nagad wallet number input
                if (_selectedPaymentMethod == 'bKash' || _selectedPaymentMethod == 'Nagad') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_selectedPaymentMethod == 'bKash' ? AppColors.bKashPink : AppColors.nagadOrange).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (_selectedPaymentMethod == 'bKash' ? AppColors.bKashPink : AppColors.nagadOrange).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.bKashInstruction,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _selectedPaymentMethod == 'bKash' ? AppColors.bKashPink : AppColors.nagadOrange,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _mfsPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: strings.bKashNumberHint,
                            prefixIcon: const Icon(Icons.phone_android, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Invoice Breakdown Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softOffWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.laborCharge,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            '৳ ${strings.formatNumber(laborRate.toInt())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (widget.isUrgent) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              strings.urgentSurcharge,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.urgentRed,
                              ),
                            ),
                            Text(
                              '৳ ${strings.formatNumber(urgencyFee.toInt())}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.urgentRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.totalPayable,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '৳ ${strings.formatNumber(total.toInt())}',
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
              ],
            ),
          ),

          // Confirm Booking Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      setState(() => _isSubmitting = true);
                      final repo = context.read<SkillCommerceRepository>();

                      final booking = await repo.createBooking(
                        skillId: widget.skill?.skillId ?? 101,
                        skillName:
                            widget.skill?.skillName ??
                            'AC Servicing & Jet Wash',
                        targetProfileId: widget.provider?.profileId,
                        providerName: widget.provider?.fullName,
                        address: _addressController.text.trim(),
                        isUrgent: widget.isUrgent,
                        laborRate: laborRate,
                      );

                      if (mounted) {
                        widget.onBookingConfirmed(booking);
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(isBn ? 'বুকিং নিশ্চিত করুন' : 'Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : AppColors.softOffWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.cardBorder,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : AppColors.slateNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
