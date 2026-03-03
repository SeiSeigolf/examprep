import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import '../services/pdf_extractor.dart';

enum IngestionStatus { idle, picking, extracting, inserting, done, error }

class IngestionState {
  const IngestionState({
    this.status = IngestionStatus.idle,
    this.currentFile,
    this.errorMessage,
  });

  final IngestionStatus status;
  final String? currentFile;  // 処理中のファイル名
  final String? errorMessage;

  IngestionState copyWith({
    IngestionStatus? status,
    String? currentFile,
    String? errorMessage,
  }) =>
      IngestionState(
        status: status ?? this.status,
        currentFile: currentFile ?? this.currentFile,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class IngestionNotifier extends StateNotifier<IngestionState> {
  IngestionNotifier(this._db) : super(const IngestionState());

  final AppDatabase _db;

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

        final pages = await compute(PdfExtractor.extractPages, path);

        // ---- DB 保存 ----
        state = state.copyWith(status: IngestionStatus.inserting);

        final fileSize = File(path).lengthSync();

        final sourceId = await _db.sourcesDao.insertSource(
          SourcesCompanion.insert(
            fileName: file.name,
            filePath: path,
            fileSize: Value(fileSize),
            pageCount: Value(pages.length),
          ),
        );

        // ページごとにセグメントを登録（テキスト付き）
        await _db.sourcesDao.insertSegments(
          pages
              .map((p) => SourceSegmentsCompanion.insert(
                    sourceId: sourceId,
                    pageNumber: p.pageNumber,
                    content: Value(p.text),
                  ))
              .toList(),
        );
      }

      state = state.copyWith(
        status: IngestionStatus.done,
        currentFile: null,
      );
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
}

final ingestionProvider =
    StateNotifierProvider<IngestionNotifier, IngestionState>((ref) {
  final db = ref.watch(databaseProvider);
  return IngestionNotifier(db);
});
