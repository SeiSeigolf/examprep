import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import '../services/text_extraction/syncfusion_extractor.dart';
import '../services/text_extraction/poppler_extractor.dart';
import '../services/text_extraction/text_extraction_pipeline.dart';
import '../services/text_extraction/vision_ocr_extractor.dart';
import '../services/text_extraction/models.dart';
import '../services/llm_text_repair_service.dart';
import '../services/ollama_client.dart';
import '../services/segment_kind_classifier.dart';

enum IngestionStatus { idle, picking, extracting, inserting, done, error }

class IngestionState {
  const IngestionState({
    this.status = IngestionStatus.idle,
    this.currentFile,
    this.errorMessage,
    this.extractingMethod,
    this.ocrCurrentPage,
    this.ocrTotalPages,
    this.qualityImproved = false,
    this.infoMessage,
  });

  final IngestionStatus status;
  final String? currentFile; // 処理中のファイル名
  final String? errorMessage;
  final String? extractingMethod;
  final int? ocrCurrentPage;
  final int? ocrTotalPages;
  final bool qualityImproved;
  final String? infoMessage;

  IngestionState copyWith({
    IngestionStatus? status,
    String? currentFile,
    String? errorMessage,
    String? extractingMethod,
    int? ocrCurrentPage,
    int? ocrTotalPages,
    bool? qualityImproved,
    String? infoMessage,
  }) => IngestionState(
    status: status ?? this.status,
    currentFile: currentFile ?? this.currentFile,
    errorMessage: errorMessage ?? this.errorMessage,
    extractingMethod: extractingMethod ?? this.extractingMethod,
    ocrCurrentPage: ocrCurrentPage ?? this.ocrCurrentPage,
    ocrTotalPages: ocrTotalPages ?? this.ocrTotalPages,
    qualityImproved: qualityImproved ?? this.qualityImproved,
    infoMessage: infoMessage ?? this.infoMessage,
  );
}

class IngestionNotifier extends StateNotifier<IngestionState> {
  IngestionNotifier(this._db) : super(const IngestionState());

  final AppDatabase _db;
  final LlmTextRepairService _repair = LlmTextRepairService(
    client: OllamaClient(),
  );
  late final TextExtractionPipeline _pipeline = TextExtractionPipeline(
    syncfusion: SyncfusionExtractor(),
    poppler: PopplerExtractor(),
    ocr: VisionOcrExtractor(
      onProgress: (current, total) {
        state = state.copyWith(
          extractingMethod: 'ocr',
          ocrCurrentPage: current,
          ocrTotalPages: total,
        );
      },
    ),
  );

  Future<void> pickAndImport({String? sourceType}) async {
    state = state.copyWith(status: IngestionStatus.picking);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(status: IngestionStatus.idle);
        return;
      }

      for (final file in result.files) {
        final srcPath = file.path;
        if (srcPath == null) continue;

        // ---- サンドボックス外ファイルをApplicationSupportへコピー ----
        final storedPath = await _copyToAppStorage(srcPath, file.name);

        // ---- テキスト抽出（別 isolate で実行） ----
        state = state.copyWith(
          status: IngestionStatus.extracting,
          currentFile: file.name,
          extractingMethod: 'auto',
          ocrCurrentPage: null,
          ocrTotalPages: null,
          qualityImproved: false,
          infoMessage: null,
        );

        const oldQuality = 0.0;
        final extraction = await _pipeline.extract(storedPath);
        final pages = extraction.pages;

        // ---- DB 保存 ----
        state = state.copyWith(status: IngestionStatus.inserting);

        final fileSize = File(storedPath).lengthSync();
        // sourceType が明示指定されていればそれを使い、なければファイル名から推定
        final resolvedSourceType = sourceType ?? _inferSourceType(file.name);

        final sourceId = await _db.sourcesDao.insertSource(
          SourcesCompanion.insert(
            fileName: file.name,
            filePath: storedPath,
            sourceType: Value(resolvedSourceType),
            fileSize: Value(fileSize),
            pageCount: Value(pages.length),
            lastExtractionMethod: Value(extraction.method),
            lastQualityScore: Value(extraction.qualityScore),
            extractionUpdatedAt: Value(DateTime.now()),
          ),
        );

        // LLM repair: ページごとに修復・分類（失敗時は従来動作）
        final segments = <SourceSegmentsCompanion>[];
        for (final p in pages) {
          final repair = await _repair.repairPageText(
            rawText: p.text,
            pageNumber: p.pageNumber,
            sourceFileName: file.name,
          );
          final kind = repair.flags.contains('llm_skipped')
              ? classifySegmentKind(p.text)
              : repair.suggestedSegmentKind;
          segments.add(
            SourceSegmentsCompanion.insert(
              sourceId: sourceId,
              pageNumber: p.pageNumber,
              content: Value(repair.cleanText),
              extractionMethod: Value(repair.suffixedMethod(extraction.method)),
              qualityScore: Value(p.qualityScore),
              ocrConfidence: Value(p.ocrConfidence),
              contentConfidence: Value(repair.qualityLabel),
              segmentKind: Value(kind),
            ),
          );
        }
        await _db.sourcesDao.insertSegments(segments);

        await _db.sourcesDao.recalculatePastExamFrequency();
        await _db.auditDao.refreshCoverageAudits();

        final improved =
            extraction.method == 'ocr' &&
            extraction.qualityScore > oldQuality + 0.1;
        state = state.copyWith(
          qualityImproved: improved,
          infoMessage: improved
              ? 'OCRで品質が改善しました (${extraction.qualityScore.toStringAsFixed(2)})'
              : null,
        );
      }

