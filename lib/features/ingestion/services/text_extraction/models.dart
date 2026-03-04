class ExtractedPage {
  const ExtractedPage({
    required this.pageNumber,
    required this.text,
    this.ocrConfidence,
    this.qualityScore,
  });

  final int pageNumber;
  final String text;
  final double? ocrConfidence;
  final double? qualityScore;

  ExtractedPage copyWith({
    String? text,
    double? ocrConfidence,
    double? qualityScore,
  }) {
    return ExtractedPage(
      pageNumber: pageNumber,
      text: text ?? this.text,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      qualityScore: qualityScore ?? this.qualityScore,
    );
  }
}

class ExtractionResult {
  const ExtractionResult({
    required this.method,
    required this.pages,
    required this.qualityScore,
    this.popplerAvailable = true,
  });

  final String method; // syncfusion|poppler|ocr
  final List<ExtractedPage> pages;
  final double qualityScore;
  final bool popplerAvailable;
}

enum ExtractionForceMode { auto, syncfusion, poppler, ocr }

abstract class PageTextExtractor {
  Future<List<ExtractedPage>> extract(String pdfPath);
}
