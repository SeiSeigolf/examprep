import 'package:drift/drift.dart';
import 'exam_units.dart';

class Claims extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examUnitId => integer().references(ExamUnits, #id)();
  TextColumn get content => text()();
  // 'high' | 'medium' | 'low'
  TextColumn get confidenceLevel =>
      text().withDefault(const Constant('medium'))();
  // 'user' | 'ai'
  TextColumn get createdBy => text().withDefault(const Constant('user'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
