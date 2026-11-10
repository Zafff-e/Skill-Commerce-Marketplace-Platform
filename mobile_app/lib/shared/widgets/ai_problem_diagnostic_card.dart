import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../models/polyglot_models.dart';

class AiProblemDiagnosticCard extends StatelessWidget {
  final AiDiagnosticResultModel diagnostic;
  final VoidCallback? onApplyToJob;
  final bool showApplyButton;

  const AiProblemDiagnosticCard({
    super.key,
    required this.diagnostic,
    this.onApplyToJob,
    this.showApplyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    final isCritical = diagnostic.severityLevel.toLowerCase() == 'critical';
    final isModerate = diagnostic.severityLevel.toLowerCase() == 'moderate';

    final severityColor = isCritical
        ? AppColors.urgentRed
        : (isModerate ? AppColors.urgentAmber : AppColors.forestGreen);

    final totalMin = diagnostic.estimatedLaborMin + diagnostic.estimatedPartsMin;
    final totalMax = diagnostic.estimatedLaborMax + diagnostic.estimatedPartsMax;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: AI Badge + Confidence + Severity Pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.forestGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.aiDiagnosisTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.slateNavy,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: severityColor, width: 0.8),
                ),
                child: Text(
                  isCritical
                      ? (isBn ? 'ঝুঁকিপূর্ণ' : 'Critical')
                      : (isModerate
                          ? (isBn ? 'মাঝারি ঝুঁকি' : 'Moderate')
                          : (isBn ? 'স্বাভাবিক' : 'Mild')),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Component & Failure Mode
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.softOffWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.build_circle_outlined, size: 16, color: AppColors.forestGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isBn ? diagnostic.bengaliComponentName : diagnostic.detectedComponent,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.slateNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.report_problem_outlined, size: 16, color: AppColors.urgentAmber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isBn ? diagnostic.bengaliFailureMode : diagnostic.failureMode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slateMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Safety Warning Box
          if (isCritical || isModerate) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.urgentRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.urgentRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.urgentRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diagnostic.safetyWarning,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.urgentRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Advisory Cost Breakdown
          Text(
            isBn ? 'সম্ভাব্য খরচ প্রাক্কলন (Advisory Estimate):' : 'Advisory Cost Estimate:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slateNavy),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildCostPill(
                  label: strings.estimatedLaborRange,
                  amount: '৳${strings.formatNumber(diagnostic.estimatedLaborMin.toInt())} - ${strings.formatNumber(diagnostic.estimatedLaborMax.toInt())}',
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCostPill(
                  label: strings.estimatedPartsRange,
                  amount: '৳${strings.formatNumber(diagnostic.estimatedPartsMin.toInt())} - ${strings.formatNumber(diagnostic.estimatedPartsMax.toInt())}',
                  color: AppColors.slateNavy,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'সর্বমোট আনুমানিক বাজেট:' : 'Total Est. Advisory Budget:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.forestGreen),
                ),
                Text(
                  '৳${strings.formatNumber(totalMin.toInt())} - ৳${strings.formatNumber(totalMax.toInt())}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.forestGreen),
                ),
              ],
            ),
          ),

          // Recommended Spare Parts List
          if (diagnostic.recommendedParts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              strings.recommendedPartsList,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slateNavy),
            ),
            const SizedBox(height: 6),
            Column(
              children: diagnostic.recommendedParts.map((part) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: AppColors.forestGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isBn ? part.bengaliPartName : part.partName,
                          style: const TextStyle(fontSize: 11, color: AppColors.slateNavy),
                        ),
                      ),
                      Text(
                        '~৳${strings.formatNumber(part.estimatedUnitPrice.toInt())}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slateMuted),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),

          // Mandatory Disclaimer
          Text(
            strings.advisoryDisclaimer,
            style: const TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: AppColors.slateMuted,
            ),
          ),

          // Apply to Form Button
          if (showApplyButton && onApplyToJob != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onApplyToJob,
                icon: const Icon(Icons.playlist_add_check_rounded, size: 16),
                label: Text(
                  strings.applyDiagnosisToJob,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostPill({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

