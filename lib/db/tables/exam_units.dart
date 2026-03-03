import 'package:drift/drift.dart';

class ExamUnits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  // '定義' | '機序' | '鑑別' | '画像所見' | 'その他'
  TextColumn get unitType => text().withDefault(const Constant('定義'))();
  TextColumn get description => text().nullable()();
  // Legacy: 'high' | 'medium' | 'low'
  TextColumn get confidenceLevel =>
      text().withDefault(const Constant('medium'))();
  // ExamConfidence enum: H / M / L
  TextColumn get examConfidence => text()
      .withDefault(const Constant('M'))
      .check(examConfidence.isIn(const ['H', 'M', 'L']))();
  // Coverage Audit status:
  // Covered / Partial / Uncovered / Conflict / LowConfidence
  TextColumn get auditStatus => text()
      .withDefault(const Constant('Uncovered'))
      .check(auditStatus.isIn(const [
        'Covered',
        'Partial',
        'Uncovered',
        'Conflict',
        'LowConfidence',
      ]))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
