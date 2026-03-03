import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/db/database.provider.dart';
import 'package:exam_os/features/review_queue/providers/review_queue.provider.dart';
import 'package:exam_os/features/study_plan/providers/study_plan.provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  test('quiz_attempts で間隔反復と優先度反映が動く', () async {
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
    final schedules = await db.select(db.claimReviewSchedules).get();
    final s1 = schedules.firstWhere((s) => s.claimId == claim1);
    final s2 = schedules.firstWhere((s) => s.claimId == claim2);
    expect(s1.intervalHours, greaterThan(s2.intervalHours)); // 正解で伸びる
    expect(s2.intervalHours, 6); // 不正解で短縮

    await (db.update(
      db.claimReviewSchedules,
    )..where((s) => s.claimId.equals(claim2))).write(
      ClaimReviewSchedulesCompanion(
        nextReviewAt: Value(DateTime.now().subtract(const Duration(hours: 1))),
      ),
    );

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final queue = await container.read(reviewQueueProvider.future);
    final top = queue.first;
    expect(top.claimId, claim2);
    expect(buildReviewReason(top), contains('期限切れレビュー'));
  });
}
