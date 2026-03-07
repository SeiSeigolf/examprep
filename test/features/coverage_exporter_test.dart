import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/exam_setup/services/coverage_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;

  setUp(() {
    db = _makeInMemoryDb();
  });

  tearDown(() => db.close());

  test('CoverageExporter: 基本的なMarkdownが生成される', () async {
    // 試験・セクション・プールを作成
    final examId = await db.examsDao.insertExam(
      ExamsCompanion.insert(
        name: '解剖学期末',
        totalPoints: const Value(100),
        date: const Value(null),
      ),
    );
    final sectionId = await db.examsDao.insertSection(
      ExamSectionsCompanion.insert(
        examId: examId,
        name: '骨格系',
        points: const Value(40),
        studyApproach: const Value('暗記'),
      ),
    );
    await db.examsDao.insertPool(
      ExamPoolsCompanion.insert(
        sectionId: sectionId,
        description: '骨格名称100文',
        totalItems: const Value(100),
        guaranteedItems: const Value(30),
      ),
    );

    // ExamUnit を section に紐づけ
    await db.into(db.examUnits).insert(
      ExamUnitsCompanion.insert(
        title: '大腿骨の解剖',
        sectionId: Value(sectionId),
        confidenceLevel: const Value('low'),
      ),
    );

    final md = await CoverageExporter.generateMarkdown(
      db,
      examId,
      now: DateTime(2026, 3, 4, 9),
    );

    expect(md, contains('# 解剖学期末 網羅資料'));
    expect(md, contains('解剖学期末'));
    expect(md, contains('骨格系'));
    expect(md, contains('暗記'));
    expect(md, contains('40点'));
    expect(md, contains('骨格名称100文'));
    expect(md, contains('全100個暗記で30問保証'));
    expect(md, contains('大腿骨の解剖'));
    expect(md, contains('学習ユニット（優先度順）'));
  });

  test('CoverageExporter: セクション未割り当てUnitが末尾に出る', () async {
    final examId = await db.examsDao.insertExam(
      ExamsCompanion.insert(name: '生理学試験'),
    );

    // セクションあり
    final sectionId = await db.examsDao.insertSection(
      ExamSectionsCompanion.insert(examId: examId, name: '循環器'),
    );
    await db.into(db.examUnits).insert(
      ExamUnitsCompanion.insert(
        title: '心拍出量',
        sectionId: Value(sectionId),
        confidenceLevel: const Value('medium'),
      ),
    );

    // セクション未割り当て
    await db.into(db.examUnits).insert(
      ExamUnitsCompanion.insert(
        title: '未割り当てUnit',
        confidenceLevel: const Value('low'),
      ),
    );

    final md = await CoverageExporter.generateMarkdown(
      db,
      examId,
      now: DateTime(2026, 3, 4, 9),
    );

    expect(md, contains('心拍出量'));
    expect(md, contains('セクション未割り当て Unit'));
    // 未割り当てUnitはセクション後に出る
    final idxSection = md.indexOf('心拍出量');
    final idxUnassigned = md.indexOf('セクション未割り当て Unit');
    expect(idxSection, lessThan(idxUnassigned));
  });

  test('CoverageExporter: プールなしでも動作する', () async {
    final examId = await db.examsDao.insertExam(
      ExamsCompanion.insert(name: 'プールなし試験'),
    );
    await db.examsDao.insertSection(
      ExamSectionsCompanion.insert(examId: examId, name: 'セクションA'),
    );

    final md = await CoverageExporter.generateMarkdown(
      db,
      examId,
      now: DateTime(2026, 3, 4),
    );

    expect(md, contains('# プールなし試験 網羅資料'));
    expect(md, contains('プールなし試験'));
    expect(md, contains('セクションA'));
    // 「全N個暗記」は出ない
    expect(md.contains('全0個暗記'), isFalse);
  });
}
