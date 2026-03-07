import 'package:drift/drift.dart' show Variable;

import '../../../db/database.dart';

// ============================================================
// Data classes
// ============================================================

class CoverageSummary {
  const CoverageSummary({
    required this.coveredCount,
    required this.partialCount,
    required this.uncoveredCount,
    required this.conflictCount,
    required this.lowConfidenceCount,
    required this.coveragePercent,
    required this.totalCount,
    required this.evidenceCount,
  });

  final int coveredCount;
  final int partialCount;
  final int uncoveredCount;
  final int conflictCount;
  final int lowConfidenceCount;
  final int coveragePercent;
  final int totalCount;
  final int evidenceCount;
}

class GroupCoverageRow {
  const GroupCoverageRow({
    required this.sourceGroup,
    required this.unitCount,
    required this.totalCount,
  });

  final String sourceGroup;
  final int unitCount;
  final int totalCount;

  int get coveragePercent =>
      totalCount > 0 ? ((unitCount / totalCount) * 100).round() : 0;
}

class UnitScoreRow {
  const UnitScoreRow({
    required this.unitId,
    required this.title,
    required this.unitType,
    required this.problemFormat,
    required this.auditStatus,
    required this.confidenceLevel,
    required this.pointWeight,
    required this.frequency,
  });

  final int unitId;
  final String title;
  final String unitType;
  final String problemFormat;
  final String auditStatus;
  final String confidenceLevel;
  final int pointWeight;
  final int frequency;

  int get expectedScore => pointWeight * frequency;
}

class EvidenceRecord {
  const EvidenceRecord({
    required this.fileName,
    required this.filePath,
    required this.pageNumber,
    required this.snippet,
    this.quality,
    this.sourceGroup,
  });

  final String fileName;
  final String filePath;
  final int pageNumber;
  final String snippet;
  final double? quality;
  final String? sourceGroup;

  String get fileUrl {
    final path = filePath.startsWith('/') ? filePath : '/$filePath';
    return 'file://$path';
  }
}

// ============================================================
// Service
// ============================================================

class CoverageMetricsService {
  // ---------- Coverage Summary ----------

  static Future<CoverageSummary> getCoverageSummary(
    AppDatabase db,
    int examProfileId,
  ) async {
    final row = await db
        .customSelect(
          '''
          SELECT
            COUNT(*) AS total,
            SUM(CASE WHEN eu.audit_status = 'Covered' THEN 1 ELSE 0 END) AS covered,
            SUM(CASE WHEN eu.audit_status = 'Partial' THEN 1 ELSE 0 END) AS partial,
            SUM(CASE WHEN eu.audit_status = 'Uncovered' THEN 1 ELSE 0 END) AS uncovered,
            SUM(CASE WHEN eu.audit_status = 'Conflict' THEN 1 ELSE 0 END) AS conflict,
            SUM(CASE WHEN eu.audit_status = 'LowConfidence' THEN 1 ELSE 0 END) AS low_conf
          FROM exam_units eu
          JOIN exam_profile_units epu ON epu.exam_unit_id = eu.id
          WHERE epu.exam_profile_id = ?1
          ''',
          variables: [Variable.withInt(examProfileId)],
          readsFrom: {db.examUnits},
        )
        .getSingle();

    final total = row.read<int>('total');
    final covered = row.read<int>('covered');
    final partial = row.read<int>('partial');
    final pct =
        total > 0 ? (((covered + partial) / total) * 100).round() : 0;

    final evRow = await db
        .customSelect(
          '''
          SELECT
            COALESCE((
              SELECT COUNT(*)
              FROM evidence_links el
              JOIN claims c ON c.id = el.claim_id
              JOIN exam_profile_units epu ON epu.exam_unit_id = c.exam_unit_id
              WHERE epu.exam_profile_id = ?1
            ), 0) +
            COALESCE((
              SELECT COUNT(*)
              FROM evidence_pack_items epi
              JOIN evidence_packs ep ON ep.id = epi.evidence_pack_id
              JOIN claims c ON c.id = ep.claim_id
              JOIN exam_profile_units epu ON epu.exam_unit_id = c.exam_unit_id
              WHERE epu.exam_profile_id = ?1
            ), 0) AS evidence_count
          ''',
          variables: [Variable.withInt(examProfileId)],
        )
        .getSingle();

    return CoverageSummary(
      coveredCount: covered,
      partialCount: partial,
      uncoveredCount: row.read<int>('uncovered'),
      conflictCount: row.read<int>('conflict'),
      lowConfidenceCount: row.read<int>('low_conf'),
      coveragePercent: pct,
      totalCount: total,
      evidenceCount: evRow.read<int>('evidence_count'),
    );
  }

  // ---------- Group Coverage ----------

