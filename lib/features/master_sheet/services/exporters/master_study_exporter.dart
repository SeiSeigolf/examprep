import 'package:drift/drift.dart' show Variable;

import '../coverage_metrics_service.dart';
import 'exam_pack_exporter.dart';

/// 学習用 Master Sheet。
/// ノイズ除去済み + 重要度順 + 勉強法前面。
/// 末尾に除外セグメント統計を付加。
class MasterStudyExporter extends ExamPackExporter {
  const MasterStudyExporter();

  @override
  Future<ExportResult> export(ExportContext ctx) async {
    final summary = await CoverageMetricsService.getCoverageSummary(
      ctx.db,
      ctx.examProfileId,
    );
    final topUnits = await CoverageMetricsService.getUnitScores(
      ctx.db,
      ctx.examProfileId,
      limit: 200,
    );
    final noiseStats = await _getNoiseStats(ctx);

    final b = StringBuffer();
    b.writeln('# ${ctx.examName} — 学習用 Master Coverage');
    b.write(ctx.header);
    b.writeln();

    // --- 完成判定 + 次アクション ---
    final isReady =
        summary.uncoveredCount == 0 &&
        summary.conflictCount <= ctx.conflictThreshold &&
        summary.lowConfidenceCount <= ctx.lowConfidenceThreshold;
    b.writeln('## 完成判定');
    b.writeln(isReady ? '**Ready ✓ — 学習開始OK**' : '**Not Ready — 次のアクションを先に実施**');
    if (!isReady) {
      b.writeln();
      if (summary.uncoveredCount > 0) {
        b.writeln('- **Uncovered ${summary.uncoveredCount}件**: Audit画面で根拠を紐づけてください');
      }
      if (summary.conflictCount > ctx.conflictThreshold) {
        b.writeln('- **Conflict ${summary.conflictCount}件**: UNSURE_AND_CONFLICTS.md で矛盾を解消してください');
      }
      if (summary.lowConfidenceCount > ctx.lowConfidenceThreshold) {
        b.writeln('- **LowConfidence ${summary.lowConfidenceCount}件**: 根拠を補強してください');
      }
    }
    b.writeln();

    // --- サマリ行 ---
    b.writeln('## Coverage サマリ');
    b.writeln('| 総Unit | Coverage | Covered | Partial | Uncovered | Conflict | LowConf |');
    b.writeln('|--------|----------|---------|---------|-----------|----------|---------|');
    b.writeln(
      '| ${summary.totalCount} | ${summary.coveragePercent}% '
      '| ${summary.coveredCount} | ${summary.partialCount} '
      '| ${summary.uncoveredCount} | ${summary.conflictCount} '
      '| ${summary.lowConfidenceCount} |',
    );
    b.writeln();

    // --- 重要度順 Unit ---
    b.writeln('## 学習優先度順 Unit 一覧');
    b.writeln();
    for (var i = 0; i < topUnits.length; i++) {
      final u = topUnits[i];
      final claims = await CoverageMetricsService.getClaimsForUnit(
        ctx.db,
        u.unitId,
        limit: 5,
      );
      // content セグメント優先でエビデンス取得（MasterStudy では clean のみ）
      final evidence = await CoverageMetricsService.getTopEvidenceForUnit(
        ctx.db,
        u.unitId,
        limit: 2,
      );
      final studyMethod = await CoverageMetricsService.getStudyMethodName(
        ctx.db,
        u.unitType,
        u.problemFormat,
      );

      // [NOISY] タグが付いた根拠は学習用では省く
      final cleanEvidence = evidence.where((e) => !e.snippet.startsWith('[NOISY')).toList();

      b.writeln('### ${i + 1}. ${u.title}');
      b.writeln(
        '**タイプ**: ${u.unitType} / ${u.problemFormat} | '
        '**配点**: ${u.pointWeight} | **頻度**: ${u.frequency} | '
        '**監査**: ${u.auditStatus}',
      );
      if (studyMethod != null) {
        b.writeln('**推奨勉強法**: $studyMethod');
      }
      b.writeln();
      if (claims.isNotEmpty) {
        b.writeln('**要点**:');
        for (final c in claims) {
          b.writeln('- ${_trim(c, 200)}');
        }
        b.writeln();
      }
      if (cleanEvidence.isNotEmpty) {
        b.writeln('**根拠**:');
        for (final ev in cleanEvidence) {
          b.writeln(
            '- ${ev.fileName} p.${ev.pageNumber}: ${_trim(ev.snippet, 140)}',
          );
        }
        b.writeln();
      }
    }

    if (topUnits.isEmpty) {
      b.writeln('> 対象 Unit がありません。');
      b.writeln();
    }

    // --- ノイズ除外統計 ---
    final totalNoise = noiseStats.values.fold(0, (a, b) => a + b);
    if (totalNoise > 0) {
      b.writeln('---');
      b.writeln('## 除外セグメント統計');
      b.writeln('根拠抽出から除外したノイズセグメント（学習内容に直接関係なし）:');
      b.writeln();
      for (final entry in noiseStats.entries) {
        if (entry.value > 0) {
          b.writeln('- ${entry.key}: ${entry.value}件');
        }
      }
      b.writeln('- **合計**: ${totalNoise}件除外（学習精度向上のため）');
    }

    return ExportResult(
      fileName: 'MASTER_STUDY.md',
      markdown: b.toString(),
      summaryJson: {
        'coveragePercent': summary.coveragePercent,
        'totalCount': summary.totalCount,
        'noiseExcludedCount': totalNoise,
        'isReady': isReady,
      },
    );
  }

  /// source_segments の segment_kind 別カウントを取得
  Future<Map<String, int>> _getNoiseStats(ExportContext ctx) async {
    final rows = await ctx.db
        .customSelect(
          '''
          SELECT ss.segment_kind, COUNT(*) AS cnt
          FROM source_segments ss
          JOIN sources s ON s.id = ss.source_id
          JOIN exam_profile_sources eps ON eps.source_id = s.id
          WHERE eps.exam_profile_id = ?1
            AND ss.segment_kind != 'content'
          GROUP BY ss.segment_kind
          ORDER BY cnt DESC
          ''',
          variables: [Variable.withInt(ctx.examProfileId)],
          readsFrom: {ctx.db.sourceSegments, ctx.db.sources},
        )
        .get();

    return {
      for (final r in rows) r.read<String>('segment_kind'): r.read<int>('cnt'),
    };
  }

  static String _trim(String text, int max) {
    final s = text.replaceAll('\n', ' ').trim();
    return s.length <= max ? s : '${s.substring(0, max)}…';
  }
}
