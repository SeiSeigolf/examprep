import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/study_plan/providers/study_plan.provider.dart';
import 'package:exam_os/features/study_plan/services/study_plan_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  test('Study PlanをMarkdownに出力できる', () async {
    final db = _makeInMemoryDb();
    addTearDown(db.close);

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
    final sourceId = await db
        .into(db.sources)
        .insert(
          SourcesCompanion.insert(fileName: 'a.pdf', filePath: '/tmp/a.pdf'),
        );
    final segmentId = await db
        .into(db.sourceSegments)
        .insert(
          SourceSegmentsCompanion.insert(
            sourceId: sourceId,
            pageNumber: 1,
            content: const Value('seg'),
          ),
        );
    await db
        .into(db.evidenceLinks)
        .insert(
          EvidenceLinksCompanion.insert(
            claimId: claimId,
            sourceSegmentId: segmentId,
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
    expect(md, contains('根拠リンク数: 1'));
    expect(md, contains('次回復習日時:'));
    expect(md, contains('根拠:'));
    expect(md, contains('a.pdf p.1'));
    expect(md, contains('file:///tmp/a.pdf'));
  });
}
