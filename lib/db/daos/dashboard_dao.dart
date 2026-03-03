import 'package:drift/drift.dart';
import '../database.dart';

part 'dashboard_dao.g.dart';

// ---- データクラス ----

class DashboardStats {
  const DashboardStats({
    required this.sourceCount,
    required this.totalPages,
    required this.examUnitCount,
    required this.claimCount,
  });

  final int sourceCount;
  final int totalPages;
  final int examUnitCount;
  final int claimCount;
}

class ConfidenceCount {
  const ConfidenceCount({required this.level, required this.count});
  final String level;
  final int count;
}

// ---- DAO ----

@DriftAccessor(
  tables: [Sources, SourceSegments, ExamUnits, Claims],
)
class DashboardDao extends DatabaseAccessor<AppDatabase>
    with _$DashboardDaoMixin {
  DashboardDao(super.db);

  /// ダッシュボード統計（全カウント）をリアルタイム監視
  Stream<DashboardStats> watchStats() {
    return customSelect(
      '''
      SELECT
        (SELECT COUNT(*) FROM sources)                       AS source_count,
        (SELECT COALESCE(SUM(page_count), 0) FROM sources)  AS total_pages,
        (SELECT COUNT(*) FROM exam_units)                    AS exam_unit_count,
        (SELECT COUNT(*) FROM claims)                        AS claim_count
      ''',
      readsFrom: {sources, examUnits, claims},
    ).watch().map((rows) {
      final row = rows.first;
      return DashboardStats(
        sourceCount: row.read<int>('source_count'),
        totalPages: row.read<int>('total_pages'),
        examUnitCount: row.read<int>('exam_unit_count'),
        claimCount: row.read<int>('claim_count'),
      );
    });
  }

  /// 信頼度の分布（GROUP BY confidence_level）をリアルタイム監視
  Stream<List<ConfidenceCount>> watchConfidenceDistribution() {
    return customSelect(
      '''
      SELECT confidence_level, COUNT(*) AS cnt
      FROM exam_units
      GROUP BY confidence_level
      ''',
      readsFrom: {examUnits},
    ).watch().map(
          (rows) => rows
              .map((row) => ConfidenceCount(
                    level: row.read<String>('confidence_level'),
                    count: row.read<int>('cnt'),
                  ))
              .toList(),
        );
  }

  /// 最近の Exam Unit（updatedAt 降順）
  Stream<List<ExamUnit>> watchRecentExamUnits(int limit) {
    return (select(examUnits)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .watch();
  }

  /// 最近取り込んだソース（importedAt 降順）
  Stream<List<Source>> watchRecentSources(int limit) {
    return (select(sources)
          ..orderBy([(t) => OrderingTerm.desc(t.importedAt)])
          ..limit(limit))
        .watch();
  }
}
