import '../pdf_extractor.dart';
import 'models.dart';

class SyncfusionExtractor implements PageTextExtractor {
  @override
  Future<List<ExtractedPage>> extract(String pdfPath) async {
    final pages = await PdfExtractor.extractPages(pdfPath);
    return pages
        .map((p) => ExtractedPage(pageNumber: p.pageNumber, text: p.text))
        .toList();
  }
}
