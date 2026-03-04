import 'package:flutter/services.dart';
import 'models.dart';

class VisionOcrExtractor implements PageTextExtractor {
  const VisionOcrExtractor();

  static const _channel = MethodChannel('exam_os/vision_ocr');

  @override
  Future<List<ExtractedPage>> extract(String pdfPath) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'ocrPdf',
      {'pdfPath': pdfPath},
    );

    if (result == null) {
      throw Exception('OCR returned null');
    }

    final pageTexts = (result['pageTexts'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    final confidences = (result['confidences'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toDouble())
        .toList();

    final pages = <ExtractedPage>[];
    for (var i = 0; i < pageTexts.length; i++) {
      pages.add(
        ExtractedPage(
          pageNumber: i + 1,
          text: pageTexts[i].trim(),
          ocrConfidence: i < confidences.length ? confidences[i] : null,
        ),
      );
    }
    return pages;
  }
}
