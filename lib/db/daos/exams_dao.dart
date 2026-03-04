import 'package:drift/drift.dart';
import '../database.dart';

part 'exams_dao.g.dart';

class SectionCoverageStat {
  const SectionCoverageStat({
    required this.section,
    required this.pools,
    required this.totalUnits,
    required this.coveredUnits,
    required this.lowConfUnits,
  });

  final ExamSection section;
  final List<ExamPool> pools;
  final int totalUnits;
  final int coveredUnits; // auditStatus = 'Covered' or 'Partial'
  final int lowConfUnits; // confidenceLevel = 'low'
}

@DriftAccessor(tables: [Exams, ExamSections, ExamPools, ExamUnits])
class ExamsDao extends DatabaseAccessor<AppDatabase> with _$ExamsDaoMixin {
  ExamsDao(super.db);

  // ---- Exams CRUD ----

  Stream<List<Exam>> watchAll() =>
      (select(exams)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();

  Future<List<Exam>> getAll() =>
      (select(exams)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<int> insertExam(ExamsCompanion c) => into(exams).insert(c);

  Future<void> updateExam(ExamsCompanion c) =>
      (update(exams)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> deleteExam(int id) => transaction(() async {
    // sections を取得して pool を先に削除（CASCADE 未設定なため手動）
    final sections = await (select(examSections)
          ..where((t) => t.examId.equals(id)))
        .get();
    for (final s in sections) {
      await (delete(examPools)..where((t) => t.sectionId.equals(s.id))).go();
    }
    await (delete(examSections)..where((t) => t.examId.equals(id))).go();
    await (delete(exams)..where((t) => t.id.equals(id))).go();
  });

  // ---- ExamSections CRUD ----

  Stream<List<ExamSection>> watchSectionsForExam(int examId) =>
      (select(examSections)
            ..where((t) => t.examId.equals(examId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .watch();

  Future<List<ExamSection>> getSectionsForExam(int examId) =>
      (select(examSections)
            ..where((t) => t.examId.equals(examId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();

  Future<int> insertSection(ExamSectionsCompanion c) =>
      into(examSections).insert(c);

  Future<void> updateSection(ExamSectionsCompanion c) =>
      (update(examSections)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> deleteSection(int id) => transaction(() async {
    await (delete(examPools)..where((t) => t.sectionId.equals(id))).go();
    await (delete(examSections)..where((t) => t.id.equals(id))).go();
  });

  // ---- ExamPools CRUD ----

  Stream<List<ExamPool>> watchPoolsForSection(int sectionId) =>
      (select(examPools)
            ..where((t) => t.sectionId.equals(sectionId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<List<ExamPool>> getPoolsForSection(int sectionId) =>
      (select(examPools)
            ..where((t) => t.sectionId.equals(sectionId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<int> insertPool(ExamPoolsCompanion c) => into(examPools).insert(c);

  Future<void> updatePool(ExamPoolsCompanion c) =>
      (update(examPools)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> deletePool(int id) =>
      (delete(examPools)..where((t) => t.id.equals(id))).go();

  // ---- Section Coverage ----

  /// 指定試験の全セクションのカバレッジ統計を返す
  Stream<List<SectionCoverageStat>> watchSectionCoverage(int examId) {
    // sections の変更 or examUnits の変更で再計算
    return (select(examSections)
          ..where((t) => t.examId.equals(examId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch()
        .asyncMap((sections) async {
          final stats = <SectionCoverageStat>[];
          for (final section in sections) {
            final pools = await getPoolsForSection(section.id);
            final units = await (select(examUnits)
                  ..where((t) => t.sectionId.equals(section.id)))
                .get();
            final covered = units.where((u) =>
                u.auditStatus == 'Covered' || u.auditStatus == 'Partial').length;
            final lowConf = units.where(
              (u) => u.confidenceLevel == 'low',
            ).length;
            stats.add(
              SectionCoverageStat(
                section: section,
                pools: pools,
                totalUnits: units.length,
                coveredUnits: covered,
                lowConfUnits: lowConf,
              ),
            );
          }
          return stats;
        });
  }

  Future<List<SectionCoverageStat>> getSectionCoverage(int examId) =>
      watchSectionCoverage(examId).first;
}
