import 'package:drift/drift.dart';
import '../database.dart';

part 'audit_dao.g.dart';

// ---- 結果データクラス ----

class SegmentCoverageResult {
  const SegmentCoverageResult({
    required this.segId,
    required this.sourceId,
    required this.pageNumber,
    required this.contentPreview,
    required this.fileName,
    required this.evidenceCount,
    required this.unitCount,
    required this.examUnitIds,
  });

  final int segId;
  final int sourceId;
  final int pageNumber;
  final String contentPreview;
  final String fileName;
  final int evidenceCount;
  final int unitCount;
  final List<int> examUnitIds;

  /// Covered / Uncovered / Conflict を返す
  String get auditStatus {
    if (evidenceCount == 0) return 'uncovered';
    if (unitCount > 1) return 'conflict';
    return 'covered';
  }
}

// ---- DAO ----

@DriftAccessor(
  tables: [SourceSegments, Sources, EvidenceLinks, Claims],
)
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  /// 全セグメントのカバレッジをリアルタイム監視
  ///
  /// 各セグメントについて:
  /// - evidence_count = 0          → Uncovered
  /// - evidence_count > 0, units=1  → Covered
  /// - units > 1                   → Conflict（複数 Exam Unit が参照）
  Stream<List<SegmentCoverageResult>> watchCoverage() {
    return customSelect(
      '''
      SELECT
        ss.id              AS seg_id,
        ss.source_id,
        ss.page_number,
        SUBSTR(ss.content, 1, 300) AS content_preview,
        s.file_name,
        COUNT(DISTINCT el.id)              AS evidence_count,
        COUNT(DISTINCT c.exam_unit_id)     AS unit_count,
        GROUP_CONCAT(DISTINCT c.exam_unit_id) AS unit_ids
      FROM source_segments ss
      LEFT JOIN sources s
        ON s.id = ss.source_id
      LEFT JOIN evidence_links el
        ON el.source_segment_id = ss.id
      LEFT JOIN claims c
        ON c.id = el.claim_id
      GROUP BY ss.id
      ORDER BY s.file_name, ss.page_number
      ''',
      readsFrom: {sourceSegments, sources, evidenceLinks, claims},
    ).watch().map(
          (rows) => rows
              .map(
                (row) => SegmentCoverageResult(
                  segId: row.read<int>('seg_id'),
                  sourceId: row.read<int>('source_id'),
                  pageNumber: row.read<int>('page_number'),
                  contentPreview:
                      row.readNullable<String>('content_preview') ?? '',
                  fileName: row.readNullable<String>('file_name') ?? '—',
                  evidenceCount: row.read<int>('evidence_count'),
                  unitCount: row.read<int>('unit_count'),
                  examUnitIds: (row.readNullable<String>('unit_ids') ?? '')
                      .split(',')
                      .where((s) => s.isNotEmpty)
                      .map(int.parse)
                      .toList(),
                ),
              )
              .toList(),
        );
  }
}
