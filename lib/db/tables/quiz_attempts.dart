import 'package:drift/drift.dart';
import 'exam_units.dart';
import 'claims.dart';

class QuizAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examUnitId =>
      integer().references(ExamUnits, #id, onDelete: KeyAction.cascade)();
  IntColumn get claimId =>
      integer().references(Claims, #id, onDelete: KeyAction.cascade)();
  TextColumn get format =>
      text().check(format.isIn(const ['選択肢', '穴埋め', '記述', '画像問題', '計算']))();
  BoolColumn get isCorrect => boolean()();
  IntColumn get secondsSpent => integer().withDefault(const Constant(0))();
  DateTimeColumn get attemptedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
