import 'package:drift/drift.dart';
import 'claims.dart';

class EvidencePacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get claimId =>
      integer().references(Claims, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get summary => text().nullable()();
  TextColumn get contentConfidence => text()
      .withDefault(const Constant('M'))
      .check(contentConfidence.isIn(const ['H', 'M', 'L']))();
  TextColumn get examConfidence => text()
      .withDefault(const Constant('M'))
      .check(examConfidence.isIn(const ['H', 'M', 'L']))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {claimId},
      ];
}
