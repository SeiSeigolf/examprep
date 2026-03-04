import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import '../services/text_extraction/syncfusion_extractor.dart';
import '../services/text_extraction/poppler_extractor.dart';
import '../services/text_extraction/text_extraction_pipeline.dart';
import '../services/text_extraction/vision_ocr_extractor.dart';
import '../services/text_extraction/models.dart';

enum IngestionStatus { idle, picking, extracting, inserting, done, error }

class IngestionState {
  const IngestionState({
    this.status = IngestionStatus.idle,
    this.currentFile,
    this.errorMessage,
  });

  final IngestionStatus status;
  final String? currentFile; // 処理中のファイル名
  final String? errorMessage;

  IngestionState copyWith({
    IngestionStatus? status,
    String? currentFile,
    String? errorMessage,
  }) => IngestionState(
    status: status ?? this.status,
    currentFile: currentFile ?? this.currentFile,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class IngestionNotifier extends StateNotifier<IngestionState> {
  IngestionNotifier(this._db) : super(const IngestionState());

  final AppDatabase _db;
  late final TextExtractionPipeline _pipeline = TextExtractionPipeline(
    syncfusion: SyncfusionExtractor(),
    poppler: PopplerExtractor(),
    ocr: const VisionOcrExtractor(),
  );

  Future<void> pickAndImport() async {
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
        final path = file.path;
        if (path == null) continue;

        // ---- テキスト抽出（別 isolate で実行） ----
        state = state.copyWith(
          status: IngestionStatus.extracting,
          currentFile: file.name,
        );

        final extraction = await _pipeline.extract(path);
        final pages = extraction.pages;

        // ---- DB 保存 ----
        state = state.copyWith(status: IngestionStatus.inserting);

        final fileSize = File(path).lengthSync();
        final sourceType = _inferSourceType(file.name);

        final sourceId = await _db.sourcesDao.insertSource(
          SourcesCompanion.insert(
            fileName: file.name,
            filePath: path,
            sourceType: Value(sourceType),
            fileSize: Value(fileSize),
            pageCount: Value(pages.length),
            lastExtractionMethod: Value(extraction.method),
            lastQualityScore: Value(extraction.qualityScore),
            extractionUpdatedAt: Value(DateTime.now()),
          ),
        );

        // ページごとにセグメントを登録（テキスト付き）
        await _db.sourcesDao.insertSegments(
          pages
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

        await _db.sourcesDao.recalculatePastExamFrequency();
        await _db.auditDao.refreshCoverageAudits();
      }

      state = state.copyWith(status: IngestionStatus.done, currentFile: null);
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(status: IngestionStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: IngestionStatus.error,
        errorMessage: e.toString(),
        currentFile: null,
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
      );

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
      state = state.copyWith(status: IngestionStatus.done, currentFile: null);
      await Future.delayed(const Duration(milliseconds: 700));
      state = state.copyWith(status: IngestionStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: IngestionStatus.error,
        errorMessage: e.toString(),
        currentFile: null,
      );
    }
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
