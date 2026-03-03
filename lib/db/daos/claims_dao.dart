import 'package:drift/drift.dart';
import '../database.dart';

part 'claims_dao.g.dart';

// ---- データクラス ----

class EvidenceWithSource {
  const EvidenceWithSource({
    required this.link,
    required this.segment,
    required this.source,
  });
  final EvidenceLink link;
  final SourceSegment segment;
  final Source source;
}

class SegmentWithSource {
  const SegmentWithSource({required this.segment, required this.source});
  final SourceSegment segment;
  final Source source;
}

// ---- DAO ----

@DriftAccessor(
  tables: [Claims, EvidenceLinks, SourceSegments, Sources],
)
class ClaimsDao extends DatabaseAccessor<AppDatabase>
    with _$ClaimsDaoMixin {
  ClaimsDao(super.db);

  // ---- Claim 取得 ----

  Stream<List<Claim>> watchClaimsForUnit(int unitId) =>
      (select(claims)
            ..where((c) => c.examUnitId.equals(unitId))
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .watch();

  // ---- Evidence-first: claim と evidence を atomic に挿入 ----

  /// [segmentIds] は空であってはいけない（Evidence-first 原則）
  Future<int> insertClaimWithEvidence(
    ClaimsCompanion claim,
    List<int> segmentIds,
  ) {
    assert(segmentIds.isNotEmpty,
        'Evidence-first 違反: segmentIds が空です。根拠なしに claim を作成できません。');
    return transaction(() async {
      final claimId = await into(claims).insert(claim);
      await batch((b) => b.insertAll(
            evidenceLinks,
            segmentIds
                .map((sid) => EvidenceLinksCompanion.insert(
                      claimId: claimId,
                      sourceSegmentId: sid,
                    ))
                .toList(),
          ));
      return claimId;
    });
  }

  /// Claim とそれに紐づく EvidenceLink を一括削除
  Future<void> deleteClaimWithEvidence(int claimId) => transaction(() async {
        await (delete(evidenceLinks)
              ..where((e) => e.claimId.equals(claimId)))
            .go();
        await (delete(claims)..where((c) => c.id.equals(claimId))).go();
      });

  // ---- Evidence 取得（join） ----

  Stream<List<EvidenceWithSource>> watchEvidenceForClaim(int claimId) {
    final query = (select(evidenceLinks)
          ..where((e) => e.claimId.equals(claimId)))
        .join([
      innerJoin(
        sourceSegments,
        sourceSegments.id.equalsExp(evidenceLinks.sourceSegmentId),
      ),
      innerJoin(sources, sources.id.equalsExp(sourceSegments.sourceId)),
    ]);
    return query.watch().map((rows) => rows
        .map((row) => EvidenceWithSource(
              link: row.readTable(evidenceLinks),
              segment: row.readTable(sourceSegments),
              source: row.readTable(sources),
            ))
        .toList());
  }

  // ---- エクスポート用 Future メソッド ----

  Future<List<Claim>> getClaimsForUnit(int unitId) =>
      (select(claims)
            ..where((c) => c.examUnitId.equals(unitId))
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .get();

  Future<List<EvidenceWithSource>> getEvidenceForClaim(int claimId) =>
      (select(evidenceLinks)..where((e) => e.claimId.equals(claimId)))
          .join([
            innerJoin(sourceSegments,
                sourceSegments.id.equalsExp(evidenceLinks.sourceSegmentId)),
            innerJoin(sources, sources.id.equalsExp(sourceSegments.sourceId)),
          ])
          .get()
          .then((rows) => rows
              .map((row) => EvidenceWithSource(
                    link: row.readTable(evidenceLinks),
                    segment: row.readTable(sourceSegments),
                    source: row.readTable(sources),
                  ))
              .toList());

  // ---- Claim 件数集計（unitId → count）----

  Stream<Map<int, int>> watchClaimCountsPerUnit() =>
      customSelect(
        'SELECT exam_unit_id, COUNT(*) AS cnt FROM claims GROUP BY exam_unit_id',
        readsFrom: {claims},
      ).watch().map((rows) => {
            for (final row in rows)
              row.read<int>('exam_unit_id'): row.read<int>('cnt'),
          });

  // ---- Evidence picker 用: 全セグメントをソース情報付きで取得 ----

  Stream<List<SegmentWithSource>> watchAllSegmentsWithSource() {
    final query = select(sourceSegments).join([
      innerJoin(sources, sources.id.equalsExp(sourceSegments.sourceId)),
    ]);
    return query.watch().map((rows) => rows
        .map((row) => SegmentWithSource(
              segment: row.readTable(sourceSegments),
              source: row.readTable(sources),
            ))
        .toList());
  }
}
