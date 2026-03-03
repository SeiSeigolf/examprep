import 'package:drift/drift.dart';
import 'exam_units.dart';
import 'source_segments.dart';

class Audits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceSegmentId =>
      integer().references(SourceSegments, #id, onDelete: KeyAction.cascade)();
  IntColumn get examUnitId =>
      integer().references(ExamUnits, #id, onDelete: KeyAction.cascade)();

  // Coverage Audit: Covered / Partial / Uncovered / Conflict / LowConfidence
  TextColumn get status => text().check(status.isIn(const [
        'Covered',
        'Partial',
        'Uncovered',
        'Conflict',
        'LowConfidence',
      ]))();

  // H / M / L
  TextColumn get contentConfidence => text()
      .withDefault(const Constant('M'))
      .check(contentConfidence.isIn(const ['H', 'M', 'L']))();

  // H / M / L
  TextColumn get examConfidence => text()
      .withDefault(const Constant('M'))
      .check(examConfidence.isIn(const ['H', 'M', 'L']))();

  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {sourceSegmentId, examUnitId},
      ];
}
