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

  test('source_segments から候補生成して ExamUnit+Claim+Evidence を作成できる', () async {
    final sourceId = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(fileName: 'gen.pdf', filePath: '/tmp/gen.pdf'),
    );
    final segmentId = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceId,
            pageNumber: 1,
            content: const Value(
              '心不全の定義：心拍出量が低下し、末梢循環不全を来す。\n\nBNPは心不全で上昇し、診断補助に有用である。',
            ),
          ),
        );

    final drafts = await db.sourcesDao.suggestExamUnitDraftsFromSource(
      sourceId,
    );
    expect(drafts, isNotEmpty);

    final created = await db.sourcesDao.createExamUnitsFromDrafts([
      drafts.first,
    ]);
    expect(created.length, 1);

    final units = await db.examUnitsDao.getAllUnits();
    expect(units.length, 1);

    final claims = await (db.select(
      db.claims,
    )..where((c) => c.examUnitId.equals(units.first.id))).get();
    expect(claims, isNotEmpty);

    final links = await (db.select(
      db.evidenceLinks,
    )..where((e) => e.claimId.equals(claims.first.id))).get();
    expect(links.length, 1);
    expect(links.first.sourceSegmentId, segmentId);

    final audit =
        await (db.select(db.audits)..where(
              (a) =>
                  a.examUnitId.equals(units.first.id) &
                  a.sourceSegmentId.equals(segmentId),
            ))
            .getSingleOrNull();
    expect(audit, isNot(equals(null)));
    expect(audit!.status, isNot('Uncovered'));
  });

  test('見出し優先と正規化重複判定で候補が安定して抽出される', () async {
    final sourceId = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(
        fileName: 'stable.pdf',
        filePath: '/tmp/stable.pdf',
      ),
    );
    await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceId,
            pageNumber: 1,
            content: const Value(
              '【心不全】\n'
              '1. BNP上昇：心不全診断に有用。\n'
              '(1) NYHA分類：重症度評価に使う。\n'
              'Heart FAILURE:\n'
              '本文の説明が続く。\n'
              'Ｈｅａｒｔ　ＦＡＩＬＵＲＥ：\n'
              '別表記だが同義。',
            ),
          ),
        );

    final drafts = await db.sourcesDao.suggestExamUnitDraftsFromSource(
      sourceId,
      limit: 10,
    );

    final titles = drafts.map((d) => d.title).toList();
    expect(titles, isNotEmpty);
    expect(titles, contains('心不全'));
    expect(
      titles.where((t) => t.toLowerCase().contains('heart failure')).length,
      1,
    );
  });
}
