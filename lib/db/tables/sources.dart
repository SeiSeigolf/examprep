import 'package:drift/drift.dart';

class Sources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
}
