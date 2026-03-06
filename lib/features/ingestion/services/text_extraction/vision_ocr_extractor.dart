import 'package:flutter/services.dart';
import 'models.dart';

typedef OcrProgressCallback = void Function(int current, int total);

class VisionOcrExtractor implements PageTextExtractor {
  const VisionOcrExtractor({this.onProgress});

  static const _channel = MethodChannel('exam_os/vision_ocr');
  final OcrProgressCallback? onProgress;

  @override
  Future<List<ExtractedPage>> extract(String pdfPath) async {
    Future<void> progressHandler(MethodCall call) async {
      if (call.method != 'ocrProgress') return;
      final args = call.arguments as Map<dynamic, dynamic>? ?? const {};
      final current = (args['current'] as num?)?.toInt() ?? 0;
      final total = (args['total'] as num?)?.toInt() ?? 0;
      onProgress?.call(current, total);
    }

    _channel.setMethodCallHandler(progressHandler);
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'ocrPdf',
      {'pdfPath': pdfPath},
    );
    _channel.setMethodCallHandler(null);

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
