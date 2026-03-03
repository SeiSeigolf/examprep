import 'package:drift/drift.dart';
import '../database.dart';

part 'sources_dao.g.dart';

class SegmentUnitDraft {
  const SegmentUnitDraft({
    required this.sourceId,
    required this.segmentId,
    required this.pageNumber,
    required this.title,
    required this.claimContent,
    required this.unitType,
    required this.problemFormat,
  });

  final int sourceId;
  final int segmentId;
  final int pageNumber;
  final String title;
  final String claimContent;
  final String unitType;
  final String problemFormat;

  SegmentUnitDraft copyWith({
    String? title,
    String? claimContent,
    String? unitType,
    String? problemFormat,
  }) {
    return SegmentUnitDraft(
      sourceId: sourceId,
      segmentId: segmentId,
      pageNumber: pageNumber,
      title: title ?? this.title,
      claimContent: claimContent ?? this.claimContent,
      unitType: unitType ?? this.unitType,
      problemFormat: problemFormat ?? this.problemFormat,
    );
  }
}

@DriftAccessor(
  tables: [
    Sources,
    SourceSegments,
    ExamUnits,
    Claims,
    EvidenceLinks,
    EvidencePacks,
    EvidencePackItems,
  ],
)
class SourcesDao extends DatabaseAccessor<AppDatabase> with _$SourcesDaoMixin {
  SourcesDao(super.db);

  /// 全ソース取得（最新順）
  Stream<List<Source>> watchAllSources() => (select(
    sources,
  )..orderBy([(t) => OrderingTerm.desc(t.importedAt)])).watch();

  /// ソース追加
  Future<int> insertSource(SourcesCompanion entry) =>
      into(sources).insert(entry);

  /// ソース削除
  Future<int> deleteSource(int id) async {
    final count = await (delete(sources)..where((t) => t.id.equals(id))).go();
    await recalculatePastExamFrequency();
    return count;
  }

  /// ソースに対してページ分のセグメントを一括挿入
  Future<void> insertSegments(List<SourceSegmentsCompanion> entries) =>
      batch((b) => b.insertAll(sourceSegments, entries));

  /// 指定ソースのセグメント一覧をページ順で監視
  Stream<List<SourceSegment>> watchSegmentsForSource(int sourceId) =>
      (select(sourceSegments)
            ..where((s) => s.sourceId.equals(sourceId))
            ..orderBy([(s) => OrderingTerm.asc(s.pageNumber)]))
          .watch();

  /// ページ数を更新（テキスト抽出後に呼ぶ）
  Future<void> updatePageCount(int sourceId, int pageCount) =>
      (update(sources)..where((s) => s.id.equals(sourceId))).write(
        SourcesCompanion(pageCount: Value(pageCount)),
      );

  /// past_exam に紐づく証拠量から unit_stats.frequency を再計算する。
  /// 手動上書き済み（frequencyManualOverride=true）の unit は更新しない。
  Future<void> recalculatePastExamFrequency() async {
    await customStatement('''
      INSERT OR IGNORE INTO unit_stats (exam_unit_id, frequency, frequency_manual_override, updated_at)
      SELECT eu.id, 1, 0, CAST(strftime('%s','now') AS INTEGER)
      FROM exam_units eu
    ''');

    await customStatement('''
      UPDATE unit_stats
      SET
        frequency = MAX(1, COALESCE((
          SELECT COUNT(DISTINCT linked.segment_id)
          FROM (
            SELECT c.exam_unit_id AS unit_id, ss.id AS segment_id
            FROM claims c
            JOIN evidence_links el
              ON el.claim_id = c.id
            JOIN source_segments ss
              ON ss.id = el.source_segment_id
            JOIN sources s
              ON s.id = ss.source_id
            WHERE s.source_type = 'past_exam'

            UNION

            SELECT c.exam_unit_id AS unit_id, ss.id AS segment_id
            FROM claims c
            JOIN evidence_packs ep
              ON ep.claim_id = c.id
            JOIN evidence_pack_items epi
              ON epi.evidence_pack_id = ep.id
            JOIN source_segments ss
              ON ss.id = epi.source_segment_id
            JOIN sources s
              ON s.id = ss.source_id
            WHERE s.source_type = 'past_exam'
          ) linked
          WHERE linked.unit_id = unit_stats.exam_unit_id
        ), 1)),
        updated_at = CAST(strftime('%s','now') AS INTEGER)
      WHERE unit_stats.frequency_manual_override = 0
    ''');
  }

