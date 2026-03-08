import 'dart:io';
import 'dart:ui' show Offset, Rect;

import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Markdown テキストを Syncfusion PDF に変換して保存する。
///
/// MVP: 「読めるPDF」優先。
/// - `# `  → 大見出し（20pt 太字）
/// - `## ` → 中見出し（16pt 太字）
/// - `### `→ 小見出し（13pt 太字）
/// - `|...|` テーブル行 → 等幅フォント
/// - `---` → 区切り線
/// - その他 → 本文（11pt）
Future<void> renderMarkdownToPdf(
  String markdown,
  String outputPath,
) async {
  final doc = PdfDocument();
  final page = doc.pages.add();
  final size = page.getClientSize();

  const margin = 40.0;
  final textWidth = size.width - margin * 2;

  // フォント
  final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
  final h1Font =
      PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
  final h2Font =
      PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
  final h3Font =
      PdfStandardFont(PdfFontFamily.helvetica, 13, style: PdfFontStyle.bold);
  final monoFont = PdfStandardFont(PdfFontFamily.courier, 10);
  final boldFont =
      PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

  final brush = PdfSolidBrush(PdfColor(30, 30, 30));
  final format = PdfLayoutFormat(layoutType: PdfLayoutType.paginate);

  PdfPage currentPage = page;
  var y = 0.0;

  void drawLine() {
    currentPage.graphics.drawLine(
      PdfPen(PdfColor(180, 180, 180)),
      Offset(margin, y),
      Offset(size.width - margin, y),
    );
    y += 8;
  }

  void drawText(
    String text,
    PdfFont font, {
    double topPad = 0,
    double bottomPad = 4.0,
  }) {
    y += topPad;
    final element = PdfTextElement(text: text, font: font, brush: brush);
    final result = element.draw(
      page: currentPage,
      bounds: Rect.fromLTWH(
        margin,
        y,
        textWidth,
        size.height - y - margin,
      ),
      format: format,
    );
    if (result != null) {
      if (result.page != currentPage) {
        currentPage = result.page;
      }
      y = result.bounds.bottom + bottomPad;
    } else {
      y += font.size + bottomPad;
    }
  }

  for (final rawLine in markdown.split('\n')) {
    final line = rawLine.trimRight();

    if (line.startsWith('# ')) {
      drawText(line.substring(2), h1Font, topPad: 8, bottomPad: 6);
    } else if (line.startsWith('## ')) {
      drawText(line.substring(3), h2Font, topPad: 6, bottomPad: 4);
    } else if (line.startsWith('### ')) {
      drawText(line.substring(4), h3Font, topPad: 4, bottomPad: 3);
    } else if (line.startsWith('---')) {
      drawLine();
    } else if (line.startsWith('|')) {
      drawText(line, monoFont, bottomPad: 2);
    } else if (line.startsWith('**') &&
        line.endsWith('**') &&
        line.length > 4) {
      drawText(line.replaceAll('**', ''), boldFont);
    } else if (line.isEmpty) {
      y += 5;
    } else {
      final plain = line.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
      drawText(plain, bodyFont);
    }
  }

  final bytes = doc.saveSync();
  doc.dispose();
  await File(outputPath).writeAsBytes(bytes);
}
