import 'package:drift/drift.dart';
import '../database.dart';

part 'study_methods_dao.g.dart';

@DriftAccessor(tables: [StudyMethods])
class StudyMethodsDao extends DatabaseAccessor<AppDatabase>
    with _$StudyMethodsDaoMixin {
  StudyMethodsDao(super.db);

  Stream<List<StudyMethod>> watchAll() =>
      (select(studyMethods)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

  Future<List<StudyMethod>> getAll() =>
      (select(studyMethods)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  /// unitType に一致する全 StudyMethod を ID 昇順で監視
  Stream<List<StudyMethod>> watchByUnitType(String unitType) =>
      (select(studyMethods)
            ..where((t) => t.unitType.equals(unitType))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();
}
