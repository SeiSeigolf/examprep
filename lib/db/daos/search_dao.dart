import 'package:drift/drift.dart';
import '../database.dart';

part 'search_dao.g.dart';

// ---- 検索結果データクラス ----

class SearchResult {
  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.parentId,
  });

  /// 'examUnit' | 'claim' | 'segment'
  final String type;
  final int id;

  /// 一覧で表示するメインテキスト
  final String title;

  /// 補足テキスト（unitType / 親ExamUnitタイトル / ファイル名）
  final String subtitle;

  /// claim → examUnitId, segment → sourceId, examUnit → null
  final int? parentId;
}

// ---- DAO ----

@DriftAccessor(
  tables: [ExamUnits, Claims, SourceSegments, Sources],
)
class SearchDao extends DatabaseAccessor<AppDatabase>
    with _$SearchDaoMixin {
  SearchDao(super.db);

  /// ExamUnit（タイトル・説明）/ Claim（内容）/ SourceSegment（テキスト）を横断検索
  ///
  /// - 大文字小文字を区別しない（LOWER + LIKE）
  /// - 最大 30 件返す
  Future<List<SearchResult>> search(String query) async {
    final q = '%${query.toLowerCase()}%';

    final rows = await customSelect(
      '''
      SELECT 'examUnit' AS type,
             eu.id,
             eu.title,
             eu.unit_type  AS subtitle,
             NULL          AS parent_id
      FROM exam_units eu
      WHERE LOWER(eu.title) LIKE ?1
         OR LOWER(COALESCE(eu.description, '')) LIKE ?1

      UNION ALL

      SELECT 'claim'        AS type,
             c.id,
             SUBSTR(c.content, 1, 80) AS title,
             eu.title       AS subtitle,
             c.exam_unit_id AS parent_id
      FROM claims c
      INNER JOIN exam_units eu ON eu.id = c.exam_unit_id
      WHERE LOWER(c.content) LIKE ?1

      UNION ALL

      SELECT 'segment'      AS type,
             ss.id,
             SUBSTR(ss.content, 1, 80) AS title,
             s.file_name    AS subtitle,
             ss.source_id   AS parent_id
      FROM source_segments ss
      INNER JOIN sources s ON s.id = ss.source_id
      WHERE ss.content != ''
        AND LOWER(ss.content) LIKE ?1

      LIMIT 30
      ''',
      variables: [Variable.withString(q)],
      readsFrom: {examUnits, claims, sourceSegments, sources},
    ).get();

    return rows.map((row) {
      final parentRaw = row.readNullable<int>('parent_id');
      return SearchResult(
        type: row.read<String>('type'),
        id: row.read<int>('id'),
        title: row.read<String>('title'),
        subtitle: row.read<String>('subtitle'),
        parentId: parentRaw,
      );
    }).toList();
  }
}
