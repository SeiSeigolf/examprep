import '../coverage_metrics_service.dart';
import 'exam_pack_exporter.dart';

/// ソースグループ別カバー率ファイルを生成するExporter。
/// group='past_exam' → PAST_EXAM_COVERAGE.md
/// group='pool'      → POOL_100_COVERAGE.md
/// group='practice'  → PRACTICE_COVERAGE.md
class SourceCoverageExporter extends ExamPackExporter {
  const SourceCoverageExporter(this.group);

  final String group;

  @override
  Future<ExportResult> export(ExportContext ctx) async {
    final units = await CoverageMetricsService.getUnitsByGroup(
      ctx.db,
      ctx.examProfileId,
      group,
    );

    final fileName = _fileName(group);
    final title = _title(group);

    final b = StringBuffer();
    b.writeln('# ${ctx.examName} — $title');
    b.write(ctx.header);
    b.writeln();

    if (units.isEmpty) {
      b.writeln('> この試験プロファイルに $group ソースからの根拠付きUnitはありません。');
      return ExportResult(fileName: fileName, markdown: b.toString());
    }

    // サマリ
    final covered =
        units
            .where(
              (u) =>
                  u.auditStatus == 'Covered' || u.auditStatus == 'Partial',
            )
            .length;
    final pct = ((covered / units.length) * 100).round();
    b.writeln('## サマリ');
    b.writeln('- 対象Unit数: ${units.length}');
    b.writeln('- カバー率: $pct% ($covered / ${units.length})');
    b.writeln();

    // ステータス別グループ
    final statusOrder = [
      'Covered',
      'Partial',
      'LowConfidence',
      'Conflict',
      'Uncovered',
    ];
    for (final status in statusOrder) {
      final inStatus = units.where((u) => u.auditStatus == status).toList();
      if (inStatus.isEmpty) continue;
      b.writeln('### $status (${inStatus.length}件)');
      for (final u in inStatus) {
        final claims = await CoverageMetricsService.getClaimsForUnit(
          ctx.db,
          u.id,
          limit: 2,
        );
        final evidence = await CoverageMetricsService.getTopEvidenceForUnit(
          ctx.db,
          u.id,
          limit: 2,
        );
        b.writeln('#### ${u.title}');
        b.writeln('- タイプ: ${u.unitType} / ${u.problemFormat}');
        if (claims.isNotEmpty) {
          b.writeln('- Claim: ${_trim(claims.first, 160)}');
        }
        for (final ev in evidence) {
          b.writeln(
            '- 根拠: ${ev.fileName} p.${ev.pageNumber} — ${_trim(ev.snippet, 120)}',
          );
        }
        b.writeln();
      }
    }

    return ExportResult(
      fileName: fileName,
      markdown: b.toString(),
      summaryJson: {
        'group': group,
        'totalUnits': units.length,
        'coveredPercent': pct,
      },
    );
  }

  static String _fileName(String group) => switch (group) {
    'past_exam' => 'PAST_EXAM_COVERAGE.md',
    'pool' => 'POOL_100_COVERAGE.md',
    'practice' => 'PRACTICE_COVERAGE.md',
    _ => '${group.toUpperCase()}_COVERAGE.md',
  };

  static String _title(String group) => switch (group) {
    'past_exam' => '過去問カバー率',
    'pool' => 'プール100問カバー率',
    'practice' => '演習問題カバー率',
    _ => '$group カバー率',
  };

  static String _trim(String text, int max) {
    final s = text.replaceAll('\n', ' ').trim();
    return s.length <= max ? s : '${s.substring(0, max)}…';
  }
}
