import 'package:exam_os/db/daos/quiz_attempts_dao.dart';
import 'package:exam_os/features/study_plan/providers/study_plan.provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('直前モードでは期限切れ最優先かつ72hで復習優先になる', () {
    final now = DateTime(2026, 3, 3, 12);
    final exam = now.add(const Duration(hours: 24));

    final overdueReview = computeStudyPriority(
      StudyPriorityInput(
        now: now,
        mode: CramMode.h72,
        examDate: exam,
        confidenceLevel: 'medium',
        mastery: const UnitMasteryStat(
          examUnitId: 1,
          attemptCount: 5,
          wrongCount: 3,
          wrongRate: 0.6,
          mastery: 0.4,
        ),
        due: UnitDueStat(
          examUnitId: 1,
          nextReviewAt: now.subtract(const Duration(hours: 1)),
          overdueCount: 2,
          scheduledCount: 5,
          avgIntervalHours: 48,
        ),
        weightFreq: const UnitWeightFreqStat(pointWeight: 3, frequency: 3),
      ),
    );

    final newLearning = computeStudyPriority(
      StudyPriorityInput(
        now: now,
        mode: CramMode.h72,
        examDate: exam,
        confidenceLevel: 'low',
        mastery: null,
        due: null,
        weightFreq: const UnitWeightFreqStat(pointWeight: 1, frequency: 1),
      ),
    );

    final longIntervalReview = computeStudyPriority(
      StudyPriorityInput(
        now: now,
        mode: CramMode.d7,
        examDate: now.add(const Duration(hours: 30)),
        confidenceLevel: 'medium',
        mastery: const UnitMasteryStat(
          examUnitId: 2,
          attemptCount: 2,
          wrongCount: 1,
          wrongRate: 0.5,
          mastery: 0.5,
        ),
        due: UnitDueStat(
          examUnitId: 2,
          nextReviewAt: now.add(const Duration(hours: 10)),
          overdueCount: 0,
          scheduledCount: 4,
          avgIntervalHours: 240,
        ),
        weightFreq: const UnitWeightFreqStat(pointWeight: 1, frequency: 1),
      ),
    );

    final shortIntervalHighWeight = computeStudyPriority(
      StudyPriorityInput(
        now: now,
        mode: CramMode.d7,
        examDate: now.add(const Duration(hours: 30)),
        confidenceLevel: 'medium',
        mastery: const UnitMasteryStat(
          examUnitId: 3,
          attemptCount: 2,
          wrongCount: 1,
          wrongRate: 0.5,
          mastery: 0.5,
        ),
        due: UnitDueStat(
          examUnitId: 3,
          nextReviewAt: now.add(const Duration(hours: 10)),
          overdueCount: 0,
          scheduledCount: 4,
          avgIntervalHours: 24,
        ),
        weightFreq: const UnitWeightFreqStat(pointWeight: 4, frequency: 4),
      ),
    );

    expect(overdueReview, greaterThan(newLearning));
    expect(shortIntervalHighWeight, greaterThan(longIntervalReview));
  });
}
