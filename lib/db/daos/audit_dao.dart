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

class AuditUnitSuggestion {
  const AuditUnitSuggestion({
    required this.unitId,
    required this.unitTitle,
    required this.score,
    required this.claimPreview,
  });

  final int unitId;
  final String unitTitle;
  final int score;
  final String claimPreview;
}

// ---- DAO ----

@DriftAccessor(
  tables: [
    SourceSegments,
    Sources,
    EvidenceLinks,
    Claims,
    Audits,
    Conflicts,
    EvidencePacks,
    EvidencePackItems,
    ExamUnits,
  ],
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
      WITH linked AS (
        SELECT el.source_segment_id AS source_segment_id, c.exam_unit_id AS exam_unit_id
        FROM evidence_links el
        JOIN claims c ON c.id = el.claim_id
        UNION ALL
        SELECT epi.source_segment_id AS source_segment_id, c.exam_unit_id AS exam_unit_id
        FROM evidence_pack_items epi
        JOIN evidence_packs ep ON ep.id = epi.evidence_pack_id
        JOIN claims c ON c.id = ep.claim_id
      )
      SELECT
        ss.id              AS seg_id,
        ss.source_id,
        ss.page_number,
        SUBSTR(ss.content, 1, 300) AS content_preview,
        s.file_name,
        COUNT(linked.exam_unit_id)              AS evidence_count,
        COUNT(DISTINCT linked.exam_unit_id)     AS unit_count,
        GROUP_CONCAT(DISTINCT linked.exam_unit_id) AS unit_ids
      FROM source_segments ss
      LEFT JOIN sources s
        ON s.id = ss.source_id
      LEFT JOIN linked
        ON linked.source_segment_id = ss.id
      GROUP BY ss.id
      ORDER BY s.file_name, ss.page_number
      ''',
      readsFrom: {
        sourceSegments,
        sources,
        evidenceLinks,
        claims,
        evidencePacks,
        evidencePackItems,
      },
    ).watch().map(
      (rows) => rows
          .map(
            (row) => SegmentCoverageResult(
              segId: row.read<int>('seg_id'),
              sourceId: row.read<int>('source_id'),
              pageNumber: row.read<int>('page_number'),
              contentPreview: row.readNullable<String>('content_preview') ?? '',
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

  /// EvidenceLinks / EvidencePackItems から audits を再計算して upsert する。
  /// 優先順位: Conflict(open) > LowConfidence > Partial > Covered
  Future<void> refreshCoverageAudits() async {
    await transaction(() async {
      await customStatement('''
        WITH linked AS (
          SELECT c.id AS claim_id, c.exam_unit_id AS exam_unit_id, el.source_segment_id AS source_segment_id, c.content_confidence AS content_confidence
          FROM claims c
          JOIN evidence_links el
            ON el.claim_id = c.id
          UNION ALL
          SELECT c.id AS claim_id, c.exam_unit_id AS exam_unit_id, epi.source_segment_id AS source_segment_id, c.content_confidence AS content_confidence
          FROM claims c
          JOIN evidence_packs ep
            ON ep.claim_id = c.id
          JOIN evidence_pack_items epi
            ON epi.evidence_pack_id = ep.id
        ),
        agg AS (
          SELECT
            exam_unit_id,
            source_segment_id,
            COUNT(*) AS evidence_count,
            MAX(CASE WHEN content_confidence = 'L' THEN 1 ELSE 0 END) AS has_low_confidence,
            CASE
              WHEN MAX(CASE WHEN content_confidence = 'L' THEN 1 ELSE 0 END) = 1 THEN 'L'
              WHEN MAX(CASE WHEN content_confidence = 'M' THEN 1 ELSE 0 END) = 1 THEN 'M'
              ELSE 'H'
            END AS merged_content_confidence
          FROM linked
          GROUP BY exam_unit_id, source_segment_id
        )
        INSERT INTO audits (
          source_segment_id,
          exam_unit_id,
          status,
          content_confidence,
          exam_confidence,
          created_at,
          updated_at
        )
        SELECT
          agg.source_segment_id,
          agg.exam_unit_id,
          CASE
            WHEN EXISTS (
              SELECT 1
              FROM conflicts cf
              WHERE cf.source_segment_id = agg.source_segment_id
                AND cf.exam_unit_id = agg.exam_unit_id
                AND cf.status = 'open'
            ) THEN 'Conflict'
            WHEN agg.has_low_confidence = 1 THEN 'LowConfidence'
            WHEN agg.evidence_count = 1 THEN 'Partial'
            ELSE 'Covered'
          END AS status,
          agg.merged_content_confidence,
          eu.exam_confidence,
          CAST(strftime('%s','now') AS INTEGER),
          CAST(strftime('%s','now') AS INTEGER)
        FROM agg
        JOIN exam_units eu
          ON eu.id = agg.exam_unit_id
        ON CONFLICT(source_segment_id, exam_unit_id) DO UPDATE SET
          status = excluded.status,
          content_confidence = excluded.content_confidence,
          exam_confidence = excluded.exam_confidence,
          updated_at = CAST(strftime('%s','now') AS INTEGER)
      ''');

      await customStatement('''
        UPDATE audits
        SET
          status = 'Uncovered',
          updated_at = CAST(strftime('%s','now') AS INTEGER)
        WHERE NOT EXISTS (
          SELECT 1
          FROM claims c
          LEFT JOIN evidence_links el
            ON el.claim_id = c.id
            AND el.source_segment_id = audits.source_segment_id
          LEFT JOIN evidence_packs ep
            ON ep.claim_id = c.id
          LEFT JOIN evidence_pack_items epi
            ON epi.evidence_pack_id = ep.id
            AND epi.source_segment_id = audits.source_segment_id
          WHERE c.exam_unit_id = audits.exam_unit_id
            AND (el.id IS NOT NULL OR epi.id IS NOT NULL)
        )
      ''');

      await customStatement('''
        UPDATE exam_units
        SET
          audit_status = CASE
            WHEN EXISTS (
              SELECT 1 FROM conflicts cf
              WHERE cf.exam_unit_id = exam_units.id
                AND cf.status = 'open'
            ) THEN 'Conflict'
            WHEN EXISTS (
              SELECT 1 FROM audits a
              WHERE a.exam_unit_id = exam_units.id
                AND a.status = 'LowConfidence'
            ) THEN 'LowConfidence'
            WHEN EXISTS (
              SELECT 1 FROM audits a
              WHERE a.exam_unit_id = exam_units.id
                AND a.status = 'Partial'
            ) THEN 'Partial'
            WHEN EXISTS (
              SELECT 1 FROM audits a
              WHERE a.exam_unit_id = exam_units.id
                AND a.status = 'Covered'
            ) THEN 'Covered'
            ELSE 'Uncovered'
          END,
          updated_at = CAST(strftime('%s','now') AS INTEGER)
      ''');
    });
  }

  Future<List<AuditUnitSuggestion>> suggestExamUnitsForSegment(
    int segmentId,
  ) async {
    final segment =
        await (select(sourceSegments)
              ..where((s) => s.id.equals(segmentId))
              ..limit(1))
            .getSingleOrNull();
    if (segment == null) return const [];

    final text = segment.content.toLowerCase();
    final rawTokens = text
        .split(RegExp(r'[^a-zA-Z0-9\u3040-\u30FF\u4E00-\u9FFF]+'))
        .where((t) => t.length >= 2)
        .toList();
    final tokens = <String>[];
    for (final token in rawTokens) {
      if (!tokens.contains(token)) {
        tokens.add(token);
      }
      if (tokens.length >= 8) break;
    }
    if (tokens.isEmpty) return const [];

    final units = await customSelect(
      '''
      SELECT eu.id AS unit_id, eu.title AS unit_title, COALESCE(GROUP_CONCAT(c.content, ' '), '') AS claims_text, COALESCE(MAX(c.content), '') AS claim_preview
      FROM exam_units eu
      LEFT JOIN claims c
        ON c.exam_unit_id = eu.id
      GROUP BY eu.id, eu.title
      ''',
      readsFrom: {examUnits, claims},
    ).get();

    final suggestions =
        units
            .map((row) {
              final unitId = row.read<int>('unit_id');
              final unitTitle = row.read<String>('unit_title');
              final claimsText = row.read<String>('claims_text').toLowerCase();
              var score = 0;
              for (final token in tokens) {
                if (unitTitle.toLowerCase().contains(token)) score += 3;
                if (claimsText.contains(token)) score += 2;
              }
              return AuditUnitSuggestion(
                unitId: unitId,
                unitTitle: unitTitle,
                score: score,
                claimPreview: row.read<String>('claim_preview'),
              );
            })
            .where((s) => s.score > 0)
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    return suggestions.take(5).toList();
  }

  Future<void> linkSegmentToUnit({
    required int segmentId,
    required int unitId,
  }) async {
    await transaction(() async {
      final segment =
          await (select(sourceSegments)
                ..where((s) => s.id.equals(segmentId))
                ..limit(1))
              .getSingle();
      var claim =
          await (select(claims)
                ..where((c) => c.examUnitId.equals(unitId))
                ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
                ..limit(1))
              .getSingleOrNull();
      if (claim == null) {
        final claimId = await into(claims).insert(
          ClaimsCompanion.insert(
            examUnitId: unitId,
            content: 'Coverage Audit から追加: p.${segment.pageNumber}',
            contentConfidence: const Value('M'),
            createdBy: const Value('ai'),
          ),
        );
        claim = await (select(
          claims,
        )..where((c) => c.id.equals(claimId))).getSingle();
      }
      final claimId = claim.id;

      await into(evidenceLinks).insert(
        EvidenceLinksCompanion.insert(
          claimId: claimId,
          sourceSegmentId: segmentId,
          note: const Value('Coverage Audit support link'),
        ),
        mode: InsertMode.insertOrIgnore,
      );

      var pack =
          await (select(evidencePacks)
                ..where((p) => p.claimId.equals(claimId))
                ..limit(1))
              .getSingleOrNull();
      if (pack == null) {
        final packId = await into(evidencePacks).insert(
          EvidencePacksCompanion.insert(
            claimId: claimId,
            contentConfidence: const Value('M'),
            examConfidence: const Value('M'),
          ),
        );
        pack = await (select(
          evidencePacks,
        )..where((p) => p.id.equals(packId))).getSingle();
      }

      final snippet = segment.content.trim();
      await into(evidencePackItems).insert(
        EvidencePackItemsCompanion.insert(
          evidencePackId: pack.id,
          sourceSegmentId: segmentId,
          pageNumber: Value(segment.pageNumber),
          snippet: Value(
            snippet.length <= 200 ? snippet : snippet.substring(0, 200),
          ),
        ),
        mode: InsertMode.insertOrIgnore,
      );

      await refreshCoverageAudits();
    });
  }
}
