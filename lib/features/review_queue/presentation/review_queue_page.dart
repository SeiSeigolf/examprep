import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/navigation.provider.dart';
import '../../exam_units/providers/claims.provider.dart';
import '../../exam_units/providers/exam_units.provider.dart';
import '../providers/review_queue.provider.dart';

class ReviewQueuePage extends ConsumerWidget {
  const ReviewQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(reviewQueueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Queue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '優先度上位50件の Claim を確認します',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: queueAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                '読み込みエラー: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'Review対象はありません',
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFF2E3340)),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF2D3440),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    title: Text(
                      item.examUnitTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.claimContent,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '要確認理由: ${buildReviewReason(item)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _MetaChip(
                                label:
                                    'Priority ${item.priority.toStringAsFixed(2)}',
                              ),
                              _MetaChip(
                                label:
                                    'W${item.pointWeight} x F${item.frequency}',
                              ),
                              _MetaChip(
                                label:
                                    'Conf ${item.contentConfidence} (${_confScore(item.contentConfidence).toStringAsFixed(1)})',
                              ),
                              _MetaChip(
                                label: 'Evidence ${item.evidenceItemCount}',
                              ),
                              _MetaChip(
                                label:
                                    'Mastery ${(item.mastery * 100).toStringAsFixed(0)}%',
                              ),
                              _MetaChip(
                                label: item.reviewOverdue
                                    ? '期限切れ'
                                    : '次回 ${item.nextReviewAt?.toLocal().toString().substring(0, 16) ?? '-'}',
                                color: item.reviewOverdue
                                    ? const Color(0xFFBF360C)
                                    : const Color(0xFF2D3440),
                              ),
                              _MetaChip(
                                label:
                                    'Conflict(open): ${item.openConflictCount > 0 ? 'Yes' : 'No'}',
                                color: item.openConflictCount > 0
                                    ? const Color(0xFFB71C1C)
                                    : const Color(0xFF2D3440),
                              ),
                              _MetaChip(
                                label:
                                    'LowConfidence: ${item.auditStatus == 'LowConfidence' ? 'Yes' : 'No'}',
                                color: item.auditStatus == 'LowConfidence'
                                    ? const Color(0xFF8E24AA)
                                    : const Color(0xFF2D3440),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white38,
                    ),
                    onTap: () {
                      ref.read(selectedClaimIdProvider.notifier).state =
                          item.claimId;
                      ref.read(selectedExamUnitIdProvider.notifier).state =
                          item.examUnitId;
                      ref.read(selectedDestinationProvider.notifier).state =
                          AppDestination.examUnits;
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, this.color = const Color(0xFF2D3440)});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }
}

double _confScore(String confidence) {
  switch (confidence) {
    case 'H':
      return 0.9;
    case 'M':
      return 0.6;
    default:
      return 0.3;
  }
}
