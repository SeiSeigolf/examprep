import 'package:drift/drift.dart';
import '../database.dart';

part 'quiz_attempts_dao.g.dart';

class UnitMasteryStat {
  const UnitMasteryStat({
    required this.examUnitId,
    required this.attemptCount,
    required this.wrongCount,
    required this.wrongRate,
    required this.mastery,
  });

  final int examUnitId;
  final int attemptCount;
  final int wrongCount;
  final double wrongRate;
  final double mastery;
}

class UnitDueStat {
  const UnitDueStat({
    required this.examUnitId,
    required this.nextReviewAt,
    required this.overdueCount,
  });

  final int examUnitId;
  final DateTime nextReviewAt;
  final int overdueCount;
}

@DriftAccessor(tables: [QuizAttempts, ClaimReviewSchedules])
class QuizAttemptsDao extends DatabaseAccessor<AppDatabase>
    with _$QuizAttemptsDaoMixin {
  QuizAttemptsDao(super.db);

  Future<int> insertAttempt({
    required int examUnitId,
    required int claimId,
    required String format,
    required bool isCorrect,
    required int secondsSpent,
  }) async {
    return transaction(() async {
      final id = await into(quizAttempts).insert(
        QuizAttemptsCompanion.insert(
          examUnitId: examUnitId,
          claimId: claimId,
          format: format,
          isCorrect: isCorrect,
          secondsSpent: Value(secondsSpent),
        ),
      );
      await _updateClaimReviewSchedule(
        examUnitId: examUnitId,
        claimId: claimId,
        isCorrect: isCorrect,
      );
      return id;
    });
  }

  Future<void> _updateClaimReviewSchedule({
    required int examUnitId,
    required int claimId,
    required bool isCorrect,
  }) async {
    final now = DateTime.now();
    final existing =
        await (db.select(db.claimReviewSchedules)
              ..where((s) => s.claimId.equals(claimId))
              ..limit(1))
            .getSingleOrNull();

    final prevInterval = existing?.intervalHours ?? 24;
    final prevEase = existing?.easeFactor ?? 2.5;
    final prevRep = existing?.repetition ?? 0;

    late final int nextInterval;
    late final double nextEase;
    late final int nextRep;

    if (isCorrect) {
      if (prevRep <= 0) {
        nextInterval = 24;
      } else if (prevRep == 1) {
        nextInterval = 72;
      } else {
        nextInterval = (prevInterval * prevEase).round().clamp(24, 24 * 90);
      }
      nextEase = (prevEase + 0.1).clamp(1.3, 3.0);
      nextRep = prevRep + 1;
    } else {
      nextInterval = 6;
      nextEase = (prevEase - 0.2).clamp(1.3, 3.0);
      nextRep = 0;
    }

    final nextReviewAt = now.add(Duration(hours: nextInterval));
    if (existing == null) {
      await db
          .into(db.claimReviewSchedules)
          .insert(
            ClaimReviewSchedulesCompanion.insert(
              examUnitId: examUnitId,
              claimId: claimId,
              nextReviewAt: nextReviewAt,
              intervalHours: Value(nextInterval),
              easeFactor: Value(nextEase),
              repetition: Value(nextRep),
              lastReviewedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    } else {
      await (db.update(
        db.claimReviewSchedules,
      )..where((s) => s.id.equals(existing.id))).write(
        ClaimReviewSchedulesCompanion(
          examUnitId: Value(examUnitId),
          claimId: Value(claimId),
          nextReviewAt: Value(nextReviewAt),
          intervalHours: Value(nextInterval),
          easeFactor: Value(nextEase),
          repetition: Value(nextRep),
          lastReviewedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Stream<Map<int, UnitMasteryStat>> watchUnitMasteryStats({
    int recentLimit = 30,
  }) {
    return customSelect(
      '''
      WITH ranked AS (
        SELECT
          qa.exam_unit_id,
          qa.is_correct,
          ROW_NUMBER() OVER (
            PARTITION BY qa.exam_unit_id
            ORDER BY qa.attempted_at DESC, qa.id DESC
          ) AS rn
        FROM quiz_attempts qa
      )
      SELECT
        exam_unit_id,
        COUNT(*) AS attempt_count,
        SUM(CASE WHEN is_correct = 0 THEN 1 ELSE 0 END) AS wrong_count,
        AVG(CASE WHEN is_correct = 1 THEN 1.0 ELSE 0.0 END) AS mastery
      FROM ranked
      WHERE rn <= ?
      GROUP BY exam_unit_id
      ''',
      variables: [Variable.withInt(recentLimit)],
      readsFrom: {quizAttempts},
    ).watch().map((rows) {
      final map = <int, UnitMasteryStat>{};
      for (final row in rows) {
        final examUnitId = row.read<int>('exam_unit_id');
        final attemptCount = row.read<int>('attempt_count');
        final wrongCount = row.read<int>('wrong_count');
        final mastery = row.read<double>('mastery');
        final wrongRate = 1 - mastery;
        map[examUnitId] = UnitMasteryStat(
          examUnitId: examUnitId,
          attemptCount: attemptCount,
          wrongCount: wrongCount,
          wrongRate: wrongRate,
          mastery: mastery,
        );
      }
      return map;
    });
  }

  Stream<Map<int, UnitDueStat>> watchUnitDueStats() {
    return customSelect(
      '''
      SELECT
        exam_unit_id,
        MIN(next_review_at) AS next_review_at,
        SUM(CASE WHEN next_review_at <= CURRENT_TIMESTAMP THEN 1 ELSE 0 END) AS overdue_count
      FROM claim_review_schedules
      GROUP BY exam_unit_id
      ''',
      readsFrom: {claimReviewSchedules},
    ).watch().map((rows) {
      final map = <int, UnitDueStat>{};
      for (final row in rows) {
        final examUnitId = row.read<int>('exam_unit_id');
        map[examUnitId] = UnitDueStat(
          examUnitId: examUnitId,
          nextReviewAt: row.read<DateTime>('next_review_at'),
          overdueCount: row.read<int>('overdue_count'),
        );
      }
      return map;
    });
  }
}
