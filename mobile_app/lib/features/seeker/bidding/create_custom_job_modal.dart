import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';
import '../../../shared/widgets/ai_problem_diagnostic_card.dart';

class CreateCustomJobModal extends StatefulWidget {
  final Function(CustomJobModel createdJob) onJobCreated;
  final AiIntakeResultModel? initialAiIntake;

  const CreateCustomJobModal({
    super.key,
    required this.onJobCreated,
    this.initialAiIntake,
  });

  static Future<CustomJobModel?> show(
    BuildContext context, {
    AiIntakeResultModel? initialAiIntake,
  }) {
    return showModalBottomSheet<CustomJobModel>(
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
          child: CreateCustomJobModal(
            initialAiIntake: initialAiIntake,
            onJobCreated: (job) => Navigator.pop(ctx, job),
          ),
        ),
      ),
    );
  }

  @override
  State<CreateCustomJobModal> createState() => _CreateCustomJobModalState();
}

class _CreateCustomJobModalState extends State<CreateCustomJobModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController(text: '1500');
  final TextEditingController _addressController = TextEditingController(text: 'রোড ১১, বনানী, ঢাকা');

  String _selectedCategory = 'Home Maintenance';
  bool _isUrgent = false;
  bool _isSubmitting = false;
  bool _isAiAnalyzing = false;
  AiIntakeResultModel? _activeAiResult;

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
  void initState() {
    super.initState();
    if (widget.initialAiIntake != null) {
      _applyAiResult(widget.initialAiIntake!);
    }
  }

  void _applyAiResult(AiIntakeResultModel result) {
    setState(() {
      _activeAiResult = result;
      _titleController.text = result.title;
      _descController.text = result.problemDescription;
      _budgetController.text = result.suggestedBudget.toInt().toString();
      _addressController.text = result.locationArea;
      _isUrgent = result.isUrgent;

      final cat = result.categorySlug.toLowerCase();
      if (cat.contains('clean')) {
        _selectedCategory = 'Cleaning & Healthcare';
      } else if (cat.contains('tech') || cat.contains('cctv')) {
        _selectedCategory = 'Tech & Electronics';
      } else if (cat.contains('moving') || cat.contains('shift')) {
        _selectedCategory = 'Logistics & Moving';
      } else {
        _selectedCategory = 'Home Maintenance';
      }
    });
  }

  Future<void> _runAiVoiceIntake({String? sampleText}) async {
    setState(() => _isAiAnalyzing = true);
    try {
      final repo = context.read<SkillCommerceRepository>();
      final result = await repo.processVoiceIntake(
        transcribedText: sampleText ??
            (_hasVoiceNote
                ? 'আমার এসি থেকে পানি পড়ছে এবং রুম ঠান্ডা হচ্ছে না, জরুরি মিস্ত্রি প্রয়োজন বনানী রোড ১১।'
                : 'সার্কিট ব্রেকার বারবার ট্রিপ করছে, ধোঁয়া বের হচ্ছে জরুরি ইলেকট্রিশিয়ান চাই।'),
      );
      if (mounted) {
        _applyAiResult(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.forestGreen,
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${result.aiSummary} (${(result.confidenceScore * 100).toInt()}% confidence)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiAnalyzing = false);
      }
    }
  }

  void _showAiVoiceSheet() {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.forestGreen),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.aiVoiceIntake,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        strings.aiVoiceIntakeSub,
                        style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              isBn ? 'উদাহরণ সিলেক্ট করুন বা সরাসরি বলুন:' : 'Choose a sample utterance or speak:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildSampleVoiceChip(
              icon: Icons.ac_unit,
              title: isBn ? '❄️ এসি ঠান্ডা হচ্ছে না, বনানী' : '❄️ AC not cooling, Banani',
              text: 'আমার ১.৫ টন ইনভার্টার এসি ঠান্ডা হচ্ছে না, গ্যাস লিক হতে পারে, বনানী ১১ রোড।',
              ctx: ctx,
            ),
            _buildSampleVoiceChip(
              icon: Icons.flash_on,
              title: isBn ? '⚡ সার্কিট ব্রেকার শর্ট সার্কিট' : '⚡ Circuit breaker short-circuit',
              text: 'মেইন ডিবি বক্সের সার্কিট ব্রেকার পুড়ে গেছে ধোঁয়া বের হচ্ছে, খুব জরুরি ইলেকট্রিশিয়ান লাগবে।',
              ctx: ctx,
            ),
            _buildSampleVoiceChip(
              icon: Icons.plumbing,
              title: isBn ? '🚰 বেসিন পাইপ লিক ও ড্রেন জ্যাম' : '🚰 Basin pipe leak & blockage',
              text: 'বাথরুমের বেসিনের পাইপ ফেটে মেঝে ভেসে যাচ্ছে, জরুরি প্লাম্বার প্রয়োজন মিরপুর ১০।',
              ctx: ctx,
            ),
            _buildSampleVoiceChip(
              icon: Icons.cleaning_services,
              title: isBn ? '🧹 ৩ রুমের ফ্ল্যাট ডিপ ক্লিনিং' : '🧹 3-Bedroom Flat Deep Cleaning',
              text: '৩ রুমের বাসা নতুন শিফট করেছি, পুরো ফ্ল্যাট ফ্লোর ও টয়লেট ডিপ ক্লিনিং লাগবে গুলশান ২।',
              ctx: ctx,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleVoiceChip({
    required IconData icon,
    required String title,
    required String text,
    required BuildContext ctx,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        _runAiVoiceIntake(sampleText: text);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.softOffWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.forestGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slateNavy),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.slateMuted),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voiceTimer?.cancel();
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
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
      _attachedPhotoName = 'problem_inspection_photo.jpg';
      _isDiagnosingPhoto = true;
    });

    try {
      final repo = context.read<SkillCommerceRepository>();
      final diag = await repo.diagnoseProblemImage(
        imageName: 'problem_inspection_photo.jpg',
        tradeCategory: _selectedCategory,
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

  void _applyDiagnosticToJob() {
    if (_activeDiagnostic == null) return;
    final isBn = AppStrings.of(context).isBengali;
    final totalMin = _activeDiagnostic!.estimatedLaborMin + _activeDiagnostic!.estimatedPartsMin;
    final totalMax = _activeDiagnostic!.estimatedLaborMax + _activeDiagnostic!.estimatedPartsMax;
    final avgTotal = ((totalMin + totalMax) / 2).round();

    setState(() {
      _budgetController.text = avgTotal.toString();
      final diagTag = isBn
          ? '\n\n[এআই ডায়াগনস্টিক: ${_activeDiagnostic!.bengaliComponentName} | ত্রুটি: ${_activeDiagnostic!.bengaliFailureMode}]'
          : '\n\n[AI Diagnostic: ${_activeDiagnostic!.detectedComponent} | Defect: ${_activeDiagnostic!.failureMode}]';
      if (!_descController.text.contains('[AI Diagnostic:')) {
        _descController.text = '${_descController.text.trim()}$diagTag';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.forestGreen,
        content: Text(
          isBn
              ? 'ডায়াগনস্টিক তথ্য অনুযায়ী বাজেট ৳$avgTotal ও বিবরণ আপডেট করা হয়েছে।'
              : 'Budget updated to ৳$avgTotal & diagnostic added to description.',
        ),
      ),
    );
  }

  Future<void> _submitJob() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter job title')),
      );
      return;
    }

    final budget = double.tryParse(_budgetController.text.trim()) ?? 1000.0;
    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<SkillCommerceRepository>();
      final newJob = await repo.createCustomJob(
        title: title,
        description: _descController.text.trim(),
        categoryName: _selectedCategory,
        budget: budget,
        location: _addressController.text.trim(),
        isUrgent: _isUrgent,
        hasVoiceNote: _hasVoiceNote,
        voiceDurationSeconds: _voiceSeconds,
        photoName: _attachedPhotoName,
      );

      if (mounted) {
        widget.onJobCreated(newJob);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.post_add_rounded, color: AppColors.forestGreen),
                    const SizedBox(width: 8),
                    Text(
                      strings.createJobTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slateNavy,
                      ),
                    ),
                  ],
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
                // AI Voice Auto-Fill Hero Card / Status
                if (_isAiAnalyzing)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.forestGreen),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            strings.aiAnalyzing,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_activeAiResult != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.forestGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.forestGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                strings.aiFilledBadge,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(_activeAiResult!.confidenceScore * 100).toInt()}% Confidence',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeAiResult!.aiSummary,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slateNavy,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.forestGreen.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.aiVoiceIntake,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.slateNavy,
                                ),
                              ),
                              Text(
                                isBn
                                    ? 'কথা বলে ফর্ম স্বয়ংক্রিয়ভাবে পূরণ করুন'
                                    : 'Speak problem to auto-fill via AI',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _showAiVoiceSheet,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.forestGreen),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: const Size(60, 32),
                          ),
                          child: Text(
                            isBn ? 'শুরু করুন' : 'Start',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title Field
                Text(
                  strings.jobTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: isBn
                        ? 'যেমন: পুরো ৩ রুমের ফ্ল্যাট ওয়্যারিং মেরামত'
                        : 'e.g. Complete 3-room flat wiring & DB repair',
                    prefixIcon: const Icon(Icons.title, color: AppColors.forestGreen),
                  ),
                ),

                const SizedBox(height: 16),

                // Category Selector
                Text(
                  isBn ? 'কাজের বিভাগ (Category)' : 'Category',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category, color: AppColors.forestGreen),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Home Maintenance',
                      child: Text(isBn ? 'হোম মেইনটেন্যান্স (এসি, ইলেকট্রিক, প্লাম্বিং)' : 'Home Maintenance'),
                    ),
                    DropdownMenuItem(
                      value: 'Cleaning & Healthcare',
                      child: Text(isBn ? 'ক্লিনিং ও হেলথকেয়ার' : 'Cleaning & Healthcare'),
                    ),
                    DropdownMenuItem(
                      value: 'Tech & Electronics',
                      child: Text(isBn ? 'টেক ও সিসিটিভি' : 'Tech & Electronics'),
                    ),
                    DropdownMenuItem(
                      value: 'Logistics & Moving',
                      child: Text(isBn ? 'বাসা বদল ও পরিবহন' : 'Logistics & Moving'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),

                const SizedBox(height: 16),

                // Description Field
                Text(
                  isBn ? 'সমস্যার বিস্তারিত বিবরণ' : 'Problem Description',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: isBn
                        ? 'কী ধরনের সমস্যা হচ্ছে বিস্তারিত লিখুন...'
                        : 'Describe what needs to be repaired...',
                  ),
                ),

                const SizedBox(height: 16),

                // Target Budget & Urgency
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.jobBudget,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: '৳ ',
                              prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'জরুরি?' : 'Urgent?',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _isUrgent = !_isUrgent),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: _isUrgent ? AppColors.urgentRed.withValues(alpha: 0.12) : AppColors.softOffWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isUrgent ? AppColors.urgentRed : AppColors.cardBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.flash_on_rounded,
                                    color: _isUrgent ? AppColors.urgentRed : AppColors.slateMuted,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isUrgent ? (isBn ? 'জরুরি' : 'Urgent') : (isBn ? 'সাধারণ' : 'Normal'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _isUrgent ? AppColors.urgentRed : AppColors.slateNavy,
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
                ),

                const SizedBox(height: 16),

                // Location Field
                Text(
                  strings.jobAddress,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on, color: AppColors.forestGreen),
                  ),
                ),

                const SizedBox(height: 20),

                // Voice Note Recording Widget
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isRecordingVoice
                        ? AppColors.urgentRed.withValues(alpha: 0.08)
                        : AppColors.softOffWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isRecordingVoice ? AppColors.urgentRed : AppColors.cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isRecordingVoice ? Icons.mic : Icons.mic_none,
                                color: _isRecordingVoice ? AppColors.urgentRed : AppColors.forestGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isRecordingVoice
                                    ? strings.recordingNow
                                    : (_hasVoiceNote ? (isBn ? 'ভয়েস নোট রেকর্ড হয়েছে' : 'Voice note recorded') : strings.voiceRecord),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isRecordingVoice ? AppColors.urgentRed : AppColors.slateNavy,
                                ),
                              ),
                            ],
                          ),
                          if (_isRecordingVoice)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.urgentRed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${strings.formatNumber(_voiceSeconds)}s / ৩০s',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            )
                          else if (_hasVoiceNote)
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isPlayingVoice ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                    color: AppColors.forestGreen,
                                    size: 28,
                                  ),
                                  onPressed: _playSimulatedVoice,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.urgentRed, size: 22),
                                  onPressed: _deleteVoiceNote,
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _toggleVoiceRecording,
                        icon: Icon(_isRecordingVoice ? Icons.stop : Icons.fiber_manual_record, size: 16),
                        label: Text(
                          _isRecordingVoice
                              ? (isBn ? 'রেকর্ডিং বন্ধ করুন' : 'Stop Recording')
                              : (isBn ? 'রেকর্ড শুরু করুন (কথা বলে জানান)' : 'Tap to Record Voice Note'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecordingVoice ? AppColors.urgentRed : AppColors.forestGreen,
                          minimumSize: const Size(double.infinity, 38),
                        ),
                      ),
                      if (_hasVoiceNote && !_isRecordingVoice) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _runAiVoiceIntake,
                          icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.forestGreen),
                          label: Text(
                            isBn ? '✨ ভয়েস নোটটি AI দিয়ে বিশ্লেষণ ও পূরণ করুন' : '✨ Auto-Fill form with this voice note',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.forestGreen),
                            minimumSize: const Size(double.infinity, 36),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Photo Attachment Tile
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softOffWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: _attachedPhotoName != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  AssetPaths.getPath('technician_appliance'),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.handyman, color: AppColors.forestGreen),
                                ),
                              )
                            : const Icon(Icons.add_a_photo, color: AppColors.forestGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.photoAttach,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              _attachedPhotoName != null
                                  ? (isBn ? 'ছবি যুক্ত করা হয়েছে (db_box.jpg)' : 'Photo attached: db_box.jpg')
                                  : (isBn ? 'যন্ত্রাংশ বা সমস্যার ছবি' : 'Take or upload problem photo'),
                              style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
                            ),
                          ],
                        ),
                      ),
                      if (_attachedPhotoName == null)
                        OutlinedButton(
                          onPressed: _pickSamplePhoto,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(60, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: Text(isBn ? 'যুক্ত করুন' : 'Add'),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.urgentRed),
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
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isBn
                                ? 'Gemini AI ছবি বিশ্লেষণ করে ত্রুটি সনাক্ত করছে...'
                                : 'Gemini AI is analyzing problem photo...',
                            style: const TextStyle(
                              fontSize: 12,
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
                    onApplyToJob: _applyDiagnosticToJob,
                  ),
              ],
            ),
          ),

          // Submit CTA Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitJob,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isBn
                              ? 'কাজ পোস্ট করুন ও দরদাম আহ্বান করুন'
                              : 'Post Job & Request Proposals',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
