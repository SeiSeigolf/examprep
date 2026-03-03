# ExamOS

医学部の期末試験対策を、**根拠付き・監査可能・ローカル完結**で進めるデスクトップ学習支援アプリです。  
PDF資料（講義資料・過去問・ノート）を取り込み、資料単位ではなく **Exam Unit** 単位で整理します。

## このプロジェクトの3つの軸
### 1. Exam Unit（学習の最小単位）
- 「定義 / 機序 / 鑑別 / 画像所見」など、試験で問われる単位で知識を管理
- Claim（主張）と根拠を紐づけて、後から検証できる状態を維持

### 2. Coverage Audit（網羅監査）
- 取り込んだ各ページ（セグメント）が学習データに反映されているかを可視化
- ステータス: `covered` / `uncovered` / `conflict`

### 3. Evidence-first（根拠優先）
- Claim作成時にEvidence（出典セグメント）を必須化
- 根拠ページへジャンプ可能
- 根拠不足の内容は「未確定」として扱う前提

## MVPスコープ（いま実装している範囲）
- PDFソース取り込み（複数選択）
- ページ単位テキスト抽出とローカルDB保存
- Exam Unit の作成/編集/削除/並び替え
- Claim作成（Evidence 1件以上必須）
- Evidence一覧表示と元PDFページ表示
- Coverage Audit 一覧とフィルタ（covered/uncovered/conflict）
- 学習プラン画面（信頼度ベース優先表示、目標時間設定）
- Exam UnitデータのMarkdownエクスポート

## MVPの非スコープ（まだやらない）
- 自動での高精度Exam Unit抽出
- クラウド同期、共同編集
- 生成AIによる自由作文

## ローカル完結と著作権リスク低減
- データはローカルSQLiteに保存し、外部送信を前提にしない設計です。
- 著作物PDFは原文の再配布を目的にせず、学習用メタデータ（Unit/Claim/Evidenceリンク）中心で扱ってください。
- 共有・公開時は、原資料そのものではなく要約情報と参照情報の扱いを推奨します。

## Tech Stack
- Flutter (Desktop)
- Drift + SQLite
- Riverpod
- Syncfusion PDF / PDF Viewer

## Setup
```bash
flutter pub get
flutter run -d macos
```

## Test
```bash
flutter test
```
