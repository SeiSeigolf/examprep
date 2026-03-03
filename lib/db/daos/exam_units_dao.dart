import 'package:drift/drift.dart';
import '../database.dart';

part 'exam_units_dao.g.dart';

@DriftAccessor(tables: [ExamUnits])
class ExamUnitsDao extends DatabaseAccessor<AppDatabase>
    with _$ExamUnitsDaoMixin {
  ExamUnitsDao(super.db);

  /// 全 Exam Unit を並び順で一括取得（エクスポート用）
  Future<List<ExamUnit>> getAllUnits() =>
      (select(examUnits)
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();

  /// 全 Exam Unit を並び順（sortOrder ASC, id ASC）で監視
  Stream<List<ExamUnit>> watchAll() =>
      (select(examUnits)
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .watch();

  Future<int> insertUnit(ExamUnitsCompanion entry) =>
      into(examUnits).insert(entry);

  Future<bool> updateUnit(ExamUnitsCompanion entry) =>
      update(examUnits).replace(entry);

  /// 信頼度のみ更新（Study Plan の信頼度アップグレード用）
  Future<void> updateConfidenceLevel(int id, String confidenceLevel) =>
      (update(examUnits)..where((t) => t.id.equals(id))).write(
        ExamUnitsCompanion(
          confidenceLevel: Value(confidenceLevel),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> deleteUnit(int id) =>
      (delete(examUnits)..where((t) => t.id.equals(id))).go();

  /// 現在の最大 sortOrder を返す（存在しなければ 0）
  Future<int> getMaxSortOrder() async {
    final result = await customSelect(
      'SELECT COALESCE(MAX(sort_order), 0) AS max_order FROM exam_units',
      readsFrom: {examUnits},
    ).getSingle();
    return result.read<int>('max_order');
  }

  /// 複数行の sortOrder を一括更新（ドラッグ&ドロップ並び替え用）
  Future<void> updateSortOrders(List<(int id, int order)> updates) =>
      batch((b) {
        for (final (id, order) in updates) {
          b.update(
            examUnits,
            ExamUnitsCompanion(sortOrder: Value(order)),
            where: (t) => t.id.equals(id),
          );
        }
      });
}
