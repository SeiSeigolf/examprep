import 'package:flutter/material.dart';
import '../../../../db/daos/audit_dao.dart';

class SegmentCoverageTile extends StatelessWidget {
  const SegmentCoverageTile({
    super.key,
    required this.result,
    this.onTapUnit,
    this.onAssistUncovered,
  });
  final SegmentCoverageResult result;
  final ValueChanged<int>? onTapUnit;
  final ValueChanged<SegmentCoverageResult>? onAssistUncovered;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (result.auditStatus) {
      'covered' => (
        Icons.check_circle_outline,
        const Color(0xFF4CAF50),
        'Covered',
      ),
      'conflict' => (
        Icons.warning_amber_outlined,
        const Color(0xFFFF9800),
        'Conflict × ${result.unitCount} Units',
      ),
      _ => (Icons.radio_button_unchecked, const Color(0xFF607D8B), 'Uncovered'),
    };

    final canNavigate = result.examUnitIds.isNotEmpty && onTapUnit != null;
    final isUncovered = result.auditStatus == 'uncovered';
    debugPrint(
      '[AuditTile] seg=${result.segId} '
      'status=${result.auditStatus} '
      'examUnitIds=${result.examUnitIds} '
      'canNavigate=$canNavigate',
    );

    return InkWell(
      onTap: canNavigate
          ? () {
              debugPrint(
                '[AuditTile] tapped → unitId=${result.examUnitIds.first}',
              );
              onTapUnit!(result.examUnitIds.first);
            }
          : (isUncovered && onAssistUncovered != null)
          ? () => onAssistUncovered!(result)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ステータスアイコン
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            // ページ番号バッジ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3440),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'p.${result.pageNumber}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // テキストプレビュー
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.contentPreview.isNotEmpty)
                    Text(
                      result.contentPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    )
                  else
                    const Text(
                      '（テキストなし）',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // ステータスバッジ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canNavigate) ...[
              const SizedBox(width: 6),
              const Icon(Icons.open_in_new, size: 11, color: Colors.white24),
            ],
            if (!canNavigate && isUncovered && onAssistUncovered != null) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.assistant_outlined,
                size: 11,
                color: Colors.white24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
