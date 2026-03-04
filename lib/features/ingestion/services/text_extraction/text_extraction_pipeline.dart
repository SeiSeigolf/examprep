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
        return _score('syncfusion', await syncfusion.extract(pdfPath));
      case ExtractionForceMode.poppler:
        return _score('poppler', await poppler.extract(pdfPath));
      case ExtractionForceMode.ocr:
        return _score('ocr', await ocr.extract(pdfPath));
      case ExtractionForceMode.auto:
        return _extractAuto(pdfPath);
    }
  }

  Future<ExtractionResult> _extractAuto(String pdfPath) async {
    final sync = _score('syncfusion', await syncfusion.extract(pdfPath));
    if (sync.qualityScore >= 0.70) return sync;

    ExtractionResult? pop;
    var popplerAvailable = true;
    try {
      pop = _score('poppler', await poppler.extract(pdfPath));
    } on PopplerMissingException {
      popplerAvailable = false;
    }

    if (pop != null && pop.qualityScore >= 0.70) {
      return ExtractionResult(
        method: pop.method,
        pages: pop.pages,
        qualityScore: pop.qualityScore,
        popplerAvailable: popplerAvailable,
      );
    }

    if (pop != null && sync.qualityScore >= 0.40 && pop.qualityScore >= 0.40) {
      final best = pop.qualityScore > sync.qualityScore ? pop : sync;
      return ExtractionResult(
        method: best.method,
        pages: best.pages,
        qualityScore: best.qualityScore,
        popplerAvailable: popplerAvailable,
      );
    }

    if ((sync.pages.isEmpty || sync.qualityScore < 0.40) &&
        (pop == null || pop.pages.isEmpty || pop.qualityScore < 0.40)) {
      final ocrResult = _score('ocr', await ocr.extract(pdfPath));
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
    return ExtractionResult(
      method: fallback.method,
      pages: fallback.pages,
      qualityScore: fallback.qualityScore,
      popplerAvailable: popplerAvailable,
    );
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
