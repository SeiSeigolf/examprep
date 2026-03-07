import '../coverage_metrics_service.dart';
import 'exam_pack_exporter.dart';

class ScoreStrategyExporter extends ExamPackExporter {
  const ScoreStrategyExporter();

  @override
  Future<ExportResult> export(ExportContext ctx) async {
    final summary = await CoverageMetricsService.getCoverageSummary(
      ctx.db,
      ctx.examProfileId,
    );
    final groups = await CoverageMetricsService.getGroupCoverage(
      ctx.db,
      ctx.examProfileId,
    );
    final topUnits = await CoverageMetricsService.getUnitScores(
      ctx.db,
      ctx.examProfileId,
      limit: 30,
    );

    final b = StringBuffer();
    b.writeln('# ${ctx.examName} — 得点戦略ダッシュボード');
    b.write(ctx.header);
    b.writeln();

    // --- 完成度サマリ ---
    b.writeln('## 完成度サマリ');
    b.writeln('| 項目 | 件数 |');
    b.writeln('|------|------|');
    b.writeln('| 総Unit数 | ${summary.totalCount} |');
    b.writeln('| Coverage | ${summary.coveragePercent}% |');
    b.writeln('| Covered | ${summary.coveredCount} |');
    b.writeln('| Partial | ${summary.partialCount} |');
    b.writeln('| Uncovered | ${summary.uncoveredCount} |');
    b.writeln('| Conflict | ${summary.conflictCount} |');
    b.writeln('| LowConfidence | ${summary.lowConfidenceCount} |');
    b.writeln('| 根拠総数 | ${summary.evidenceCount} |');
    b.writeln();

    // --- 完成判定 ---
    final isReady =
        summary.uncoveredCount == 0 &&
        summary.conflictCount <= ctx.conflictThreshold &&
        summary.lowConfidenceCount <= ctx.lowConfidenceThreshold;
    b.writeln('## 完成判定');
    b.writeln(isReady ? '**判定: Ready ✓**' : '**判定: Not Ready**');
    if (!isReady) {
      b.writeln();
      b.writeln('次にやること:');
      if (summary.uncoveredCount > 0) {
        b.writeln('1. Uncovered ${summary.uncoveredCount}件を解消');
      }
      if (summary.conflictCount > ctx.conflictThreshold) {
        b.writeln(
          '2. Conflict ${summary.conflictCount}件を確認（しきい値: ${ctx.conflictThreshold}）',
        );
      }
      if (summary.lowConfidenceCount > ctx.lowConfidenceThreshold) {
        b.writeln(
          '3. LowConfidence ${summary.lowConfidenceCount}件を補強（しきい値: ${ctx.lowConfidenceThreshold}）',
        );
      }
    }
    b.writeln();

    // --- ソースグループ別カバー率 ---
    if (groups.isNotEmpty) {
      b.writeln('## ソースグループ別カバー率');
      b.writeln('| ソースグループ | カバー Units | カバー率 |');
      b.writeln('|----------------|--------------|----------|');
      for (final g in groups) {
        b.writeln(
          '| ${g.sourceGroup} | ${g.unitCount} / ${g.totalCount} | ${g.coveragePercent}% |',
        );
      }
      b.writeln();
    }

    // --- 得点優先度TOP30 ---
    if (topUnits.isNotEmpty) {
      b.writeln('## 得点優先度 TOP ${topUnits.length}');
      b.writeln('| # | タイトル | タイプ | 配点 | 頻度 | 期待得点 | 監査 |');
      b.writeln('|---|--------|--------|------|------|----------|------|');
      for (var i = 0; i < topUnits.length; i++) {
        final u = topUnits[i];
        b.writeln(
          '| ${i + 1} | ${_trim(u.title, 40)} | ${u.unitType} | ${u.pointWeight} | ${u.frequency} | ${u.expectedScore} | ${u.auditStatus} |',
        );
      }
      b.writeln();
    }

    return ExportResult(
      fileName: 'SCORE_STRATEGY.md',
      markdown: b.toString(),
      summaryJson: {
        'coveragePercent': summary.coveragePercent,
        'totalCount': summary.totalCount,
        'uncoveredCount': summary.uncoveredCount,
        'conflictCount': summary.conflictCount,
        'lowConfidenceCount': summary.lowConfidenceCount,
        'isReady': isReady,
      },
    );
  }

  static String _trim(String text, int max) {
    final s = text.replaceAll('\n', ' ').trim();
    return s.length <= max ? s : '${s.substring(0, max)}…';
  }
}
