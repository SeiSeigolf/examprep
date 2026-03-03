import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/study_plan/providers/study_plan.provider.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  test('quiz_attempts 保存で未習熟度とReview優先度が変化する', () async {
    final db = _makeInMemoryDb();
    addTearDown(db.close);

    final unit1 = await db
        .into(db.examUnits)
        .insert(
          ExamUnitsCompanion.insert(
            title: 'Unit A',
            confidenceLevel: const Value('medium'),
          ),
        );
    final unit2 = await db
        .into(db.examUnits)
        .insert(
          ExamUnitsCompanion.insert(
            title: 'Unit B',
            confidenceLevel: const Value('medium'),
          ),
        );

    final claim1 = await db
        .into(db.claims)
        .insert(
          ClaimsCompanion.insert(
            examUnitId: unit1,
            content: 'A claim',
            contentConfidence: const Value('M'),
            createdBy: const Value('test'),
          ),
        );
    final claim2 = await db
        .into(db.claims)
        .insert(
          ClaimsCompanion.insert(
            examUnitId: unit2,
            content: 'B claim',
            contentConfidence: const Value('M'),
            createdBy: const Value('test'),
          ),
        );

    await db
        .into(db.unitStats)
        .insert(UnitStatsCompanion.insert(examUnitId: unit1));
    await db
        .into(db.unitStats)
        .insert(UnitStatsCompanion.insert(examUnitId: unit2));

    for (var i = 0; i < 3; i++) {
      await db.quizAttemptsDao.insertAttempt(
        examUnitId: unit1,
        claimId: claim1,
        format: '選択肢',
        isCorrect: true,
        secondsSpent: 10,
      );
      await db.quizAttemptsDao.insertAttempt(
        examUnitId: unit2,
        claimId: claim2,
        format: '選択肢',
        isCorrect: false,
        secondsSpent: 10,
      );
    }

    final mastery = await db.quizAttemptsDao.watchUnitMasteryStats().first;
    final m1 = mastery[unit1]!;
    final m2 = mastery[unit2]!;

    expect(computeUnmasteryScore(m2), greaterThan(computeUnmasteryScore(m1)));

    final priorities = await db
        .customSelect(
          '''
      SELECT
        c.id AS claim_id,
        (
          COALESCE(us.point_weight, 1) *
          COALESCE(us.frequency, 1) *
          (1 - CASE c.content_confidence WHEN 'H' THEN 0.9 WHEN 'M' THEN 0.6 ELSE 0.3 END)
        ) * (1 - COALESCE(qa.mastery, 0.0)) AS review_priority
      FROM claims c
      LEFT JOIN unit_stats us ON us.exam_unit_id = c.exam_unit_id
      LEFT JOIN (
        SELECT claim_id, AVG(CASE WHEN is_correct = 1 THEN 1.0 ELSE 0.0 END) AS mastery
        FROM quiz_attempts
        GROUP BY claim_id
      ) qa ON qa.claim_id = c.id
      WHERE c.id IN (?, ?)
      ''',
          variables: [Variable.withInt(claim1), Variable.withInt(claim2)],
          readsFrom: {db.claims, db.unitStats, db.quizAttempts},
        )
        .get();
    final p1 = priorities
        .firstWhere((r) => r.read<int>('claim_id') == claim1)
        .read<double>('review_priority');
    final p2 = priorities
        .firstWhere((r) => r.read<int>('claim_id') == claim2)
        .read<double>('review_priority');
    expect(p2, greaterThan(p1));
  });
}
