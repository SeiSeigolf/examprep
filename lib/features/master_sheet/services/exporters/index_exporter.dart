import 'exam_pack_exporter.dart';

class IndexExporter extends ExamPackExporter {
  const IndexExporter(this.packFiles);

  /// 他のExporterが生成するファイル名リスト（順序付き）
  final List<String> packFiles;

  @override
  Future<ExportResult> export(ExportContext ctx) async {
    final b = StringBuffer();
    b.writeln('# ${ctx.examName} — 網羅資料パック INDEX');
    b.write(ctx.header);
    b.writeln();
    b.writeln('## ファイル一覧');
    b.writeln();
    for (final f in packFiles) {
      final label = _label(f);
      b.writeln('- [$label](./$f)');
    }
    b.writeln();
    b.writeln('## 使い方');
    b.writeln('1. **SCORE_STRATEGY.md** で得点戦略を確認');
    b.writeln('2. **PAST_EXAM_COVERAGE.md** で過去問カバー率を把握');
    b.writeln('3. **POOL_100_COVERAGE.md / PRACTICE_COVERAGE.md** で演習問題の確認');
    b.writeln('4. **UNSURE_AND_CONFLICTS.md** で曖昧・矛盾を解消');
    b.writeln('5. **MASTER_STUDY.md** で学習用まとめを確認（ノイズ除去・勉強法付き）');
    b.writeln('6. **MASTER_AUDIT.md** で根拠・監査ログを確認（詳細版）');

    return ExportResult(fileName: 'INDEX.md', markdown: b.toString());
  }

  static String _label(String fileName) {
    return switch (fileName) {
      'SCORE_STRATEGY.md' => '得点戦略ダッシュボード',
      'PAST_EXAM_COVERAGE.md' => '過去問カバー率',
      'POOL_100_COVERAGE.md' => 'プール100問カバー率',
      'PRACTICE_COVERAGE.md' => '演習問題カバー率',
      'UNSURE_AND_CONFLICTS.md' => '曖昧・Conflict一覧',
      'MASTER_STUDY.md' => '学習用 Master Coverage（ノイズ除去）',
      'MASTER_AUDIT.md' => '監査用 Master Coverage（根拠詳細）',
      'MASTER_COVERAGE.md' => 'Master Coverage Sheet',
      _ => fileName,
    };
  }
}
