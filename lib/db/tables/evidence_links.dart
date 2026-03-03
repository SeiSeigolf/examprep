import 'package:drift/drift.dart';
import 'claims.dart';
import 'source_segments.dart';

class EvidenceLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get claimId =>
      integer().references(Claims, #id, onDelete: KeyAction.cascade)();
  IntColumn get sourceSegmentId =>
      integer().references(SourceSegments, #id, onDelete: KeyAction.cascade)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {claimId, sourceSegmentId},
      ];
}
