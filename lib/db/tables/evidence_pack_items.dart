import 'package:drift/drift.dart';
import 'evidence_packs.dart';
import 'source_segments.dart';

class EvidencePackItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get evidencePackId =>
      integer().references(EvidencePacks, #id, onDelete: KeyAction.cascade)();
  IntColumn get sourceSegmentId =>
      integer().references(SourceSegments, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageNumber => integer().nullable()();
  TextColumn get snippet => text().nullable()();
  IntColumn get weight => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {evidencePackId, sourceSegmentId},
      ];
}
