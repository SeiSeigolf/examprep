import 'dart:io';

import '../../../db/database.dart';
import 'exporters/exam_pack_exporter.dart';
import 'exporters/index_exporter.dart';
import 'exporters/master_exporter.dart';
import 'exporters/score_strategy_exporter.dart';
import 'exporters/source_coverage_exporter.dart';
import 'exporters/unsure_exporter.dart';

// ============================================================
// 結果クラス
// ============================================================

class ExamPackFile {
  const ExamPackFile({
    required this.fileName,
    required this.path,
    required this.markdown,
    this.summaryJson,
  });

  final String fileName;
  final String path;
  final String markdown;
  final Map<String, dynamic>? summaryJson;
}

class ExamPackResult {
  const ExamPackResult({
    required this.outputDir,
    required this.files,
    required this.examProfileId,
  });

  final String outputDir;
  final List<ExamPackFile> files;
  final int examProfileId;

  String get indexPath =>
      files.firstWhere((f) => f.fileName == 'INDEX.md').path;
}

// ============================================================
// Generator
// ============================================================

class ExamPackGenerator {
  ExamPackGenerator(this._db, {List<ExamPackExporter>? exporters})
    : _exporters = exporters;

  final AppDatabase _db;
  final List<ExamPackExporter>? _exporters;

  /// ファイルI/Oなしでmarkdownを生成（テスト用）
  Future<List<ExportResult>> generateMarkdowns({
    required int examProfileId,
    required String examName,
    DateTime? examDate,
    String? subject,
    DateTime? now,
  }) async {
    final ctx = ExportContext(
      db: _db,
      examProfileId: examProfileId,
      outputDir: '',
      examName: examName,
      now: now ?? DateTime.now(),
      examDate: examDate,
      subject: subject,
    );
    return _runExporters(ctx);
  }

  /// markdownを生成してoutputDir配下に保存
  Future<ExamPackResult> generateAndSave({
    required int examProfileId,
    required String examName,
    required String outputDir,
    DateTime? examDate,
    String? subject,
    DateTime? now,
  }) async {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final ctx = ExportContext(
      db: _db,
      examProfileId: examProfileId,
      outputDir: outputDir,
      examName: examName,
      now: now ?? DateTime.now(),
      examDate: examDate,
      subject: subject,
    );

    final results = await _runExporters(ctx);

    final files = <ExamPackFile>[];
    for (final r in results) {
      final filePath = '$outputDir/${r.fileName}';
      await File(filePath).writeAsString(r.markdown);
      files.add(
        ExamPackFile(
          fileName: r.fileName,
          path: filePath,
          markdown: r.markdown,
          summaryJson: r.summaryJson,
        ),
      );
    }

    return ExamPackResult(
      outputDir: outputDir,
      files: files,
      examProfileId: examProfileId,
    );
  }

  Future<List<ExportResult>> _runExporters(ExportContext ctx) async {
    final custom = _exporters;
    if (custom != null) {
      // カスタムExporterリストが注入されている場合はそれを使う
      final results = <ExportResult>[];
      for (final e in custom) {
        results.add(await e.export(ctx));
      }
      return results;
    }

    // デフォルトの7ファイル構成
    const contentExporterFileNames = [
      'SCORE_STRATEGY.md',
      'PAST_EXAM_COVERAGE.md',
      'POOL_100_COVERAGE.md',
      'PRACTICE_COVERAGE.md',
      'UNSURE_AND_CONFLICTS.md',
      'MASTER_COVERAGE.md',
    ];

    final contentExporters = <ExamPackExporter>[
      const ScoreStrategyExporter(),
      const SourceCoverageExporter('past_exam'),
      const SourceCoverageExporter('pool'),
      const SourceCoverageExporter('practice'),
      const UnsureExporter(),
      const MasterExporter(),
    ];

    final contentResults = <ExportResult>[];
    for (final e in contentExporters) {
      contentResults.add(await e.export(ctx));
    }

    // INDEXは最後に生成（他ファイル名を参照する）
    final indexResult = await IndexExporter(contentExporterFileNames).export(ctx);

    return [indexResult, ...contentResults];
  }
}
