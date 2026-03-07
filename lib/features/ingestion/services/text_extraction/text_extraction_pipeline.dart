import 'package:flutter/foundation.dart';
import 'models.dart';
import 'poppler_extractor.dart';
import 'quality_score.dart';

class TextExtractionPipeline {
  TextExtractionPipeline({
    required this.syncfusion,
    required this.poppler,
    required this.ocr,
  });

  final PageTextExtractor syncfusion;
  final PageTextExtractor poppler;
  final PageTextExtractor ocr;

  Future<ExtractionResult> extract(
    String pdfPath, {
    ExtractionForceMode mode = ExtractionForceMode.auto,
  }) async {
    switch (mode) {
      case ExtractionForceMode.syncfusion:
        debugPrint('[Pipeline] Step 1: Syncfusion抽出開始');
        final r = _score('syncfusion', await syncfusion.extract(pdfPath));
        debugPrint('[Pipeline] Step 1: Syncfusion完了 score=${r.qualityScore.toStringAsFixed(2)}');
        _printPagePreviews(r.pages);
        debugPrint('[Pipeline] 最終採用: method=${r.method} score=${r.qualityScore.toStringAsFixed(2)}');
        return r;
      case ExtractionForceMode.poppler:
        debugPrint('[Pipeline] Step 2: Poppler抽出開始');
        final r = _score('poppler', await poppler.extract(pdfPath));
        debugPrint('[Pipeline] Step 2: Poppler完了 score=${r.qualityScore.toStringAsFixed(2)}');
        _printPagePreviews(r.pages);
        debugPrint('[Pipeline] 最終採用: method=${r.method} score=${r.qualityScore.toStringAsFixed(2)}');
        return r;
      case ExtractionForceMode.ocr:
        debugPrint('[Pipeline] Step 3: OCR抽出開始');
        final r = _score('ocr', await ocr.extract(pdfPath));
        debugPrint('[Pipeline] Step 3: OCR完了 score=${r.qualityScore.toStringAsFixed(2)}');
        _printPagePreviews(r.pages);
        debugPrint('[Pipeline] 最終採用: method=${r.method} score=${r.qualityScore.toStringAsFixed(2)}');
        return r;
      case ExtractionForceMode.auto:
        return _extractAuto(pdfPath);
    }
  }

  Future<ExtractionResult> _extractAuto(String pdfPath) async {
    debugPrint('[Pipeline] Step 1: Syncfusion抽出開始');
    final sync = _score('syncfusion', await syncfusion.extract(pdfPath));
    debugPrint('[Pipeline] Step 1: Syncfusion完了 score=${sync.qualityScore.toStringAsFixed(2)}');
    _printPagePreviews(sync.pages);
    if (sync.qualityScore >= 0.85) {
      debugPrint('[Pipeline] 最終採用: method=${sync.method} score=${sync.qualityScore.toStringAsFixed(2)}');
      return sync;
    }

    ExtractionResult? pop;
    var popplerAvailable = true;
    try {
      debugPrint('[Pipeline] Step 2: Poppler抽出開始');
      pop = _score('poppler', await poppler.extract(pdfPath));
      debugPrint('[Pipeline] Step 2: Poppler完了 score=${pop.qualityScore.toStringAsFixed(2)}');
      _printPagePreviews(pop.pages);
    } on PopplerMissingException {
      popplerAvailable = false;
      debugPrint('[Pipeline] Step 2: Poppler未導入 スキップ');
    }

    if (pop != null && pop.qualityScore >= 0.85) {
      debugPrint('[Pipeline] 最終採用: method=${pop.method} score=${pop.qualityScore.toStringAsFixed(2)}');
      return ExtractionResult(
        method: pop.method,
        pages: pop.pages,
        qualityScore: pop.qualityScore,
        popplerAvailable: popplerAvailable,
      );
    }

    if (pop != null && sync.qualityScore >= 0.50 && pop.qualityScore >= 0.50) {
      final best = pop.qualityScore > sync.qualityScore ? pop : sync;
      debugPrint('[Pipeline] Syncfusion=${sync.qualityScore.toStringAsFixed(2)} vs Poppler=${pop.qualityScore.toStringAsFixed(2)} → ${best.method}を採用');
      debugPrint('[Pipeline] 最終採用: method=${best.method} score=${best.qualityScore.toStringAsFixed(2)}');
      return ExtractionResult(
        method: best.method,
        pages: best.pages,
        qualityScore: best.qualityScore,
        popplerAvailable: popplerAvailable,
      );
    }

    if ((sync.pages.isEmpty || sync.qualityScore < 0.50) &&
        (pop == null || pop.pages.isEmpty || pop.qualityScore < 0.50)) {
      debugPrint('[Pipeline] Step 3: OCR抽出開始');
      final ocrResult = _score('ocr', await ocr.extract(pdfPath));
      debugPrint('[Pipeline] Step 3: OCR完了 score=${ocrResult.qualityScore.toStringAsFixed(2)}');
      _printPagePreviews(ocrResult.pages);
      debugPrint('[Pipeline] 最終採用: method=${ocrResult.method} score=${ocrResult.qualityScore.toStringAsFixed(2)}');
      return ExtractionResult(
        method: ocrResult.method,
        pages: ocrResult.pages,
        qualityScore: ocrResult.qualityScore,
        popplerAvailable: popplerAvailable,
      );
    }

    final fallback = pop != null && pop.qualityScore > sync.qualityScore
        ? pop
        : sync;
    debugPrint('[Pipeline] 最終採用: method=${fallback.method} score=${fallback.qualityScore.toStringAsFixed(2)}');
    return ExtractionResult(
      method: fallback.method,
      pages: fallback.pages,
      qualityScore: fallback.qualityScore,
      popplerAvailable: popplerAvailable,
    );
  }

  void _printPagePreviews(List<ExtractedPage> pages) {
    for (final p in pages) {
      final preview = p.text.replaceAll('\n', ' ').trim();
      final snippet = preview.length > 50 ? preview.substring(0, 50) : preview;
      debugPrint('[Pipeline]   p${p.pageNumber}: "$snippet"');
    }
  }

  ExtractionResult _score(String method, List<ExtractedPage> rawPages) {
    if (rawPages.isEmpty) {
      return ExtractionResult(method: method, pages: const [], qualityScore: 0);
    }
    final scoredPages = rawPages
        .map((p) => p.copyWith(qualityScore: computeQualityScore(p.text)))
        .toList();
    final avg =
        scoredPages.map((p) => p.qualityScore ?? 0).reduce((a, b) => a + b) /
        scoredPages.length;
    return ExtractionResult(
      method: method,
      pages: scoredPages,
      qualityScore: avg,
    );
  }
}
