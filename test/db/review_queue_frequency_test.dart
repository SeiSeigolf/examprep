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

  test('past_exam の根拠が増えると unit_stats.frequency が増える', () async {
    final pastSourceId = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(
        fileName: 'past_exam_2024.pdf',
        filePath: '/tmp/past_exam_2024.pdf',
        sourceType: const Value('past_exam'),
      ),
    );
    final lectureSourceId = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(
        fileName: 'lecture_01.pdf',
        filePath: '/tmp/lecture_01.pdf',
        sourceType: const Value('lecture'),
      ),
    );

    final pastSeg1Id = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: pastSourceId,
            pageNumber: 1,
            content: const Value('past segment 1'),
          ),
        );
    final pastSeg2Id = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: pastSourceId,
            pageNumber: 2,
            content: const Value('past segment 2'),
          ),
        );
    final lectureSegId = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: lectureSourceId,
            pageNumber: 1,
            content: const Value('lecture segment'),
          ),
        );

    final unitId = await db.examUnitsDao.insertUnit(
      ExamUnitsCompanion.insert(title: '循環器'),
    );
    final claimId = await db.claimsDao.insertClaimWithEvidence(
      ClaimsCompanion.insert(examUnitId: unitId, content: '心不全ではBNPが上昇する'),
      [pastSeg1Id],
    );

    await db.sourcesDao.recalculatePastExamFrequency();

    final packId = await db.evidencePacksDao.upsertEvidencePack(
      claimId: claimId,
    );
    await db.evidencePacksDao.replaceItems(packId, [
      EvidencePackItemInput(sourceSegmentId: pastSeg2Id, weight: 1),
      EvidencePackItemInput(
        sourceSegmentId: lectureSegId,
        weight: 1,
      ), // lecture は除外
    ]);

    final stat = await (db.select(
      db.unitStats,
    )..where((t) => t.examUnitId.equals(unitId))).getSingle();
    expect(stat.frequency, 2); // past_exam segment: id=1,2
  });

  test('frequencyManualOverride=true の unit は自動更新されない', () async {
    final unitId = await db.examUnitsDao.insertUnit(
      ExamUnitsCompanion.insert(title: '消化器'),
    );
    await db
        .into(db.unitStats)
        .insert(
          UnitStatsCompanion.insert(
            examUnitId: unitId,
            frequency: const Value(99),
            frequencyManualOverride: const Value(true),
          ),
        );

    await db.sourcesDao.recalculatePastExamFrequency();

    final stat = await (db.select(
      db.unitStats,
    )..where((t) => t.examUnitId.equals(unitId))).getSingle();
    expect(stat.frequency, 99);
  });
}
