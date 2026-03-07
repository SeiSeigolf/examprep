import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/db/database.provider.dart';
import 'package:exam_os/features/audit/providers/audit.provider.dart';
import 'package:exam_os/features/quick_generate/services/master_coverage_sheet_exporter.dart';
import 'package:exam_os/features/quick_generate/services/quick_generate_pipeline.dart';
import 'package:exam_os/features/review_queue/providers/review_queue.provider.dart';
import 'package:exam_os/shared/providers/exam_profile.provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  test(
    'quick generate pipeline: Unit/Claim/Evidence生成 + 監査更新 + Markdown要件',
    () async {
      final db = _makeInMemoryDb();
      addTearDown(db.close);

      final sourceId = await db
          .into(db.sources)
          .insert(
            SourcesCompanion.insert(
              fileName: 'past_exam_cardio.pdf',
              filePath: '/tmp/past_exam_cardio.pdf',
              sourceType: const Value('past_exam'),
            ),
          );

      await db
          .into(db.sourceSegments)
          .insert(
            SourceSegmentsCompanion.insert(
              sourceId: sourceId,
              pageNumber: 1,
              content: const Value('【心不全】心不全は心拍出量低下を来す病態である。'),
            ),
          );
      await db
          .into(db.sourceSegments)
          .insert(
            SourceSegmentsCompanion.insert(
              sourceId: sourceId,
              pageNumber: 2,
              content: const Value('【肺水腫】左心不全で肺うっ血が進行すると肺水腫を生じる。'),
            ),
          );

      // スコープ外データ
      final otherSourceId = await db
          .into(db.sources)
          .insert(
            SourcesCompanion.insert(
              fileName: 'other_scope.pdf',
              filePath: '/tmp/other_scope.pdf',
              sourceType: const Value('lecture'),
            ),
          );
      final otherSegId = await db
          .into(db.sourceSegments)
          .insert(
            SourceSegmentsCompanion.insert(
              sourceId: otherSourceId,
              pageNumber: 1,
              content: const Value('【別範囲】別試験の内容'),
            ),
          );
      final otherUnitId = await db
          .into(db.examUnits)
          .insert(
            ExamUnitsCompanion.insert(
              title: '別試験ユニット',
              description: const Value('別範囲'),
            ),
          );
      final otherClaimId = await db
          .into(db.claims)
          .insert(
            ClaimsCompanion.insert(
              examUnitId: otherUnitId,
              content: '別範囲のclaim',
            ),
          );
      await db
          .into(db.evidenceLinks)
          .insert(
            EvidenceLinksCompanion.insert(
              claimId: otherClaimId,
              sourceSegmentId: otherSegId,
            ),
          );

      final beforeCoverage = await db.auditDao.watchCoverage().first;
      final beforeUncovered = beforeCoverage
          .where((c) => c.auditStatus == 'uncovered')
          .length;

      final extraSourceId = await db
          .into(db.sources)
          .insert(
            SourcesCompanion.insert(
              fileName: 'auto_link_source.pdf',
              filePath: '/tmp/auto_link_source.pdf',
              sourceType: const Value('past_exam'),
            ),
          );
      await db
          .into(db.sourceSegments)
          .insert(
            SourceSegmentsCompanion.insert(
              sourceId: extraSourceId,
              pageNumber: 5,
              content: const Value('【自動紐づけ】自動でリンクされるべきページ'),
            ),
          );
      final extraUnitId = await db
          .into(db.examUnits)
          .insert(
            ExamUnitsCompanion.insert(
              title: '自動紐づけUnit',
              unitType: const Value('定義'),
              confidenceLevel: const Value('low'),
            ),
          );
      await db
          .into(db.claims)
          .insert(
            ClaimsCompanion.insert(
              examUnitId: extraUnitId,
              content: '自動紐づけClaim',
              contentConfidence: const Value('L'),
            ),
          );
      final pipeline = QuickGeneratePipeline(
        db,
        exporter: (db, input) async {
          expect(input.examProfileId, isNotNull);
          final generated = await MasterCoverageSheetExporter.generateMarkdown(
            db,
            input,
            now: DateTime(2026, 3, 8, 9),
          );
          final outPath =
              '/tmp/quick_generate_pipeline_test_${DateTime.now().millisecondsSinceEpoch}.md';
          await File(outPath).writeAsString(generated.markdown);
          return MasterCoverageExportResult(
            path: outPath,
            summary: generated.summary,
          );
        },
      );

      final result = await pipeline.run(
        QuickGenerateRequest(
          examName: '循環器期末',
          subject: '循環器',
          existingSourceIds: [sourceId, extraSourceId],
        ),
      );

      final unitCount = await db
          .customSelect('SELECT COUNT(*) AS c FROM exam_units')
          .getSingle();
      final claimCount = await db
          .customSelect('SELECT COUNT(*) AS c FROM claims')
          .getSingle();
      final evidenceCount = await db
          .customSelect('SELECT COUNT(*) AS c FROM evidence_links')
          .getSingle();

      expect(unitCount.read<int>('c'), greaterThan(0));
      expect(claimCount.read<int>('c'), greaterThan(0));
      expect(evidenceCount.read<int>('c'), greaterThan(0));

      final afterCoverage = await db.auditDao.watchCoverage().first;
      final afterUncovered = afterCoverage
          .where((c) => c.auditStatus == 'uncovered')
          .length;
      expect(afterUncovered, lessThan(beforeUncovered));

      final md = await File(result.markdownPath).readAsString();
      expect(result.examProfileId, greaterThan(0));
      expect(md, contains('完成判定'));
      expect(md, contains('出題率'));
      expect(md, contains('Claims:'));
      expect(md, contains('根拠(上位3件):'));
      expect(md, contains('推奨勉強法'));
      expect(md, contains('file:///tmp/past_exam_cardio.pdf'));

      final profileSources = await db
          .customSelect(
            '''
        SELECT COUNT(*) AS c
        FROM exam_profile_sources
        WHERE exam_profile_id = ?1
        ''',
            variables: [Variable.withInt(result.examProfileId)],
          )
          .getSingle();
      final profileUnits = await db
          .customSelect(
            '''
        SELECT COUNT(*) AS c
        FROM exam_profile_units
        WHERE exam_profile_id = ?1
        ''',
            variables: [Variable.withInt(result.examProfileId)],
          )
          .getSingle();
      expect(profileSources.read<int>('c'), greaterThan(0));
      expect(profileUnits.read<int>('c'), greaterThan(0));

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      container.read(activeExamProfileIdProvider.notifier).state =
          result.examProfileId;

      final scopedCoverage = await container.read(coverageProvider.future);
      final afterScopedUncovered = scopedCoverage
          .where((r) => r.auditStatus == 'uncovered')
          .length;
      expect(afterScopedUncovered, lessThan(beforeUncovered));
      expect(result.autoLinkedCount, greaterThanOrEqualTo(0));

      final scopedReview = await container.read(reviewQueueProvider.future);
      expect(scopedReview.every((r) => r.examUnitId != otherUnitId), isTrue);

      final activeProfileId = container.read(activeExamProfileIdProvider)!;
      final scopedDup = await db.examUnitsDao.findDuplicateCandidates(
        examProfileId: activeProfileId,
        limit: 20,
      );
      final scopedUnitRows = await db
          .customSelect(
            '''
        SELECT exam_unit_id
        FROM exam_profile_units
        WHERE exam_profile_id = ?1
        ''',
            variables: [Variable.withInt(result.examProfileId)],
          )
          .get();
      final scopedUnitIds = scopedUnitRows
          .map((r) => r.read<int>('exam_unit_id'))
          .toSet();
      expect(
        scopedDup.every(
          (p) =>
              scopedUnitIds.contains(p.left.id) &&
              scopedUnitIds.contains(p.right.id),
        ),
        isTrue,
      );
    },
  );
}
