import 'dart:io';
import 'models.dart';

class PopplerMissingException implements Exception {
  const PopplerMissingException();

  @override
  String toString() =>
      'pdftotext not found. Install with: brew install poppler';
}

class PopplerExtractor implements PageTextExtractor {
  // macOSのGUIアプリはシェルのPATHを継承しないため、固定パスで探す
  static const _candidatePaths = [
    '/opt/homebrew/bin/pdftotext', // Apple Silicon Homebrew
    '/usr/local/bin/pdftotext',    // Intel Homebrew
    'pdftotext',                    // PATH経由（fallback）
  ];

  static Future<String?> _resolvedPath() async {
    for (final candidate in _candidatePaths) {
      try {
        // 引数なしで実行: Usage表示してexit!=0で終わるがProcessExceptionは投げない
        // ProcessExceptionが投げられなければバイナリが存在する
        await Process.run(candidate, []);
        return candidate;
      } on ProcessException {
        // バイナリが見つからない場合は次を試す
      }
    }
    return null;
  }

  static Future<bool> isAvailable() async {
    return await _resolvedPath() != null;
  }

  @override
  Future<List<ExtractedPage>> extract(String pdfPath) async {
    final executable = await _resolvedPath();
    if (executable == null) throw const PopplerMissingException();

    final tempDir = await Directory.systemTemp.createTemp('exam_os_poppler_');
    try {
      final outPath = '${tempDir.path}/out.txt';
      final result = await Process.run(executable, [
        '-layout',
        pdfPath,
        outPath,
      ]);

      if (result.exitCode != 0) {
        final stderr = (result.stderr ?? '').toString().toLowerCase();
        if (stderr.contains('not found') || stderr.contains('no such file')) {
          throw const PopplerMissingException();
        }
        throw Exception('pdftotext failed: ${result.stderr}');
      }

      final text = await File(outPath).readAsString();
      final chunks = text.split('\f');
      final pages = <ExtractedPage>[];
      for (var i = 0; i < chunks.length; i++) {
        final page = chunks[i].trim();
        if (i == chunks.length - 1 && page.isEmpty) continue;
        pages.add(ExtractedPage(pageNumber: i + 1, text: page));
      }
      return pages;
    } on ProcessException {
      throw const PopplerMissingException();
    } finally {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  }
}
