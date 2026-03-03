import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PageText {
  const PageText({required this.pageNumber, required this.text});
  final int pageNumber;
  final String text;
}

class PdfExtractor {
  /// PDFファイルからページごとにテキストを抽出する。
  /// 画像PDFなどテキストなしのページは空文字になる。
  /// isolate から呼び出せるよう static にしている。
  static Future<List<PageText>> extractPages(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final count = document.pages.count;

    final results = <PageText>[];
    for (int i = 0; i < count; i++) {
      try {
        final text =
            extractor.extractText(startPageIndex: i, endPageIndex: i);
        results.add(PageText(pageNumber: i + 1, text: text.trim()));
      } catch (_) {
        // テキスト抽出に失敗したページは空文字で登録
        results.add(PageText(pageNumber: i + 1, text: ''));
      }
    }

    document.dispose();
    return results;
  }
}
