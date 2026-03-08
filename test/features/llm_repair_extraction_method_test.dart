/// LLM repair が extraction_method サフィックスとして正しく記録されることを検証する。
///
/// 検証観点:
///   - changed=true  → `<base>+llm_changed`
///   - changed=false, LLM適用 → `<base>+llm`
///   - LLM失敗/スキップ → サフィックスなし（元の method のまま）
library;

import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/ingestion/services/llm_text_repair_service.dart';
import 'package:exam_os/features/ingestion/services/ollama_client.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── モック OllamaClient ─────────────────────────────────────────────

class _MockOllamaClient extends OllamaClient {
  _MockOllamaClient(this._response)
    : super(baseUrl: 'http://localhost:11434');

  final String? _response;

  @override
  Future<String?> generate({
    required String model,
    required String prompt,
    double temperature = 0.0,
  }) async => _response;
}

String _repairJson({
  required String cleanText,
  required String qualityLabel,
  required String segmentKind,
  required bool changed,
  List<String> flags = const [],
}) {
  final escapedText = cleanText
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n');
  final flagsJson = flags.map((f) => '"$f"').join(', ');
  return '{"clean_text":"$escapedText","quality_label":"$qualityLabel",'
      '"suggested_segment_kind":"$segmentKind","flags":[$flagsJson],'
      '"changed":$changed}';
}

// ─── ヘルパー: DBとソースを作成してセグメントを取得 ───────────────────────

AppDatabase _makeDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// テスト用テキスト（60文字以上: 60文字丁度になるよう調整）
const _longText =
    '心不全とは心拍出量が低下し末梢組織の需要を満たせない病態。'
    '浮腫・呼吸困難が主症状で、治療は利尿薬・ACE阻害薬が基本です。';

Future<String?> _runRepairAndInsert({
  required AppDatabase db,
  required LlmTextRepairService repairSvc,
  required String rawText,
  required String baseExtractionMethod,
}) async {
  // source を作成
  final sourceId = await db.sourcesDao.insertSource(
    SourcesCompanion.insert(
      fileName: 'test.pdf',
      filePath: '/tmp/test_${DateTime.now().microsecondsSinceEpoch}.pdf',
      sourceType: const Value('lecture'),
    ),
  );

  // repair を実行
  final repair = await repairSvc.repairPageText(
    rawText: rawText,
    pageNumber: 1,
    sourceFileName: 'test.pdf',
  );

  final kind = repair.flags.contains('llm_skipped') ? 'content' : repair.suggestedSegmentKind;

  // セグメントを保存（pipeline/provider と同じロジック）
  await db.sourcesDao.insertSegments([
    SourceSegmentsCompanion.insert(
      sourceId: sourceId,
      pageNumber: 1,
      content: Value(repair.cleanText),
      extractionMethod: Value(repair.suffixedMethod(baseExtractionMethod)),
      segmentKind: Value(kind),
    ),
  ]);

  // 保存された extraction_method を読み取る
  final rows = await db.customSelect(
    'SELECT extraction_method FROM source_segments WHERE source_id = ?',
    variables: [Variable<int>(sourceId)],
  ).get();
  if (rows.isEmpty) return null;
  return rows.first.read<String?>('extraction_method');
}

// ─────────────────────────────────────────────────────────────────────

void main() {
  group('LLM repair extraction_method サフィックス', () {
    test('changed=true のとき "+llm_changed" が付く', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          _repairJson(
            cleanText: '心不全とは心拍出量が低下し末梢組織の需要を満たせない病態。',
            qualityLabel: 'H',
            segmentKind: 'content',
            changed: true,
          ),
        ),
      );

      final method = await _runRepairAndInsert(
        db: db,
        repairSvc: svc,
        rawText: _longText,
        baseExtractionMethod: 'poppler',
      );

      expect(method, 'poppler+llm_changed');
    });

    test('changed=false, LLM適用 のとき "+llm" が付く', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          _repairJson(
            cleanText: _longText,
            qualityLabel: 'M',
            segmentKind: 'content',
            changed: false,
          ),
        ),
      );

      final method = await _runRepairAndInsert(
        db: db,
        repairSvc: svc,
        rawText: _longText,
        baseExtractionMethod: 'ocr',
      );

      expect(method, 'ocr+llm');
    });

    test('LLM失敗（null レスポンス）のとき元の method のまま', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final svc = LlmTextRepairService(
        client: _MockOllamaClient(null),
      );

      final method = await _runRepairAndInsert(
        db: db,
        repairSvc: svc,
        rawText: _longText,
        baseExtractionMethod: 'syncfusion',
      );

      expect(method, 'syncfusion');
    });

    test('LLM失敗（JSON破損）のとき元の method のまま', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final svc = LlmTextRepairService(
        client: _MockOllamaClient('これはJSONではありません'),
      );

      final method = await _runRepairAndInsert(
        db: db,
        repairSvc: svc,
        rawText: _longText,
        baseExtractionMethod: 'poppler',
      );

      expect(method, 'poppler');
    });

    test('テキストが短い（<60文字）ときスキップされ元の method のまま', () async {
      final db = _makeDb();
      addTearDown(db.close);

      // 短いテキスト: LLM は呼ばれず passthrough
      final svc = LlmTextRepairService(
        client: _MockOllamaClient('should not be called'),
      );

      final method = await _runRepairAndInsert(
        db: db,
        repairSvc: svc,
        rawText: '短いテキスト',
        baseExtractionMethod: 'syncfusion',
      );

      expect(method, 'syncfusion');
    });

    test('OCRベースで changed=true のとき "ocr+llm_changed"', () async {
      final db = _makeDb();
      addTearDown(db.close);

      const repairedText = '心不全とは心拍出量が低下し末梢組織の需要を満たせない病態。';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          _repairJson(
            cleanText: repairedText,
            qualityLabel: 'H',
            segmentKind: 'content',
            changed: true,
          ),
        ),
      );

      final method = await _runRepairAndInsert(
        db: db,
        repairSvc: svc,
        rawText: _longText,
        baseExtractionMethod: 'ocr',
      );

      expect(method, 'ocr+llm_changed');
    });
  });

  group('RepairResult.suffixedMethod', () {
    test('スキップ時は baseMethod そのまま', () {
      final r = RepairResult.passthrough('text');
      expect(r.suffixedMethod('poppler'), 'poppler');
    });

    test('changed=true は +llm_changed', () {
      final r = RepairResult(
        cleanText: 'clean',
        qualityLabel: 'H',
        suggestedSegmentKind: 'content',
        flags: const [],
        changed: true,
      );
      expect(r.suffixedMethod('ocr'), 'ocr+llm_changed');
    });

    test('changed=false は +llm', () {
      final r = RepairResult(
        cleanText: 'same',
        qualityLabel: 'M',
        suggestedSegmentKind: 'content',
        flags: const [],
        changed: false,
      );
      expect(r.suffixedMethod('syncfusion'), 'syncfusion+llm');
    });
  });
}
