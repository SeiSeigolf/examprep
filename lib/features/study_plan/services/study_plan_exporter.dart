import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../../../db/database.dart';
import '../providers/study_plan.provider.dart';

class StudyPlanExportEntry {
  const StudyPlanExportEntry({
    required this.unit,
    required this.methodName,
    required this.evidenceLinkCount,
    required this.nextReviewAt,
  });

  final ExamUnit unit;
  final String methodName;
  final int evidenceLinkCount;
  final DateTime? nextReviewAt;
}

class StudyPlanExporter {
  static Future<String> export(
    AppDatabase db, {
    required int topN,
    required CramMode mode,
    required DateTime? examDate,
  }) async {
    final md = await generateMarkdown(
      db,
      topN: topN,
      mode: mode,
      examDate: examDate,
    );

    String? savePath;
    try {
      final location = await getSaveLocation(
        suggestedName: 'study_plan_export.md',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Markdown', extensions: ['md']),
        ],
      );
      savePath = location?.path;
    } catch (_) {}

    if (savePath == null) {
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      savePath = '${dir.path}/study_plan_$ts.md';
    }

    await File(savePath).writeAsString(md);
    return savePath;
  }

  static Future<String> generateMarkdown(
    AppDatabase db, {
    required int topN,
    required CramMode mode,
    required DateTime? examDate,
    DateTime? now,
  }) async {
    final nowAt = now ?? DateTime.now();
    final units = await db.examUnitsDao.getAllUnits();
    final methods = await db.studyMethodsDao.getAll();
    final masteryByUnit = await db.quizAttemptsDao
        .watchUnitMasteryStats()
        .first;
    final dueByUnit = await db.quizAttemptsDao.watchUnitDueStats().first;
    final wfByUnit = await _loadWeightFrequency(db);

    final methodsByKey = <String, StudyMethod>{};
    for (final m in methods) {
      methodsByKey.putIfAbsent('${m.unitType}::${m.problemFormat}', () => m);
    }

    final sorted = [...units];
    sorted.sort((a, b) {
      final sa = computeStudyPriority(
        StudyPriorityInput(
          now: nowAt,
          mode: mode,
          examDate: examDate,
          confidenceLevel: a.confidenceLevel,
          mastery: masteryByUnit[a.id],
          due: dueByUnit[a.id],
          weightFreq: wfByUnit[a.id],
        ),
      );
      final sb = computeStudyPriority(
        StudyPriorityInput(
          now: nowAt,
          mode: mode,
          examDate: examDate,
          confidenceLevel: b.confidenceLevel,
          mastery: masteryByUnit[b.id],
          due: dueByUnit[b.id],
          weightFreq: wfByUnit[b.id],
        ),
      );
      if (sa != sb) return sb.compareTo(sa);
      return a.createdAt.compareTo(b.createdAt);
    });

    final entries = <StudyPlanExportEntry>[];
    for (final u in sorted.take(topN)) {
      final method =
          methodsByKey['${u.unitType}::${u.problemFormat}'] ??
          methodsByKey['${u.unitType}::選択肢'];
      final evidenceCount = await _countEvidenceLinks(db, u.id);
      entries.add(
        StudyPlanExportEntry(
          unit: u,
          methodName: method?.methodName ?? '学習（方法未設定）',
          evidenceLinkCount: evidenceCount,
          nextReviewAt: dueByUnit[u.id]?.nextReviewAt,
        ),
      );
    }
    return buildMarkdown(
      entries,
      topN: topN,
      mode: mode,
      examDate: examDate,
      now: nowAt,
    );
  }

  static String buildMarkdown(
    List<StudyPlanExportEntry> entries, {
    required int topN,
    required CramMode mode,
    required DateTime? examDate,
    required DateTime now,
  }) {
    final b = StringBuffer();
    b.writeln('# Study Plan Export');
    b.writeln('generated_at: ${now.toIso8601String()}');
    b.writeln('mode: ${mode.name}');
    b.writeln('exam_date: ${examDate?.toIso8601String() ?? '-'}');
    b.writeln('top_n: $topN');
    b.writeln();
    b.writeln('## 今日やること');
    b.writeln();
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      b.writeln('${i + 1}. ${e.unit.title}');
      b.writeln('   - やること: ${e.methodName} (${e.unit.problemFormat})');
      b.writeln('   - 根拠リンク数: ${e.evidenceLinkCount}');
      b.writeln('   - 次回復習日時: ${_formatDate(e.nextReviewAt)}');
    }
    return b.toString();
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final l = dt.toLocal();
    final y = l.year.toString().padLeft(4, '0');
    final m = l.month.toString().padLeft(2, '0');
    final d = l.day.toString().padLeft(2, '0');
    final hh = l.hour.toString().padLeft(2, '0');
    final mm = l.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  static Future<Map<int, UnitWeightFreqStat>> _loadWeightFrequency(
    AppDatabase db,
  ) async {
    final rows = await db
        .customSelect(
          '''
      SELECT exam_unit_id, point_weight, frequency
      FROM unit_stats
      ''',
          readsFrom: {db.unitStats},
        )
        .get();
    final map = <int, UnitWeightFreqStat>{};
    for (final row in rows) {
      map[row.read<int>('exam_unit_id')] = UnitWeightFreqStat(
        pointWeight: row.read<int>('point_weight'),
        frequency: row.read<int>('frequency'),
      );
    }
    return map;
  }

  static Future<int> _countEvidenceLinks(AppDatabase db, int examUnitId) async {
    final row = await db
        .customSelect(
          '''
      SELECT
        COALESCE((
          SELECT COUNT(*)
          FROM evidence_links el
          JOIN claims c ON c.id = el.claim_id
          WHERE c.exam_unit_id = ?
        ), 0) +
        COALESCE((
          SELECT COUNT(*)
          FROM evidence_pack_items epi
          JOIN evidence_packs ep ON ep.id = epi.evidence_pack_id
          JOIN claims c ON c.id = ep.claim_id
          WHERE c.exam_unit_id = ?
        ), 0) AS evidence_count
      ''',
          variables: [
            Variable.withInt(examUnitId),
            Variable.withInt(examUnitId),
          ],
          readsFrom: {
            db.evidenceLinks,
            db.evidencePackItems,
            db.evidencePacks,
            db.claims,
          },
        )
        .getSingle();
    return row.read<int>('evidence_count');
  }
}
