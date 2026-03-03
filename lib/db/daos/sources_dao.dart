import 'package:drift/drift.dart';
import '../database.dart';

part 'sources_dao.g.dart';

@DriftAccessor(tables: [Sources, SourceSegments])
class SourcesDao extends DatabaseAccessor<AppDatabase>
    with _$SourcesDaoMixin {
  SourcesDao(super.db);

  /// 全ソース取得（最新順）
  Stream<List<Source>> watchAllSources() =>
      (select(sources)..orderBy([(t) => OrderingTerm.desc(t.importedAt)]))
          .watch();

  /// ソース追加
  Future<int> insertSource(SourcesCompanion entry) =>
      into(sources).insert(entry);

  /// ソース削除
  Future<int> deleteSource(int id) =>
      (delete(sources)..where((t) => t.id.equals(id))).go();

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
}
