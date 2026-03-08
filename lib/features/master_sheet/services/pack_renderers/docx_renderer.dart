import 'dart:io';

import 'package:archive/archive.dart';

/// Markdown テキストを最小限の DOCX (OOXML) に変換して保存する。
///
/// DOCX = ZIP of XML。外部送信なし・ローカル完結。
/// MVP: 見出し(H1/H2/H3) + 本文 + テーブル行。
/// Boolein inline bold 未対応（**text** はそのままテキストに）。
Future<void> renderMarkdownToDocx(
  String markdown,
  String outputPath,
) async {
  final bodyXml = _markdownToDocxBody(markdown);
  final docBytes = _buildDocxBytes(bodyXml);
  await File(outputPath).writeAsBytes(docBytes);
}

// ============================================================
// Markdown → Word body XML
// ============================================================

String _markdownToDocxBody(String markdown) {
  final buf = StringBuffer();
  for (final rawLine in markdown.split('\n')) {
    final line = rawLine.trimRight();
    if (line.startsWith('# ')) {
      buf.write(_paragraph(line.substring(2), style: 'Heading1'));
    } else if (line.startsWith('## ')) {
      buf.write(_paragraph(line.substring(3), style: 'Heading2'));
    } else if (line.startsWith('### ')) {
      buf.write(_paragraph(line.substring(4), style: 'Heading3'));
    } else if (line.startsWith('---')) {
      buf.write(_hrParagraph());
    } else if (line.startsWith('|')) {
      // テーブル行 → 等幅段落
      buf.write(_paragraph(line, mono: true));
    } else if (line.isEmpty) {
      buf.write(_paragraph(''));
    } else {
      buf.write(_paragraph(_stripMarkdown(line)));
    }
  }
  return buf.toString();
}

String _paragraph(
  String text, {
  String? style,
  bool mono = false,
}) {
  final styleXml = style != null
      ? '<w:pStyle w:val="${_xmlEscape(style)}"/>'
      : '';
  final fontXml = mono
      ? '<w:rFonts w:ascii="Courier New" w:hAnsi="Courier New"/><w:sz w:val="18"/>'
      : '';
  return '<w:p>'
      '<w:pPr><w:pStyle w:val="${_xmlEscape(style ?? 'Normal')}"/></w:pPr>'
      '<w:r>'
      '<w:rPr>$fontXml</w:rPr>'
      '<w:t xml:space="preserve">${_xmlEscape(text)}</w:t>'
      '</w:r>'
      '</w:p>';
}

String _hrParagraph() {
  return '<w:p>'
      '<w:pPr>'
      '<w:pBdr>'
      '<w:bottom w:val="single" w:sz="6" w:space="1" w:color="AAAAAA"/>'
      '</w:pBdr>'
      '</w:pPr>'
      '</w:p>';
}

String _stripMarkdown(String s) {
  // ** bold ** を剥ぐ
  return s.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
}

String _xmlEscape(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

// ============================================================
// DOCX バイナリ構築
// ============================================================

List<int> _buildDocxBytes(String bodyXml) {
  final archive = Archive();

  // [Content_Types].xml
  _addFile(
    archive,
    '[Content_Types].xml',
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml"
    ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml"
    ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>''',
  );

  // _rels/.rels
  _addFile(
    archive,
    '_rels/.rels',
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
    Target="word/document.xml"/>
</Relationships>''',
  );

  // word/_rels/document.xml.rels
  _addFile(
    archive,
    'word/_rels/document.xml.rels',
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
    Target="styles.xml"/>
</Relationships>''',
  );

  // word/styles.xml（最小限：Normal + Heading1-3）
  _addFile(archive, 'word/styles.xml', _stylesXml());

  // word/document.xml
  _addFile(
    archive,
    'word/document.xml',
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
$bodyXml
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
    </w:sectPr>
  </w:body>
</w:document>''',
  );

  return ZipEncoder().encode(archive) ?? [];
}

void _addFile(Archive archive, String name, String content) {
  final bytes = content.codeUnits;
  archive.addFile(
    ArchiveFile(name, bytes.length, bytes),
  );
}

String _stylesXml() => '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:styleId="Normal" w:default="1">
    <w:name w:val="Normal"/>
    <w:rPr>
      <w:rFonts w:ascii="Hiragino Kaku Gothic Pro" w:hAnsi="Hiragino Kaku Gothic Pro"/>
      <w:sz w:val="22"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="40"/>
      <w:color w:val="1F3A5F"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="32"/>
      <w:color w:val="2A5298"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:basedOn w:val="Normal"/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="26"/>
    </w:rPr>
  </w:style>
</w:styles>''';
