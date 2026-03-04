import 'package:drift/drift.dart';

class Sources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text().unique()();
  // lecture / past_exam / assignment / notes
  TextColumn get sourceType => text()
      .withDefault(const Constant('lecture'))
      .check(
        sourceType.isIn(const [
          'lecture',
          'past_exam',
          'assignment',
          'notes',
          'professor_notes',
          'voice_memo',
          'other',
        ]),
      )();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
}
