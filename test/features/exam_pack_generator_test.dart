import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/master_sheet/services/exam_pack_generator.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

// インメモリDBで試験プロファイル + 複数ソースグループのデータを組み立てる
Future<({AppDatabase db, int profileId})> _buildFixture() async {
  final db = _makeInMemoryDb();

  // --- past_exam ソース ---
  final pastSourceId = await db.into(db.sources).insert(
    SourcesCompanion.insert(
      fileName: 'past_exam_cardio.pdf',
      filePath: '/tmp/past_exam_cardio.pdf',
      sourceType: const Value('past_exam'),
      sourceGroup: const Value('past_exam'),
    ),
  );
  final pastSegId = await db.into(db.sourceSegments).insert(
    SourceSegmentsCompanion.insert(
      sourceId: pastSourceId,
      pageNumber: 1,
      content: const Value('【心不全】心拍出量が低下する病態。'),
    ),
  );

  // --- pool ソース ---
  final poolSourceId = await db.into(db.sources).insert(
    SourcesCompanion.insert(
      fileName: 'pool_100.pdf',
      filePath: '/tmp/pool_100.pdf',
      sourceType: const Value('lecture'),
      sourceGroup: const Value('pool'),
    ),
  );
  final poolSegId = await db.into(db.sourceSegments).insert(
    SourceSegmentsCompanion.insert(
      sourceId: poolSourceId,
      pageNumber: 3,
      content: const Value('【大動脈解離】突発性胸背部痛が特徴。'),
    ),
  );

  // --- practice ソース ---
  final practiceSourceId = await db.into(db.sources).insert(
    SourcesCompanion.insert(
      fileName: 'practice_drill.pdf',
      filePath: '/tmp/practice_drill.pdf',
      sourceType: const Value('assignment'),
      sourceGroup: const Value('practice'),
    ),
  );
  final practiceSegId = await db.into(db.sourceSegments).insert(
    SourceSegmentsCompanion.insert(
      sourceId: practiceSourceId,
      pageNumber: 1,
      content: const Value('【心筋梗塞】冠動脈閉塞による心筋壊死。'),
    ),
  );

  // --- exam units ---
  final unit1Id = await db.into(db.examUnits).insert(
    ExamUnitsCompanion.insert(
      title: '心不全',
      auditStatus: const Value('Covered'),
      unitType: const Value('定義'),
      problemFormat: const Value('選択肢'),
    ),
  );
  final unit2Id = await db.into(db.examUnits).insert(
    ExamUnitsCompanion.insert(
      title: '大動脈解離',
      auditStatus: const Value('Partial'),
      unitType: const Value('鑑別'),
      problemFormat: const Value('選択肢'),
    ),
  );
  final unit3Id = await db.into(db.examUnits).insert(
    ExamUnitsCompanion.insert(
      title: '心筋梗塞',
      auditStatus: const Value('Uncovered'),
      unitType: const Value('定義'),
      problemFormat: const Value('選択肢'),
    ),
  );
  final unit4Id = await db.into(db.examUnits).insert(
    ExamUnitsCompanion.insert(
      title: '心室細動',
      auditStatus: const Value('Conflict'),
      unitType: const Value('機序'),
      problemFormat: const Value('記述'),
    ),
  );

  // --- claims + evidence (past_exam) ---
  final claim1Id = await db.into(db.claims).insert(
    ClaimsCompanion.insert(
      examUnitId: unit1Id,
      content: '心不全とは心拍出量が低下して末梢組織の需要を満たせない状態。',
    ),
  );
  final ep1Id = await db.into(db.evidencePacks).insert(
    EvidencePacksCompanion.insert(claimId: claim1Id),
  );
  await db.into(db.evidencePackItems).insert(
    EvidencePackItemsCompanion.insert(
      evidencePackId: ep1Id,
      sourceSegmentId: pastSegId,
      snippet: const Value('心拍出量が低下する病態。'),
    ),
  );

  // --- claims + evidence (pool) ---
  final claim2Id = await db.into(db.claims).insert(
    ClaimsCompanion.insert(
      examUnitId: unit2Id,
      content: '大動脈解離はDeBakey分類で管理。',
    ),
  );
  final ep2Id = await db.into(db.evidencePacks).insert(
    EvidencePacksCompanion.insert(claimId: claim2Id),
  );
  await db.into(db.evidencePackItems).insert(
    EvidencePackItemsCompanion.insert(
      evidencePackId: ep2Id,
      sourceSegmentId: poolSegId,
      snippet: const Value('突発性胸背部痛が特徴。'),
    ),
  );

  // --- claims + evidence (practice) ---
  final claim3Id = await db.into(db.claims).insert(
    ClaimsCompanion.insert(
      examUnitId: unit3Id,
      content: '心筋梗塞では冠動脈が閉塞して心筋壊死が起こる。',
    ),
  );
  await db.into(db.evidenceLinks).insert(
    EvidenceLinksCompanion.insert(
      claimId: claim3Id,
      sourceSegmentId: practiceSegId,
    ),
  );

  // --- exam profile ---
  await db.customStatement('''
    INSERT INTO exam_profiles (exam_name, created_at)
    VALUES ('循環器期末', CURRENT_TIMESTAMP)
    ''');
  final profileRow =
      await db.customSelect('SELECT last_insert_rowid() AS id').getSingle();
  final profileId = profileRow.read<int>('id');

  for (final unitId in [unit1Id, unit2Id, unit3Id, unit4Id]) {
    await db.customStatement(
      'INSERT INTO exam_profile_units (exam_profile_id, exam_unit_id) VALUES (?, ?)',
      [profileId, unitId],
    );
  }
  for (final sourceId in [pastSourceId, poolSourceId, practiceSourceId]) {
    await db.customStatement(
      'INSERT INTO exam_profile_sources (exam_profile_id, source_id) VALUES (?, ?)',
      [profileId, sourceId],
    );
  }

  return (db: db, profileId: profileId);
}

