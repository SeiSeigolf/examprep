import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/sources.dart';
import 'tables/source_segments.dart';
import 'tables/exam_units.dart';
import 'tables/claims.dart';
import 'tables/evidence_links.dart';
import 'tables/audits.dart';
import 'tables/conflicts.dart';
import 'tables/study_methods.dart';
import 'tables/unit_stats.dart';
import 'tables/evidence_packs.dart';
import 'tables/evidence_pack_items.dart';
import 'tables/unit_merge_history.dart';
import 'daos/sources_dao.dart';
import 'daos/exam_units_dao.dart';
import 'daos/claims_dao.dart';
import 'daos/audit_dao.dart';
import 'daos/dashboard_dao.dart';
import 'daos/search_dao.dart';
import 'daos/study_methods_dao.dart';
import 'daos/evidence_packs_dao.dart';

export 'tables/sources.dart';
export 'tables/source_segments.dart';
export 'tables/exam_units.dart';
export 'tables/claims.dart';
export 'tables/evidence_links.dart';
export 'tables/audits.dart';
export 'tables/conflicts.dart';
export 'tables/study_methods.dart';
export 'tables/unit_stats.dart';
export 'tables/evidence_packs.dart';
export 'tables/evidence_pack_items.dart';
export 'tables/unit_merge_history.dart';
export 'daos/evidence_packs_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Sources,
    SourceSegments,
    ExamUnits,
    Claims,
    EvidenceLinks,
    Audits,
    Conflicts,
    StudyMethods,
    UnitStats,
    EvidencePacks,
    EvidencePackItems,
    UnitMergeHistory,
  ],
  daos: [
    SourcesDao,
    ExamUnitsDao,
    ClaimsDao,
    AuditDao,
    DashboardDao,
    SearchDao,
    StudyMethodsDao,
    EvidencePacksDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// テスト用コンストラクタ（in-memory DB）
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedStudyMethods();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(examUnits, examUnits.sortOrder);
        await customStatement('UPDATE exam_units SET sort_order = id');
      }
      if (from < 3) {
        await m.createTable(studyMethods);
      }
      if (from < 4) {
        // 旧シードを全削除して 25通りで入れ直す
        await customStatement('DELETE FROM study_methods');
        await _seedStudyMethods();
      }
      if (from < 5) {
        await m.addColumn(sourceSegments, sourceSegments.contentConfidence);
        await m.addColumn(examUnits, examUnits.examConfidence);
        await m.addColumn(claims, claims.contentConfidence);
        await m.createTable(audits);
        await m.createTable(conflicts);
        await m.createTable(unitStats);
      }
      if (from < 6) {
        await m.createTable(evidencePacks);
        await m.createTable(evidencePackItems);

        // Backfill: 1 claim = 1 evidence_pack
        await m.database.customStatement('''
    INSERT INTO evidence_packs (claim_id, created_at, updated_at, summary, content_confidence, exam_confidence)
    SELECT DISTINCT
      el.claim_id,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP,
      NULL,
      'M',
      'M'
    FROM evidence_links el
  ''');

        await m.database.customStatement('''
    INSERT OR IGNORE INTO evidence_pack_items
      (evidence_pack_id, source_segment_id, page_number, snippet, weight, created_at)
    SELECT
      ep.id,
      el.source_segment_id,
      NULL,
      NULL,
      1,
      CURRENT_TIMESTAMP
    FROM evidence_links el
    JOIN evidence_packs ep
      ON ep.claim_id = el.claim_id
  ''');
      }
      if (from < 7) {
        await m.addColumn(unitStats, unitStats.pointWeight);
        await m.addColumn(unitStats, unitStats.frequency);
      }
      if (from < 8) {
        await m.addColumn(sources, sources.sourceType);
        await m.addColumn(unitStats, unitStats.frequencyManualOverride);
        await m.database.customStatement('''
          UPDATE evidence_pack_items
          SET page_number = (
            SELECT ss.page_number
            FROM source_segments ss
            WHERE ss.id = evidence_pack_items.source_segment_id
          )
          WHERE page_number IS NULL
        ''');
        await m.database.customStatement('''
          UPDATE evidence_pack_items
          SET snippet = SUBSTR((
            SELECT ss.content
            FROM source_segments ss
            WHERE ss.id = evidence_pack_items.source_segment_id
          ), 1, 200)
          WHERE snippet IS NULL
        ''');
      }
      if (from < 9) {
        await m.createTable(unitMergeHistory);
      }
      if (from < 10) {
        await m.addColumn(examUnits, examUnits.problemFormat);
      }
    },
  );

  // ---- 5×5 = 25通りのシードデータ ----
  Future<void> _seedStudyMethods() async {
    final seeds = [
      // ---- 定義 ----
      StudyMethodsCompanion.insert(
        unitType: '定義',
        problemFormat: '選択肢',
        methodName: 'フラッシュカード暗記',
        description: '定義を表面、キーワードを裏面にしたカードで繰り返し暗記する',
        estimatedMinutes: 20,
      ),
      StudyMethodsCompanion.insert(
        unitType: '定義',
        problemFormat: '記述',
        methodName: '定義文の書き直し',
        description: '教科書を閉じ、定義を自分の言葉でノートに書き直して確認する',
        estimatedMinutes: 25,
      ),
      StudyMethodsCompanion.insert(
        unitType: '定義',
        problemFormat: '穴埋め',
        methodName: '穴埋めシート練習',
        description: '定義文のキーワードを隠して何度も書き込む穴埋めシートを作成する',
        estimatedMinutes: 20,
      ),
      StudyMethodsCompanion.insert(
        unitType: '定義',
        problemFormat: '画像問題',
        methodName: '概念図ラベリング',
        description: '概念図・模式図のラベルを隠して名称を書き込む練習をする',
        estimatedMinutes: 25,
      ),
      StudyMethodsCompanion.insert(
        unitType: '定義',
        problemFormat: '計算',
        methodName: '定義値の計算練習',
        description: '定義に含まれる数値・閾値を使った簡単な計算問題を解く',
        estimatedMinutes: 20,
      ),

      // ---- 機序 ----
      StudyMethodsCompanion.insert(
        unitType: '機序',
        problemFormat: '選択肢',
        methodName: 'ステップ並べ替え',
        description: '機序の各ステップをシャッフルして正しい順序に並べ替える練習をする',
        estimatedMinutes: 30,
      ),
      StudyMethodsCompanion.insert(
        unitType: '機序',
        problemFormat: '記述',
        methodName: 'フローチャート作成',
        description: '病態生理のステップをフローチャートで書き起こして理解を確認する',
        estimatedMinutes: 40,
      ),
      StudyMethodsCompanion.insert(
        unitType: '機序',
        problemFormat: '穴埋め',
        methodName: '穴埋め機序図',
        description: '機序図の中間ステップを隠した穴埋め問題を繰り返し解く',
        estimatedMinutes: 35,
      ),
      StudyMethodsCompanion.insert(
        unitType: '機序',
        problemFormat: '画像問題',
        methodName: '機序図読み取り',
        description: '機序の模式図を見て各矢印・段階の意味を口頭で説明する練習をする',
        estimatedMinutes: 30,
      ),
      StudyMethodsCompanion.insert(
        unitType: '機序',
        problemFormat: '計算',
        methodName: 'パラメータ計算練習',
        description: '機序に関連する生理学的パラメータ（例: 心拍出量、GFR）を計算式から導く',
        estimatedMinutes: 35,
      ),

      // ---- 鑑別 ----
      StudyMethodsCompanion.insert(
        unitType: '鑑別',
        problemFormat: '選択肢',
        methodName: '比較表作成',
        description: '鑑別疾患を縦軸、鑑別ポイントを横軸にした比較表を作成して違いを把握する',
        estimatedMinutes: 35,
      ),
      StudyMethodsCompanion.insert(
        unitType: '鑑別',
        problemFormat: '記述',
        methodName: '鑑別ポイント列挙',
        description: '各疾患の特徴的な症状・検査値を声に出しながら列挙して記憶に定着させる',
        estimatedMinutes: 45,
      ),
      StudyMethodsCompanion.insert(
        unitType: '鑑別',
        problemFormat: '穴埋め',
        methodName: '鑑別チェックリスト穴埋め',
        description: '各疾患の症状・所見をチェックリスト形式にして空欄を埋める練習をする',
        estimatedMinutes: 30,
      ),
      StudyMethodsCompanion.insert(
        unitType: '鑑別',
        problemFormat: '画像問題',
        methodName: '典型画像で鑑別訓練',
        description: '各疾患の典型的な画像を見て鑑別診断の根拠を述べる練習をする',
        estimatedMinutes: 35,
      ),
      StudyMethodsCompanion.insert(
        unitType: '鑑別',
        problemFormat: '計算',
        methodName: '検査値閾値の確認',
        description: '鑑別に使う検査値の基準値・カットオフ値を計算問題形式で確認する',
        estimatedMinutes: 25,
      ),

      // ---- 画像所見 ----
      StudyMethodsCompanion.insert(
        unitType: '画像所見',
        problemFormat: '選択肢',
        methodName: '画像×診断マッチング',
        description: '画像と診断名を対応させるマッチング問題で視覚的記憶を強化する',
        estimatedMinutes: 25,
      ),
      StudyMethodsCompanion.insert(
        unitType: '画像所見',
        problemFormat: '記述',
        methodName: '所見レポート作成',
        description: '画像を見て放射線科レポート形式で所見を文章にまとめる練習をする',
        estimatedMinutes: 40,
      ),
      StudyMethodsCompanion.insert(
        unitType: '画像所見',
        problemFormat: '穴埋め',
        methodName: '所見フォーム穴埋め',
        description: '典型的な所見レポートのキーワードを隠した穴埋め問題を解く',
        estimatedMinutes: 30,
      ),
      StudyMethodsCompanion.insert(
        unitType: '画像所見',
        problemFormat: '画像問題',
        methodName: '所見読み取り練習',
        description: '画像を見て所見を声に出して読み上げ、正解と照合する練習を繰り返す',
        estimatedMinutes: 30,
      ),
      StudyMethodsCompanion.insert(
        unitType: '画像所見',
        problemFormat: '計算',
        methodName: '計測値の読み取り',
        description: '画像上の臓器サイズ・狭窄率などの計測値を読み取る計算練習をする',
        estimatedMinutes: 25,
      ),

      // ---- その他 ----
      StudyMethodsCompanion.insert(
        unitType: 'その他',
        problemFormat: '選択肢',
        methodName: '反復演習',
        description: '過去問や類題を繰り返し解いてパターン認識を高める',
        estimatedMinutes: 20,
      ),
      StudyMethodsCompanion.insert(
        unitType: 'その他',
        problemFormat: '記述',
        methodName: '要点まとめ',
        description: '重要ポイントを自分の言葉でまとめ直して理解度を確認する',
        estimatedMinutes: 30,
      ),
      StudyMethodsCompanion.insert(
        unitType: 'その他',
        problemFormat: '穴埋め',
        methodName: '重要語句穴埋め',
        description: '重要語句をまとめたプリントの空欄を繰り返し埋める練習をする',
        estimatedMinutes: 20,
      ),
      StudyMethodsCompanion.insert(
        unitType: 'その他',
        problemFormat: '画像問題',
        methodName: '図表読み取り練習',
        description: '統計グラフ・解剖図・心電図などの図表を読み取り答える練習をする',
        estimatedMinutes: 25,
      ),
      StudyMethodsCompanion.insert(
        unitType: 'その他',
        problemFormat: '計算',
        methodName: '計算問題反復練習',
        description: '投薬量・腎機能・酸塩基平衡など頻出の計算問題を繰り返し解く',
        estimatedMinutes: 30,
      ),
    ];
    await batch((b) => b.insertAll(studyMethods, seeds));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'exam_os.db'));
    return NativeDatabase.createInBackground(file);
  });
}
