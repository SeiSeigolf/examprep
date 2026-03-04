import 'package:drift/drift.dart';

class Exams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime().nullable()();
  IntColumn get totalPoints => integer().withDefault(const Constant(100))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
