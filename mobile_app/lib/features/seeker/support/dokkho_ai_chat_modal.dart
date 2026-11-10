import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';

class DokkhoAiChatModal extends StatefulWidget {
  final int? activeBookingId;

  const DokkhoAiChatModal({super.key, this.activeBookingId});

  static Future<void> show(BuildContext context, {int? activeBookingId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DokkhoAiChatModal(activeBookingId: activeBookingId),
        ),
      ),
    );
  }

  @override
  State<DokkhoAiChatModal> createState() => _DokkhoAiChatModalState();
}

class _DokkhoAiChatModalState extends State<DokkhoAiChatModal> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiSupportChatMessageModel> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      AiSupportChatMessageModel(
        id: 'welcome',
        textBengali:
            'আসসালামু আলাইকুম! আমি Dokkho AI সহকারী। আপনার কারিগর খোঁজা, চলতি বুকিং ট্র্যাক করা বা খরচের হিসাব জানতে নিচে ক্লিক করুন অথবা যেকোনো প্রশ্ন লিখুন।',
        textEnglish:
            'Hello! I am Dokkho AI Assistant. I can help you find verified technicians, track your active bookings, or estimate service costs.',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: [
          '📍 আমার চলতি বুকিং কোথায়?',
          '💰 এসি ও ইলেকট্রিক কাজের রেট চার্ট',
          '❌ ক্যান্সেলেশন ও রিফান্ড নিয়ম',
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? presetText]) async {
    final query = (presetText ?? _textController.text).trim();
    if (query.isEmpty) return;

    _textController.clear();

    final userMsg = AiSupportChatMessageModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      textBengali: query,
      textEnglish: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final repo = context.read<SkillCommerceRepository>();
      final reply = await repo.sendSupportChatMessage(
        message: query,
        activeBookingId: widget.activeBookingId,
      );

      if (mounted) {
        setState(() {
          _messages.add(reply);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSending = false);
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.forestGreen.withValues(alpha: 0.1),
                      backgroundImage: const AssetImage(AssetPaths.aiChatbot),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            strings.dokkhoAiAssistant,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.slateNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Gemini AI',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        strings.dokkhoAiTagline,
                        style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
                      ),
                    ],
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

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(msg, isBn);
              },
            ),
          ),

          if (_isSending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'Dokkho AI ভাবছে...' : 'Dokkho AI is typing...',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.slateMuted),
                  ),
                ],
              ),
            ),

          // Chat Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: strings.chatInputPlaceholder,
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.slateMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      isDense: true,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _sendMessage(),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(AiSupportChatMessageModel msg, bool isBn) {
    final text = isBn ? msg.textBengali : msg.textEnglish;

    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.forestGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ),
      );
    }

    // AI message
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 13, color: AppColors.forestGreen),
                SizedBox(width: 4),
                Text(
                  'Dokkho AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softOffWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.slateNavy,
                    ),
                  ),

                  // Inline Tool Result Card (e.g. Booking Status Tool)
                  if (msg.executedToolName == 'GetMyBookingStatus') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_bike_rounded, color: AppColors.forestGreen, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isBn ? 'কারিগর: মোঃ রফিকুল ইসলাম' : 'Technician: Rafiqul',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                Text(
                                  isBn ? 'স্ট্যাটাস: রওনা হয়েছেন (১৫ মিনিট বাকি)' : 'Status: On The Way (~15 mins)',
                                  style: const TextStyle(fontSize: 10, color: AppColors.forestGreen),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isBn ? 'চলতি কাজ' : 'Active',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Suggested Follow-up chips
            if (msg.suggestedFollowUps.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.suggestedFollowUps.map((chipText) {
                  return InkWell(
                    onTap: () => _sendMessage(chipText),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_outlined, size: 12, color: AppColors.forestGreen),
                          const SizedBox(width: 4),
                          Text(
                            chipText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

