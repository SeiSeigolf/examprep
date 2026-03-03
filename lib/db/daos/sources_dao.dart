import 'package:drift/drift.dart';
import '../database.dart';

part 'sources_dao.g.dart';

@DriftAccessor(tables: [Sources, SourceSegments])
class SourcesDao extends DatabaseAccessor<AppDatabase> with _$SourcesDaoMixin {
  SourcesDao(super.db);

  /// 全ソース取得（最新順）
  Stream<List<Source>> watchAllSources() => (select(
    sources,
  )..orderBy([(t) => OrderingTerm.desc(t.importedAt)])).watch();

  /// ソース追加
  Future<int> insertSource(SourcesCompanion entry) =>
      into(sources).insert(entry);

  /// ソース削除
  Future<int> deleteSource(int id) async {
    final count = await (delete(sources)..where((t) => t.id.equals(id))).go();
    await recalculatePastExamFrequency();
    return count;
  }

  /// ソースに対してページ分のセグメントを一括挿入
  Future<void> insertSegments(List<SourceSegmentsCompanion> entries) =>
      batch((b) => b.insertAll(sourceSegments, entries));

  /// 指定ソースのセグメント一覧をページ順で監視
  Stream<List<SourceSegment>> watchSegmentsForSource(int sourceId) =>
      (select(sourceSegments)
            ..where((s) => s.sourceId.equals(sourceId))
            ..orderBy([(s) => OrderingTerm.asc(s.pageNumber)]))
          .watch();

  /// ページ数を更新（テキスト抽出後に呼ぶ）
  Future<void> updatePageCount(int sourceId, int pageCount) =>
      (update(sources)..where((s) => s.id.equals(sourceId))).write(
        SourcesCompanion(pageCount: Value(pageCount)),
      );

  /// past_exam に紐づく証拠量から unit_stats.frequency を再計算する。
  /// 手動上書き済み（frequencyManualOverride=true）の unit は更新しない。
  Future<void> recalculatePastExamFrequency() async {
    await customStatement('''
      INSERT OR IGNORE INTO unit_stats (exam_unit_id, frequency, frequency_manual_override, updated_at)
      SELECT eu.id, 1, 0, CAST(strftime('%s','now') AS INTEGER)
      FROM exam_units eu
    ''');

    await customStatement('''
      UPDATE unit_stats
      SET
        frequency = MAX(1, COALESCE((
          SELECT COUNT(DISTINCT linked.segment_id)
          FROM (
            SELECT c.exam_unit_id AS unit_id, ss.id AS segment_id
            FROM claims c
            JOIN evidence_links el
              ON el.claim_id = c.id
            JOIN source_segments ss
              ON ss.id = el.source_segment_id
            JOIN sources s
              ON s.id = ss.source_id
            WHERE s.source_type = 'past_exam'

            UNION

            SELECT c.exam_unit_id AS unit_id, ss.id AS segment_id
            FROM claims c
            JOIN evidence_packs ep
              ON ep.claim_id = c.id
            JOIN evidence_pack_items epi
              ON epi.evidence_pack_id = ep.id
            JOIN source_segments ss
              ON ss.id = epi.source_segment_id
            JOIN sources s
              ON s.id = ss.source_id
            WHERE s.source_type = 'past_exam'
          ) linked
          WHERE linked.unit_id = unit_stats.exam_unit_id
        ), 1)),
        updated_at = CAST(strftime('%s','now') AS INTEGER)
      WHERE unit_stats.frequency_manual_override = 0
    ''');
  }
}
