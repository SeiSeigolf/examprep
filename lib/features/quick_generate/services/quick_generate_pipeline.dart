import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:path_provider/path_provider.dart';

import '../../../db/database.dart';
import '../../ingestion/services/segment_kind_classifier.dart';
import '../../ingestion/services/text_extraction/poppler_extractor.dart';
import '../../ingestion/services/text_extraction/syncfusion_extractor.dart';
import '../../ingestion/services/text_extraction/text_extraction_pipeline.dart';
import '../../ingestion/services/text_extraction/vision_ocr_extractor.dart';
import 'master_coverage_sheet_exporter.dart';

class QuickGenerateRequest {
  const QuickGenerateRequest({
    required this.examName,
    this.examDate,
    this.subject,
    this.pdfPaths = const [],
    this.sourceType,
    this.existingSourceIds = const [],
  });

  final String examName;
  final DateTime? examDate;
  final String? subject;
  final List<String> pdfPaths;
  final String? sourceType;
  final List<int> existingSourceIds;
}

enum QuickGenerateStep {
  extracting,
  drafting,
  deduplicating,
  auditing,
  exporting,
  done,
}

class QuickGenerateProgress {
  const QuickGenerateProgress({
    required this.step,
    required this.message,
    this.current,
    this.total,
  });

  final QuickGenerateStep step;
  final String message;
  final int? current;
  final int? total;
}

class QuickGenerateResult {
  const QuickGenerateResult({
    required this.examProfileId,
    required this.markdownPath,
    required this.sourceIds,
    required this.createdUnitIds,
    required this.autoMergedCount,
    required this.autoMergedPairs,
    required this.autoLinkedCount,
    required this.summary,
  });

  final int examProfileId;
  final String markdownPath;
  final List<int> sourceIds;
  final List<int> createdUnitIds;
  final int autoMergedCount;
  final List<AutoMergedPair> autoMergedPairs;
  final int autoLinkedCount;
  final MasterCoverageSummary summary;
}

class AutoMergedPair {
  const AutoMergedPair({
    required this.parentUnitId,
    required this.childUnitId,
    required this.parentTitle,
    required this.childTitle,
    required this.score,
  });

  final int parentUnitId;
  final int childUnitId;
  final String parentTitle;
  final String childTitle;
  final double score;
}

class QuickGeneratePipeline {
  QuickGeneratePipeline(
    this._db, {
    TextExtractionPipeline? extractionPipeline,
    Future<MasterCoverageExportResult> Function(
      AppDatabase db,
      MasterCoverageExportInput input,
    )?
    exporter,
  }) : _pipeline =
           extractionPipeline ??
           TextExtractionPipeline(
             syncfusion: SyncfusionExtractor(),
             poppler: PopplerExtractor(),
             ocr: VisionOcrExtractor(),
           ),
       _exporter = exporter;

  final AppDatabase _db;
  final TextExtractionPipeline _pipeline;
  final Future<MasterCoverageExportResult> Function(
    AppDatabase db,
    MasterCoverageExportInput input,
  )?
  _exporter;

  Future<QuickGenerateResult> run(
    QuickGenerateRequest request, {
    void Function(QuickGenerateProgress progress)? onProgress,
  }) async {
    final sourceIds = <int>[...request.existingSourceIds];

    final pdfPaths = request.pdfPaths
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (pdfPaths.isNotEmpty) {
      for (var i = 0; i < pdfPaths.length; i++) {
        final p = pdfPaths[i];
        onProgress?.call(
          QuickGenerateProgress(
            step: QuickGenerateStep.extracting,
            message: 'PDF抽出中: ${_fileName(p)}',
            current: i + 1,
            total: pdfPaths.length,
          ),
        );
        final sourceId = await _importPdf(p, sourceType: request.sourceType);
        sourceIds.add(sourceId);
      }
    }

    if (sourceIds.isEmpty) {
      throw StateError('対象ソースがありません。PDFを追加するか既存ソースを選択してください。');
    }

    final createdUnitIds = <int>[];
    for (var i = 0; i < sourceIds.length; i++) {
      final sourceId = sourceIds[i];
      onProgress?.call(
        QuickGenerateProgress(
          step: QuickGenerateStep.drafting,
          message: 'Unit候補作成中 (sourceId=$sourceId)',
          current: i + 1,
          total: sourceIds.length,
        ),
      );
      final drafts = await _db.sourcesDao.suggestExamUnitDraftsFromSource(
        sourceId,
      );
      if (drafts.isEmpty) continue;
      final ids = await _db.sourcesDao.createExamUnitsFromDrafts(drafts);
      createdUnitIds.addAll(ids);
    }

    final examProfileId = await _createExamProfile(
      examName: request.examName,
      examDate: request.examDate,
      subject: request.subject,
      sourceIds: sourceIds,
      unitIds: createdUnitIds,
    );

    onProgress?.call(
      const QuickGenerateProgress(
        step: QuickGenerateStep.deduplicating,
        message: '重複候補を自動統合中',
      ),
    );
    final mergedPairs = await _autoMergeHighSimilarityUnits(createdUnitIds);
    final mergedCount = mergedPairs.length;

    onProgress?.call(
      const QuickGenerateProgress(
        step: QuickGenerateStep.auditing,
        message: '監査と頻度を更新中',
      ),
    );
    await _db.auditDao.refreshCoverageAudits(examProfileId: examProfileId);
    await _db.sourcesDao.recalculatePastExamFrequency();
    await _downgradeUnitsWithoutEvidence(createdUnitIds);

    final autoLinkedCount = await _db.auditDao.autoLinkUncoveredSegments(
      examProfileId: examProfileId,
    );
    await _db.auditDao.refreshCoverageAudits(examProfileId: examProfileId);

    onProgress?.call(
      const QuickGenerateProgress(
        step: QuickGenerateStep.exporting,
        message: 'Master Coverage Sheetを生成中',
      ),
    );
    final exportFn = _exporter ?? MasterCoverageSheetExporter.export;
    final export = await exportFn(
      _db,
      MasterCoverageExportInput(
        examName: request.examName,
        examDate: request.examDate,
        subject: request.subject,
        sourceIds: sourceIds,
        focusUnitIds: createdUnitIds,
        autoMergedCount: mergedCount,
        examProfileId: examProfileId,
      ),
    );

    onProgress?.call(
      const QuickGenerateProgress(step: QuickGenerateStep.done, message: '完了'),
    );

    return QuickGenerateResult(
      examProfileId: examProfileId,
      markdownPath: export.path,
      sourceIds: sourceIds,
      createdUnitIds: createdUnitIds,
      autoMergedCount: mergedCount,
      autoMergedPairs: mergedPairs.take(10).toList(),
      autoLinkedCount: autoLinkedCount,
      summary: export.summary,
    );
  }

