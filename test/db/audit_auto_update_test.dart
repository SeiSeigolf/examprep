import 'package:drift/drift.dart';
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

  test('EvidencePackItems 更新で audits が自動更新される', () async {
    final sourceId = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(
        fileName: 'test.pdf',
        filePath: '/tmp/test_audit.pdf',
      ),
    );
    final segmentId = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceId,
            pageNumber: 1,
            content: const Value('segment'),
          ),
        );

    final unitId = await db.examUnitsDao.insertUnit(
      ExamUnitsCompanion.insert(title: 'unit'),
    );
    final claimId = await db.claimsDao.insertClaimWithEvidence(
      ClaimsCompanion.insert(
        examUnitId: unitId,
        content: 'claim',
        contentConfidence: const Value('L'),
      ),
      [segmentId],
    );

    final packId = await db.evidencePacksDao.upsertEvidencePack(
      claimId: claimId,
    );
    await db.evidencePacksDao.replaceItems(packId, [
      EvidencePackItemInput(sourceSegmentId: segmentId),
    ]);

    var audit =
        await (db.select(db.audits)..where(
              (a) =>
                  a.examUnitId.equals(unitId) &
                  a.sourceSegmentId.equals(segmentId),
            ))
            .getSingle();
    expect(audit.status, 'LowConfidence');

    await db
        .into(db.conflicts)
        .insert(
          ConflictsCompanion.insert(
            sourceSegmentId: segmentId,
            examUnitId: unitId,
            claimId: Value(claimId),
            status: const Value('open'),
          ),
        );

    await db.evidencePacksDao.replaceItems(packId, [
      EvidencePackItemInput(sourceSegmentId: segmentId),
    ]);

    audit =
        await (db.select(db.audits)..where(
              (a) =>
                  a.examUnitId.equals(unitId) &
                  a.sourceSegmentId.equals(segmentId),
            ))
            .getSingle();
    expect(audit.status, 'Conflict');
  });
}
