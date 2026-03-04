import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

/// 1日の学習目標時間（分）
final dailyGoalMinutesProvider = StateProvider<int>((ref) => 120);
final studyPlanTopNProvider = StateProvider<int>((ref) => 20);
final examDateProvider = StateProvider<DateTime?>((ref) => null);

enum CramMode { off, h72, d7 }

final cramModeProvider = StateProvider<CramMode>((ref) => CramMode.off);

/// 全 StudyMethod のストリーム
final studyMethodsProvider = StreamProvider<List<StudyMethod>>(
  (ref) => ref.watch(databaseProvider).studyMethodsDao.watchAll(),
);

String _studyMethodKey(String unitType, String problemFormat) =>
    '$unitType::$problemFormat';

/// unitType + problemFormat → 推奨 StudyMethod のマップ（最初の1件）
final studyMethodsByKeyProvider = Provider<Map<String, StudyMethod>>((ref) {
  final methods = ref.watch(studyMethodsProvider).valueOrNull ?? [];
  final map = <String, StudyMethod>{};
  for (final m in methods) {
    final key = _studyMethodKey(m.unitType, m.problemFormat);
    map.putIfAbsent(key, () => m);
  }
  return map;
});

/// unitType → その unit_type の全 StudyMethod リスト
final studyMethodsByUnitTypeProvider =
    Provider<Map<String, List<StudyMethod>>>((ref) {
      final methods = ref.watch(studyMethodsProvider).valueOrNull ?? [];
      final map = <String, List<StudyMethod>>{};
      for (final m in methods) {
        map.putIfAbsent(m.unitType, () => []).add(m);
      }
      return map;
    });

StudyMethod? resolveRecommendedMethod(
  Map<String, StudyMethod> methodsByKey,
  ExamUnit unit,
) {
  return methodsByKey[_studyMethodKey(unit.unitType, unit.problemFormat)] ??
      methodsByKey[_studyMethodKey(unit.unitType, '選択肢')];
}

final unitMasteryStatsProvider = StreamProvider<Map<int, UnitMasteryStat>>((
  ref,
) {
  return ref.watch(databaseProvider).quizAttemptsDao.watchUnitMasteryStats();
});

final unitDueStatsProvider = StreamProvider<Map<int, UnitDueStat>>((ref) {
  return ref.watch(databaseProvider).quizAttemptsDao.watchUnitDueStats();
});

class UnitWeightFreqStat {
  const UnitWeightFreqStat({
    required this.pointWeight,
    required this.frequency,
  });
  final int pointWeight;
  final int frequency;
}

final unitWeightFreqStatsProvider =
    StreamProvider<Map<int, UnitWeightFreqStat>>((ref) {
      final db = ref.watch(databaseProvider);
      return db
          .customSelect(
            '''
      SELECT exam_unit_id, point_weight, frequency
      FROM unit_stats
      ''',
            readsFrom: {db.unitStats},
          )
          .watch()
          .map((rows) {
            final map = <int, UnitWeightFreqStat>{};
            for (final row in rows) {
              map[row.read<int>('exam_unit_id')] = UnitWeightFreqStat(
                pointWeight: row.read<int>('point_weight'),
                frequency: row.read<int>('frequency'),
              );
            }
            return map;
          });
    });

double computeUnmasteryScore(UnitMasteryStat? stat) {
  if (stat == null) return 0;
  return stat.wrongRate + (stat.attemptCount.clamp(0, 10) / 10);
}

class StudyPriorityInput {
  const StudyPriorityInput({
    required this.now,
    required this.mode,
    required this.examDate,
    required this.confidenceLevel,
    required this.mastery,
    required this.due,
    required this.weightFreq,
  });

  final DateTime now;
  final CramMode mode;
  final DateTime? examDate;
  final String confidenceLevel;
  final UnitMasteryStat? mastery;
  final UnitDueStat? due;
  final UnitWeightFreqStat? weightFreq;
}

double computeStudyPriority(StudyPriorityInput input) {
  const confidenceScore = {'low': 2.0, 'medium': 1.0, 'high': 0.0};
  var score =
      (confidenceScore[input.confidenceLevel] ?? 1.0) +
      computeUnmasteryScore(input.mastery);

  final due = input.due;
  if (due != null) {
    if (due.overdueCount > 0 || due.nextReviewAt.isBefore(input.now)) {
      score += 1000 + due.overdueCount.clamp(0, 10);
    } else if (due.nextReviewAt.isBefore(
      input.now.add(const Duration(hours: 24)),
    )) {
      score += 4;
    } else if (due.nextReviewAt.isBefore(
      input.now.add(const Duration(days: 3)),
    )) {
      score += 2;
    }
  }

  final wf = input.weightFreq;
  if (wf != null) {
    score += (wf.pointWeight - 1) * 0.6;
    score += (wf.frequency - 1) * 0.5;
  }

  if (input.mode != CramMode.off && input.examDate != null) {
    final remainingHours = input.examDate!
        .difference(input.now)
        .inHours
        .toDouble()
        .clamp(0, 24 * 365);
    final windowHours = input.mode == CramMode.h72 ? 72.0 : 24.0 * 7;
    final pressure = (1 - (remainingHours / windowHours)).clamp(0.0, 1.0);

    final isReview = due != null && due.scheduledCount > 0;
    if (input.mode == CramMode.h72) {
      score += isReview ? 4 : -4;
    } else {
      score += isReview ? 2 : -1;
    }

    final intervalHours = due?.avgIntervalHours ?? 24.0;
    score -= pressure * (intervalHours / 24.0) * 1.2;
  }
  return score;
}

/// 推奨学習ユニットリスト
/// 優先順位:
/// 1) 信頼度（low > medium > high）
/// 2) 未習熟度スコア（誤答率 + 回数）
/// 3) createdAt（古い順）
final recommendedUnitsProvider = StreamProvider<List<ExamUnit>>((ref) {
  final masteryByUnit = ref.watch(unitMasteryStatsProvider).valueOrNull ?? {};
  final dueByUnit = ref.watch(unitDueStatsProvider).valueOrNull ?? {};
  final wfByUnit = ref.watch(unitWeightFreqStatsProvider).valueOrNull ?? {};
  final mode = ref.watch(cramModeProvider);
  final examDate = ref.watch(examDateProvider);
  return ref.watch(databaseProvider).examUnitsDao.watchAll().map((units) {
    final sorted = [...units];
    sorted.sort((a, b) {
      final now = DateTime.now();
      final sa = computeStudyPriority(
        StudyPriorityInput(
          now: now,
          mode: mode,
          examDate: examDate,
          confidenceLevel: a.confidenceLevel,
          mastery: masteryByUnit[a.id],
          due: dueByUnit[a.id],
          weightFreq: wfByUnit[a.id],
        ),
      );
      final sb = computeStudyPriority(
        StudyPriorityInput(
          now: now,
          mode: mode,
          examDate: examDate,
          confidenceLevel: b.confidenceLevel,
          mastery: masteryByUnit[b.id],
          due: dueByUnit[b.id],
          weightFreq: wfByUnit[b.id],
        ),
      );

      if (sa != sb) return sb.compareTo(sa);
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  });
});
