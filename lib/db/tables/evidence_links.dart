import 'package:drift/drift.dart';
import 'claims.dart';
import 'source_segments.dart';

class EvidenceLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get claimId => integer().references(Claims, #id)();
  IntColumn get sourceSegmentId =>
      integer().references(SourceSegments, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
