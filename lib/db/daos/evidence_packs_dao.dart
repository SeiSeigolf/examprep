import 'package:drift/drift.dart';
import '../database.dart';

part 'evidence_packs_dao.g.dart';

class EvidencePackItemInput {
  const EvidencePackItemInput({
    required this.sourceSegmentId,
    this.pageNumber,
    this.snippet,
    this.weight = 1,
  });

  final int sourceSegmentId;
  final int? pageNumber;
  final String? snippet;
  final int weight;
}

class EvidencePackBundle {
  const EvidencePackBundle({required this.pack, required this.items});

  final EvidencePack pack;
  final List<EvidencePackItem> items;
}

@DriftAccessor(
  tables: [
    Claims,
    EvidenceLinks,
    EvidencePacks,
    EvidencePackItems,
    SourceSegments,
  ],
)
class EvidencePacksDao extends DatabaseAccessor<AppDatabase>
    with _$EvidencePacksDaoMixin {
  EvidencePacksDao(super.db);

  Stream<EvidencePackBundle?> watchEvidencePackForClaim(int claimId) {
    final packQuery = select(evidencePacks)
      ..where((p) => p.claimId.equals(claimId))
      ..limit(1);

    final itemsQuery = select(evidencePackItems)
      ..orderBy([(i) => OrderingTerm.asc(i.id)]);

    return packQuery.watchSingleOrNull().asyncMap((pack) async {
      if (pack == null) return null;
      final items =
          await (itemsQuery..where((i) => i.evidencePackId.equals(pack.id)))
              .get();
      return EvidencePackBundle(pack: pack, items: items);
    });
  }

  Future<int> upsertEvidencePack({
    required int claimId,
    String? summary,
    String contentConfidence = 'M',
    String examConfidence = 'M',
  }) async {
    final existing =
        await (select(evidencePacks)
              ..where((p) => p.claimId.equals(claimId))
              ..limit(1))
            .getSingleOrNull();

    if (existing == null) {
      return into(evidencePacks).insert(
        EvidencePacksCompanion.insert(
          claimId: claimId,
          summary: Value(summary),
          contentConfidence: Value(contentConfidence),
          examConfidence: Value(examConfidence),
        ),
      );
    }

    await (update(evidencePacks)..where((p) => p.id.equals(existing.id))).write(
      EvidencePacksCompanion(
        summary: Value(summary),
        contentConfidence: Value(contentConfidence),
        examConfidence: Value(examConfidence),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return existing.id;
  }

  Future<void> replaceItems(int packId, List<EvidencePackItemInput> items) =>
      transaction(() async {
        await (delete(
          evidencePackItems,
        )..where((i) => i.evidencePackId.equals(packId))).go();

        final deduped = <int, EvidencePackItemInput>{};
        for (final item in items) {
          deduped[item.sourceSegmentId] = item;
        }

        if (deduped.isEmpty) return;
        final segmentRows = await (select(
          sourceSegments,
        )..where((s) => s.id.isIn(deduped.keys))).get();
        final segmentMap = {for (final s in segmentRows) s.id: s};

        await batch((b) {
          b.insertAll(
            evidencePackItems,
            deduped.values
                .map(
                  (item) => EvidencePackItemsCompanion.insert(
                    evidencePackId: packId,
                    sourceSegmentId: item.sourceSegmentId,
                    pageNumber: Value(
                      item.pageNumber ??
                          segmentMap[item.sourceSegmentId]?.pageNumber,
                    ),
                    snippet: Value(
                      (item.snippet != null && item.snippet!.trim().isNotEmpty)
                          ? item.snippet
                          : _snippetFromSegment(
                              segmentMap[item.sourceSegmentId]?.content,
                            ),
                    ),
                    weight: Value(item.weight),
                  ),
                )
                .toList(),
          );
        });
        await db.sourcesDao.recalculatePastExamFrequency();
      });

  Future<void> deleteClaimCascade(int claimId) async {
    await (delete(claims)..where((c) => c.id.equals(claimId))).go();
  }

  String? _snippetFromSegment(String? content) {
    if (content == null) return null;
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length <= 200 ? trimmed : trimmed.substring(0, 200);
  }
}
