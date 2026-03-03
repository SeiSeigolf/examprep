import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/study_plan/providers/study_plan.provider.dart';
import 'package:exam_os/features/study_plan/services/study_plan_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  test('Study PlanをMarkdownに出力できる（根拠並び順とsnippet正規化）', () async {
    final db = _makeInMemoryDb();
    addTearDown(db.close);
    final longSnippet = '${List.filled(260, 'X').join()}\nnewline';

    final unitId = await db
        .into(db.examUnits)
        .insert(
          ExamUnitsCompanion.insert(
            title: '心不全',
            unitType: const Value('定義'),
            problemFormat: const Value('選択肢'),
            confidenceLevel: const Value('medium'),
          ),
        );
    final claimId = await db
        .into(db.claims)
        .insert(
          ClaimsCompanion.insert(
            examUnitId: unitId,
            content: '心不全は心拍出量の低下を伴う。',
            contentConfidence: const Value('M'),
            createdBy: const Value('test'),
          ),
        );
    final sourceA = await db
        .into(db.sources)
        .insert(
          SourcesCompanion.insert(fileName: 'a.pdf', filePath: '/tmp/a.pdf'),
        );
    final sourceB = await db
        .into(db.sources)
        .insert(
          SourcesCompanion.insert(fileName: 'b.pdf', filePath: '/tmp/b.pdf'),
        );
    final sourceC = await db
        .into(db.sources)
        .insert(
          SourcesCompanion.insert(fileName: 'c.pdf', filePath: '/tmp/c.pdf'),
        );
    final sourceD = await db
        .into(db.sources)
        .insert(
          SourcesCompanion.insert(fileName: 'd.pdf', filePath: '/tmp/d.pdf'),
        );

    final segmentA = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceA,
            pageNumber: 3,
            content: const Value('seg A'),
          ),
        );
    final segmentB = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceB,
            pageNumber: 2,
            content: const Value('seg B'),
          ),
        );
    final segmentC = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceC,
            pageNumber: 2,
            content: const Value('seg C'),
          ),
        );
    final segmentD = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceD,
            pageNumber: 1,
            content: const Value('seg D'),
          ),
        );

    final packId = await db
        .into(db.evidencePacks)
        .insert(EvidencePacksCompanion.insert(claimId: claimId));
    await db
        .into(db.evidencePackItems)
        .insert(
          EvidencePackItemsCompanion.insert(
            evidencePackId: packId,
            sourceSegmentId: segmentA,
            pageNumber: const Value(3),
            weight: const Value(3),
            snippet: const Value('A\nline1'),
          ),
        );
    await db
        .into(db.evidencePackItems)
        .insert(
          EvidencePackItemsCompanion.insert(
            evidencePackId: packId,
            sourceSegmentId: segmentB,
            pageNumber: const Value(2),
            weight: const Value(5),
            snippet: const Value('B snippet'),
          ),
        );
    await db
        .into(db.evidencePackItems)
        .insert(
          EvidencePackItemsCompanion.insert(
            evidencePackId: packId,
            sourceSegmentId: segmentC,
            pageNumber: const Value(2),
            weight: const Value(5),
            snippet: const Value('C snippet'),
          ),
        );
    await db
        .into(db.evidencePackItems)
        .insert(
          EvidencePackItemsCompanion.insert(
            evidencePackId: packId,
            sourceSegmentId: segmentD,
            pageNumber: const Value(1),
            weight: const Value(1),
            snippet: Value(longSnippet),
          ),
        );
    await db
        .into(db.claimReviewSchedules)
        .insert(
          ClaimReviewSchedulesCompanion.insert(
            examUnitId: unitId,
            claimId: claimId,
            nextReviewAt: DateTime(2026, 3, 4, 9),
          ),
        );

    final md = await StudyPlanExporter.generateMarkdown(
      db,
      topN: 5,
      mode: CramMode.d7,
      examDate: DateTime(2026, 3, 10, 9),
      now: DateTime(2026, 3, 3, 9),
    );

    expect(md, contains('# Study Plan Export'));
    expect(md, contains('心不全'));
    expect(md, contains('やること:'));
    expect(md, contains('根拠リンク数: 4'));
    expect(md, contains('次回復習日時:'));
    expect(md, contains('根拠:'));
    expect(md, contains('b.pdf p.2'));
    expect(md, contains('c.pdf p.2'));
    expect(md, contains('a.pdf p.3'));
    expect(md, contains('file:///tmp/a.pdf'));
    final iB = md.indexOf('b.pdf p.2');
    final iC = md.indexOf('c.pdf p.2');
    final iA = md.indexOf('a.pdf p.3');
    expect(iB, greaterThan(-1));
    expect(iC, greaterThan(iB));
    expect(iA, greaterThan(iC));
    expect(md, contains('A line1'));
    expect(md.contains('X' * 220), isFalse);
  });
}
