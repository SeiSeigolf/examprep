import 'package:drift/drift.dart';
import 'exam_units.dart';

class UnitMergeHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId =>
      integer().references(ExamUnits, #id, onDelete: KeyAction.noAction)();
  IntColumn get childId => integer()();
  DateTimeColumn get mergedAt => dateTime().withDefault(currentDateAndTime)();
  // comma separated claim ids
  TextColumn get movedClaimIds => text()();

  // Child snapshot for undo (MVP)
  TextColumn get childTitle => text()();
  TextColumn get childUnitType => text().withDefault(const Constant('定義'))();
  TextColumn get childDescription => text().nullable()();
  TextColumn get childConfidenceLevel =>
      text().withDefault(const Constant('medium'))();
  TextColumn get childExamConfidence =>
      text().withDefault(const Constant('M'))();
  TextColumn get childAuditStatus =>
      text().withDefault(const Constant('Uncovered'))();
  IntColumn get childSortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get undoneAt => dateTime().nullable()();
}
