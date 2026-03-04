import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

/// 全試験リスト
final examsProvider = StreamProvider<List<Exam>>(
  (ref) => ref.watch(databaseProvider).examsDao.watchAll(),
);

/// 試験が1件以上登録されているか（ウィザード vs ダッシュボード切り替え用）
final hasAnyExamProvider = Provider<bool>(
  (ref) => (ref.watch(examsProvider).valueOrNull ?? []).isNotEmpty,
);

/// 現在選択中の試験 ID
final selectedExamIdProvider = StateProvider<int?>((ref) => null);

/// 選択試験のセクション一覧
final sectionsForSelectedExamProvider = StreamProvider<List<ExamSection>>((
  ref,
) {
  final examId = ref.watch(selectedExamIdProvider);
  if (examId == null) return const Stream.empty();
  return ref.watch(databaseProvider).examsDao.watchSectionsForExam(examId);
});

/// セクション別カバレッジ（family: examId）
final sectionCoverageProvider =
    StreamProvider.family<List<SectionCoverageStat>, int>((ref, examId) {
      return ref.watch(databaseProvider).examsDao.watchSectionCoverage(examId);
    });