  Future<int> _importPdf(String srcPath, {String? sourceType}) async {
    final file = File(srcPath);
    if (!file.existsSync()) {
      throw StateError('ファイルが見つかりません: $srcPath');
    }

    final fileName = _fileName(srcPath);
    final storedPath = await _copyToAppStorage(srcPath, fileName);
    final extraction = await _pipeline.extract(storedPath);

    final existingRow = await _db.customSelect(
      'SELECT id FROM sources WHERE file_path = ?',
      variables: [Variable<String>(storedPath)],
    ).getSingleOrNull();
    if (existingRow != null) {
      return existingRow.read<int>('id');
    }

    final inferredType = sourceType ?? _inferSourceType(fileName);
    final sourceId = await _db.sourcesDao.insertSource(
      SourcesCompanion.insert(
        fileName: fileName,
        filePath: storedPath,
        sourceType: Value(inferredType),
        sourceGroup: Value(_inferSourceGroup(fileName, inferredType)),
        fileSize: Value(file.lengthSync()),
        pageCount: Value(extraction.pages.length),
        lastExtractionMethod: Value(extraction.method),
        lastQualityScore: Value(extraction.qualityScore),
        extractionUpdatedAt: Value(DateTime.now()),
      ),
    );

    await _db.sourcesDao.insertSegments(
      extraction.pages
          .map(
            (p) => SourceSegmentsCompanion.insert(
              sourceId: sourceId,
              pageNumber: p.pageNumber,
              content: Value(p.text),
              extractionMethod: Value(extraction.method),
              qualityScore: Value(p.qualityScore),
              ocrConfidence: Value(p.ocrConfidence),
              segmentKind: Value(classifySegmentKind(p.text)),
            ),
          )
          .toList(),
    );

    return sourceId;
  }

  Future<String> _copyToAppStorage(String srcPath, String fileName) async {
    final appSupport = await getApplicationSupportDirectory();
    final pdfsDir = Directory('${appSupport.path}/pdfs');
    if (!pdfsDir.existsSync()) {
      await pdfsDir.create(recursive: true);
    }

    var candidateName = fileName;
    var dest = File('${pdfsDir.path}/$candidateName');
    var suffix = 0;
    while (dest.existsSync()) {
      suffix++;
      candidateName = _fileNameWithSuffix(fileName, suffix);
      dest = File('${pdfsDir.path}/$candidateName');
    }

    await File(srcPath).copy(dest.path);
    return dest.path;
  }

