import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
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

  test('試験を作成・取得できる', () async {
    final id = await db.examsDao.insertExam(
      ExamsCompanion.insert(
        name: '解剖学期末',
        totalPoints: const Value(100),
      ),
    );

    final exams = await db.examsDao.watchAll().first;
    expect(exams.length, 1);
    expect(exams.first.id, id);
    expect(exams.first.name, '解剖学期末');
    expect(exams.first.totalPoints, 100);
  });

  test('セクションを作成・取得できる', () async {
    final examId = await db.examsDao.insertExam(
      ExamsCompanion.insert(name: '生理学試験'),
    );

    final sectionId = await db.examsDao.insertSection(
      ExamSectionsCompanion.insert(
        examId: examId,
        name: '循環器',
        points: const Value(30),
        studyApproach: const Value('理解'),
      ),
    );

    final sections = await db.examsDao.watchSectionsForExam(examId).first;
    expect(sections.length, 1);
    expect(sections.first.id, sectionId);
    expect(sections.first.name, '循環器');
    expect(sections.first.points, 30);
    expect(sections.first.studyApproach, '理解');
  });

  test('出題プールを作成・取得できる', () async {
    final examId = await db.examsDao.insertExam(
      ExamsCompanion.insert(name: '解剖学'),
    );
    final sectionId = await db.examsDao.insertSection(
      ExamSectionsCompanion.insert(examId: examId, name: '骨格'),
    );

    await db.examsDao.insertPool(
      ExamPoolsCompanion.insert(
        sectionId: sectionId,
        description: '骨格名称100文',
        totalItems: const Value(100),
        guaranteedItems: const Value(30),
      ),
    );

    final pools = await db.examsDao.watchPoolsForSection(sectionId).first;
    expect(pools.length, 1);
    expect(pools.first.description, '骨格名称100文');
    expect(pools.first.totalItems, 100);
    expect(pools.first.guaranteedItems, 30);
  });

  test('試験削除でセクションとプールも削除される', () async {
    final examId = await db.examsDao.insertExam(
      ExamsCompanion.insert(name: '削除試験'),
    );
    final sectionId = await db.examsDao.insertSection(
      ExamSectionsCompanion.insert(examId: examId, name: 'セクション1'),
    );
    await db.examsDao.insertPool(
      ExamPoolsCompanion.insert(
        sectionId: sectionId,
        description: 'プール1',
        totalItems: const Value(10),
        guaranteedItems: const Value(5),
      ),
    );

    await db.examsDao.deleteExam(examId);

    final exams = await db.examsDao.watchAll().first;
    final sections = await db.examsDao.watchSectionsForExam(examId).first;
    final pools = await db.examsDao.watchPoolsForSection(sectionId).first;

    expect(exams, isEmpty);
    expect(sections, isEmpty);
    expect(pools, isEmpty);
  });

  test('SectionCoverage: sectionIdで紐づいたExamUnitが集計される', () async {
    final examId = await db.examsDao.insertExam(
      ExamsCompanion.insert(name: 'カバレッジ試験'),
    );
    final sectionId = await db.examsDao.insertSection(
      ExamSectionsCompanion.insert(examId: examId, name: '内科'),
    );

    // ExamUnit を section に紐づけ
    await db.into(db.examUnits).insert(
      ExamUnitsCompanion.insert(
        title: 'Unit A',
        sectionId: Value(sectionId),
        confidenceLevel: const Value('low'),
      ),
    );
    await db.into(db.examUnits).insert(
      ExamUnitsCompanion.insert(
        title: 'Unit B',
        sectionId: Value(sectionId),
        auditStatus: const Value('Covered'),
        confidenceLevel: const Value('high'),
      ),
    );

    final stats = await db.examsDao.getSectionCoverage(examId);
    expect(stats.length, 1);
    expect(stats.first.totalUnits, 2);
    expect(stats.first.coveredUnits, 1); // Unit B のみ Covered
    expect(stats.first.lowConfUnits, 1); // Unit A のみ low
  });
}
