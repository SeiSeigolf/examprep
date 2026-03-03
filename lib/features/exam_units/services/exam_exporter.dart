import 'dart:io';
import 'dart:math';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../../db/database.dart';

class ExamExporter {
  /// 全 Exam Unit を Markdown でエクスポートし、保存したパスを返す。
  /// ファイルセレクターダイアログ → 失敗時はドキュメントフォルダへ自動保存。
  static Future<String> export(AppDatabase db) async {
    final units = await db.examUnitsDao.getAllUnits();
    debugPrint('[Export] units.length = ${units.length}');

    final buf = StringBuffer();
    buf.writeln('# ExamOS エクスポート');
    buf.writeln('エクスポート日時: ${DateTime.now().toLocal()}');
    buf.writeln();
    buf.writeln('---');
    buf.writeln();

    for (final unit in units) {
      final level = const {
            'high': 'High',
            'medium': 'Medium',
            'low': 'Low',
          }[unit.confidenceLevel] ??
          unit.confidenceLevel;
      buf.writeln('## ${unit.title} (信頼度: $level)');
      buf.writeln('タイプ: ${unit.unitType}');
      buf.writeln();
      if (unit.description != null && unit.description!.isNotEmpty) {
        buf.writeln(unit.description);
        buf.writeln();
      }

      final claims = await db.claimsDao.getClaimsForUnit(unit.id);
      if (claims.isNotEmpty) {
        buf.writeln('### Claims');
        for (final claim in claims) {
          final evidences = await db.claimsDao.getEvidenceForClaim(claim.id);
          final refs = evidences
              .map((e) => '${e.source.fileName} p.${e.segment.pageNumber}')
              .join(', ');
          final suffix = refs.isEmpty ? '' : ' (根拠: $refs)';
          buf.writeln('- ${claim.content}$suffix');
        }
        buf.writeln();
      }
    }

    final content = buf.toString();
    debugPrint('[Export] markdown preview (100 chars): '
        '${content.substring(0, min(100, content.length))}');

    // ① ファイルセレクターダイアログを試みる
    String? savePath;
    try {
      final location = await getSaveLocation(
        suggestedName: 'exam_units_export.md',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Markdown', extensions: ['md']),
        ],
      );
      debugPrint('[Export] getSaveLocation returned: ${location?.path}');
      savePath = location?.path;
    } catch (e) {
      debugPrint('[Export] getSaveLocation threw: $e');
    }

    // ② ダイアログが使えない場合はドキュメントフォルダへ自動保存
    if (savePath == null) {
      debugPrint('[Export] falling back to documents directory');
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      savePath = '${dir.path}/exam_units_$ts.md';
    }

    await File(savePath).writeAsString(content);
    debugPrint('[Export] saved to: $savePath');
    return savePath;
  }
}
