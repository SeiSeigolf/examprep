# ExamOS — CLAUDE.md

## プロジェクト概要

**ExamOS**: 医学部期末テスト最適化システム（ローカル完結・根拠付き）

過去問・講義資料・課題・ノートを統合し、Exam Unit単位で管理。
根拠付き・網羅監査付きで点数最大化する「試験OS」。

---

## 技術スタック

| 領域 | 技術 |
|------|------|
| UI | Flutter Desktop (macOS向け) |
| DB | SQLite（drift パッケージ） |
| PDF処理 | syncfusion_flutter_pdf または printing |
| LLM（将来） | Ollama API（ローカル） |

---

## 設計原則（必ず遵守）

1. **Evidence-first**: すべての情報に根拠（source_segment）を紐づける。根拠なし生成禁止。
2. **ローカル完結**: クラウドへのデータ送信禁止。著作権リスク低減。
3. **Exam Unit中心**: 資料単位ではなく出題・採点の最小単位で管理。
4. **信頼度表示**: High / Medium / Low で根拠の強さを明示。
5. **Conflict併記**: 矛盾する情報は統合せず、両方を並列表示する。

---

## DBスキーマ

```
sources            — 取り込んだファイル（PDF/画像）
source_segments    — ファイル内断片（ページ/スライド単位）
exam_units         — 学習の最小単位（定義・機序・鑑別・画像所見など）
claims             — AI or ユーザーが生成した説明文
evidence_links     — claim ↔ source_segment の紐づけ
```

---

## コーディング規約

- **言語**: Dart
- **状態管理**: Riverpod
- **ディレクトリ構造**: feature-first
  ```
  lib/
    features/
      ingestion/     # PDF取り込み・テキスト抽出
      exam_units/    # Exam Unit CRUD・詳細画面
      evidence/      # Evidence Link管理
      audit/         # Coverage Audit
    db/              # driftスキーマ・DAO
    shared/          # 共通ウィジェット・ユーティリティ
  ```
- **コメント**: 日本語OK
- **テスト**: 主要ロジック（DB操作・根拠リンク・監査ロジック）にはunit test必須

---

## Phase 1 MVP スコープ

- [ ] PDF取り込み・テキスト抽出
- [ ] Exam Unit の手動作成・編集
- [ ] Evidence Link（根拠紐づけ）
- [ ] Coverage Audit（Covered / Uncovered / Conflict）
- [ ] 信頼度ラベル（H / M / L）
- [ ] 学習ユニット詳細画面 + 根拠パネル

---

## 実装時の注意

- drift の`@DriftDatabase`は`lib/db/`に集約する
- Riverpodプロバイダーは`*.provider.dart`サフィックスで命名
- LLM連携コードは`OllamaService`に分離し、Phase 2まで実装不要
- UI文字列は日本語で問題ない（ローカル専用ツール）
- `evidence_links`なしに`claims`を作成・保存するコードを書いてはいけない
