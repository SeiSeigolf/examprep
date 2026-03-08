import 'dart:convert';

import 'package:http/http.dart' as http;

/// Ollama ローカルLLM クライアント（共通版）。
///
/// - `thinking` フィールドは完全に無視し `response` フィールドのみを返す。
/// - 失敗時は null を返す（例外を投げない）。
/// - ローカル専用: 渡された baseUrl 以外への送信は行わない。
class SharedOllamaClient {
  SharedOllamaClient({
    this.baseUrl = 'http://localhost:11434',
    this.timeout = const Duration(seconds: 60),
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  /// `POST /api/generate` を呼び、`response` フィールド文字列を返す。
  ///
  /// レスポンスには `thinking` フィールドが混入することがある（qwen3など）が、
  /// 本メソッドは必ず `response` だけを取り出す。
  ///
  /// 返り値は "生の文字列" であり、呼び元が必要なら jsonDecode を行う。
  /// タイムアウト・接続不可・JSON破損時はすべて null。
  Future<String?> generate({
    required String model,
    required String prompt,
    double temperature = 0.0,
  }) async {
    final uri = Uri.parse('$baseUrl/api/generate');
    final body = jsonEncode({
      'model': model,
      'prompt': prompt,
      'stream': false,
      'options': {'temperature': temperature},
    });

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode != 200) return null;

      // Ollamaレスポンスは {"model":..., "response":"...", "thinking":"...", ...}
      // thinking は無視し response だけを返す
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final responseField = decoded['response'];
        if (responseField is String) return responseField;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// generate() の結果文字列を JSON としてデコードする。
  ///
  /// LLM は `response` に JSON 文字列を返すことがある:
  /// `{"units":[...]}` などのエスケープ済み JSON。
  /// このメソッドでそれをパースし Map/List に変換する。
  ///
  /// パース失敗時は null。
  Future<Map<String, dynamic>?> generateJson({
    required String model,
    required String prompt,
    double temperature = 0.0,
  }) async {
    final raw = await generate(
      model: model,
      prompt: prompt,
      temperature: temperature,
    );
    if (raw == null) return null;
    return _tryParseJson(raw);
  }

  static Map<String, dynamic>? _tryParseJson(String raw) {
    // マークダウンコードブロックを除去
    final cleaned = raw
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    // {...} だけを抽出してパース
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch == null) return null;

    try {
      final decoded = jsonDecode(jsonMatch.group(0)!);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}