  Future<List<SegmentUnitDraft>> suggestExamUnitDraftsFromSource(
    int sourceId, {
    int limit = 40,
  }) async {
    final segments =
        await (select(sourceSegments)
              ..where((s) => s.sourceId.equals(sourceId))
              ..orderBy([(s) => OrderingTerm.asc(s.pageNumber)]))
            .get();

    final drafts = <SegmentUnitDraft>[];
    final seenTitles = <String>{}; // normalized title
    for (final seg in segments) {
      final text = seg.content.trim();
      if (text.length < 8) continue;

      final headingLines = _extractHeadingLikeLines(text);
      if (headingLines.isNotEmpty) {
        for (final heading in headingLines.take(5)) {
          final title = _extractCandidateTitle(heading);
          if (title.length < 2) continue;
          final norm = _normalizeTitle(title);
          if (seenTitles.contains(norm)) continue;
          seenTitles.add(norm);

          drafts.add(
            SegmentUnitDraft(
              sourceId: sourceId,
              segmentId: seg.id,
              pageNumber: seg.pageNumber,
              title: title,
              claimContent: _claimAroundHeading(text, heading),
              unitType: _inferUnitType('$title $text'),
              problemFormat: _inferProblemFormat('$title $text'),
            ),
          );
          if (drafts.length >= limit) return drafts;
        }
      } else {
        final chunks = text
            .split(RegExp(r'\n{2,}|(?<=[。.!?])\s+'))
            .map((e) => e.trim())
            .where((e) => e.length >= 8)
            .take(3);
        for (final chunk in chunks) {
          final title = _extractCandidateTitle(chunk);
          if (title.length < 2) continue;
          final norm = _normalizeTitle(title);
          if (seenTitles.contains(norm)) continue;
          seenTitles.add(norm);

          drafts.add(
            SegmentUnitDraft(
              sourceId: sourceId,
              segmentId: seg.id,
              pageNumber: seg.pageNumber,
              title: title,
              claimContent: _toClaimContent(chunk),
              unitType: _inferUnitType('$title $chunk'),
              problemFormat: _inferProblemFormat('$title $chunk'),
            ),
          );
          if (drafts.length >= limit) return drafts;
        }
      }
    }
    return drafts;
  }

