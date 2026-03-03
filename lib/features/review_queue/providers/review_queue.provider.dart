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
    required this.evidenceItemCount,
    required this.mastery,
    required this.reviewOverdue,
    required this.nextReviewAt,
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
  final int evidenceItemCount;
  final double mastery;
  final bool reviewOverdue;
  final DateTime? nextReviewAt;
  final double priority;
}

String buildReviewReason(ReviewQueueItem item) {
  final reasons = <String>[];
  if (item.reviewOverdue) {
    reasons.add('0) 期限切れレビュー');
  }
  if (item.openConflictCount > 0) {
    reasons.add('1) Conflict(open) がある');
  }
  if (item.auditStatus == 'LowConfidence') {
    reasons.add('2) auditStatus=LowConfidence');
  }
  if (item.contentConfidence == 'L') {
    reasons.add('3) contentConfidence=L');
  }
  if (item.evidenceItemCount <= 1) {
    reasons.add('4) evidence数が少ない (${item.evidenceItemCount})');
  }
  if (reasons.isEmpty) {
    return '優先度スコアが高い';
  }
  return reasons.join(' / ');
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
          COUNT(DISTINCT epi.id) AS evidence_item_count,
          COALESCE(qa.mastery, 0.0) AS mastery,
          crs.next_review_at AS next_review_at,
          CASE WHEN crs.next_review_at IS NOT NULL AND crs.next_review_at <= CURRENT_TIMESTAMP THEN 1 ELSE 0 END AS review_overdue,
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
          ) *
          (1 - COALESCE(qa.mastery, 0.0))
          +
          CASE WHEN crs.next_review_at IS NOT NULL AND crs.next_review_at <= CURRENT_TIMESTAMP THEN 1000 ELSE 0 END
          AS review_priority
        FROM claims c
        JOIN exam_units u
          ON u.id = c.exam_unit_id
        LEFT JOIN unit_stats us
          ON us.exam_unit_id = u.id
        LEFT JOIN conflicts cf
          ON (cf.claim_id = c.id OR cf.exam_unit_id = u.id)
          AND cf.status = 'open'
        LEFT JOIN evidence_packs ep
          ON ep.claim_id = c.id
        LEFT JOIN evidence_pack_items epi
          ON epi.evidence_pack_id = ep.id
        LEFT JOIN (
          SELECT
            claim_id,
            AVG(CASE WHEN is_correct = 1 THEN 1.0 ELSE 0.0 END) AS mastery
          FROM quiz_attempts
          GROUP BY claim_id
        ) qa
          ON qa.claim_id = c.id
        LEFT JOIN claim_review_schedules crs
          ON crs.claim_id = c.id
        GROUP BY
          c.id,
          c.exam_unit_id,
          u.title,
          c.content,
          c.content_confidence,
          u.audit_status,
          us.point_weight,
          us.frequency,
          qa.mastery,
          crs.next_review_at
        ORDER BY
          review_priority DESC,
          open_conflict_count DESC,
          c.id ASC
        LIMIT $limit
        ''',
        readsFrom: {
          db.claims,
          db.examUnits,
          db.unitStats,
          db.conflicts,
          db.evidencePacks,
          db.evidencePackItems,
          db.quizAttempts,
          db.claimReviewSchedules,
        },
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
                evidenceItemCount: row.read<int>('evidence_item_count'),
                mastery: row.read<double>('mastery'),
                reviewOverdue: row.read<int>('review_overdue') == 1,
                nextReviewAt: row.data['next_review_at'] == null
                    ? null
                    : row.read<DateTime>('next_review_at'),
                priority: row.read<double>('review_priority'),
              ),
            )
            .toList(),
      );
});
