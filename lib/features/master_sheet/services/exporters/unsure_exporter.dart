import 'package:drift/drift.dart' show Variable;

import '../coverage_metrics_service.dart';
import 'exam_pack_exporter.dart';

/// Conflict / LowConfidence / Uncovered を一覧化するExporter
class UnsureExporter extends ExamPackExporter {
  const UnsureExporter();

  @override
  Future<ExportResult> export(ExportContext ctx) async {
    final rows = await ctx.db
        .customSelect(
          '''
          SELECT eu.id, eu.title, eu.unit_type, eu.problem_format,
                 eu.audit_status, eu.confidence_level
          FROM exam_units eu
          JOIN exam_profile_units epu ON epu.exam_unit_id = eu.id
          WHERE epu.exam_profile_id = ?1
            AND eu.audit_status IN ('Conflict', 'LowConfidence', 'Uncovered')
          ORDER BY
            CASE eu.audit_status
              WHEN 'Conflict' THEN 1
              WHEN 'LowConfidence' THEN 2
              WHEN 'Uncovered' THEN 3
              ELSE 4
            END,
            eu.id ASC
          ''',
          variables: [Variable.withInt(ctx.examProfileId)],
          readsFrom: {ctx.db.examUnits},
        )
        .get();

    final b = StringBuffer();
    b.writeln('# ${ctx.examName} — 曖昧・Conflict一覧');
    b.write(ctx.header);
    b.writeln();

    if (rows.isEmpty) {
      b.writeln('> Conflict / LowConfidence / Uncovered は0件です。学習準備完了です！');
      return ExportResult(
        fileName: 'UNSURE_AND_CONFLICTS.md',
        markdown: b.toString(),
        summaryJson: {'conflictCount': 0, 'lowConfCount': 0, 'uncoveredCount': 0},
      );
    }

    int conflictCount = 0, lowConfCount = 0, uncoveredCount = 0;

    String? currentStatus;
    for (final r in rows) {
      final unitId = r.read<int>('id');
      final title = r.read<String>('title');
      final status = r.read<String>('audit_status');
      final unitType = r.read<String>('unit_type');
      final format = r.read<String>('problem_format');

      if (status != currentStatus) {
        currentStatus = status;
        b.writeln('## $status');
        b.writeln();
      }

      switch (status) {
        case 'Conflict':
          conflictCount++;
        case 'LowConfidence':
          lowConfCount++;
        case 'Uncovered':
          uncoveredCount++;
      }

      b.writeln('### $title');
      b.writeln('- タイプ: $unitType / $format');

      final claims = await CoverageMetricsService.getClaimsForUnit(
        ctx.db,
        unitId,
        limit: 3,
      );
      if (claims.isNotEmpty) {
        b.writeln('- Claims:');
        for (final c in claims) {
          b.writeln('  - ${_trim(c, 180)}');
        }
      }

      final evidence = await CoverageMetricsService.getTopEvidenceForUnit(
        ctx.db,
        unitId,
        limit: 2,
      );
      if (evidence.isNotEmpty) {
        b.writeln('- 根拠:');
        for (final ev in evidence) {
          b.writeln(
            '  - ${ev.fileName} p.${ev.pageNumber}: ${_trim(ev.snippet, 120)}',
          );
        }
      }

      if (status == 'Conflict') {
        b.writeln('- **アクション**: 矛盾する根拠を比較し、正しい記述を選んでClaimを修正');
      } else if (status == 'LowConfidence') {
        b.writeln('- **アクション**: 追加ソースで根拠を補強するか、Claimを見直し');
      } else {
        b.writeln('- **アクション**: 根拠となるセグメントをEvidenceリンクに追加');
      }
      b.writeln();
    }

    return ExportResult(
      fileName: 'UNSURE_AND_CONFLICTS.md',
      markdown: b.toString(),
      summaryJson: {
        'conflictCount': conflictCount,
        'lowConfCount': lowConfCount,
        'uncoveredCount': uncoveredCount,
      },
    );
  }

  static String _trim(String text, int max) {
    final s = text.replaceAll('\n', ' ').trim();
    return s.length <= max ? s : '${s.substring(0, max)}…';
  }
}
