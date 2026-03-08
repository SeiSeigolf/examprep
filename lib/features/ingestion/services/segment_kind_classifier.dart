/// セグメントのノイズ種別を判定するヘルパー。
///
/// 値: content | header | syllabus | assignment_meta | references | boilerplate
String classifySegmentKind(String text) {
  final t = text.trim();

  // 短すぎる → header 扱い
  if (t.length < 20) return 'header';

  // シラバス系
  if (_matchesAny(t, const [
    '達成目標', '到達目標', '評価方法', '成績評価', '授業計画', '講義計画', 'シラバス',
    '授業の概要', '授業目標', '学習目標', 'ディプロマポリシー', 'カリキュラムポリシー',
  ])) return 'syllabus';

  // 参考書・文献
  if (_matchesAny(t, const [
    '参考書', '教科書', '参考文献', '推薦図書', '参考資料', '引用文献', '文献一覧',
    'References', 'Bibliography',
  ])) return 'references';

  // 課題・提出・URL
  if (_matchesAny(t, const [
    '課題', '提出', '締切', '期限', '提出先', 'PDFにして', 'スキャン',
    'Adobe Scan', 'Google Drive', 'Dropbox', 'Moodle',
    'http://', 'https://', 'URL', 'メール', 'mail', '@',
  ])) return 'assignment_meta';

  // ボイラープレート
  if (_matchesAny(t, const [
    '注意事項', '連絡先', 'オフィスアワー', '問い合わせ', '氏名', '学籍番号',
    '遅刻', '欠席', '出席', '著作権', '禁じます', '無断転載',
  ])) return 'boilerplate';

  // 1行かつ短い（見出し的）
  if (!t.contains('\n') && t.length <= 30) return 'header';

  return 'content';
}

bool _matchesAny(String text, List<String> keywords) {
  for (final kw in keywords) {
    if (text.contains(kw)) return true;
  }
  return false;
}
