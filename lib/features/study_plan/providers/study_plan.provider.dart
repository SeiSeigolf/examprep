import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

/// 1日の学習目標時間（分）
final dailyGoalMinutesProvider = StateProvider<int>((ref) => 120);

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

double computeUnmasteryScore(UnitMasteryStat? stat) {
  if (stat == null) return 0;
  return stat.wrongRate + (stat.attemptCount.clamp(0, 10) / 10);
}

/// 推奨学習ユニットリスト
/// 優先順位:
/// 1) 信頼度（low > medium > high）
/// 2) 未習熟度スコア（誤答率 + 回数）
/// 3) createdAt（古い順）
final recommendedUnitsProvider = StreamProvider<List<ExamUnit>>((ref) {
  final masteryByUnit = ref.watch(unitMasteryStatsProvider).valueOrNull ?? {};
  final dueByUnit = ref.watch(unitDueStatsProvider).valueOrNull ?? {};
  return ref.watch(databaseProvider).examUnitsDao.watchAll().map((units) {
    const confidenceScore = {'low': 2.0, 'medium': 1.0, 'high': 0.0};
    final sorted = [...units];
    sorted.sort((a, b) {
      final ma = masteryByUnit[a.id];
      final mb = masteryByUnit[b.id];
      final ua = computeUnmasteryScore(ma);
      final ub = computeUnmasteryScore(mb);
      final da = _duePriority(dueByUnit[a.id]);
      final db = _duePriority(dueByUnit[b.id]);

      final sa = (confidenceScore[a.confidenceLevel] ?? 1.0) + ua + da;
      final sb = (confidenceScore[b.confidenceLevel] ?? 1.0) + ub + db;

      if (sa != sb) return sb.compareTo(sa);
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  });
});

double _duePriority(UnitDueStat? stat) {
  if (stat == null) return 0;
  final now = DateTime.now();
  if (stat.overdueCount > 0 || stat.nextReviewAt.isBefore(now)) {
    return 4 + (stat.overdueCount.clamp(0, 5) * 0.3);
  }
  if (stat.nextReviewAt.isBefore(now.add(const Duration(hours: 24)))) {
    return 2;
  }
  return 0;
}
