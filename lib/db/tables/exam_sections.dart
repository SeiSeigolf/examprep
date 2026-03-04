import 'package:drift/drift.dart';
import 'exams.dart';

class ExamSections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  TextColumn get name => text()();
  IntColumn get points => integer().withDefault(const Constant(0))();
  // '暗記' | '理解' | '計算'
  TextColumn get studyApproach => text()
      .withDefault(const Constant('暗記'))
      .check(studyApproach.isIn(const ['暗記', '理解', '計算']))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
