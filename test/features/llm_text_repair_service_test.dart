import 'package:exam_os/features/ingestion/services/llm_text_repair_service.dart';
import 'package:exam_os/features/ingestion/services/ollama_client.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── モック OllamaClient ─────────────────────────────────────────────

/// 固定レスポンスを返すモック
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

String _buildOllamaJson({
  required String cleanText,
  required String qualityLabel,
  required String suggestedSegmentKind,
  List<String> flags = const [],
  bool changed = false,
}) {
  final flagsJson = flags.map((f) => '"$f"').join(', ');
  return '''
{
  "clean_text": ${_jsonString(cleanText)},
  "quality_label": "$qualityLabel",
  "suggested_segment_kind": "$suggestedSegmentKind",
  "flags": [$flagsJson],
  "changed": $changed
}''';
}

String _jsonString(String s) =>
    '"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';

// ─────────────────────────────────────────────────────────────────────

void main() {
  group('LlmTextRepairService', () {
    test('短いテキスト(<60文字)はLLMをスキップしてpassthroughを返す', () async {
      final svc = LlmTextRepairService(
        client: _MockOllamaClient('should not be called'),
      );
      final result = await svc.repairPageText(
        rawText: '短いテキスト',
        pageNumber: 1,
        sourceFileName: 'test.pdf',
      );
      expect(result.flags, contains('llm_skipped'));
      expect(result.changed, isFalse);
      expect(result.cleanText, '短いテキスト');
    });

    test('suggestedSegmentKind=syllabus になるケース', () async {
      const rawText =
          'この授業のシラバスに記載する内容は以下の通りです。達成目標・評価方法・授業計画を示します。各回の学習内容は別途配布します。';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          _buildOllamaJson(
            cleanText: rawText,
            qualityLabel: 'M',
            suggestedSegmentKind: 'syllabus',
            changed: false,
          ),
        ),
      );
      final result = await svc.repairPageText(
        rawText: rawText,
        pageNumber: 2,
        sourceFileName: 'lecture.pdf',
      );
      expect(result.suggestedSegmentKind, 'syllabus');
      expect(result.flags, isNot(contains('llm_skipped')));
    });

    test('suggestedSegmentKind=assignment_meta になるケース（提出・URL含む）', () async {
      const rawText =
          '課題の提出期限は2026年3月15日です。https://example.ac.jp/submit よりアップロードしてください。締切を過ぎた場合は受付不可です。';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          _buildOllamaJson(
            cleanText: rawText,
            qualityLabel: 'H',
            suggestedSegmentKind: 'assignment_meta',
            flags: ['llm_kind'],
            changed: false,
          ),
        ),
      );
      final result = await svc.repairPageText(
        rawText: rawText,
        pageNumber: 3,
        sourceFileName: 'assignment.pdf',
      );
      expect(result.suggestedSegmentKind, 'assignment_meta');
      expect(result.flags, contains('llm_kind'));
    });

    test('changed=true のとき cleanText が採用される', () async {
      // 60文字以上のrawTextにしてスキップを回避
      const rawText =
          '心不全と は心拍出量が低下 し末梢組織の需要を満た せない病態を指す。'
          '浮腫・呼吸困難・尿量低下が主症状で ある。治療は利尿薬・ACE阻害薬が基本。';
      const repairedText =
          '心不全とは心拍出量が低下し末梢組織の需要を満たせない病態を指す。'
          '浮腫・呼吸困難・尿量低下が主症状である。治療は利尿薬・ACE阻害薬が基本。';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          _buildOllamaJson(
            cleanText: repairedText,
            qualityLabel: 'H',
            suggestedSegmentKind: 'content',
            changed: true,
          ),
        ),
      );
      final result = await svc.repairPageText(
        rawText: rawText,
        pageNumber: 5,
        sourceFileName: 'lecture.pdf',
      );
      expect(result.changed, isTrue);
      expect(result.cleanText, repairedText);
      expect(result.qualityLabel, 'H');
    });

    test('LLM がnullを返す（接続不可）場合はpassthroughを返す', () async {
      const rawText =
          '大動脈解離はDeBakey分類I/II/IIIに分けられる。突発性胸背部痛が特徴的所見。Stanford分類ではA型（上行大動脈）が手術適応。';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient(null),
      );
      final result = await svc.repairPageText(
        rawText: rawText,
        pageNumber: 1,
        sourceFileName: 'cardio.pdf',
      );
      expect(result.flags, contains('llm_skipped'));
      expect(result.cleanText, rawText);
    });

    test('JSON が壊れている場合はpassthroughを返す', () async {
      const rawText =
          '心筋梗塞は冠動脈の閉塞による心筋壊死である。治療は再灌流療法（PCI/tPA）が基本。ST上昇型と非ST上昇型に分類する。';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient('これはJSONではありません壊れたレスポンス'),
      );
      final result = await svc.repairPageText(
        rawText: rawText,
        pageNumber: 4,
        sourceFileName: 'cardio.pdf',
      );
      expect(result.flags, contains('llm_skipped'));
      expect(result.cleanText, rawText);
    });

    test('長すぎるテキストは truncated フラグが付く', () async {
      // 4001文字を超えるテキスト
      final longText = 'あ' * 4001;
      const repairedText = '修復後テキスト（短縮版）が返ってきた';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          _buildOllamaJson(
            cleanText: repairedText,
            qualityLabel: 'M',
            suggestedSegmentKind: 'content',
            changed: true,
          ),
        ),
      );
      final result = await svc.repairPageText(
        rawText: longText,
        pageNumber: 10,
        sourceFileName: 'long.pdf',
      );
      expect(result.flags, contains('truncated'));
    });

    test('LLM が不正な quality_label/segment_kind を返した場合はデフォルト値', () async {
      const rawText =
          '呼吸不全の診断にはPaO2 60mmHg未満を基準とする。I型は低酸素血症のみ、II型は高CO2血症を伴う。酸素投与と人工換気が治療の基本。';
      final svc = LlmTextRepairService(
        client: _MockOllamaClient(
          '{"clean_text": "$rawText", "quality_label": "INVALID", '
          '"suggested_segment_kind": "unknown_kind", "flags": [], "changed": false}',
        ),
      );
      final result = await svc.repairPageText(
        rawText: rawText,
        pageNumber: 7,
        sourceFileName: 'pulmonology.pdf',
      );
      expect(result.qualityLabel, 'M'); // デフォルト
      expect(result.suggestedSegmentKind, 'content'); // デフォルト
    });
  });
}
