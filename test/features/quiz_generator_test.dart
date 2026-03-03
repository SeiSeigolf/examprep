import 'package:exam_os/db/database.dart';
import 'package:exam_os/features/exam_units/services/quiz_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('problemFormatごとにクイズ生成形式が切り替わる', () {
    final target = Claim(
      id: 1,
      examUnitId: 10,
      content: '心不全の機序は心拍出量の低下である。',
      contentConfidence: 'M',
      confidenceLevel: 'medium',
      createdBy: 'test',
      createdAt: DateTime(2026, 1, 1),
    );
    final others = [
      target,
      target.copyWith(id: 2, content: '肺水腫では呼吸困難が悪化する。'),
      target.copyWith(id: 3, content: 'BNP高値は心不全診断の補助となる。'),
    ];

    final mcq = generateQuizForUnit(
      problemFormat: '選択肢',
      targetClaim: target,
      allClaimsInUnit: others,
    );
    expect(mcq.problemFormat, '選択肢');
    expect(mcq.choices.length, 4);
    expect(mcq.correctChoiceIndex, isNotNull);

    final fill = generateQuizForUnit(
      problemFormat: '穴埋め',
      targetClaim: target,
      allClaimsInUnit: others,
    );
    expect(fill.problemFormat, '穴埋め');
    expect(fill.prompt.contains('____'), isTrue);
    expect(fill.answer, isNotNull);

    final desc = generateQuizForUnit(
      problemFormat: '記述',
      targetClaim: target,
      allClaimsInUnit: others,
    );
    expect(desc.problemFormat, '記述');
    expect(desc.rubric, isNotEmpty);
  });
}
