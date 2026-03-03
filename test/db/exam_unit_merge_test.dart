import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;

  setUp(() {
    db = _makeInMemoryDb();
  });

  tearDown(() => db.close());

  test('統合後に親Unitへデータが集約される', () async {
    final sourceId = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(fileName: 's.pdf', filePath: '/tmp/s.pdf'),
    );
    final seg1 = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceId,
            pageNumber: 1,
            content: const Value('alpha beta'),
          ),
        );
    final seg2 = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceId,
            pageNumber: 2,
            content: const Value('alpha gamma'),
          ),
        );

    final parentId = await db.examUnitsDao.insertUnit(
      ExamUnitsCompanion.insert(title: '心不全'),
    );
    final childId = await db.examUnitsDao.insertUnit(
      ExamUnitsCompanion.insert(title: '心不全（重複）'),
    );

    final parentClaim = await db.claimsDao.insertClaimWithEvidence(
      ClaimsCompanion.insert(examUnitId: parentId, content: 'BNP上昇'),
      [seg1],
    );
    final childClaim = await db.claimsDao.insertClaimWithEvidence(
      ClaimsCompanion.insert(examUnitId: childId, content: 'BNPが高い'),
      [seg2],
    );

    final parentPack = await db.evidencePacksDao.upsertEvidencePack(
      claimId: parentClaim,
    );
    await db.evidencePacksDao.replaceItems(parentPack, [
      EvidencePackItemInput(sourceSegmentId: seg1),
    ]);
    final childPack = await db.evidencePacksDao.upsertEvidencePack(
      claimId: childClaim,
    );
    await db.evidencePacksDao.replaceItems(childPack, [
      EvidencePackItemInput(sourceSegmentId: seg2),
    ]);

    Future<void> upsertStats(int unitId) async {
      final existing = await (db.select(
        db.unitStats,
      )..where((u) => u.examUnitId.equals(unitId))).getSingleOrNull();
      if (existing == null) {
        await db
            .into(db.unitStats)
            .insert(
              UnitStatsCompanion.insert(
                examUnitId: unitId,
                claimCount: const Value(1),
                evidenceCount: const Value(1),
              ),
            );
      } else {
        await (db.update(
          db.unitStats,
        )..where((u) => u.id.equals(existing.id))).write(
          UnitStatsCompanion(
            claimCount: const Value(1),
            evidenceCount: const Value(1),
          ),
        );
      }
    }

    await upsertStats(parentId);
    await upsertStats(childId);

    await db.examUnitsDao.mergeUnits(
      parentUnitId: parentId,
      childUnitId: childId,
    );

    final childUnit = await (db.select(
      db.examUnits,
    )..where((u) => u.id.equals(childId))).getSingleOrNull();
    expect(childUnit, equals(null));

    final claims = await (db.select(
      db.claims,
    )..where((c) => c.examUnitId.equals(parentId))).get();
    expect(claims.length, 2);

    final links = await (db.select(db.evidenceLinks)).get();
    expect(links.length, 2);

    final packItems = await (db.select(db.evidencePackItems)).get();
    expect(packItems.length, 2);

    final childAudits = await (db.select(
      db.audits,
    )..where((a) => a.examUnitId.equals(childId))).get();
    expect(childAudits, isEmpty);

    final parentStat = await (db.select(
      db.unitStats,
    )..where((u) => u.examUnitId.equals(parentId))).getSingle();
    expect(parentStat.claimCount, greaterThanOrEqualTo(2));
    expect(parentStat.evidenceCount, greaterThanOrEqualTo(2));
  });
}
