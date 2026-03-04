import 'package:drift/drift.dart';
import 'exam_sections.dart';
import 'sources.dart';

class ExamPools extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sectionId => integer().references(ExamSections, #id)();
  TextColumn get description => text()();
  IntColumn get totalItems => integer().withDefault(const Constant(0))();
  IntColumn get guaranteedItems => integer().withDefault(const Constant(0))();
  IntColumn get sourceId => integer().nullable().references(Sources, #id)();
}
