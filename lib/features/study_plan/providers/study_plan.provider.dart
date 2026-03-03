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

/// 推奨学習ユニットリスト
/// 優先順位: low confidence → medium → high
/// 同一 confidence 内は createdAt 昇順（古い順）
final recommendedUnitsProvider = StreamProvider<List<ExamUnit>>((ref) {
  return ref.watch(databaseProvider).examUnitsDao.watchAll().map((units) {
    const order = {'low': 0, 'medium': 1, 'high': 2};
    final sorted = [...units];
    sorted.sort((a, b) {
      final ca = order[a.confidenceLevel] ?? 1;
      final cb = order[b.confidenceLevel] ?? 1;
      if (ca != cb) return ca.compareTo(cb);
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  });
});
