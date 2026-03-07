import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/database.dart';

class MasterCoverageExportInput {
  const MasterCoverageExportInput({
    required this.examName,
    required this.sourceIds,
    required this.focusUnitIds,
    required this.autoMergedCount,
    this.examProfileId,
    this.examDate,
    this.subject,
  });

  final String examName;
  final DateTime? examDate;
  final String? subject;
  final List<int> sourceIds;
  final List<int> focusUnitIds;
  final int autoMergedCount;
  final int? examProfileId;
}

class MasterCoverageSummary {
  const MasterCoverageSummary({
    required this.coveragePercent,
    required this.uncoveredCount,
    required this.conflictCount,
    required this.lowConfidenceCount,
  });

  final int coveragePercent;
  final int uncoveredCount;
  final int conflictCount;
  final int lowConfidenceCount;
}

class MasterCoverageExportResult {
  const MasterCoverageExportResult({required this.path, required this.summary});

  final String path;
  final MasterCoverageSummary summary;
}

class MasterCoverageSheetExporter {
  static Future<MasterCoverageExportResult> export(
    AppDatabase db,
    MasterCoverageExportInput input,
  ) async {
    final generated = await generateMarkdown(db, input);

    String? savePath;
    try {
      final location = await getSaveLocation(
        suggestedName: 'master_coverage_sheet.md',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Markdown', extensions: ['md']),
        ],
      );
      savePath = location?.path;
    } catch (_) {}

    if (savePath == null) {
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      savePath = '${dir.path}/master_coverage_$ts.md';
    }

