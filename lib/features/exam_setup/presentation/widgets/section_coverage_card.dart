import 'package:flutter/material.dart';
import '../../../../db/database.dart';

/// セクション別カバレッジ・保証得点カード
class SectionCoverageCard extends StatelessWidget {
  const SectionCoverageCard({super.key, required this.stat});

  final SectionCoverageStat stat;

  @override
  Widget build(BuildContext context) {
    final section = stat.section;
    final coverRate = stat.totalUnits == 0
        ? 0.0
        : stat.coveredUnits / stat.totalUnits;
    final coverPct = (coverRate * 100).round();

    // 出題プールの保証得点合計
    final guaranteedItems = stat.pools.fold<int>(
      0,
      (sum, p) => sum + p.guaranteedItems,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D3440)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- ヘッダー ----
          Row(
            children: [
              _ApproachChip(approach: section.studyApproach),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${section.points}点',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ---- カバレッジバー ----
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: coverRate,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF2D3440),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      coverRate >= 0.8
                          ? const Color(0xFF4CAF50)
                          : coverRate >= 0.5
                          ? const Color(0xFFFF9800)
                          : const Color(0xFFEF5350),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 36,
                child: Text(
                  '$coverPct%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ---- ユニット統計 + プール情報 ----
          Row(
            children: [
              _StatChip(
                label:
                    'Unit ${stat.coveredUnits}/${stat.totalUnits}',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF4A90D9),
              ),
              if (stat.lowConfUnits > 0) ...[
                const SizedBox(width: 6),
                _StatChip(
                  label: '要強化 ${stat.lowConfUnits}',
                  icon: Icons.warning_amber_outlined,
                  color: const Color(0xFFEF5350),
                ),
              ],
              if (guaranteedItems > 0) ...[
                const SizedBox(width: 6),
                _StatChip(
                  label: '保証 $guaranteedItems問',
                  icon: Icons.stars_outlined,
                  color: const Color(0xFFFFD54F),
                ),
              ],
            ],
          ),

          // ---- 出題プール一覧 ----
          if (stat.pools.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFF2D3440)),
            const SizedBox(height: 6),
            ...stat.pools.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    const Icon(
                      Icons.format_list_numbered,
                      size: 11,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        p.totalItems > 0
                            ? '${p.description}：全${p.totalItems}個暗記で${p.guaranteedItems}問保証'
                            : p.description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApproachChip extends StatelessWidget {
  const _ApproachChip({required this.approach});
  final String approach;

  static const _colors = {
    '暗記': Color(0xFF7B61FF),
    '理解': Color(0xFF4A90D9),
    '計算': Color(0xFFFF9800),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[approach] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        approach,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 10),
        ),
      ],
    );
  }
}
