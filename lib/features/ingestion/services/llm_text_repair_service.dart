import 'dart:convert';

import 'ollama_client.dart';

/// LLM repair の結果。
class RepairResult {
  const RepairResult({
    required this.cleanText,
    required this.qualityLabel,
    required this.suggestedSegmentKind,
    required this.flags,
    required this.changed,
  });

  final String cleanText;

  /// 'H' | 'M' | 'L'
  final String qualityLabel;

  /// 'content' | 'header' | 'syllabus' | 'assignment_meta' | 'references' | 'boilerplate'
  final String suggestedSegmentKind;

  final List<String> flags;
  final bool changed;

  /// repair 失敗・スキップ時の passthrough ファクトリ。
  factory RepairResult.passthrough(String rawText) => RepairResult(
    cleanText: rawText,
    qualityLabel: 'M',
    suggestedSegmentKind: 'content',
    flags: const ['llm_skipped'],
    changed: false,
  );
}

/// Ollama を使ってページテキストを修復・分類するサービス。
/// LLM が利用不可/JSONパース失敗の場合は元テキストをそのまま返す。
class LlmTextRepairService {
  LlmTextRepairService({OllamaClient? client})
    : _client = client ?? OllamaClient();

  final OllamaClient _client;

  static const _minLength = 60;
  static const _maxLength = 4000;
  static const _defaultModel = 'qwen3:4b';

  Future<RepairResult> repairPageText({
    required String rawText,
    required int pageNumber,
    required String sourceFileName,
    String model = _defaultModel,
  }) async {
    // 短すぎるテキストはスキップ（ヘッダ扱いは既存分類に委ねる）
    if (rawText.trim().length < _minLength) {
      return RepairResult.passthrough(rawText);
    }

    final flags = <String>[];
    String textToRepair = rawText;

    // 長すぎる場合は先頭2000 + 末尾2000文字に切り詰め
    if (rawText.length > _maxLength) {
      final head = rawText.substring(0, _maxLength ~/ 2);
      final tail = rawText.substring(rawText.length - _maxLength ~/ 2);
      textToRepair = '$head\n[...truncated...]\n$tail';
      flags.add('truncated');
    }

    final prompt = _buildPrompt(textToRepair, pageNumber, sourceFileName);
    final response = await _client.generate(model: model, prompt: prompt);

    if (response == null) {
      return RepairResult.passthrough(rawText);
    }

    return _parseResponse(response, rawText, flags);
  }

  static String _buildPrompt(
    String text,
    int pageNumber,
    String sourceFileName,
  ) {
    return '''あなたはPDFテキスト修復AIです。以下のルールを厳守してください。
- 入力テキストに含まれる文字だけを使って修復・整形する（情報追加・要約・創作禁止）
- OCR/抽出ノイズ（文字化け・不要な改行・スペース過剰）を修正する
- ヘッダ/フッタ/URL/提出締切/参考書/シラバスっぽい内容は suggested_segment_kind をそれぞれ header/assignment_meta/references/syllabus に設定
- 文字化けが多く意味が崩壊している場合は quality_label="L"、読める場合は"H"か"M"
- 出力はJSONのみ（他のテキスト禁止）

JSONスキーマ（必ずこの形式）:
{
  "clean_text": "修復後テキスト",
  "quality_label": "H|M|L",
  "suggested_segment_kind": "content|header|syllabus|assignment_meta|references|boilerplate",
  "flags": ["flag1", ...],
  "changed": true|false
}

--- 入力テキスト（ファイル: $sourceFileName, ページ: $pageNumber） ---
$text
--- END ---

JSONのみ出力:''';
  }

  static RepairResult _parseResponse(
    String response,
    String rawText,
    List<String> existingFlags,
  ) {
    // LLM がマークダウンコードブロックで包んで返すことがあるので除去
    final cleaned = response
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    // JSON部分だけ抽出（{...}）
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch == null) return RepairResult.passthrough(rawText);

    try {
      final decoded = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      final cleanText = decoded['clean_text'] as String?;
      if (cleanText == null || cleanText.trim().isEmpty) {
        return RepairResult.passthrough(rawText);
      }

      final qualityLabel = _sanitizeQuality(decoded['quality_label']);
      final segmentKind = _sanitizeKind(decoded['suggested_segment_kind']);
      final changed = decoded['changed'] == true;

      final rawFlags = decoded['flags'];
      final llmFlags = rawFlags is List
          ? rawFlags.whereType<String>().toList()
          : <String>[];

      return RepairResult(
        cleanText: cleanText,
        qualityLabel: qualityLabel,
        suggestedSegmentKind: segmentKind,
        flags: [...existingFlags, ...llmFlags],
        changed: changed,
      );
    } catch (_) {
      return RepairResult.passthrough(rawText);
    }
  }

  static String _sanitizeQuality(dynamic raw) {
    const valid = {'H', 'M', 'L'};
    if (raw is String && valid.contains(raw)) return raw;
    return 'M';
  }

  static String _sanitizeKind(dynamic raw) {
    const valid = {
      'content',
      'header',
      'syllabus',
      'assignment_meta',
      'references',
      'boilerplate',
    };
    if (raw is String && valid.contains(raw)) return raw;
    return 'content';
  }
}
