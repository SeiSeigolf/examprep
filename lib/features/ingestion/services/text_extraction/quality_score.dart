double computeQualityScore(String text) {
  if (text.trim().isEmpty) return 0;

  final total = text.runes.length;
  if (total == 0) return 0;

  var jp = 0;
  var badReplacement = 0;
  var control = 0;

  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    if (_isJapaneseRune(rune)) jp++;
    if (ch == '�' || ch == '□' || ch == '?') badReplacement++;
    if (_isControlRune(rune)) control++;
  }

  final jpRatio = jp / total;
  final badRatio = badReplacement / total;
  final controlRatio = control / total;
  final lengthScore = (text.trim().length / 400).clamp(0.0, 1.0);

  final score =
      (jpRatio * 0.45) +
      ((1 - badRatio) * 0.30) +
      ((1 - controlRatio) * 0.15) +
      (lengthScore * 0.10);
  return score.clamp(0.0, 1.0);
}

String qualityLabel(double score) {
  if (score >= 0.70) return 'Good';
  if (score >= 0.40) return 'OK';
  return 'Bad';
}

bool _isJapaneseRune(int rune) {
  final hiragana = rune >= 0x3040 && rune <= 0x309F;
  final katakana = rune >= 0x30A0 && rune <= 0x30FF;
  final kanji = rune >= 0x4E00 && rune <= 0x9FFF;
  return hiragana || katakana || kanji;
}

bool _isControlRune(int rune) {
  if (rune == 0x09 || rune == 0x0A || rune == 0x0D) return false;
  return rune < 0x20 || (rune >= 0x7F && rune <= 0x9F);
}
