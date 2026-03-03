import 'package:drift/drift.dart';

class ExamUnits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  // '定義' | '機序' | '鑑別' | '画像所見' | 'その他'
  TextColumn get unitType => text().withDefault(const Constant('定義'))();
  TextColumn get description => text().nullable()();
  // 'high' | 'medium' | 'low'
  TextColumn get confidenceLevel =>
      text().withDefault(const Constant('medium'))();
  // 'covered' | 'uncovered' | 'conflict'
  TextColumn get auditStatus =>
      text().withDefault(const Constant('uncovered'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
