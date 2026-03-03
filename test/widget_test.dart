// ExamOS スモークテスト
import 'package:drift/native.dart';
import 'package:exam_os/app.dart';
import 'package:exam_os/db/database.dart';
import 'package:exam_os/db/database.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('アプリが起動できる', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const ExamOsApp(),
      ),
    );
    await tester.pump();
    expect(find.text('ExamOS'), findsOneWidget);

    // drift の zero-duration タイマーをドレインしてからアンマウント
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
