import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/quick_generate/services/master_coverage_sheet_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  test('MasterCoverageSheetExporter: 完成判定(Not Ready)と次アクションを出力する', () async {
    final db = _makeInMemoryDb();
    addTearDown(db.close);

    final unitId = await db
        .into(db.examUnits)
        .insert(
          ExamUnitsCompanion.insert(
            title: '心不全',
            auditStatus: const Value('Uncovered'),
            confidenceLevel: const Value('low'),
          ),
        );

    final profileRow = await db.customSelect('''
      INSERT INTO exam_profiles (exam_name, created_at)
      VALUES ('循環器期末', CURRENT_TIMESTAMP)
      RETURNING id
      ''').getSingle();
    final profileId = profileRow.read<int>('id');

    await db.customStatement(
      'INSERT INTO exam_profile_units (exam_profile_id, exam_unit_id) VALUES (?, ?)',
      [profileId, unitId],
    );

    final generated = await MasterCoverageSheetExporter.generateMarkdown(
      db,
      MasterCoverageExportInput(
        examName: '循環器期末',
        examProfileId: profileId,
        sourceIds: const [],
        focusUnitIds: const [],
        autoMergedCount: 0,
      ),
      now: DateTime(2026, 3, 8, 9),
    );

    expect(generated.markdown, contains('完成判定'));
    expect(generated.markdown, contains('判定: Not Ready'));
    expect(generated.markdown, contains('Uncovered解消'));
    expect(generated.markdown, contains('Conflict確認'));
    expect(generated.markdown, contains('LowConfidence補強'));
    expect(generated.markdown, contains('Conflict <= 5 / LowConfidence <= 10'));
  });
}
