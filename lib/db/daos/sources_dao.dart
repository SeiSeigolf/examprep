import 'package:drift/drift.dart';
import '../database.dart';

part 'sources_dao.g.dart';

class SegmentUnitDraft {
  const SegmentUnitDraft({
    required this.sourceId,
    required this.segmentId,
    required this.pageNumber,
    required this.title,
    required this.claimContent,
  });

  final int sourceId;
  final int segmentId;
  final int pageNumber;
  final String title;
  final String claimContent;
}

@DriftAccessor(
  tables: [Sources, SourceSegments, ExamUnits, Claims, EvidenceLinks],
)
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

  Future<List<SegmentUnitDraft>> suggestExamUnitDraftsFromSource(
    int sourceId, {
    int limit = 40,
  }) async {
    final segments =
        await (select(sourceSegments)
              ..where((s) => s.sourceId.equals(sourceId))
              ..orderBy([(s) => OrderingTerm.asc(s.pageNumber)]))
            .get();

    final drafts = <SegmentUnitDraft>[];
    final seenTitles = <String>{};
    for (final seg in segments) {
      final text = seg.content.trim();
      if (text.length < 8) continue;

      final chunks = text
          .split(RegExp(r'\n{2,}|(?<=[。.!?])\s+'))
          .map((e) => e.trim())
          .where((e) => e.length >= 8)
          .take(4);

      for (final chunk in chunks) {
        final title = _extractCandidateTitle(chunk);
        if (title.length < 3) continue;
        final norm = title.toLowerCase();
        if (seenTitles.contains(norm)) continue;
        seenTitles.add(norm);

        drafts.add(
          SegmentUnitDraft(
            sourceId: sourceId,
            segmentId: seg.id,
            pageNumber: seg.pageNumber,
            title: title,
            claimContent: _toClaimContent(chunk),
          ),
        );
        if (drafts.length >= limit) return drafts;
      }
    }
    return drafts;
  }

  Future<int> createExamUnitsFromDrafts(List<SegmentUnitDraft> drafts) async {
    if (drafts.isEmpty) return 0;
    return transaction(() async {
      var created = 0;
      for (final draft in drafts) {
        final unitId = await into(examUnits).insert(
          ExamUnitsCompanion.insert(
            title: draft.title,
            unitType: const Value('その他'),
            description: Value(
              'Auto-generated from source p.${draft.pageNumber}',
            ),
          ),
        );

        final claimId = await into(claims).insert(
          ClaimsCompanion.insert(
            examUnitId: unitId,
            content: draft.claimContent,
            contentConfidence: const Value('M'),
            createdBy: const Value('ai'),
          ),
        );
        await into(evidenceLinks).insert(
          EvidenceLinksCompanion.insert(
            claimId: claimId,
            sourceSegmentId: draft.segmentId,
            note: const Value('auto-generated from source segment'),
          ),
        );
        created++;
      }

      await db.auditDao.refreshCoverageAudits();
      return created;
    });
  }

  String _extractCandidateTitle(String chunk) {
    final firstLine = chunk.split('\n').first.trim();
    var t = firstLine;
    if (t.contains('：')) {
      t = t.split('：').first.trim();
    } else if (t.contains(':')) {
      t = t.split(':').first.trim();
    }
    t = t.replaceFirst(RegExp(r'^[\-\*\d\.\)\s]+'), '').trim();
    if (t.length > 32) t = t.substring(0, 32);
    return t;
  }

  String _toClaimContent(String chunk) {
    final text = chunk.replaceAll('\n', ' ').trim();
    if (text.length <= 180) return text;
    return '${text.substring(0, 180)}…';
  }
}
