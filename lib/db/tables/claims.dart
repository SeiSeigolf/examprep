import 'package:drift/drift.dart';
import 'exam_units.dart';

class Claims extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examUnitId =>
      integer().references(ExamUnits, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  // ContentConfidence enum: H / M / L
  TextColumn get contentConfidence => text()
      .withDefault(const Constant('M'))
      .check(contentConfidence.isIn(const ['H', 'M', 'L']))();
  // 'high' | 'medium' | 'low'
  TextColumn get confidenceLevel =>
      text().withDefault(const Constant('medium'))();
  // 'user' | 'ai'
  TextColumn get createdBy => text().withDefault(const Constant('user'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
