import '../../../../db/database.dart';

// ============================================================
// ExportContext — 各Exporterが受け取る共通コンテキスト
// ============================================================

class ExportContext {
  const ExportContext({
    required this.db,
    required this.examProfileId,
    required this.outputDir,
    required this.examName,
    required this.now,
    this.examDate,
    this.subject,
    this.conflictThreshold = 5,
    this.lowConfidenceThreshold = 10,
  });

  final AppDatabase db;
  final int examProfileId;
  final String outputDir;
  final String examName;
  final DateTime now;
  final DateTime? examDate;
  final String? subject;
  final int conflictThreshold;
  final int lowConfidenceThreshold;

  String get header {
    final b = StringBuffer();
    b.writeln('生成日時: ${now.toLocal().toString().substring(0, 16)}');
    if (subject != null && subject!.trim().isNotEmpty) {
      b.writeln('科目: ${subject!.trim()}');
    }
    if (examDate != null) {
      b.writeln('試験日: ${examDate!.toLocal().toString().substring(0, 10)}');
    }
    return b.toString();
  }
}

// ============================================================
// ExportResult
// ============================================================

class ExportResult {
  const ExportResult({
    required this.fileName,
    required this.markdown,
    this.summaryJson,
  });

  final String fileName;
  final String markdown;
  final Map<String, dynamic>? summaryJson;
}

// ============================================================
// Abstract base
// ============================================================

abstract class ExamPackExporter {
  const ExamPackExporter();

  Future<ExportResult> export(ExportContext ctx);
}
