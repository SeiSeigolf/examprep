import 'package:flutter/material.dart';
import '../../../../db/daos/audit_dao.dart';

class CoverageSummaryBar extends StatelessWidget {
  const CoverageSummaryBar({super.key, required this.results});
  final List<SegmentCoverageResult> results;

  @override
  Widget build(BuildContext context) {
    int covered = 0, uncovered = 0, conflict = 0;
    for (final r in results) {
      switch (r.auditStatus) {
        case 'covered':
          covered++;
        case 'conflict':
          conflict++;
        default:
          uncovered++;
      }
    }
    final total = results.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D23),
        border: Border(bottom: BorderSide(color: Color(0xFF2E3340))),
      ),
      child: Row(
        children: [
          _Stat(
            label: 'Covered',
            count: covered,
            color: const Color(0xFF4CAF50),
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: 20),
          _Stat(
            label: 'Uncovered',
            count: uncovered,
            color: const Color(0xFF607D8B),
            icon: Icons.radio_button_unchecked,
          ),
          const SizedBox(width: 20),
          _Stat(
            label: 'Conflict',
            count: conflict,
            color: const Color(0xFFFF9800),
            icon: Icons.warning_amber_outlined,
          ),
          const Spacer(),
          if (total > 0) ...[
            Text(
              '網羅率 ',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            Text(
              '${(covered / total * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : covered / total,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                  minHeight: 8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}
