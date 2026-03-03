import '../../../db/database.dart';

class GeneratedQuiz {
  const GeneratedQuiz({
    required this.problemFormat,
    required this.prompt,
    this.choices = const [],
    this.correctChoiceIndex,
    this.answer,
    this.rubric = const [],
  });

  final String problemFormat;
  final String prompt;
  final List<String> choices;
  final int? correctChoiceIndex;
  final String? answer;
  final List<String> rubric;
}

GeneratedQuiz generateQuizForUnit({
  required String problemFormat,
  required Claim targetClaim,
  required List<Claim> allClaimsInUnit,
}) {
  switch (problemFormat) {
    case '穴埋め':
      return _generateFillBlank(targetClaim.content);
    case '記述':
      return _generateDescriptive(targetClaim.content);
    case '選択肢':
    default:
      return _generateMultipleChoice(
        targetClaim.content,
        allClaimsInUnit.map((c) => c.content).toList(),
      );
  }
}

GeneratedQuiz _generateMultipleChoice(String target, List<String> allClaims) {
  final correct = _normalizeSentence(target);
  final choices = <String>[correct];

  for (final c in allClaims) {
    final candidate = _normalizeSentence(c);
    if (candidate == correct) continue;
    if (!choices.contains(candidate)) {
      choices.add(candidate);
    }
    if (choices.length >= 4) break;
  }

  var altIndex = 0;
  while (choices.length < 4) {
    final alt = _makeDistractor(correct, altIndex);
    altIndex++;
    if (!choices.contains(alt)) {
      choices.add(alt);
    }
  }

  return GeneratedQuiz(
    problemFormat: '選択肢',
    prompt: '次のうち正しい記述を1つ選んでください。',
    choices: choices.take(4).toList(),
    correctChoiceIndex: 0,
    answer: correct,
  );
}

GeneratedQuiz _generateFillBlank(String claim) {
  final normalized = _normalizeSentence(claim);
  final keyword = _pickKeyword(normalized) ?? normalized.split(' ').first;
  final blanked = normalized.replaceFirst(keyword, '____');
  return GeneratedQuiz(problemFormat: '穴埋め', prompt: blanked, answer: keyword);
}

GeneratedQuiz _generateDescriptive(String claim) {
  final normalized = _normalizeSentence(claim);
  final parts = normalized
      .split(RegExp(r'[、,。]'))
      .map((p) => p.trim())
      .where((p) => p.length >= 4)
      .toList();

  final rubric = <String>[];
  if (parts.isNotEmpty) {
    rubric.addAll(parts.take(3).map((p) => '$p に言及できている'));
  } else {
    final kws = _extractKeywords(normalized);
    rubric.addAll(kws.take(3).map((k) => '$k を説明できている'));
  }
  if (rubric.isEmpty) {
    rubric.add('主要な病態・定義を説明できている');
  }

  return GeneratedQuiz(
    problemFormat: '記述',
    prompt: '次を説明してください: $normalized',
    rubric: rubric,
  );
}

String _makeDistractor(String claim, int index) {
  final keyword = _pickKeyword(claim);
  if (keyword == null || keyword.isEmpty) {
    return '上記以外の一般的な病態説明が正しい';
  }
  const wrongTokens = ['低下', '増加', '抑制', '促進', '正常', '異常なし', '陰性'];
  final wrong = wrongTokens[index % wrongTokens.length];
  return claim.replaceFirst(keyword, wrong);
}

String _normalizeSentence(String s) {
  final t = s.replaceAll('\n', ' ').trim();
  if (t.length <= 160) return t;
  return '${t.substring(0, 160)}...';
}

String? _pickKeyword(String claim) {
  final kws = _extractKeywords(claim);
  if (kws.isEmpty) return null;
  kws.sort((a, b) => b.length.compareTo(a.length));
  return kws.first;
}

List<String> _extractKeywords(String text) {
  final matches = RegExp(r'[A-Za-z]{3,}|[一-龥ぁ-んァ-ンー]{2,}').allMatches(text);
  const stop = {'これ', 'それ', 'ため', 'こと', 'もの', 'ある', 'ない', 'する'};
  return matches
      .map((m) => m.group(0)!.trim())
      .where((w) => !stop.contains(w))
      .toSet()
      .toList();
}
