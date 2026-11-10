import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';

class BiddingProposalsModal extends StatefulWidget {
  final CustomJobModel job;
  final Function(BookingModel confirmedBooking) onProposalAccepted;

  const BiddingProposalsModal({
    super.key,
    required this.job,
    required this.onProposalAccepted,
  });

  static Future<BookingModel?> show(
    BuildContext context, {
    required CustomJobModel job,
  }) {
    return showModalBottomSheet<BookingModel>(
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
          child: BiddingProposalsModal(
            job: job,
            onProposalAccepted: (b) => Navigator.pop(ctx, b),
          ),
        ),
      ),
    );
  }

  @override
  State<BiddingProposalsModal> createState() => _BiddingProposalsModalState();
}

class _BiddingProposalsModalState extends State<BiddingProposalsModal> {
  int? _acceptingProposalId;

  Future<void> _handleAccept(JobProposalModel proposal) async {
    setState(() => _acceptingProposalId = proposal.proposalId);
    try {
      final repo = context.read<SkillCommerceRepository>();
      final booking = await repo.acceptJobProposal(
        jobId: widget.job.jobId,
        proposalId: proposal.proposalId,
      );
      if (mounted) {
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${strings.bookingConfirmed} ${proposal.providerName} ${strings.statusOnTheWay}',
            ),
            backgroundColor: AppColors.forestGreen,
          ),
        );
        widget.onProposalAccepted(booking);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _acceptingProposalId = null);
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
    final proposals = widget.job.proposals;

    return Column(
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

        // Modal Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppColors.forestGreen),
                  const SizedBox(width: 8),
                  Text(
                    strings.biddingModalTitle,
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

        // Job Summary Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softOffWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.slateNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '৳ ${strings.formatNumber(widget.job.budget.toInt())}',
                      style: const TextStyle(
                        color: AppColors.forestGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.urgentRed),
                  const SizedBox(width: 4),
                  Text(
                    widget.job.location,
                    style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                  ),
                  const Spacer(),
                  if (widget.job.hasVoiceNote) ...[
                    const Icon(Icons.mic, size: 14, color: AppColors.forestGreen),
                    const SizedBox(width: 2),
                    Text(
                      '${strings.formatNumber(widget.job.voiceDurationSeconds)}s',
                      style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (widget.job.photoName != null) ...[
                    const Icon(Icons.photo_camera, size: 14, color: AppColors.forestGreen),
                    const SizedBox(width: 2),
                    Text(
                      isBn ? 'ছবি' : 'Photo',
                      style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Proposals List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn
                    ? 'প্রাপ্ত প্রস্তাবসমূহ (${strings.formatNumber(proposals.length)})'
                    : 'Received Proposals (${proposals.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.slateNavy,
                ),
              ),
              Text(
                isBn ? 'স্বচ্ছ দরদাম' : 'Live Negotiation',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.forestGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Proposals List
        Expanded(
          child: proposals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_empty_rounded, size: 40, color: AppColors.slateMuted),
                      const SizedBox(height: 10),
                      Text(
                        isBn
                            ? 'নিকটস্থ কারিগররা প্রস্তাব পাঠাচ্ছেন...'
                            : 'Waiting for technicians to submit proposals...',
                        style: const TextStyle(color: AppColors.slateMuted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: proposals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final proposal = proposals[index];
                    final isAccepted = proposal.status == 'Accepted';
                    final isAccepting = _acceptingProposalId == proposal.proposalId;
                    final avatarPath = AssetPaths.getPath(proposal.providerAvatarKey);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isAccepted ? AppColors.forestGreen.withValues(alpha: 0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isAccepted ? AppColors.forestGreen : AppColors.cardBorder,
                          width: isAccepted ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: AssetImage(avatarPath),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            proposal.providerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.slateNavy,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, color: AppColors.forestGreen, size: 15),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${proposal.rating} (${strings.formatNumber(proposal.reviewsCount)})',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.access_time_rounded, size: 13, color: AppColors.slateMuted),
                                        const SizedBox(width: 2),
                                        Text(
                                          isBn
                                              ? '${strings.formatNumber(proposal.estimatedArrivalMins)} মিনিটে আসবেন'
                                              : 'Arrives in ${proposal.estimatedArrivalMins}m',
                                          style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '৳ ${strings.formatNumber(proposal.proposedAmount.toInt())}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.forestGreen,
                                    ),
                                  ),
                                  Text(
                                    isBn ? 'প্রস্তাবিত মূল্য' : 'Proposed Price',
                                    style: const TextStyle(fontSize: 10, color: AppColors.slateMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          if (proposal.proposalNote.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.softOffWhite,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.slateMuted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      proposal.proposalNote,
                                      style: const TextStyle(fontSize: 12, color: AppColors.slateNavy),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling ${proposal.phone}...')),
                                  );
                                },
                                icon: const Icon(Icons.call, size: 16),
                                label: Text(isBn ? 'কল দিন' : 'Call'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(80, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (isAccepted || isAccepting)
                                      ? null
                                      : () => _handleAccept(proposal),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAccepted ? Colors.grey : AppColors.forestGreen,
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: isAccepting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          isAccepted
                                              ? (isBn ? 'গৃহীত হয়েছে' : 'Accepted')
                                              : strings.acceptProposal,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

