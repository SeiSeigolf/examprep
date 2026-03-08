import '../../../quick_generate/services/master_coverage_sheet_exporter.dart'
    show MasterCoverageExportInput, MasterCoverageSheetExporter;
import 'exam_pack_exporter.dart';

/// 監査用 Master Sheet（根拠・status・file link 厚め）。
/// 既存の MasterCoverageSheetExporter をそのままラップし、ファイル名のみ変える。
class MasterAuditExporter extends ExamPackExporter {
  const MasterAuditExporter();

  @override
  Future<ExportResult> export(ExportContext ctx) async {
    final generated = await MasterCoverageSheetExporter.generateMarkdown(
      ctx.db,
      MasterCoverageExportInput(
        examName: ctx.examName,
        examDate: ctx.examDate,
        subject: ctx.subject,
        sourceIds: const [],
        focusUnitIds: const [],
        autoMergedCount: 0,
        examProfileId: ctx.examProfileId,
      ),
      now: ctx.now,
    );

    return ExportResult(
      fileName: 'MASTER_AUDIT.md',
      markdown: generated.markdown,
      summaryJson: {
        'coveragePercent': generated.summary.coveragePercent,
        'uncoveredCount': generated.summary.uncoveredCount,
        'conflictCount': generated.summary.conflictCount,
        'lowConfidenceCount': generated.summary.lowConfidenceCount,
      },
    );
  }
}
