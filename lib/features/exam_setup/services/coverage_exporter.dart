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

    final exams = await db.examsDao.getAll();
    final exam = exams.where((e) => e.id == examId).firstOrNull;
    if (exam == null) return '# エラー: 試験が見つかりません\n';

    final stats = await db.examsDao.getSectionCoverage(examId);
    final allUnits = await db.examUnitsDao.getAllUnits();
    final methods = await db.studyMethodsDao.getAll();
    final methodsByKey = <String, StudyMethod>{};
    for (final m in methods) {
      methodsByKey.putIfAbsent('${m.unitType}::${m.problemFormat}', () => m);
    }

    final unitSourceWeights = await _loadUnitSourceWeights(db);
    final unitFrequencies = await _loadUnitFrequencies(db);
    final totalPastExamSegments = await _countTotalPastExamSegments(db);
    final unitClaims = await _loadUnitClaims(db);

    return buildMarkdown(
      exam: exam,
      stats: stats,
      allUnits: allUnits,
      methodsByKey: methodsByKey,
      unitSourceWeights: unitSourceWeights,
      unitFrequencies: unitFrequencies,
      totalPastExamSegments: totalPastExamSegments,
      unitClaims: unitClaims,
      now: nowAt,
    );
  }

  static String buildMarkdown({
    required Exam exam,
    required List<SectionCoverageStat> stats,
    required List<ExamUnit> allUnits,
    required Map<String, StudyMethod> methodsByKey,
    required Map<int, double> unitSourceWeights,
    required Map<int, int> unitFrequencies,
    required int totalPastExamSegments,
    required Map<int, List<_ClaimWithEvidence>> unitClaims,
    required DateTime now,
  }) {
    final b = StringBuffer();
    final examDateStr = exam.date != null
        ? exam.date!.toLocal().toString().substring(0, 10)
        : '未設定';

    b.writeln('# ${exam.name} 網羅資料');
    b.writeln('生成日: ${now.toLocal().toString().substring(0, 10)}');
    b.writeln('試験日: $examDateStr　合計: ${exam.totalPoints}点');
    b.writeln();

    if (stats.isEmpty) {
      b.writeln('> セクションが登録されていません。試験設定画面からセクションを追加してください。');
      return b.toString();
    }

    final totalUnits = allUnits.where((u) => u.sectionId != null).length;
    final assignedUnits = allUnits.where((u) => u.sectionId != null);
    final coveredAll = assignedUnits.where(
      (u) => u.auditStatus == 'Covered' || u.auditStatus == 'Partial',
    ).length;
    final coverPctAll =
        totalUnits == 0 ? 0 : (coveredAll / totalUnits * 100).round();
    b.writeln('**全体カバー率: $coverPctAll%** ($coveredAll/$totalUnits Unit)');
    b.writeln();
    b.writeln('---');
    b.writeln();

    for (final stat in stats) {
      final section = stat.section;
      final sectionUnits = allUnits
          .where((u) => u.sectionId == section.id)
          .toList();

      final coverPct = stat.totalUnits == 0
          ? 0
          : (stat.coveredUnits / stat.totalUnits * 100).round();

      final pointsStr = section.points > 0 ? '配点: ${section.points}点' : '';
      b.writeln(
        '## ■ ${section.name}${pointsStr.isEmpty ? '' : '（$pointsStr）'}',
      );
      b.writeln('勉強法: ${section.studyApproach}系');
      if (section.description != null && section.description!.isNotEmpty) {
        b.writeln('> ${section.description}');
      }
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
            b.writeln(
              '- **${pool.description}**: '
              '全${pool.totalItems}個暗記で${pool.guaranteedItems}問保証',
            );
          } else {
            b.writeln('- **${pool.description}**');
          }
          if (pool.note != null && pool.note!.isNotEmpty) {
            b.writeln('  > ${pool.note}');
          }
        }
        b.writeln();
      }

      // ---- Unit を信頼度別に分類・ソート ----
      final lowUnits = sectionUnits
          .where((u) => u.confidenceLevel == 'low')
          .toList();
      final medUnits = sectionUnits
          .where((u) => u.confidenceLevel == 'medium')
          .toList();
      final highUnits = sectionUnits
          .where((u) => u.confidenceLevel == 'high')
          .toList();

      _sortByPriority(lowUnits, unitSourceWeights, unitFrequencies);
      _sortByPriority(medUnits, unitSourceWeights, unitFrequencies);

      if (lowUnits.isNotEmpty) {
        b.writeln('### 学習ユニット（優先度順）');
        _writeUnitList(
          b,
          lowUnits,
          methodsByKey,
          unitFrequencies,
          totalPastExamSegments,
          unitClaims,
          '優先',
        );
      }

      if (medUnits.isNotEmpty) {
        b.writeln('### 確認学習 Unit（Medium信頼度）');
        _writeUnitList(
          b,
          medUnits,
          methodsByKey,
          unitFrequencies,
          totalPastExamSegments,
          unitClaims,
          '確認',
        );
      }

      if (highUnits.isNotEmpty) {
        b.writeln('### 完了 Unit（High信頼度）');
        for (final u in highUnits) {
          b.writeln('- [x] ${u.title}');
        }
        b.writeln();
      }

      b.writeln(
        '### セクションカバー率: $coverPct%'
        '（${stat.coveredUnits}/${stat.totalUnits}ユニットカバー済み）',
      );
      b.writeln();
      b.writeln('---');
      b.writeln();
    }

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
    Map<int, int> frequencies,
  ) {
    units.sort((a, b) {
      final fa = frequencies[a.id] ?? 0;
      final fb = frequencies[b.id] ?? 0;
      if (fa != fb) return fb.compareTo(fa); // 出題頻度が高い順
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
    Map<int, int> frequencies,
    int totalPastExamSegments,
    Map<int, List<_ClaimWithEvidence>> unitClaims,
    String priorityLabel,
  ) {
    for (var i = 0; i < units.length; i++) {
      final u = units[i];
      final freq = frequencies[u.id] ?? 0;
      final freqStr = freq > 0
          ? '出題率: ${totalPastExamSegments > 0 ? (freq / totalPastExamSegments * 100).round() : 0}%（過去問$freq回出題）'
          : '出題履歴なし';
      final confLabel = switch (u.confidenceLevel) {
        'high' => 'High',
        'low' => 'Low',
        _ => 'Medium',
      };

      b.writeln(
        '${i + 1}. **${u.title}** — 信頼度: $confLabel — $freqStr',
      );

      // Claims + 根拠
      final claims = unitClaims[u.id] ?? [];
      if (claims.isNotEmpty) {
        b.writeln('   Claims:');
        for (final c in claims) {
          final content = c.content.length > 100
              ? '${c.content.substring(0, 100)}…'
              : c.content;
          b.write('   - $content');
          if (c.sourceName != null) {
            final pageStr =
                c.pageNumber != null ? ' p.${c.pageNumber}' : '';
            b.write('（根拠: ${c.sourceName}$pageStr）');
          }
          b.writeln();
        }
      }

      // 推奨勉強法
      final method =
          methodsByKey['${u.unitType}::${u.problemFormat}'] ??
          methodsByKey['${u.unitType}::選択肢'];
      if (method != null) {
        b.writeln(
          '   推奨勉強法: ${method.methodName}（${method.estimatedMinutes}分）',
        );
      }
      b.writeln();
    }
  }

  // ---- データ取得ヘルパー ----

  static Future<Map<int, double>> _loadUnitSourceWeights(
    AppDatabase db,
  ) async {
    final rows = await db
        .customSelect(
          '''
      SELECT c.exam_unit_id, s.source_type
      FROM claims c
      JOIN evidence_packs ep ON ep.claim_id = c.id
      JOIN evidence_pack_items epi ON epi.evidence_pack_id = ep.id
      JOIN source_segments ss ON ss.id = epi.source_segment_id
      JOIN sources s ON s.id = ss.source_id
      UNION
      SELECT c.exam_unit_id, s.source_type
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

  /// unit_stats テーブルから各ユニットの出題頻度を取得
  static Future<Map<int, int>> _loadUnitFrequencies(AppDatabase db) async {
    final rows = await db
        .customSelect(
          'SELECT exam_unit_id, frequency FROM unit_stats',
          readsFrom: {db.unitStats},
        )
        .get();
    return {
      for (final r in rows)
        r.read<int>('exam_unit_id'): r.read<int>('frequency'),
    };
  }

  /// 過去問ソースのセグメント総数を取得（出題率の分母）
  static Future<int> _countTotalPastExamSegments(AppDatabase db) async {
    final rows = await db
        .customSelect(
          '''
      SELECT COUNT(*) AS cnt
      FROM source_segments ss
      JOIN sources s ON s.id = ss.source_id
      WHERE s.source_type = 'past_exam'
      ''',
          readsFrom: {db.sourceSegments, db.sources},
        )
        .get();
    if (rows.isEmpty) return 0;
    return rows.first.read<int>('cnt');
  }

  /// 各ユニットの Claims と代表根拠ソース情報を取得
  static Future<Map<int, List<_ClaimWithEvidence>>> _loadUnitClaims(
    AppDatabase db,
  ) async {
    final rows = await db
        .customSelect(
          '''
      SELECT
        c.exam_unit_id,
        c.content,
        s.file_name AS source_name,
        ss.page_number
      FROM claims c
      LEFT JOIN evidence_links el ON el.claim_id = c.id
      LEFT JOIN source_segments ss ON ss.id = el.source_segment_id
      LEFT JOIN sources s ON s.id = ss.source_id
      GROUP BY c.id
      ORDER BY c.exam_unit_id, c.id
      ''',
          readsFrom: {
            db.claims,
            db.evidenceLinks,
            db.sourceSegments,
            db.sources,
          },
        )
        .get();

    final map = <int, List<_ClaimWithEvidence>>{};
    for (final r in rows) {
      final unitId = r.read<int>('exam_unit_id');
      final content = r.read<String>('content');
      final sourceName = r.readNullable<String>('source_name');
      final pageNumber = r.readNullable<int>('page_number');
      map.putIfAbsent(unitId, () => []).add(
        _ClaimWithEvidence(
          content: content,
          sourceName: sourceName,
          pageNumber: pageNumber,
        ),
      );
    }
    return map;
  }
}

class _ClaimWithEvidence {
  const _ClaimWithEvidence({
    required this.content,
    this.sourceName,
    this.pageNumber,
  });
  final String content;
  final String? sourceName;
  final int? pageNumber;
}