  static Future<List<GroupCoverageRow>> getGroupCoverage(
    AppDatabase db,
    int examProfileId,
  ) async {
    final totalRow = await db
        .customSelect(
          'SELECT COUNT(*) AS total FROM exam_profile_units WHERE exam_profile_id = ?1',
          variables: [Variable.withInt(examProfileId)],
        )
        .getSingle();
    final total = totalRow.read<int>('total');
    if (total == 0) return const [];

    // (unit_id, source_group) ペアを取得して集計
    final rows = await db
        .customSelect(
          '''
          SELECT s.source_group, COUNT(DISTINCT links.unit_id) AS unit_count
          FROM sources s
          JOIN source_segments ss ON ss.source_id = s.id
          JOIN (
            SELECT el.source_segment_id AS seg_id, c.exam_unit_id AS unit_id
            FROM evidence_links el
            JOIN claims c ON c.id = el.claim_id
            UNION
            SELECT epi.source_segment_id AS seg_id, c.exam_unit_id AS unit_id
            FROM evidence_pack_items epi
            JOIN evidence_packs ep ON ep.id = epi.evidence_pack_id
            JOIN claims c ON c.id = ep.claim_id
          ) links ON links.seg_id = ss.id
          JOIN exam_profile_units epu ON epu.exam_unit_id = links.unit_id
            AND epu.exam_profile_id = ?1
          GROUP BY s.source_group
          ORDER BY unit_count DESC
          ''',
          variables: [Variable.withInt(examProfileId)],
          readsFrom: {db.sources, db.sourceSegments},
        )
        .get();

    return rows
        .map(
          (r) => GroupCoverageRow(
            sourceGroup: r.read<String>('source_group'),
            unitCount: r.read<int>('unit_count'),
            totalCount: total,
          ),
        )
        .toList();
  }

  // ---------- Unit Scores ----------

  static Future<List<UnitScoreRow>> getUnitScores(
    AppDatabase db,
    int examProfileId, {
    int limit = 50,
  }) async {
    final rows = await db
        .customSelect(
          '''
          SELECT
            eu.id,
            eu.title,
            eu.unit_type,
            eu.problem_format,
            eu.audit_status,
            eu.confidence_level,
            COALESCE(us.point_weight, 1) AS point_weight,
            COALESCE(us.frequency, 1) AS frequency
          FROM exam_units eu
          JOIN exam_profile_units epu ON epu.exam_unit_id = eu.id
            AND epu.exam_profile_id = ?1
          LEFT JOIN unit_stats us ON us.exam_unit_id = eu.id
          ORDER BY (COALESCE(us.point_weight, 1) * COALESCE(us.frequency, 1)) DESC,
                   eu.id ASC
          LIMIT ?2
          ''',
          variables: [
            Variable.withInt(examProfileId),
            Variable.withInt(limit),
          ],
          readsFrom: {db.examUnits, db.unitStats},
        )
        .get();

    return rows
        .map(
          (r) => UnitScoreRow(
            unitId: r.read<int>('id'),
            title: r.read<String>('title'),
            unitType: r.read<String>('unit_type'),
            problemFormat: r.read<String>('problem_format'),
            auditStatus: r.read<String>('audit_status'),
            confidenceLevel: r.read<String>('confidence_level'),
            pointWeight: r.read<int>('point_weight'),
            frequency: r.read<int>('frequency'),
          ),
        )
        .toList();
  }

  // ---------- Top Evidence for Unit ----------

  static Future<List<EvidenceRecord>> getTopEvidenceForUnit(
    AppDatabase db,
    int unitId, {
    int limit = 3,
  }) async {
    final rows = await db
        .customSelect(
          '''
          SELECT
            s.file_name,
            s.file_path,
            s.source_group,
            COALESCE(epi.page_number, ss.page_number) AS page_number,
            COALESCE(epi.snippet, SUBSTR(ss.content, 1, 200)) AS snippet,
            s.last_quality_score AS quality
          FROM claims c
          JOIN evidence_packs ep ON ep.claim_id = c.id
          JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id
          JOIN source_segments ss ON ss.id = epi.source_segment_id
          JOIN sources s ON s.id = ss.source_id
          WHERE c.exam_unit_id = ?1
          ORDER BY COALESCE(epi.weight, 1) DESC
          LIMIT ?2
          ''',
          variables: [Variable.withInt(unitId), Variable.withInt(limit)],
          readsFrom: {
            db.claims,
            db.evidencePacks,
            db.evidencePackItems,
            db.sourceSegments,
            db.sources,
          },
        )
        .get();

    if (rows.isNotEmpty) {
      return _toEvidenceList(rows);
    }

    // fallback: evidence_links
    final fallback = await db
        .customSelect(
          '''
          SELECT
            s.file_name,
            s.file_path,
            s.source_group,
            ss.page_number,
            SUBSTR(ss.content, 1, 200) AS snippet,
            s.last_quality_score AS quality
          FROM claims c
          JOIN evidence_links el ON el.claim_id = c.id
          JOIN source_segments ss ON ss.id = el.source_segment_id
          JOIN sources s ON s.id = ss.source_id
          WHERE c.exam_unit_id = ?1
          ORDER BY ss.page_number ASC
          LIMIT ?2
          ''',
          variables: [Variable.withInt(unitId), Variable.withInt(limit)],
          readsFrom: {
            db.claims,
            db.evidenceLinks,
            db.sourceSegments,
            db.sources,
          },
        )
        .get();

    return _toEvidenceList(fallback);
  }

