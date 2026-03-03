import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.provider.dart';

class ReviewQueueItem {
  const ReviewQueueItem({
    required this.claimId,
    required this.examUnitId,
    required this.examUnitTitle,
    required this.claimContent,
    required this.contentConfidence,
    required this.auditStatus,
    required this.pointWeight,
    required this.frequency,
    required this.openConflictCount,
    required this.priority,
  });

  final int claimId;
  final int examUnitId;
  final String examUnitTitle;
  final String claimContent;
  final String contentConfidence;
  final String auditStatus;
  final int pointWeight;
  final int frequency;
  final int openConflictCount;
  final double priority;
}

final reviewQueueProvider = StreamProvider<List<ReviewQueueItem>>((ref) {
  final db = ref.watch(databaseProvider);
  const limit = 50;

  return db
      .customSelect(
        '''
        SELECT
          c.id AS claim_id,
          c.exam_unit_id AS exam_unit_id,
          u.title AS exam_unit_title,
          c.content AS claim_content,
          c.content_confidence AS content_confidence,
          u.audit_status AS audit_status,
          COALESCE(us.point_weight, 1) AS point_weight,
          COALESCE(us.frequency, 1) AS frequency,
          COUNT(DISTINCT cf.id) AS open_conflict_count,
          (
            COALESCE(us.point_weight, 1) *
            COALESCE(us.frequency, 1) *
            (
              1 - CASE c.content_confidence
                WHEN 'H' THEN 0.9
                WHEN 'M' THEN 0.6
                ELSE 0.3
              END
            )
          ) *
          (
            1 +
            CASE WHEN COUNT(DISTINCT cf.id) > 0 THEN 2 ELSE 0 END +
            CASE WHEN u.audit_status = 'LowConfidence' THEN 1 ELSE 0 END
          ) AS review_priority
        FROM claims c
        JOIN exam_units u
          ON u.id = c.exam_unit_id
        LEFT JOIN unit_stats us
          ON us.exam_unit_id = u.id
        LEFT JOIN conflicts cf
          ON (cf.claim_id = c.id OR cf.exam_unit_id = u.id)
          AND cf.status = 'open'
        GROUP BY
          c.id,
          c.exam_unit_id,
          u.title,
          c.content,
          c.content_confidence,
          u.audit_status,
          us.point_weight,
          us.frequency
        ORDER BY
          review_priority DESC,
          open_conflict_count DESC,
          c.id ASC
        LIMIT $limit
        ''',
        readsFrom: {db.claims, db.examUnits, db.unitStats, db.conflicts},
      )
      .watch()
      .map(
        (rows) => rows
            .map(
              (row) => ReviewQueueItem(
                claimId: row.read<int>('claim_id'),
                examUnitId: row.read<int>('exam_unit_id'),
                examUnitTitle: row.read<String>('exam_unit_title'),
                claimContent: row.read<String>('claim_content'),
                contentConfidence: row.read<String>('content_confidence'),
                auditStatus: row.read<String>('audit_status'),
                pointWeight: row.read<int>('point_weight'),
                frequency: row.read<int>('frequency'),
                openConflictCount: row.read<int>('open_conflict_count'),
                priority: row.read<num>('review_priority').toDouble(),
              ),
            )
            .toList(),
      );
});
