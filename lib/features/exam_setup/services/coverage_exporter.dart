import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../../../db/database.dart';
import '../../../shared/constants/source_weights.dart';

class CoverageExporter {
  static Future<String> export(AppDatabase db, int examId) async {
    final md = await generateMarkdown(db, examId);

    String? savePath;
    try {
      final location = await getSaveLocation(
        suggestedName: 'coverage_export.md',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Markdown', extensions: ['md']),
        ],
      );
      savePath = location?.path;
    } catch (_) {}

    if (savePath == null) {
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      savePath = '${dir.path}/coverage_$ts.md';
    }

    await File(savePath).writeAsString(md);
    return savePath;
  }

  static Future<String> generateMarkdown(
    AppDatabase db,
    int examId, {
    DateTime? now,
  }) async {
    final nowAt = now ?? DateTime.now();

    // 試験情報
    final exams = await db.examsDao.getAll();
    final exam = exams.where((e) => e.id == examId).firstOrNull;
    if (exam == null) return '# エラー: 試験が見つかりません\n';

    // セクションカバレッジ
    final stats = await db.examsDao.getSectionCoverage(examId);

    // 全 ExamUnit（section別にフィルタするため取得）
    final allUnits = await db.examUnitsDao.getAllUnits();

    // 全 StudyMethod
    final methods = await db.studyMethodsDao.getAll();
    final methodsByKey = <String, StudyMethod>{};
    for (final m in methods) {
      methodsByKey.putIfAbsent('${m.unitType}::${m.problemFormat}', () => m);
    }

    // 各unitのEvidenceリンク情報（source_type重み計算用）
    final unitSourceWeights = await _loadUnitSourceWeights(db);

    return buildMarkdown(
      exam: exam,
      stats: stats,
      allUnits: allUnits,
      methodsByKey: methodsByKey,
      unitSourceWeights: unitSourceWeights,
      now: nowAt,
    );
  }

  static String buildMarkdown({
    required Exam exam,
    required List<SectionCoverageStat> stats,
    required List<ExamUnit> allUnits,
    required Map<String, StudyMethod> methodsByKey,
    required Map<int, double> unitSourceWeights,
    required DateTime now,
  }) {
    final b = StringBuffer();
    final examDateStr = exam.date != null
        ? exam.date!.toLocal().toString().substring(0, 10)
        : '未設定';

    b.writeln('# これだけ見れば合格 — ${exam.name}');
    b.writeln('generated_at: ${now.toIso8601String()}');
    b.writeln('試験日: $examDateStr | 総配点: ${exam.totalPoints}点');
    b.writeln();

    if (stats.isEmpty) {
      b.writeln('> セクションが登録されていません。試験設定画面からセクションを追加してください。');
      return b.toString();
    }

    // 試験全体のサマリー
    final totalUnits = allUnits.where((u) => u.sectionId != null).length;
    final assignedUnits = allUnits.where((u) => u.sectionId != null);
    final coveredAll = assignedUnits.where(
      (u) => u.auditStatus == 'Covered' || u.auditStatus == 'Partial',
    ).length;
    final coverPctAll = totalUnits == 0
        ? 0
        : (coveredAll / totalUnits * 100).round();
    b.writeln('**全体カバー率: $coverPctAll%** ($coveredAll/$totalUnits Unit)');
    b.writeln();
    b.writeln('---');
    b.writeln();

    // セクション別
    for (final stat in stats) {
      final section = stat.section;
      final sectionUnits = allUnits
          .where((u) => u.sectionId == section.id)
          .toList();

      final coverPct = stat.totalUnits == 0
          ? 0
          : (stat.coveredUnits / stat.totalUnits * 100).round();

      b.writeln(
        '## ${section.name}（学習法: ${section.studyApproach} | ${section.points}点）',
      );
      b.writeln(
        'カバー率: $coverPct% (${stat.coveredUnits}/${stat.totalUnits} Unit) '
        '| 低信頼度: ${stat.lowConfUnits}件',
      );
      b.writeln();

      // ---- 出題プール ----
      if (stat.pools.isNotEmpty) {
        b.writeln('### 出題プール');
        for (final pool in stat.pools) {
          if (pool.totalItems > 0) {
            final pct = section.points == 0
                ? 0.0
                : pool.guaranteedItems /
                      (pool.totalItems == 0 ? 1 : pool.totalItems) *
                      100;
            b.writeln(
              '- **${pool.description}**: '
              '全${pool.totalItems}個暗記で${pool.guaranteedItems}問保証'
              '（配点の ${pct.toStringAsFixed(0)}%）',
            );
          } else {
            b.writeln('- **${pool.description}**');
          }
        }
        b.writeln();
      }

      // ---- Unit を信頼度別に分類 ----
      final lowUnits = sectionUnits
          .where((u) => u.confidenceLevel == 'low')
          .toList();
      final medUnits = sectionUnits
          .where((u) => u.confidenceLevel == 'medium')
          .toList();
      final highUnits = sectionUnits
          .where((u) => u.confidenceLevel == 'high')
          .toList();

      // 信頼度でソート（ソース重みも考慮）
      _sortByPriority(lowUnits, unitSourceWeights);
      _sortByPriority(medUnits, unitSourceWeights);

      if (lowUnits.isNotEmpty) {
        b.writeln('### 優先学習 Unit（Low信頼度）');
        _writeUnitList(b, lowUnits, methodsByKey);
      }

      if (medUnits.isNotEmpty) {
        b.writeln('### 確認学習 Unit（Medium信頼度）');
        _writeUnitList(b, medUnits, methodsByKey);
      }

      if (highUnits.isNotEmpty) {
        b.writeln('### 完了 Unit（High信頼度）');
        for (final u in highUnits) {
          b.writeln('- [x] ${u.title}');
        }
        b.writeln();
      }

      b.writeln('---');
      b.writeln();
    }

    // セクション未割り当て Unit の概要
    final unassigned = allUnits.where((u) => u.sectionId == null).toList();
    if (unassigned.isNotEmpty) {
      b.writeln('## セクション未割り当て Unit（${unassigned.length}件）');
      b.writeln('> Exam Units 画面からセクションに割り当ててください。');
      b.writeln();
    }

    return b.toString();
  }

  static void _sortByPriority(
    List<ExamUnit> units,
    Map<int, double> weights,
  ) {
    units.sort((a, b) {
      final wa = weights[a.id] ?? 0.0;
      final wb = weights[b.id] ?? 0.0;
      if (wa != wb) return wb.compareTo(wa);
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  static void _writeUnitList(
    StringBuffer b,
    List<ExamUnit> units,
    Map<String, StudyMethod> methodsByKey,
  ) {
    for (var i = 0; i < units.length; i++) {
      final u = units[i];
      final method =
          methodsByKey['${u.unitType}::${u.problemFormat}'] ??
          methodsByKey['${u.unitType}::選択肢'];
      final methodStr = method != null
          ? '${method.methodName}（${method.estimatedMinutes}分）'
          : '学習方法未設定';
      b.writeln('${i + 1}. **${u.title}** — $methodStr');
    }
    b.writeln();
  }

  /// unit ごとに紐づくソースの重み合計を計算
  static Future<Map<int, double>> _loadUnitSourceWeights(
    AppDatabase db,
  ) async {
    final rows = await db
        .customSelect(
          '''
      SELECT
        c.exam_unit_id,
        s.source_type
      FROM claims c
      JOIN evidence_packs ep ON ep.claim_id = c.id
      JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id
      JOIN source_segments ss ON ss.id = epi.source_segment_id
      JOIN sources s ON s.id = ss.source_id
      UNION
      SELECT
        c.exam_unit_id,
        s.source_type
      FROM claims c
      JOIN evidence_links el ON el.claim_id = c.id
      JOIN source_segments ss ON ss.id = el.source_segment_id
      JOIN sources s ON s.id = ss.source_id
      ''',
          readsFrom: {
            db.claims,
            db.evidencePacks,
            db.evidencePackItems,
            db.evidenceLinks,
            db.sourceSegments,
            db.sources,
          },
        )
        .get();

    final map = <int, double>{};
    for (final row in rows) {
      final unitId = row.read<int>('exam_unit_id');
      final sourceType = row.read<String>('source_type');
      final weight = sourceTypeWeights[sourceType] ?? 0.5;
      map[unitId] = (map[unitId] ?? 0.0) + weight;
    }
    return map;
  }
}