  static List<EvidenceRecord> _toEvidenceList(
    List<dynamic> rows,
  ) {
    final seen = <String>{};
    final out = <EvidenceRecord>[];
    for (final r in rows) {
      final key =
          '${r.read<String>('file_path')}:${r.read<int>('page_number')}';
      if (seen.contains(key)) continue;
      seen.add(key);
      out.add(
        EvidenceRecord(
          fileName: r.read<String>('file_name'),
          filePath: r.read<String>('file_path'),
          pageNumber: r.read<int>('page_number'),
          snippet: _normalizeSnippet(r.read<String>('snippet')),
          quality: r.readNullable<double>('quality'),
          sourceGroup: r.readNullable<String>('source_group'),
        ),
      );
    }
    return out;
  }

  // ---------- Units by Group ----------

  static Future<List<ExamUnit>> getUnitsByGroup(
    AppDatabase db,
    int examProfileId,
    String sourceGroup,
  ) async {
    final rows = await db
        .customSelect(
          '''
          SELECT DISTINCT eu.*
          FROM exam_units eu
          JOIN exam_profile_units epu ON epu.exam_unit_id = eu.id
            AND epu.exam_profile_id = ?1
          JOIN claims c ON c.exam_unit_id = eu.id
          WHERE EXISTS (
            SELECT 1 FROM evidence_links el
            JOIN source_segments ss ON ss.id = el.source_segment_id
            JOIN sources s ON s.id = ss.source_id
            WHERE el.claim_id = c.id AND s.source_group = ?2
          )
          OR EXISTS (
            SELECT 1 FROM evidence_packs ep
            JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id
            JOIN source_segments ss ON ss.id = epi.source_segment_id
            JOIN sources s ON s.id = ss.source_id
            WHERE ep.claim_id = c.id AND s.source_group = ?2
          )
          ORDER BY eu.sort_order ASC, eu.id ASC
          ''',
          variables: [
            Variable.withInt(examProfileId),
            Variable.withString(sourceGroup),
          ],
          readsFrom: {
            db.examUnits,
            db.claims,
            db.evidenceLinks,
            db.evidencePacks,
            db.evidencePackItems,
            db.sourceSegments,
            db.sources,
          },
        )
        .get();

    return rows.map((r) => db.examUnits.map(r.data)).toList();
  }

  // ---------- Claims for Unit ----------

  static Future<List<String>> getClaimsForUnit(
    AppDatabase db,
    int unitId, {
    int limit = 5,
  }) async {
    final rows = await db
        .customSelect(
          '''
          SELECT content FROM claims
          WHERE exam_unit_id = ?1
          ORDER BY created_at ASC
          LIMIT ?2
          ''',
          variables: [Variable.withInt(unitId), Variable.withInt(limit)],
          readsFrom: {db.claims},
        )
        .get();
    return rows.map((r) => r.read<String>('content')).toList();
  }

  // ---------- Study Method ----------

  static Future<String?> getStudyMethodName(
    AppDatabase db,
    String unitType,
    String problemFormat,
  ) async {
    final row = await db
        .customSelect(
          '''
          SELECT method_name FROM study_methods
          WHERE unit_type = ?1 AND problem_format = ?2
          LIMIT 1
          ''',
          variables: [
            Variable.withString(unitType),
            Variable.withString(problemFormat),
          ],
          readsFrom: {db.studyMethods},
        )
        .getSingleOrNull();
    if (row != null) return row.read<String>('method_name');

    // unit_type だけで fallback
    final fallback = await db
        .customSelect(
          '''
          SELECT method_name FROM study_methods
          WHERE unit_type = ?1
          ORDER BY id ASC
          LIMIT 1
          ''',
          variables: [Variable.withString(unitType)],
          readsFrom: {db.studyMethods},
        )
        .getSingleOrNull();
    return fallback?.read<String>('method_name');
  }

  // ---------- Helpers ----------

  static String _normalizeSnippet(String text) {
    final s = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s.length <= 200 ? s : '${s.substring(0, 200)}...';
  }
}
