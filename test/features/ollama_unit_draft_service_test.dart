import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/quick_generate/services/ollama_unit_draft_service.dart';
import 'package:exam_os/shared/llm/ollama_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// ─── モック http.Client ────────────────────────────────────────────────

class _MockHttpClient extends http.BaseClient {
  _MockHttpClient(this._responseBody);

  final String _responseBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode(_responseBody)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _FailingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw Exception('connection refused');
  }
}

String _ollamaResponse(String innerJson) =>
    '{"model":"qwen3:4b","response":${_jsonStr(innerJson)},"thinking":"","done":true}';

String _jsonStr(String s) =>
    '"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';

AppDatabase _makeDb() => AppDatabase.forTesting(NativeDatabase.memory());

// ─────────────────────────────────────────────────────────────────────

void main() {
  group('SharedOllamaClient', () {
    test('thinking フィールドを無視して response だけ返す', () async {
      const innerJson =
          '{"units":[{"title":"心不全","unitType":"定義","problemFormat":"選択肢"}]}';
      final client = SharedOllamaClient(
        httpClient: _MockHttpClient(_ollamaResponse(innerJson)),
      );
      final result = await client.generate(model: 'qwen3:4b', prompt: 'test');
      expect(result, innerJson);
    });

    test('generateJson: response 内の JSON を二重デコード', () async {
      const innerJson =
          '{"units":[{"title":"大動脈解離","unitType":"鑑別","problemFormat":"選択肢"}]}';
      final client = SharedOllamaClient(
        httpClient: _MockHttpClient(_ollamaResponse(innerJson)),
      );
      final json = await client.generateJson(
        model: 'qwen3:4b',
        prompt: 'test',
      );
      expect(json, isNotNull);
      expect(json!['units'], isA<List>());
      expect((json['units'] as List).first['title'], '大動脈解離');
    });

    test('接続失敗時は null を返す', () async {
      final client = SharedOllamaClient(
        httpClient: _FailingHttpClient(),
      );
      final result = await client.generate(model: 'qwen3:4b', prompt: 'test');
      expect(result, isNull);
    });

    test('thinking が空でも正常動作', () async {
      const body =
          '{"model":"qwen3:4b","response":"hello","thinking":null,"done":true}';
      final client = SharedOllamaClient(httpClient: _MockHttpClient(body));
      final result = await client.generate(model: 'qwen3:4b', prompt: 'test');
      expect(result, 'hello');
    });
  });

  group('OllamaUnitDraftService', () {
    test('正常なJSONレスポンスから SegmentUnitDraft リストを生成', () async {
      final db = _makeDb();
      addTearDown(db.close);

      // セットアップ: source + content セグメント
      final sourceId = await db.sourcesDao.insertSource(
        SourcesCompanion.insert(
          fileName: 'cardio.pdf',
          filePath: '/tmp/cardio.pdf',
          sourceType: const Value('lecture'),
        ),
      );
      await db.sourcesDao.insertSegments([
        SourceSegmentsCompanion.insert(
          sourceId: sourceId,
          pageNumber: 1,
          content: const Value(
            '心不全は心拍出量低下。浮腫・呼吸困難が主症状。治療は利尿薬・ACE阻害薬。',
          ),
          segmentKind: const Value('content'),
        ),
      ]);

      const innerJson = '{"units":['
          '{"title":"心不全","unitType":"定義","problemFormat":"選択肢"},'
          '{"title":"心不全の治療","unitType":"治療","problemFormat":"記述"}'
          ']}';
      final client = SharedOllamaClient(
        httpClient: _MockHttpClient(_ollamaResponse(innerJson)),
      );
      final svc = OllamaUnitDraftService(
        client: client,
        model: 'qwen3:4b',
      );

      final drafts = await svc.generateDrafts(db: db, sourceId: sourceId);
      expect(drafts.length, 2);
      expect(drafts.first.title, '心不全');
      expect(drafts.first.unitType, '定義');
      expect(drafts[1].title, '心不全の治療');
      expect(drafts[1].problemFormat, '記述');
    });

    test('接続失敗時は空リストを返す（例外なし）', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final sourceId = await db.sourcesDao.insertSource(
        SourcesCompanion.insert(
          fileName: 'cardio.pdf',
          filePath: '/tmp/cardio.pdf',
          sourceType: const Value('lecture'),
        ),
      );
      await db.sourcesDao.insertSegments([
        SourceSegmentsCompanion.insert(
          sourceId: sourceId,
          pageNumber: 1,
          content: const Value('大動脈解離はDeBakey分類で管理。突発性胸背部痛が特徴。'),
          segmentKind: const Value('content'),
        ),
      ]);

      final client = SharedOllamaClient(
        httpClient: _FailingHttpClient(),
      );
      final svc = OllamaUnitDraftService(
        client: client,
        model: 'qwen3:4b',
      );

      final drafts = await svc.generateDrafts(db: db, sourceId: sourceId);
      expect(drafts, isEmpty);
    });

    test('不正なJSONでも空リスト（例外なし）', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final sourceId = await db.sourcesDao.insertSource(
        SourcesCompanion.insert(
          fileName: 'cardio.pdf',
          filePath: '/tmp/cardio.pdf',
          sourceType: const Value('lecture'),
        ),
      );
      await db.sourcesDao.insertSegments([
        SourceSegmentsCompanion.insert(
          sourceId: sourceId,
          pageNumber: 1,
          content: const Value('心筋梗塞は冠動脈閉塞による心筋壊死。再灌流療法が基本治療。'),
          segmentKind: const Value('content'),
        ),
      ]);

      const body =
          '{"model":"qwen3:4b","response":"壊れたJSONです","thinking":"","done":true}';
      final client = SharedOllamaClient(httpClient: _MockHttpClient(body));
      final svc = OllamaUnitDraftService(
        client: client,
        model: 'qwen3:4b',
      );

      final drafts = await svc.generateDrafts(db: db, sourceId: sourceId);
      expect(drafts, isEmpty);
    });

    test('content セグメントが0件なら空リスト', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final sourceId = await db.sourcesDao.insertSource(
        SourcesCompanion.insert(
          fileName: 'empty.pdf',
          filePath: '/tmp/empty.pdf',
          sourceType: const Value('lecture'),
        ),
      );
      // syllabus セグメントのみ（content なし）
      await db.sourcesDao.insertSegments([
        SourceSegmentsCompanion.insert(
          sourceId: sourceId,
          pageNumber: 1,
          content: const Value('シラバス: 到達目標・評価方法・授業計画'),
          segmentKind: const Value('syllabus'),
        ),
      ]);

      final client = SharedOllamaClient(
        httpClient: _MockHttpClient(
          '{"response":"{}","thinking":"","done":true}',
        ),
      );
      final svc = OllamaUnitDraftService(
        client: client,
        model: 'qwen3:4b',
      );

      final drafts = await svc.generateDrafts(db: db, sourceId: sourceId);
      expect(drafts, isEmpty);
    });

    test('不正な unitType はデフォルト「定義」に正規化', () async {
      final db = _makeDb();
      addTearDown(db.close);

      final sourceId = await db.sourcesDao.insertSource(
        SourcesCompanion.insert(
          fileName: 'test.pdf',
          filePath: '/tmp/test.pdf',
          sourceType: const Value('lecture'),
        ),
      );
      await db.sourcesDao.insertSegments([
        SourceSegmentsCompanion.insert(
          sourceId: sourceId,
          pageNumber: 1,
          content: const Value('心室細動は心拍数300-600/分の不整脈。除細動が緊急治療。'),
          segmentKind: const Value('content'),
        ),
      ]);

      const innerJson =
          '{"units":[{"title":"心室細動","unitType":"INVALID_TYPE","problemFormat":"選択肢"}]}';
      final client = SharedOllamaClient(
        httpClient: _MockHttpClient(_ollamaResponse(innerJson)),
      );
      final svc = OllamaUnitDraftService(
        client: client,
        model: 'qwen3:4b',
      );

      final drafts = await svc.generateDrafts(db: db, sourceId: sourceId);
      expect(drafts.length, 1);
      expect(drafts.first.unitType, '定義'); // デフォルト
    });
  });
}