    await File(savePath).writeAsString(generated.markdown);
    return MasterCoverageExportResult(
      path: savePath,
      summary: generated.summary,
    );
  }

  static Future<({String markdown, MasterCoverageSummary summary})>
  generateMarkdown(
    AppDatabase db,
    MasterCoverageExportInput input, {
    DateTime? now,
  }) async {
    final nowAt = now ?? DateTime.now();

    final targetUnits = await _loadTargetUnits(db, input);
    final scopedSourceIds = input.examProfileId == null
        ? input.sourceIds.toSet().toList()
        : await loadSourceIdsByProfile(db, input.examProfileId!);
    final sourceById = await _loadSourceMap(db, scopedSourceIds);
    final claimRows = await _loadClaimsByUnit(
      db,
      targetUnits.map((u) => u.id).toList(),
    );
    final methodRows = await db.studyMethodsDao.getAll();
    final methodByKey = <String, StudyMethod>{
      for (final m in methodRows) '${m.unitType}::${m.problemFormat}': m,
    };
    final methodsByUnitType = <String, List<StudyMethod>>{};
    for (final m in methodRows) {
      (methodsByUnitType[m.unitType] ??= []).add(m);
    }

    final wfByUnit = await _loadWeightFrequency(
      db,
      targetUnits.map((u) => u.id).toList(),
    );
    final summary = _buildSummary(targetUnits);

    final b = StringBuffer();
    b.writeln('# ${input.examName} Master Coverage Sheet');
    b.writeln('生成日時: ${nowAt.toLocal().toString().substring(0, 16)}');
    if (input.subject != null && input.subject!.trim().isNotEmpty) {
      b.writeln('科目: ${input.subject!.trim()}');
    }
    if (input.examDate != null) {
      b.writeln(
        '試験日: ${input.examDate!.toLocal().toString().substring(0, 10)}',
      );
    }
    b.writeln();
    b.writeln('## 完成度サマリ');
    b.writeln('- Coverage: ${summary.coveragePercent}%');
    b.writeln('- Uncovered: ${summary.uncoveredCount}');
    b.writeln('- Conflict: ${summary.conflictCount}');
    b.writeln('- LowConfidence: ${summary.lowConfidenceCount}');
    b.writeln('- 重複統合: ${input.autoMergedCount}');
    b.writeln();
    const conflictThreshold = 5;
    const lowConfidenceThreshold = 10;
    final isReady =
        summary.uncoveredCount == 0 &&
        summary.conflictCount <= conflictThreshold &&
        summary.lowConfidenceCount <= lowConfidenceThreshold;
    b.writeln('## 完成判定');
    b.writeln(
      '- しきい値: Conflict <= $conflictThreshold / LowConfidence <= $lowConfidenceThreshold',
    );
    if (isReady) {
      b.writeln('- 判定: Ready');
      b.writeln('- この資料で学習開始OK');
    } else {
      b.writeln('- 判定: Not Ready');
      b.writeln('- 次にやること:');
      b.writeln('  1. Uncovered解消');
      b.writeln('  2. Conflict確認');
      b.writeln('  3. LowConfidence補強');
    }
    b.writeln();

    final sorted = [...targetUnits]
      ..sort((a, b) {
        final awf = wfByUnit[a.id] ?? (1, 1);
        final bwf = wfByUnit[b.id] ?? (1, 1);
        final ap = _priorityScore(a, awf.$1, awf.$2);
        final bp = _priorityScore(b, bwf.$1, bwf.$2);
        if (ap != bp) return bp.compareTo(ap);
        return a.createdAt.compareTo(b.createdAt);
      });

    for (var i = 0; i < sorted.length; i++) {
      final unit = sorted[i];
      final wf = wfByUnit[unit.id] ?? (1, 1);
      final freqText = wf.$2 > 0
          ? 'frequency=${wf.$2} (past_exam根拠ベース)'
          : 'frequency=0';
      final claims = claimRows[unit.id] ?? const <_ClaimRecord>[];
      final evidence = await _topEvidenceForUnit(db, unit.id, sourceById);
      final method = methodByKey['${unit.unitType}::${unit.problemFormat}'];
      final subMethods =
          methodsByUnitType[unit.unitType] ?? const <StudyMethod>[];
      final reasons = <String>[];
      if (unit.auditStatus == 'Conflict') reasons.add('Conflict');
      if (unit.auditStatus == 'LowConfidence') reasons.add('LowConfidence');
      if (unit.auditStatus == 'Partial' || unit.auditStatus == 'Uncovered') {
        reasons.add('根拠不足');
      }
      if (evidence.any((e) => (e.quality ?? 0) < 0.5)) {
        reasons.add('抽出品質低');
      }

      b.writeln('## ${i + 1}. ${unit.title}');
      b.writeln('- Unit: ${unit.unitType} / ${unit.problemFormat}');
      b.writeln('- 出題率: $freqText');
      b.writeln(
        '- 推奨勉強法: ${[if (method != null) method.methodName, ...subMethods.map((m) => m.methodName).where((name) => method == null || name != method.methodName).take(2)].join(' / ')}',
      );
      b.writeln('- 監査ステータス: ${unit.auditStatus}');
      if (reasons.isNotEmpty) {
        b.writeln('- 要確認: ${reasons.join(', ')}');
      }

      b.writeln('- Claims:');
      if (claims.isEmpty) {
        b.writeln('  - (なし)');
      } else {
        for (final c in claims.take(5)) {
          b.writeln('  - ${_trim(c.content, 180)}');
        }
      }

      b.writeln('- 根拠(上位3件):');
      if (evidence.isEmpty) {
        b.writeln('  - (なし)');
      } else {
        for (final e in evidence.take(3)) {
          b.writeln(
            '  - ${e.fileName} p.${e.pageNumber}: ${_trim(e.snippet, 140)} | file://${e.filePath}',
          );
        }
      }

      b.writeln();
    }

    if (sorted.isEmpty) {
      b.writeln('> 対象Unitがありません。PDFまたは対象ソースを見直してください。');
    }

    return (markdown: b.toString(), summary: summary);
  }

  static MasterCoverageSummary _buildSummary(List<ExamUnit> units) {
    if (units.isEmpty) {
      return const MasterCoverageSummary(
        coveragePercent: 0,
        uncoveredCount: 0,
        conflictCount: 0,
        lowConfidenceCount: 0,
      );
    }

    final covered = units
        .where((u) => u.auditStatus == 'Covered' || u.auditStatus == 'Partial')
        .length;
    final uncovered = units.where((u) => u.auditStatus == 'Uncovered').length;
    final conflict = units.where((u) => u.auditStatus == 'Conflict').length;
    final low = units.where((u) => u.auditStatus == 'LowConfidence').length;
    final pct = ((covered / units.length) * 100).round();

    return MasterCoverageSummary(
      coveragePercent: pct,
      uncoveredCount: uncovered,
      conflictCount: conflict,
      lowConfidenceCount: low,
    );
  }

  static Future<List<ExamUnit>> _loadTargetUnits(
    AppDatabase db,
    MasterCoverageExportInput input,
  ) async {
    if (input.examProfileId != null) {
      final rows = await db
          .customSelect(
            '''
            SELECT eu.*
            FROM exam_units eu
            JOIN exam_profile_units epu
              ON epu.exam_unit_id = eu.id
            WHERE epu.exam_profile_id = ?1
            ''',
            variables: [Variable.withInt(input.examProfileId!)],
            readsFrom: {db.examUnits},
          )
          .get();
      return rows.map((r) => db.examUnits.map(r.data)).toList();
    }

    final focus = input.focusUnitIds.toSet().toList();
    if (focus.isNotEmpty) {
      final placeholders = List.filled(focus.length, '?').join(',');
      final rows = await db
          .customSelect(
            'SELECT * FROM exam_units WHERE id IN ($placeholders)',
            variables: focus.map((id) => Variable.withInt(id)).toList(),
            readsFrom: {db.examUnits},
          )
          .get();
      return rows.map((r) => db.examUnits.map(r.data)).toList();
    }

    final sourceIds = input.sourceIds.toSet().toList();
    if (sourceIds.isEmpty) return const [];

    final sourceIn = List.filled(sourceIds.length, '?').join(',');
    final rows = await db
        .customSelect(
          '''
      SELECT DISTINCT eu.*
      FROM exam_units eu
      JOIN claims c ON c.exam_unit_id = eu.id
      LEFT JOIN evidence_links el ON el.claim_id = c.id
      LEFT JOIN evidence_packs ep ON ep.claim_id = c.id
      LEFT JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id
      LEFT JOIN source_segments ss1 ON ss1.id = el.source_segment_id
      LEFT JOIN source_segments ss2 ON ss2.id = epi.source_segment_id
      WHERE ss1.source_id IN ($sourceIn)
         OR ss2.source_id IN ($sourceIn)
      ''',
          variables:
              sourceIds.map(Variable.withInt).toList() +
              sourceIds.map(Variable.withInt).toList(),
          readsFrom: {
            db.examUnits,
            db.claims,
            db.evidenceLinks,
            db.evidencePacks,
            db.evidencePackItems,
            db.sourceSegments,
          },
        )
        .get();

    return rows.map((r) => db.examUnits.map(r.data)).toList();
  }

  static Future<Map<int, Source>> _loadSourceMap(
    AppDatabase db,
    List<int> sourceIds,
  ) async {
    if (sourceIds.isEmpty) return const {};
    final placeholders = List.filled(sourceIds.length, '?').join(',');
    final rows = await db
        .customSelect(
          'SELECT * FROM sources WHERE id IN ($placeholders)',
          variables: sourceIds.map(Variable.withInt).toList(),
          readsFrom: {db.sources},
        )
        .get();
    return {for (final r in rows) r.read<int>('id'): db.sources.map(r.data)};
  }

  static Future<List<int>> loadSourceIdsByProfile(
    AppDatabase db,
    int examProfileId,
  ) async {
    final rows = await db
        .customSelect(
          '''
          SELECT source_id
          FROM exam_profile_sources
          WHERE exam_profile_id = ?1
          ''',
          variables: [Variable.withInt(examProfileId)],
        )
        .get();
    return rows.map((r) => r.read<int>('source_id')).toList();
  }

  static Future<Map<int, List<_ClaimRecord>>> _loadClaimsByUnit(
    AppDatabase db,
    List<int> unitIds,
  ) async {
    if (unitIds.isEmpty) return const {};
    final placeholders = List.filled(unitIds.length, '?').join(',');
    final rows = await db
        .customSelect(
          '''
      SELECT id, exam_unit_id, content
      FROM claims
      WHERE exam_unit_id IN ($placeholders)
      ORDER BY created_at ASC
      ''',
          variables: unitIds.map(Variable.withInt).toList(),
          readsFrom: {db.claims},
        )
        .get();

    final map = <int, List<_ClaimRecord>>{};
    for (final row in rows) {
      final unitId = row.read<int>('exam_unit_id');
      (map[unitId] ??= []).add(
        _ClaimRecord(
          id: row.read<int>('id'),
          content: row.read<String>('content'),
        ),
      );
    }
    return map;
  }

  static Future<Map<int, (int, int)>> _loadWeightFrequency(
    AppDatabase db,
    List<int> unitIds,
  ) async {
    if (unitIds.isEmpty) return const {};
    final placeholders = List.filled(unitIds.length, '?').join(',');
    final rows = await db
        .customSelect(
          '''
      SELECT exam_unit_id, point_weight, frequency
      FROM unit_stats
      WHERE exam_unit_id IN ($placeholders)
      ''',
          variables: unitIds.map(Variable.withInt).toList(),
          readsFrom: {db.unitStats},
        )
        .get();

    return {
      for (final row in rows)
        row.read<int>('exam_unit_id'): (
          row.read<int>('point_weight'),
          row.read<int>('frequency'),
        ),
    };
  }

  static double _priorityScore(ExamUnit u, int weight, int frequency) {
    final confidence = switch (u.confidenceLevel) {
      'low' => 2.0,
      'medium' => 1.0,
      _ => 0.0,
    };
    final audit = switch (u.auditStatus) {
      'Conflict' => 3.0,
      'LowConfidence' => 2.5,
      'Partial' => 1.0,
      'Uncovered' => 1.5,
      _ => 0.0,
    };
    return confidence + audit + (weight * 0.6) + (frequency * 0.5);
  }

  static Future<List<_EvidenceRecord>> _topEvidenceForUnit(
    AppDatabase db,
    int unitId,
    Map<int, Source> sourceById,
  ) async {
    final rows = await db
        .customSelect(
          '''
      WITH linked AS (
        SELECT
          c.id AS claim_id,
          s.id AS source_id,
          s.file_name AS file_name,
          s.file_path AS file_path,
          ss.page_number AS page_number,
          COALESCE(epi.snippet, ss.content) AS snippet,
          epi.weight AS evidence_weight,
          s.last_quality_score AS source_quality
        FROM claims c
        JOIN evidence_links el ON el.claim_id = c.id
        JOIN source_segments ss ON ss.id = el.source_segment_id
        JOIN sources s ON s.id = ss.source_id
        LEFT JOIN evidence_packs ep ON ep.claim_id = c.id
        LEFT JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id AND epi.source_segment_id = ss.id
        WHERE c.exam_unit_id = ?1

        UNION ALL

        SELECT
          c.id AS claim_id,
          s.id AS source_id,
          s.file_name AS file_name,
          s.file_path AS file_path,
          ss.page_number AS page_number,
          COALESCE(epi.snippet, ss.content) AS snippet,
          epi.weight AS evidence_weight,
          s.last_quality_score AS source_quality
        FROM claims c
        JOIN evidence_packs ep ON ep.claim_id = c.id
        JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id
        JOIN source_segments ss ON ss.id = epi.source_segment_id
        JOIN sources s ON s.id = ss.source_id
        WHERE c.exam_unit_id = ?1
      )
      SELECT *
      FROM linked
      ORDER BY COALESCE(evidence_weight, 1) DESC, claim_id ASC
      LIMIT 10
      ''',
          variables: [Variable.withInt(unitId)],
          readsFrom: {
            db.claims,
            db.evidenceLinks,
            db.evidencePacks,
            db.evidencePackItems,
            db.sourceSegments,
            db.sources,
          },
        )
        .get();

    final seen = <String>{};
    final out = <_EvidenceRecord>[];
    for (final row in rows) {
      final sourceId = row.read<int>('source_id');
      final page = row.read<int>('page_number');
      final key = '$sourceId:$page';
      if (seen.contains(key)) continue;
      seen.add(key);
      final src = sourceById[sourceId];
      out.add(
        _EvidenceRecord(
          fileName: src?.fileName ?? row.read<String>('file_name'),
          filePath: src?.filePath ?? row.read<String>('file_path'),
          pageNumber: page,
          snippet: row.readNullable<String>('snippet') ?? '',
          quality: row.readNullable<double>('source_quality'),
        ),
      );
      if (out.length >= 3) break;
    }
    return out;
  }

  static String _trim(String text, int max) {
    final cleaned = text.replaceAll('\n', ' ').trim();
    if (cleaned.length <= max) return cleaned;
    return '${cleaned.substring(0, max)}...';
  }
}

class _ClaimRecord {
  const _ClaimRecord({required this.id, required this.content});

  final int id;
  final String content;
}

class _EvidenceRecord {
  const _EvidenceRecord({
    required this.fileName,
    required this.filePath,
    required this.pageNumber,
    required this.snippet,
    this.quality,
  });

  final String fileName;
  final String filePath;
  final int pageNumber;
  final String snippet;
  final double? quality;
}
