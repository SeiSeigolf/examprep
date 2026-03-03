import 'package:drift/drift.dart';
import 'exam_units.dart';

class UnitStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examUnitId =>
      integer().references(ExamUnits, #id, onDelete: KeyAction.cascade)();

  IntColumn get sourceCount => integer().withDefault(const Constant(0))();
  IntColumn get segmentCount => integer().withDefault(const Constant(0))();
  IntColumn get claimCount => integer().withDefault(const Constant(0))();
  IntColumn get evidenceCount => integer().withDefault(const Constant(0))();
  IntColumn get conflictCount => integer().withDefault(const Constant(0))();
  IntColumn get pointWeight => integer().withDefault(const Constant(1))();
  IntColumn get frequency => integer().withDefault(const Constant(1))();

  DateTimeColumn get lastAuditedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {examUnitId},
  ];
}
