import 'package:drift/drift.dart';

class StudyMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  // '定義' | '機序' | '鑑別' | '画像所見' | 'その他'
  TextColumn get unitType => text().check(unitType.isIn(const [
        '定義',
        '機序',
        '鑑別',
        '画像所見',
        'その他',
      ]))();
  // '選択肢' | '穴埋め' | '記述' | '画像問題'
  TextColumn get problemFormat =>
      text().check(problemFormat.isIn(const ['選択肢', '穴埋め', '記述', '画像問題', '計算']))();
  TextColumn get methodName => text()();
  TextColumn get description => text()();
  IntColumn get estimatedMinutes => integer()();
}
