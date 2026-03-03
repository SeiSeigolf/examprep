import 'package:drift/drift.dart';
import '../database.dart';

part 'exam_units_dao.g.dart';

class UnitDuplicateCandidate {
  const UnitDuplicateCandidate({
    required this.left,
    required this.right,
    required this.score,
    required this.overlapTokens,
  });

  final ExamUnit left;
  final ExamUnit right;
  final double score;
  final List<String> overlapTokens;
}

class UnitMergeSummary {
  const UnitMergeSummary({
    required this.unitId,
    required this.claimCount,
    required this.evidenceCount,
    required this.conflictCount,
    required this.auditStatus,
  });

  final int unitId;
  final int claimCount;
  final int evidenceCount;
  final int conflictCount;
  final String auditStatus;
}

class UnitMergeResult {
  const UnitMergeResult({
    required this.parentUnitId,
    required this.childUnitId,
    required this.movedClaimIds,
    required this.movedEvidenceCount,
  });

  final int parentUnitId;
  final int childUnitId;
  final List<int> movedClaimIds;
  final int movedEvidenceCount;
}

class UnitMergeHistoryEntry {
  const UnitMergeHistoryEntry({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.mergedAt,
    required this.movedClaimIds,
    required this.undoneAt,
  });

  final int id;
  final int parentId;
  final int childId;
  final DateTime mergedAt;
  final List<int> movedClaimIds;
  final DateTime? undoneAt;
}