  Future<List<int>> createExamUnitsFromDrafts(
    List<SegmentUnitDraft> drafts,
  ) async {
    if (drafts.isEmpty) return const [];
    return transaction(() async {
      final createdIds = <int>[];
      for (final draft in drafts) {
        final unitId = await into(examUnits).insert(
          ExamUnitsCompanion.insert(
            title: draft.title,
            unitType: Value(draft.unitType),
            problemFormat: Value(draft.problemFormat),
            description: Value(
              'Auto-generated from source p.${draft.pageNumber}',
            ),
          ),
        );

        final claimId = await into(claims).insert(
          ClaimsCompanion.insert(
            examUnitId: unitId,
            content: draft.claimContent,
            contentConfidence: const Value('M'),
            createdBy: const Value('ai'),
          ),
        );
        await into(evidenceLinks).insert(
          EvidenceLinksCompanion.insert(
            claimId: claimId,
            sourceSegmentId: draft.segmentId,
            note: const Value('auto-generated from source segment'),
          ),
        );
        final packId = await into(evidencePacks).insert(
          EvidencePacksCompanion.insert(
            claimId: claimId,
            contentConfidence: const Value('M'),
            examConfidence: const Value('M'),
          ),
        );
        await into(evidencePackItems).insert(
          EvidencePackItemsCompanion.insert(
            evidencePackId: packId,
            sourceSegmentId: draft.segmentId,
            pageNumber: Value(draft.pageNumber),
            snippet: Value(_snippetFromClaim(draft.claimContent)),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        createdIds.add(unitId);
      }

      await db.auditDao.refreshCoverageAudits();
      return createdIds;
    });
  }

  String _extractCandidateTitle(String chunk) {
    final firstLine = chunk.split('\n').first.trim();
    var t = firstLine;
    final bracketed = RegExp(r'【([^】]{1,40})】').firstMatch(t);
    if (bracketed != null) {
      t = bracketed.group(1)!.trim();
    }
    if (t.contains('：')) {
      t = t.split('：').first.trim();
    } else if (t.contains(':')) {
      t = t.split(':').first.trim();
    }
    t = t
        .replaceFirst(RegExp(r'^\s*(?:\d+[\.\)]|[（(]\d+[）)])\s*'), '')
        .replaceFirst(RegExp(r'^[\-\*\s]+'), '')
        .trim();
    if (t.length > 32) t = t.substring(0, 32);
    return t;
  }

  List<String> _extractHeadingLikeLines(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final scored = <(String line, int score)>[];
    for (final line in lines) {
      final score = _headingScore(line);
      if (score >= 3) {
        scored.add((line, score));
      }
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => e.$1).toList();
  }

  int _headingScore(String line) {
    var score = 0;
    if (line.length <= 28) score += 2;
    if (line.contains(':') || line.contains('：')) score += 2;
    if (RegExp(r'^\s*【[^】]{1,40}】\s*$').hasMatch(line)) {
      score += 5;
    }
    if (RegExp(r'^\s*(\d+[\.\)]|[（(]\d+[）)]|【[^】]{1,40}】)').hasMatch(line)) {
      score += 2;
    }
    final letters = RegExp(r'[A-Za-z]').allMatches(line).length;
    if (letters > 2) {
      final uppers = RegExp(r'[A-Z]').allMatches(line).length;
      final ratio = uppers / letters;
      if (ratio >= 0.6) score += 2;
    }
    return score;
  }

  String _normalizeTitle(String s) {
    final sb = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final code = rune;
      if (code >= 0xFF10 && code <= 0xFF19) {
        sb.writeCharCode(code - 0xFF10 + 0x30);
      } else if (code >= 0xFF21 && code <= 0xFF3A) {
        sb.writeCharCode(code - 0xFF21 + 0x41);
      } else if (code >= 0xFF41 && code <= 0xFF5A) {
        sb.writeCharCode(code - 0xFF41 + 0x61);
      } else if (_isIgnorablePunctuation(ch)) {
        continue;
      } else if (ch.trim().isEmpty) {
        continue;
      } else {
        sb.write(ch);
      }
    }
    return sb.toString().toLowerCase();
  }

  bool _isIgnorablePunctuation(String ch) {
    const punct = '、。,.-_:：;；()[]【】「」『』"\'!?！？';
    return punct.contains(ch);
  }

  String _claimAroundHeading(String text, String heading) {
    final idx = text.indexOf(heading);
    if (idx < 0) return _toClaimContent(text);
    final tail = text.substring(idx + heading.length).trimLeft();
    if (tail.isEmpty) return _toClaimContent(text);
    return _toClaimContent('$heading $tail');
  }

  String _toClaimContent(String chunk) {
    final text = chunk.replaceAll('\n', ' ').trim();
    if (text.length <= 180) return text;
    return '${text.substring(0, 180)}…';
  }

  String _snippetFromClaim(String claim) {
    final t = claim.trim();
    if (t.length <= 200) return t;
    return t.substring(0, 200);
  }

  String _inferUnitType(String text) {
    final t = text.toLowerCase();
    if (RegExp(
      r'(ct|mri|x線|xray|レントゲン|エコー|ultrasound|us|画像|所見|陰影)',
    ).hasMatch(t)) {
      return '画像所見';
    }
    if (RegExp(r'(鑑別|除外|見分け|比較|違い)').hasMatch(t)) {
      return '鑑別';
    }
    if (RegExp(r'(機序|病態|メカニズム|原因|過程|作用)').hasMatch(t)) {
      return '機序';
    }
    if (RegExp(r'(定義|とは|をいう|意味)').hasMatch(t)) {
      return '定義';
    }
    return 'その他';
  }

  String _inferProblemFormat(String text) {
    final t = text.toLowerCase();
    if (RegExp(r'(計算|算出|求めよ|求める|=|％|%|mg/?dl|mmhg|ml)').hasMatch(t)) {
      return '計算';
    }
    if (RegExp(
      r'(ct|mri|x線|xray|レントゲン|エコー|ultrasound|us|画像|写真|図)',
    ).hasMatch(t)) {
      return '画像問題';
    }
    if (RegExp(r'(穴埋め|空欄|____|＿|（\s*）|\(\s*\))').hasMatch(t)) {
      return '穴埋め';
    }
    if (RegExp(r'(次のうち|正しいもの|誤っている|選べ|選択肢|①|②|a\.|b\.)').hasMatch(t)) {
      return '選択肢';
    }
    if (RegExp(r'(述べよ|説明せよ|記載せよ|理由を)').hasMatch(t)) {
      return '記述';
    }
    return '選択肢';
  }
}