      state = state.copyWith(
        status: IngestionStatus.done,
        currentFile: null,
        extractingMethod: null,
        ocrCurrentPage: null,
        ocrTotalPages: null,
      );
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        status: IngestionStatus.idle,
        qualityImproved: false,
        infoMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: IngestionStatus.error,
        errorMessage: e.toString(),
        currentFile: null,
        extractingMethod: null,
        ocrCurrentPage: null,
        ocrTotalPages: null,
      );
    }
  }

  Future<void> reextractSource({
    required int sourceId,
    ExtractionForceMode mode = ExtractionForceMode.auto,
  }) async {
    try {
      final source = await _db.sourcesDao.getSourceById(sourceId);
      if (source == null) return;

      state = state.copyWith(
        status: IngestionStatus.extracting,
        currentFile: source.fileName,
        extractingMethod: mode.name,
        ocrCurrentPage: null,
        ocrTotalPages: null,
        qualityImproved: false,
        infoMessage: null,
      );

      final oldQuality = source.lastQualityScore ?? 0;
      final extraction = await _pipeline.extract(source.filePath, mode: mode);
      state = state.copyWith(status: IngestionStatus.inserting);

      await _db.sourcesDao.replaceSegmentsForSource(
        sourceId,
        extraction.pages
            .map(
              (p) => SourceSegmentsCompanion.insert(
                sourceId: sourceId,
                pageNumber: p.pageNumber,
                content: Value(p.text),
                extractionMethod: Value(extraction.method),
                qualityScore: Value(p.qualityScore),
                ocrConfidence: Value(p.ocrConfidence),
              ),
            )
            .toList(),
      );
      await _db.sourcesDao.updateSourceExtractionMeta(
        sourceId: sourceId,
        method: extraction.method,
        qualityScore: extraction.qualityScore,
        pageCount: extraction.pages.length,
      );

      await _db.sourcesDao.recalculatePastExamFrequency();
      await _db.auditDao.refreshCoverageAudits();
      final improved =
          extraction.method == 'ocr' &&
          extraction.qualityScore > oldQuality + 0.05;
      state = state.copyWith(
        status: IngestionStatus.done,
        currentFile: null,
        extractingMethod: null,
        ocrCurrentPage: null,
        ocrTotalPages: null,
        qualityImproved: improved,
        infoMessage: improved
            ? 'OCRで品質が改善しました (${oldQuality.toStringAsFixed(2)} → ${extraction.qualityScore.toStringAsFixed(2)})'
            : null,
      );
      await Future.delayed(const Duration(milliseconds: 700));
      state = state.copyWith(
        status: IngestionStatus.idle,
        qualityImproved: false,
        infoMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: IngestionStatus.error,
        errorMessage: e.toString(),
        currentFile: null,
        extractingMethod: null,
        ocrCurrentPage: null,
        ocrTotalPages: null,
      );
    }
  }

  /// ファイルをApplicationSupportのpdfsフォルダにコピーし、コピー先パスを返す。
  /// 同名ファイルが既に存在する場合は上書きしない（既存パスを返す）。
  Future<String> _copyToAppStorage(String srcPath, String fileName) async {
    final appSupport = await getApplicationSupportDirectory();
    final pdfsDir = Directory('${appSupport.path}/pdfs');
    if (!pdfsDir.existsSync()) await pdfsDir.create(recursive: true);

    final destPath = '${pdfsDir.path}/$fileName';
    final dest = File(destPath);
    if (!dest.existsSync()) {
      await File(srcPath).copy(destPath);
    }
    return destPath;
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
        lower.contains('録音') ||
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
}

final ingestionProvider =
    StateNotifierProvider<IngestionNotifier, IngestionState>((ref) {
      final db = ref.watch(databaseProvider);
      return IngestionNotifier(db);
    });