  Future<List<AutoMergedPair>> _autoMergeHighSimilarityUnits(
    List<int> scopedUnitIds,
  ) async {
    if (scopedUnitIds.isEmpty) return const [];
    final scope = scopedUnitIds.toSet();
    final merged = <AutoMergedPair>[];
    var guard = 0;

    while (guard < 50) {
      guard++;
      final candidates = await _db.examUnitsDao.findDuplicateCandidates(
        limit: 40,
      );
      final high = candidates.where((c) {
        final sameType = c.left.unitType == c.right.unitType;
        final sameFormat = c.left.problemFormat == c.right.problemFormat;
        final sameAudit =
            (c.left.auditStatus == 'Covered' &&
                c.right.auditStatus == 'Covered') ||
            (c.left.auditStatus == 'Partial' &&
                c.right.auditStatus == 'Partial');
        return c.score >= 0.32 &&
            scope.contains(c.left.id) &&
            scope.contains(c.right.id) &&
            sameType &&
            sameFormat &&
            sameAudit;
      }).toList()..sort((a, b) => b.score.compareTo(a.score));

      if (high.isEmpty) break;

      var mergedThisRound = 0;
      final consumed = <int>{};
      for (final c in high) {
        if (consumed.contains(c.left.id) || consumed.contains(c.right.id)) {
          continue;
        }
        await _db.examUnitsDao.mergeUnits(
          parentUnitId: c.left.id,
          childUnitId: c.right.id,
        );
        consumed.add(c.left.id);
        consumed.add(c.right.id);
        merged.add(
          AutoMergedPair(
            parentUnitId: c.left.id,
            childUnitId: c.right.id,
            parentTitle: c.left.title,
            childTitle: c.right.title,
            score: c.score,
          ),
        );
        mergedThisRound++;
      }
      if (mergedThisRound == 0) break;
    }

    return merged;
  }

  Future<void> _downgradeUnitsWithoutEvidence(List<int> unitIds) async {
    if (unitIds.isEmpty) return;

    final ids = unitIds.toSet().toList();
    final inClause = List.filled(ids.length, '?').join(',');
    await _db.customStatement('''
      UPDATE exam_units
      SET confidence_level = 'low',
          updated_at = CAST(strftime('%s','now') AS INTEGER)
      WHERE id IN ($inClause)
        AND NOT EXISTS (
          SELECT 1
          FROM claims c
          LEFT JOIN evidence_links el ON el.claim_id = c.id
          LEFT JOIN evidence_packs ep ON ep.claim_id = c.id
          LEFT JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id
          WHERE c.exam_unit_id = exam_units.id
            AND (el.id IS NOT NULL OR epi.id IS NOT NULL)
        )
      ''', ids);
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\\\', '/');
    final idx = normalized.lastIndexOf('/');
    return idx >= 0 ? normalized.substring(idx + 1) : normalized;
  }

  String _fileNameWithSuffix(String original, int index) {
    final dot = original.lastIndexOf('.');
    final name = dot >= 0 ? original.substring(0, dot) : original;
    final ext = dot >= 0 ? original.substring(dot) : '';
    return '$name ($index)$ext';
  }

  String _inferSourceGroup(String fileName, String sourceType) {
    final lower = fileName.toLowerCase();
    // pool / practice は source_type にない広い分類
    if (lower.contains('pool') || fileName.contains('プール')) {
      return 'pool';
    }
    if (lower.contains('practice') ||
        lower.contains('drill') ||
        fileName.contains('演習') ||
        fileName.contains('練習')) {
      return 'practice';
    }
    // assignment は practice グループに統合
    if (sourceType == 'assignment') return 'practice';
    // それ以外は source_type をそのままグループ名に使う
    return sourceType;
  }

  String _inferSourceType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('past') ||
        lower.contains('exam') ||
        fileName.contains('過去問')) {
      return 'past_exam';
    }
    if (lower.contains('prof') ||
        lower.contains('teacher') ||
        fileName.contains('教授') ||
        fileName.contains('先生')) {
      return 'professor_notes';
    }
    if (lower.contains('voice') ||
        lower.contains('audio') ||
        lower.contains('record') ||
        fileName.contains('音声')) {
      return 'voice_memo';
    }
    if (lower.contains('note') || fileName.contains('ノート')) {
      return 'notes';
    }
    if (lower.contains('assignment') || fileName.contains('課題')) {
      return 'assignment';
    }
    return 'lecture';
  }

  Future<int> _createExamProfile({
    required String examName,
    required DateTime? examDate,
    required String? subject,
    required List<int> sourceIds,
    required List<int> unitIds,
  }) async {
    await _db.customStatement(
      '''
      INSERT INTO exam_profiles (exam_name, exam_date, subject, created_at)
      VALUES (?, ?, ?, CURRENT_TIMESTAMP)
      ''',
      [
        examName,
        examDate?.toIso8601String(),
        (subject != null && subject.trim().isNotEmpty) ? subject.trim() : null,
      ],
    );
    final row = await _db
        .customSelect('SELECT CAST(last_insert_rowid() AS INTEGER) AS id')
        .getSingle();
    final profileId = row.read<int>('id');

    final sourceSet = sourceIds.toSet();
    for (final sourceId in sourceSet) {
      await _db.customStatement(
        '''
        INSERT OR IGNORE INTO exam_profile_sources (exam_profile_id, source_id)
        VALUES (?, ?)
        ''',
        [profileId, sourceId],
      );
    }

    final unitSet = unitIds.toSet();
    for (final unitId in unitSet) {
      await _db.customStatement(
        '''
        INSERT OR IGNORE INTO exam_profile_units (exam_profile_id, exam_unit_id)
        VALUES (?, ?)
        ''',
        [profileId, unitId],
      );
    }

    return profileId;
  }
}