void main() {
  group('ExamPackGenerator', () {
    test('generateMarkdowns: 7ファイルが生成される', () async {
      final fixture = await _buildFixture();
      final db = fixture.db;
      addTearDown(db.close);

      final generator = ExamPackGenerator(db);
      final results = await generator.generateMarkdowns(
        examProfileId: fixture.profileId,
        examName: '循環器期末',
        now: DateTime(2026, 3, 8, 9),
      );

      expect(results.length, 7);

      final fileNames = results.map((r) => r.fileName).toSet();
      expect(fileNames, containsAll([
        'INDEX.md',
        'SCORE_STRATEGY.md',
        'PAST_EXAM_COVERAGE.md',
        'POOL_100_COVERAGE.md',
        'PRACTICE_COVERAGE.md',
        'UNSURE_AND_CONFLICTS.md',
        'MASTER_COVERAGE.md',
      ]));
    });

    test('INDEX.md: 全ファイルへのリンクが含まれる', () async {
      final fixture = await _buildFixture();
      final db = fixture.db;
      addTearDown(db.close);

      final generator = ExamPackGenerator(db);
      final results = await generator.generateMarkdowns(
        examProfileId: fixture.profileId,
        examName: '循環器期末',
        now: DateTime(2026, 3, 8, 9),
      );

      final index = results.firstWhere((r) => r.fileName == 'INDEX.md');
      expect(index.markdown, contains('SCORE_STRATEGY.md'));
      expect(index.markdown, contains('PAST_EXAM_COVERAGE.md'));
      expect(index.markdown, contains('POOL_100_COVERAGE.md'));
      expect(index.markdown, contains('PRACTICE_COVERAGE.md'));
      expect(index.markdown, contains('UNSURE_AND_CONFLICTS.md'));
      expect(index.markdown, contains('MASTER_COVERAGE.md'));
      expect(index.markdown, contains('循環器期末'));
    });

    test('SCORE_STRATEGY.md: カバレッジサマリ + 総Unit数を含む', () async {
      final fixture = await _buildFixture();
      final db = fixture.db;
      addTearDown(db.close);

      final generator = ExamPackGenerator(db);
      final results = await generator.generateMarkdowns(
        examProfileId: fixture.profileId,
        examName: '循環器期末',
        now: DateTime(2026, 3, 8, 9),
      );

      final score = results.firstWhere((r) => r.fileName == 'SCORE_STRATEGY.md');
      expect(score.markdown, contains('完成度サマリ'));
      expect(score.markdown, contains('総Unit数'));
      expect(score.markdown, contains('Coverage'));
      expect(score.summaryJson, isNotNull);
      expect(score.summaryJson!['totalCount'], 4);
    });

    test('PAST_EXAM_COVERAGE.md: past_examグループのUnitが含まれる', () async {
      final fixture = await _buildFixture();
      final db = fixture.db;
      addTearDown(db.close);

      final generator = ExamPackGenerator(db);
      final results = await generator.generateMarkdowns(
        examProfileId: fixture.profileId,
        examName: '循環器期末',
        now: DateTime(2026, 3, 8, 9),
      );

      final pastExam =
          results.firstWhere((r) => r.fileName == 'PAST_EXAM_COVERAGE.md');
      expect(pastExam.markdown, contains('心不全'));
    });

    test('UNSURE_AND_CONFLICTS.md: Conflict + Uncovered が含まれる', () async {
      final fixture = await _buildFixture();
      final db = fixture.db;
      addTearDown(db.close);

      final generator = ExamPackGenerator(db);
      final results = await generator.generateMarkdowns(
        examProfileId: fixture.profileId,
        examName: '循環器期末',
        now: DateTime(2026, 3, 8, 9),
      );

      final unsure =
          results.firstWhere((r) => r.fileName == 'UNSURE_AND_CONFLICTS.md');
      expect(unsure.markdown, contains('Conflict'));
      expect(unsure.markdown, contains('Uncovered'));
      expect(unsure.markdown, contains('心室細動'));
      expect(unsure.markdown, contains('心筋梗塞'));
      expect(unsure.summaryJson!['conflictCount'], 1);
      expect(unsure.summaryJson!['uncoveredCount'], 1);
    });

    test('MASTER_COVERAGE.md: 全Unitを含む統合シートが生成される', () async {
      final fixture = await _buildFixture();
      final db = fixture.db;
      addTearDown(db.close);

      final generator = ExamPackGenerator(db);
      final results = await generator.generateMarkdowns(
        examProfileId: fixture.profileId,
        examName: '循環器期末',
        now: DateTime(2026, 3, 8, 9),
      );

      final master =
          results.firstWhere((r) => r.fileName == 'MASTER_COVERAGE.md');
      expect(master.markdown, contains('循環器期末'));
      expect(master.markdown, contains('完成判定'));
      expect(master.markdown, contains('心不全'));
    });
  });
}
