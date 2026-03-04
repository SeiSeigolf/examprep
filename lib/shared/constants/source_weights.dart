/// source_type ごとの重み（高いほど信頼性が高く優先度に影響する）
const Map<String, double> sourceTypeWeights = {
  'past_exam': 1.0,
  'professor_notes': 0.9,
  'notes': 0.8,
  'lecture': 0.7,
  'assignment': 0.6,
  'voice_memo': 0.5,
  'other': 0.3,
};

/// source_type → 日本語表示ラベル
const Map<String, String> sourceTypeLabels = {
  'past_exam': '過去問',
  'professor_notes': '教授メモ',
  'notes': 'ノート',
  'lecture': '講義資料',
  'assignment': '課題',
  'voice_memo': '音声メモ',
  'other': 'その他',
};

/// 選択肢リスト（ドロップダウン用）
const List<String> sourceTypeValues = [
  'past_exam',
  'professor_notes',
  'notes',
  'lecture',
  'assignment',
  'voice_memo',
  'other',
];
