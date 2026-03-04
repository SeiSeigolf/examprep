import 'package:exam_os/features/ingestion/services/text_extraction/models.dart';
import 'package:exam_os/features/ingestion/services/text_extraction/quality_score.dart';
import 'package:exam_os/features/ingestion/services/text_extraction/text_extraction_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExtractor implements PageTextExtractor {
  _FakeExtractor(this.pages);
  final List<ExtractedPage> pages;

  @override
  Future<List<ExtractedPage>> extract(String pdfPath) async => pages;
}

void main() {
  test('computeQualityScore: 日本語正常は高く、壊れ文字と空は低い', () {
    final good = computeQualityScore('心不全は心拍出量の低下を伴う。呼吸困難や浮腫を来すことがある。');
    final bad = computeQualityScore('�□???? ???? �□');
    final empty = computeQualityScore('');

    expect(good, greaterThanOrEqualTo(0.7));
    expect(bad, lessThan(0.4));
    expect(empty, lessThan(0.4));
  });

  test('fallback選択: sync低品質 -> poppler低品質 -> OCR採用', () async {
    final pipeline = TextExtractionPipeline(
      syncfusion: _FakeExtractor(const [
        ExtractedPage(pageNumber: 1, text: '�□????'),
      ]),
      poppler: _FakeExtractor(const [
        ExtractedPage(pageNumber: 1, text: '???? ?? □'),
      ]),
      ocr: _FakeExtractor(const [
        ExtractedPage(pageNumber: 1, text: '心不全は心拍出量の低下を伴う'),
      ]),
    );

    final result = await pipeline.extract('/tmp/a.pdf');
    expect(result.method, 'ocr');
    expect(result.qualityScore, greaterThanOrEqualTo(0.7));
  });
}
