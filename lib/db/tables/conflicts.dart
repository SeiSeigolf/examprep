import 'package:drift/drift.dart';
import 'audits.dart';
import 'claims.dart';
import 'exam_units.dart';
import 'source_segments.dart';

class Conflicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceSegmentId =>
      integer().references(SourceSegments, #id, onDelete: KeyAction.cascade)();
  IntColumn get examUnitId =>
      integer().references(ExamUnits, #id, onDelete: KeyAction.cascade)();
  IntColumn get claimId =>
      integer().nullable().references(Claims, #id, onDelete: KeyAction.cascade)();
  IntColumn get auditId =>
      integer().nullable().references(Audits, #id, onDelete: KeyAction.cascade)();

  // open / resolved / dismissed
  TextColumn get status => text()
      .withDefault(const Constant('open'))
      .check(status.isIn(const ['open', 'resolved', 'dismissed']))();
  TextColumn get reason => text().nullable()();
  TextColumn get resolutionNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}
