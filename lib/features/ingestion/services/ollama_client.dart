import 'dart:convert';

import 'package:http/http.dart' as http;

/// Ollama ローカルLLM クライアント（http://localhost:11434 のみ）。
/// 失敗時は例外でなく null を返す（呼び元がスキップ判断）。
class OllamaClient {
  OllamaClient({
    this.baseUrl = 'http://localhost:11434',
    this.timeout = const Duration(seconds: 12),
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  /// `POST /api/generate` を呼び、response フィールドを返す。
  /// タイムアウト・接続失敗・JSON破損時はすべて null。
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

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['response'] as String?;
      }
      return null;
    } catch (_) {
      // タイムアウト・接続不可・パースエラー → repair スキップ
      return null;
    }
  }
}
