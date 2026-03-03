import 'package:drift/drift.dart';
import 'sources.dart';

class SourceSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId =>
      integer().references(Sources, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageNumber => integer()();
  // 抽出テキスト（Phase 1 では空でも可）
  TextColumn get content => text().withDefault(const Constant(''))();
  // 'page' | 'slide'
  TextColumn get segmentType => text().withDefault(const Constant('page'))();
  // H / M / L
  TextColumn get contentConfidence => text()
      .withDefault(const Constant('M'))
      .check(contentConfidence.isIn(const ['H', 'M', 'L']))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