@DriftAccessor(
  tables: [
    ExamUnits,
    Claims,
    EvidenceLinks,
    EvidencePacks,
    EvidencePackItems,
    Audits,
    UnitStats,
    Conflicts,
    UnitMergeHistory,
  ],
)
class ExamUnitsDao extends DatabaseAccessor<AppDatabase>
    with _$ExamUnitsDaoMixin {
  ExamUnitsDao(super.db);

  /// 全 Exam Unit を並び順で一括取得（エクスポート用）
  Future<List<ExamUnit>> getAllUnits() =>
      (select(examUnits)..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
          .get();

  /// 全 Exam Unit を並び順（sortOrder ASC, id ASC）で監視
  Stream<List<ExamUnit>> watchAll() =>
      (select(examUnits)..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
          .watch();

  Future<int> insertUnit(ExamUnitsCompanion entry) =>
      into(examUnits).insert(entry);

  Future<bool> updateUnit(ExamUnitsCompanion entry) =>
      update(examUnits).replace(entry);

  /// 信頼度のみ更新（Study Plan の信頼度アップグレード用）
  Future<void> updateConfidenceLevel(int id, String confidenceLevel) =>
      (update(examUnits)..where((t) => t.id.equals(id))).write(
        ExamUnitsCompanion(
          confidenceLevel: Value(confidenceLevel),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> deleteUnit(int id) =>
      (delete(examUnits)..where((t) => t.id.equals(id))).go();

  /// 現在の最大 sortOrder を返す（存在しなければ 0）
  Future<int> getMaxSortOrder() async {
    final result = await customSelect(
      'SELECT COALESCE(MAX(sort_order), 0) AS max_order FROM exam_units',
      readsFrom: {examUnits},
    ).getSingle();
    return result.read<int>('max_order');
  }

  /// 複数行の sortOrder を一括更新（ドラッグ&ドロップ並び替え用）
  Future<void> updateSortOrders(List<(int id, int order)> updates) =>
      batch((b) {
        for (final (id, order) in updates) {
          b.update(
            examUnits,
            ExamUnitsCompanion(sortOrder: Value(order)),
            where: (t) => t.id.equals(id),
          );
        }
      });

  Future<List<UnitDuplicateCandidate>> findDuplicateCandidates({
    int limit = 20,
  }) async {
    final units = await getAllUnits();
    if (units.length < 2) return const [];

    final claimRows = await customSelect(
      '''
      SELECT exam_unit_id, content
      FROM claims
      ''',
      readsFrom: {claims},
    ).get();
    final claimsByUnit = <int, List<String>>{};
    for (final row in claimRows) {
      final unitId = row.read<int>('exam_unit_id');
      (claimsByUnit[unitId] ??= []).add(row.read<String>('content'));
    }

    final vectors = <int, Set<String>>{};
    for (final unit in units) {
      final text = <String>[
        unit.title,
        unit.description ?? '',
        ...?claimsByUnit[unit.id],
      ].join(' ');
      vectors[unit.id] = _tokenize(text);
    }

    final candidates = <UnitDuplicateCandidate>[];
    for (var i = 0; i < units.length; i++) {
      for (var j = i + 1; j < units.length; j++) {
        final left = units[i];
        final right = units[j];
        final l = vectors[left.id]!;
        final r = vectors[right.id]!;
        if (l.isEmpty || r.isEmpty) continue;
        final overlap = l.intersection(r);
        if (overlap.isEmpty) continue;
        final union = l.union(r);
        final score = overlap.length / union.length;
        if (score < 0.08) continue;
        candidates.add(
          UnitDuplicateCandidate(
            left: left,
            right: right,
            score: score,
            overlapTokens: overlap.take(8).toList(),
          ),
        );
      }
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.take(limit).toList();
  }

  Future<UnitMergeSummary> getUnitMergeSummary(int unitId) async {
    final row = await customSelect(
      '''
      SELECT
        eu.id AS unit_id,
        COALESCE((SELECT COUNT(*) FROM claims c WHERE c.exam_unit_id = eu.id), 0) AS claim_count,
        (
          COALESCE((SELECT COUNT(*) FROM evidence_links el JOIN claims c ON c.id = el.claim_id WHERE c.exam_unit_id = eu.id), 0) +
          COALESCE((SELECT COUNT(*) FROM evidence_pack_items epi JOIN evidence_packs ep ON ep.id = epi.evidence_pack_id JOIN claims c ON c.id = ep.claim_id WHERE c.exam_unit_id = eu.id), 0)
        ) AS evidence_count,
        COALESCE((SELECT COUNT(*) FROM conflicts cf WHERE cf.exam_unit_id = eu.id AND cf.status = 'open'), 0) AS conflict_count,
        eu.audit_status AS audit_status
      FROM exam_units eu
      WHERE eu.id = ?
      LIMIT 1
      ''',
      variables: [Variable.withInt(unitId)],
      readsFrom: {
        examUnits,
        claims,
        evidenceLinks,
        evidencePacks,
        evidencePackItems,
        conflicts,
      },
    ).getSingle();

    return UnitMergeSummary(
      unitId: row.read<int>('unit_id'),
      claimCount: row.read<int>('claim_count'),
      evidenceCount: row.read<int>('evidence_count'),
      conflictCount: row.read<int>('conflict_count'),
      auditStatus: row.read<String>('audit_status'),
    );
  }

  Future<UnitMergeResult> mergeUnits({
    required int parentUnitId,
    required int childUnitId,
  }) async {
    if (parentUnitId == childUnitId) {
      return UnitMergeResult(
        parentUnitId: parentUnitId,
        childUnitId: childUnitId,
        movedClaimIds: const [],
        movedEvidenceCount: 0,
      );
    }

    return transaction(() async {
      final childUnit =
          await (select(examUnits)
                ..where((u) => u.id.equals(childUnitId))
                ..limit(1))
              .getSingle();

      final childClaimRows = await (select(
        claims,
      )..where((c) => c.examUnitId.equals(childUnitId))).get();
      final movedClaimIds = childClaimRows.map((c) => c.id).toList();
      var movedEvidenceCount = 0;
      if (movedClaimIds.isNotEmpty) {
        final evidenceCountRow = await customSelect(
          '''
          SELECT
            COALESCE((SELECT COUNT(*) FROM evidence_links WHERE claim_id IN (${_inClause(movedClaimIds.length)})), 0)
            +
            COALESCE((SELECT COUNT(*) FROM evidence_pack_items epi JOIN evidence_packs ep ON ep.id = epi.evidence_pack_id WHERE ep.claim_id IN (${_inClause(movedClaimIds.length)})), 0)
            AS evidence_count
          ''',
          variables: [
            ...movedClaimIds.map(Variable.withInt),
            ...movedClaimIds.map(Variable.withInt),
          ],
          readsFrom: {evidenceLinks, evidencePacks, evidencePackItems},
        ).getSingle();
        movedEvidenceCount = evidenceCountRow.read<int>('evidence_count');
      }

      await _saveMergeHistory(
        parentUnitId: parentUnitId,
        childUnit: childUnit,
        movedClaimIds: movedClaimIds,
      );

      await (update(claims)..where((c) => c.examUnitId.equals(childUnitId)))
          .write(ClaimsCompanion(examUnitId: Value(parentUnitId)));

      await _mergeAudits(parentUnitId: parentUnitId, childUnitId: childUnitId);
      await _mergeUnitStats(
        parentUnitId: parentUnitId,
        childUnitId: childUnitId,
      );

      await (update(conflicts)..where((c) => c.examUnitId.equals(childUnitId)))
          .write(ConflictsCompanion(examUnitId: Value(parentUnitId)));

      await (delete(examUnits)..where((u) => u.id.equals(childUnitId))).go();

      await db.auditDao.refreshCoverageAudits();
      await db.sourcesDao.recalculatePastExamFrequency();

      return UnitMergeResult(
        parentUnitId: parentUnitId,
        childUnitId: childUnitId,
        movedClaimIds: movedClaimIds,
        movedEvidenceCount: movedEvidenceCount,
      );
    });
  }

  Future<void> _saveMergeHistory({
    required int parentUnitId,
    required ExamUnit childUnit,
    required List<int> movedClaimIds,
  }) async {
    await into(unitMergeHistory).insert(
      UnitMergeHistoryCompanion.insert(
        parentId: parentUnitId,
        childId: childUnit.id,
        movedClaimIds: movedClaimIds.join(','),
        childTitle: childUnit.title,
        childUnitType: Value(childUnit.unitType),
        childDescription: Value(childUnit.description),
        childConfidenceLevel: Value(childUnit.confidenceLevel),
        childExamConfidence: Value(childUnit.examConfidence),
        childAuditStatus: Value(childUnit.auditStatus),
        childSortOrder: Value(childUnit.sortOrder),
      ),
    );
  }

  Future<List<UnitMergeHistoryEntry>> getRecentMergeHistory({
    int limit = 10,
  }) async {
    final rows =
        await (select(unitMergeHistory)
              ..orderBy([(h) => OrderingTerm.desc(h.id)])
              ..limit(limit))
            .get();
    return rows
        .map(
          (h) => UnitMergeHistoryEntry(
            id: h.id,
            parentId: h.parentId,
            childId: h.childId,
            mergedAt: h.mergedAt,
            movedClaimIds: h.movedClaimIds
                .split(',')
                .where((e) => e.isNotEmpty)
                .map(int.parse)
                .toList(),
            undoneAt: h.undoneAt,
          ),
        )
        .toList();
  }

  Future<int?> undoLatestMerge() async {
    return transaction(() async {
      final latest =
          await (select(unitMergeHistory)
                ..where((h) => h.undoneAt.isNull())
                ..orderBy([(h) => OrderingTerm.desc(h.id)])
                ..limit(1))
              .getSingleOrNull();
      if (latest == null) return null;

      final claimsToRestore = latest.movedClaimIds
          .split(',')
          .where((e) => e.isNotEmpty)
          .map(int.parse)
          .toList();

      final existingChild =
          await (select(examUnits)
                ..where((u) => u.id.equals(latest.childId))
                ..limit(1))
              .getSingleOrNull();
      if (existingChild == null) {
        await into(examUnits).insert(
          ExamUnitsCompanion(
            id: Value(latest.childId),
            title: Value(latest.childTitle),
            unitType: Value(latest.childUnitType),
            description: Value(latest.childDescription),
            confidenceLevel: Value(latest.childConfidenceLevel),
            examConfidence: Value(latest.childExamConfidence),
            auditStatus: Value(latest.childAuditStatus),
            sortOrder: Value(latest.childSortOrder),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      if (claimsToRestore.isNotEmpty) {
        await (update(claims)..where((c) => c.id.isIn(claimsToRestore))).write(
          ClaimsCompanion(examUnitId: Value(latest.childId)),
        );
      }

      final childStats =
          await (select(unitStats)
                ..where((u) => u.examUnitId.equals(latest.childId))
                ..limit(1))
              .getSingleOrNull();
      if (childStats == null) {
        await into(unitStats).insert(
          UnitStatsCompanion.insert(examUnitId: latest.childId),
          mode: InsertMode.insertOrIgnore,
        );
      }

      await (update(unitMergeHistory)..where((h) => h.id.equals(latest.id)))
          .write(UnitMergeHistoryCompanion(undoneAt: Value(DateTime.now())));

      await db.auditDao.refreshCoverageAudits();
      await db.sourcesDao.recalculatePastExamFrequency();
      return latest.parentId;
    });
  }

  Future<void> _mergeAudits({
    required int parentUnitId,
    required int childUnitId,
  }) async {
    final childRows = await (select(
      audits,
    )..where((a) => a.examUnitId.equals(childUnitId))).get();

    for (final child in childRows) {
      final parent =
          await (select(audits)
                ..where(
                  (a) =>
                      a.examUnitId.equals(parentUnitId) &
                      a.sourceSegmentId.equals(child.sourceSegmentId),
                )
                ..limit(1))
              .getSingleOrNull();

      if (parent == null) {
        await (update(audits)..where((a) => a.id.equals(child.id))).write(
          AuditsCompanion(
            examUnitId: Value(parentUnitId),
            updatedAt: Value(DateTime.now()),
          ),
        );
        continue;
      }

      final mergedStatus = _worseAuditStatus(parent.status, child.status);
      final mergedContentConfidence = _worseConfidence(
        parent.contentConfidence,
        child.contentConfidence,
      );
      final mergedExamConfidence = _worseConfidence(
        parent.examConfidence,
        child.examConfidence,
      );

      await (update(audits)..where((a) => a.id.equals(parent.id))).write(
        AuditsCompanion(
          status: Value(mergedStatus),
          contentConfidence: Value(mergedContentConfidence),
          examConfidence: Value(mergedExamConfidence),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await (delete(audits)..where((a) => a.id.equals(child.id))).go();
    }
  }

  Future<void> _mergeUnitStats({
    required int parentUnitId,
    required int childUnitId,
  }) async {
    final parent =
        await (select(unitStats)
              ..where((u) => u.examUnitId.equals(parentUnitId))
              ..limit(1))
            .getSingleOrNull();
    final child =
        await (select(unitStats)
              ..where((u) => u.examUnitId.equals(childUnitId))
              ..limit(1))
            .getSingleOrNull();

    if (child == null) return;
    if (parent == null) {
      await (update(unitStats)..where((u) => u.id.equals(child.id))).write(
        UnitStatsCompanion(examUnitId: Value(parentUnitId)),
      );
      return;
    }

    await (update(unitStats)..where((u) => u.id.equals(parent.id))).write(
      UnitStatsCompanion(
        sourceCount: Value(parent.sourceCount + child.sourceCount),
        segmentCount: Value(parent.segmentCount + child.segmentCount),
        claimCount: Value(parent.claimCount + child.claimCount),
        evidenceCount: Value(parent.evidenceCount + child.evidenceCount),
        conflictCount: Value(parent.conflictCount + child.conflictCount),
        pointWeight: Value(
          parent.pointWeight > child.pointWeight
              ? parent.pointWeight
              : child.pointWeight,
        ),
        frequency: Value(
          parent.frequency > child.frequency
              ? parent.frequency
              : child.frequency,
        ),
        frequencyManualOverride: Value(
          parent.frequencyManualOverride || child.frequencyManualOverride,
        ),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await (delete(unitStats)..where((u) => u.id.equals(child.id))).go();
  }

  Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-zA-Z0-9\u3040-\u30FF\u4E00-\u9FFF]+'))
        .where((t) => t.length >= 2)
        .toSet();
  }

  String _worseAuditStatus(String a, String b) {
    const rank = <String, int>{
      'Conflict': 5,
      'LowConfidence': 4,
      'Uncovered': 3,
      'Partial': 2,
      'Covered': 1,
    };
    return (rank[a] ?? 0) >= (rank[b] ?? 0) ? a : b;
  }

  String _worseConfidence(String a, String b) {
    const rank = <String, int>{'L': 3, 'M': 2, 'H': 1};
    return (rank[a] ?? 0) >= (rank[b] ?? 0) ? a : b;
  }

  String _inClause(int count) {
    return List.filled(count, '?').join(',');
  }
}
