import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';

class AdHocMaterialsSheet extends StatefulWidget {
  final int bookingId;
  final Function(BookingModel updatedBooking) onPartAdded;

  const AdHocMaterialsSheet({
    super.key,
    required this.bookingId,
    required this.onPartAdded,
  });

  static Future<BookingModel?> show(
    BuildContext context, {
    required int bookingId,
  }) {
    return showModalBottomSheet<BookingModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: AdHocMaterialsSheet(
            bookingId: bookingId,
            onPartAdded: (b) => Navigator.pop(ctx, b),
          ),
        ),
      ),
    );
  }

  @override
  State<AdHocMaterialsSheet> createState() => _AdHocMaterialsSheetState();
}

class _AdHocMaterialsSheetState extends State<AdHocMaterialsSheet> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int _quantity = 1;
  bool _isSubmitting = false;

  // Quick suggestions for technician speed
  final List<Map<String, dynamic>> _quickSuggestions = [
    {'name': 'ক্যাপাসিটর (45uF Capacitor)', 'price': 450},
    {'name': 'গ্যাস রিফিল (R32 Gas 1kg)', 'price': 1800},
    {'name': 'সার্কিট ব্রেকার (16A Breaker)', 'price': 350},
    {'name': 'ড্রেন পাইপ (Drain Pipe 5ft)', 'price': 220},
    {'name': 'টেফলন টেপ ও গ্লু (Teflon Tape)', 'price': 100},
  ];

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
          // Drag Handle
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.addParts,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slateNavy,
                      ),
                    ),
                    Text(
                      isBn
                          ? 'কাজের জন্য কেনা যন্ত্রাংশের বিল যোগ করুন'
                          : 'Add replacement parts to invoice',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slateMuted,
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
                // Commission Isolation Policy Alert Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.emeraldMint.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.forestGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? '💡 যন্ত্রাংশের খরচে কোনো প্ল্যাটফর্ম কমিশন নেই। আপনি পুরো টাকাটি ফেরত পাবেন।'
                              : '💡 0% platform commission on physical parts. 100% of this amount goes to you!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Quick Suggestion Chips
                Text(
                  isBn
                      ? 'সাধারণ যন্ত্রাংশ (Quick Presets):'
                      : 'Common parts presets:',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slateNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickSuggestions.map((item) {
                    return ActionChip(
                      label: Text('${item['name']} (৳${item['price']})'),
                      labelStyle: const TextStyle(fontSize: 11),
                      backgroundColor: AppColors.softOffWhite,
                      side: const BorderSide(color: AppColors.cardBorder),
                      onPressed: () {
                        setState(() {
                          _descController.text = item['name'];
                          _priceController.text = item['price'].toString();
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // Part Description Input
                Text(
                  strings.partDescription,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    hintText: isBn
                        ? 'যন্ত্রাংশের নাম লিখুন'
                        : 'e.g., Capacitor 45uF',
                    prefixIcon: const Icon(
                      Icons.build_rounded,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Unit Price & Quantity Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.partUnitPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '450',
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'পরিমাণ (Qty)' : 'Quantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.softOffWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                  child: const Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: AppColors.slateNavy,
                                  ),
                                ),
                                Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => _quantity++),
                                  child: const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: AppColors.slateNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Submit Part Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final desc = _descController.text.trim();
                      final price =
                          double.tryParse(_priceController.text.trim()) ?? 0.0;
                      if (desc.isEmpty || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBn
                                  ? 'সঠিক বিবরণ ও মূল্য প্রদান করুন'
                                  : 'Please enter valid description and price',
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);
                      final repo = context.read<SkillCommerceRepository>();

                      final updated = await repo.addBookingPart(
                        bookingId: widget.bookingId,
                        itemDescription: desc,
                        unitPrice: price,
                        quantity: _quantity,
                      );

                      if (mounted) {
                        widget.onPartAdded(updated);
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
                  : Text(isBn ? 'বিলে যোগ করুন' : 'Add to Invoice'),
            ),
          ),
        ],
      ),
    );
  }
}
