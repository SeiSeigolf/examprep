import 'package:drift/drift.dart';
import 'exam_units.dart';
import 'claims.dart';

class ClaimReviewSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examUnitId =>
      integer().references(ExamUnits, #id, onDelete: KeyAction.cascade)();
  IntColumn get claimId =>
      integer().references(Claims, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get nextReviewAt => dateTime()();
  IntColumn get intervalHours => integer().withDefault(const Constant(24))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetition => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {claimId},
  ];
}
