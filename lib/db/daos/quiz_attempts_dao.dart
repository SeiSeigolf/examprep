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

@DriftAccessor(tables: [QuizAttempts])
class QuizAttemptsDao extends DatabaseAccessor<AppDatabase>
    with _$QuizAttemptsDaoMixin {
  QuizAttemptsDao(super.db);

  Future<int> insertAttempt({
    required int examUnitId,
    required int claimId,
    required String format,
    required bool isCorrect,
    required int secondsSpent,
  }) {
    return into(quizAttempts).insert(
      QuizAttemptsCompanion.insert(
        examUnitId: examUnitId,
        claimId: claimId,
        format: format,
        isCorrect: isCorrect,
        secondsSpent: Value(secondsSpent),
      ),
    );
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
}
