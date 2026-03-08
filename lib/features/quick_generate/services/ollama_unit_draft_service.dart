import 'package:drift/drift.dart' show Variable;

import '../../../db/database.dart';
import '../../../db/daos/sources_dao.dart';
import '../../../shared/llm/ollama_client.dart';

/// Ollama を使ってソースのセグメントから Unit 候補を生成するサービス。
///
/// 失敗・タイムアウト・JSON不正の場合は空リストを返し、呼び元がフォールバック。
class OllamaUnitDraftService {
  OllamaUnitDraftService({
    required SharedOllamaClient client,
    required this.model,
  }) : _client = client;

  final SharedOllamaClient _client;
  final String model;

  /// ソース `sourceId` に属する content セグメントを読み取り、
  /// Ollama に Unit 候補を生成させる。
  ///
  /// JSONスキーマ:
  /// ```json
  /// {"units":[{"title":"...","unitType":"...","problemFormat":"..."}]}
  /// ```
  ///
  /// 失敗時は空リストを返す（例外なし）。
  Future<List<SegmentUnitDraft>> generateDrafts({
    required AppDatabase db,
    required int sourceId,
    int maxSegmentChars = 6000,
  }) async {
    // content 種別セグメントだけ取得
    final rows = await db
        .customSelect(
          '''SELECT id, page_number, content
             FROM source_segments
             WHERE source_id = ? AND segment_kind = 'content'
             ORDER BY page_number
             LIMIT 40''',
          variables: [Variable<int>(sourceId)],
        )
        .get();

    if (rows.isEmpty) return const [];

    // テキストを結合（長すぎる場合は切り詰め）
    final buf = StringBuffer();
    for (final r in rows) {
      final text = r.read<String>('content').trim();
      if (text.isEmpty) continue;
      buf.write(text);
      buf.write('\n\n');
      if (buf.length >= maxSegmentChars) break;
    }
    final combinedText = buf.toString().trim();
    if (combinedText.isEmpty) return const [];

    final prompt = _buildPrompt(combinedText);
    final json = await _client.generateJson(
      model: model,
      prompt: prompt,
    );

    if (json == null) return const [];
    return _parseUnits(json, sourceId, rows);
  }

  static String _buildPrompt(String content) {
    return '''あなたは医学部試験の出題分析AIです。以下のルールを厳守してください。
- 入力テキストから「出題されそうな学習単位（Unit）」を抽出する
- 創作・推測禁止。テキストに書かれた概念だけを使う
- 各UnitのtitleはA4ページタイトルに相当する短い名詞句（最大20文字）
- unitTypeは「定義」「機序」「鑑別」「症状」「治療」「検査」「予後」「画像」のいずれか
- problemFormatは「選択肢」か「記述」
- 出力はJSONのみ（説明文・コメント禁止）

JSONスキーマ（必ずこの形式のみ）:
{"units":[{"title":"string","unitType":"string","problemFormat":"string"}]}

--- 入力テキスト ---
$content
--- END ---

JSONのみ出力:''';
  }

  static List<SegmentUnitDraft> _parseUnits(
    Map<String, dynamic> json,
    int sourceId,
    List<dynamic> rows,
  ) {
    final rawUnits = json['units'];
    if (rawUnits is! List) return const [];

    // 最初のセグメントをデフォルト根拠として使う
    // Drift QueryRow は .read<T>(key) でアクセス
    int defaultSegId = 0;
    int defaultPage = 1;
    if (rows.isNotEmpty) {
      try {
        defaultSegId = rows.first.read<int>('id');
        defaultPage = rows.first.read<int>('page_number');
      } catch (_) {
        // ignore
      }
    }

    const validUnitTypes = {
      '定義', '機序', '鑑別', '症状', '治療', '検査', '予後', '画像',
    };

    final drafts = <SegmentUnitDraft>[];
    for (final raw in rawUnits) {
      if (raw is! Map<String, dynamic>) continue;

      final title = (raw['title'] as String?)?.trim() ?? '';
      if (title.isEmpty || title.length > 40) continue;

      final unitType = (raw['unitType'] as String?)?.trim() ?? '定義';
      final safeUnitType = validUnitTypes.contains(unitType) ? unitType : '定義';

      final problemFormat = (raw['problemFormat'] as String?)?.trim() ?? '選択肢';
      final safeProblemFormat =
          problemFormat == '記述' ? '記述' : '選択肢';

      drafts.add(
        SegmentUnitDraft(
          sourceId: sourceId,
          segmentId: defaultSegId,
          pageNumber: defaultPage,
          title: title,
          claimContent: '$title に関する学習事項',
          unitType: safeUnitType,
          problemFormat: safeProblemFormat,
        ),
      );
    }
    return drafts;
  }
}
