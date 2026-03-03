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

  test('Uncovered セグメントを紐づけると Covered になる', () async {
    final sourceId = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(
        fileName: 'uncovered.pdf',
        filePath: '/tmp/uncovered.pdf',
      ),
    );
    final segmentId = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceId,
            pageNumber: 3,
            content: const Value('心不全 BNP 呼吸困難'),
          ),
        );
    final unitId = await db.examUnitsDao.insertUnit(
      ExamUnitsCompanion.insert(
        title: '心不全',
        description: const Value('BNP 呼吸困難'),
      ),
    );

    final before = await db.auditDao.watchCoverage().first;
    final beforeRow = before.firstWhere((r) => r.segId == segmentId);
    expect(beforeRow.auditStatus, 'uncovered');

    await db.auditDao.linkSegmentToUnit(segmentId: segmentId, unitId: unitId);

    final audit =
        await (db.select(db.audits)..where(
              (a) =>
                  a.sourceSegmentId.equals(segmentId) &
                  a.examUnitId.equals(unitId),
            ))
            .getSingle();
    expect(audit.status, 'Covered');
  });
}
