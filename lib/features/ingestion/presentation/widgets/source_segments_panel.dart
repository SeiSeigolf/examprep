import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
import '../../../../db/database.provider.dart';
import '../../../../db/daos/sources_dao.dart';
import '../../../../db/daos/exam_units_dao.dart';
import '../../../../shared/providers/navigation.provider.dart';
import '../../../exam_units/providers/exam_units.provider.dart';
import '../../providers/ingestion.provider.dart';
import '../../providers/selected_source.provider.dart';
import '../../providers/sources_list.provider.dart';
import '../../services/text_extraction/models.dart';
import '../../services/text_extraction/quality_score.dart';

/// 選択中ソースのページ一覧 + テキストプレビューパネル
class SourceSegmentsPanel extends ConsumerWidget {
  const SourceSegmentsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedSourceIdProvider);

    if (selectedId == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 40, color: Colors.white12),
            SizedBox(height: 12),
            Text(
              'ソースを選択するとページ一覧が表示されます',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final sourcesAsync = ref.watch(sourcesListProvider);
    final source = sourcesAsync.whenData(
      (list) => list.where((s) => s.id == selectedId).firstOrNull,
    );
    final ingestion = ref.watch(ingestionProvider);

    final segmentsAsync = ref.watch(segmentsForSourceProvider(selectedId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- パネルヘッダー ----
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1D23),
            border: Border(bottom: BorderSide(color: Color(0xFF2E3340))),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 16,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  source.value?.fileName ?? '読み込み中...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              segmentsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (segs) => Row(
                  children: [
                    if (source.value != null) ...[
                      _MiniQualityBadge(score: source.value!.lastQualityScore),
                      const SizedBox(width: 6),
                      Text(
                        source.value!.lastExtractionMethod ?? 'unknown',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${segs.length} ページ',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed:
                          ingestion.status == IngestionStatus.extracting ||
                              ingestion.status == IngestionStatus.inserting
                          ? null
                          : () => ref
                                .read(ingestionProvider.notifier)
                                .reextractSource(
                                  sourceId: selectedId,
                                  mode: ExtractionForceMode.auto,
                                ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '再抽出(自動)',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed:
                          ingestion.status == IngestionStatus.extracting ||
                              ingestion.status == IngestionStatus.inserting
                          ? null
                          : () => ref
                                .read(ingestionProvider.notifier)
                                .reextractSource(
                                  sourceId: selectedId,
                                  mode: ExtractionForceMode.poppler,
                                ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '再抽出(Poppler)',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed:
                          ingestion.status == IngestionStatus.extracting ||
                              ingestion.status == IngestionStatus.inserting
                          ? null
                          : () => ref
                                .read(ingestionProvider.notifier)
                                .reextractSource(
                                  sourceId: selectedId,
                                  mode: ExtractionForceMode.ocr,
                                ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '再抽出(OCR)',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: segs.isEmpty
                          ? null
                          : () => showDialog(
                              context: context,
                              builder: (_) => _AutoGenerateUnitsDialog(
                                sourceId: selectedId,
                              ),
                            ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('候補生成', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ---- セグメント一覧 ----
        Expanded(
          child: segmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'エラー: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            data: (segments) {
              if (segments.isEmpty) {
                return const Center(
                  child: Text(
                    'セグメントがありません',
                    style: TextStyle(color: Colors.white24),
                  ),
                );
              }
              final preview = _sourcePreview(segments);
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      'テキストプレビュー: $preview',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...List.generate(segments.length, (i) {
                    return Column(
                      children: [
                        _SegmentTile(segment: segments[i]),
                        if (i != segments.length - 1)
                          const Divider(height: 1, color: Color(0xFF2E3340)),
                      ],
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniQualityBadge extends StatelessWidget {
  const _MiniQualityBadge({required this.score});
  final double? score;

  @override
  Widget build(BuildContext context) {
    final s = score ?? 0;
    final label = qualityLabel(s);
    final color = label == 'Good'
        ? const Color(0xFF2E7D32)
        : label == 'OK'
        ? const Color(0xFFEF6C00)
        : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(60),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        '$label ${s.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

String _sourcePreview(List<SourceSegment> segments) {
  for (final s in segments) {
    final t = s.content.trim();
    if (t.isNotEmpty) {
      return t.length <= 300 ? t : '${t.substring(0, 300)}...';
    }
  }
  return '(テキストなし)';
}

class _AutoGenerateUnitsDialog extends ConsumerStatefulWidget {
  const _AutoGenerateUnitsDialog({required this.sourceId});
  final int sourceId;

  @override
  ConsumerState<_AutoGenerateUnitsDialog> createState() =>
      _AutoGenerateUnitsDialogState();
}

class _AutoGenerateUnitsDialogState
    extends ConsumerState<_AutoGenerateUnitsDialog> {
  bool _creating = false;
  late Future<List<SegmentUnitDraft>> _future;
  final _selected = <int>{};
  final _unitTypes = const ['定義', '機序', '鑑別', '画像所見', 'その他'];
  final _problemFormats = const ['選択肢', '穴埋め', '記述', '画像問題', '計算'];
  final _unitTypeByIndex = <int, String>{};
  final _problemFormatByIndex = <int, String>{};

  @override
  void initState() {
    super.initState();
    _future = ref
        .read(databaseProvider)
        .sourcesDao
        .suggestExamUnitDraftsFromSource(widget.sourceId);
  }

  Future<void> _create(List<SegmentUnitDraft> drafts) async {
    setState(() => _creating = true);
    try {
      final selectedDrafts = _selected.map((i) {
        final d = drafts[i];
        return d.copyWith(
          unitType: _unitTypeByIndex[i],
          problemFormat: _problemFormatByIndex[i],
        );
      }).toList();
      final createdUnitIds = await ref
          .read(databaseProvider)
          .sourcesDao
          .createExamUnitsFromDrafts(selectedDrafts);
      final count = createdUnitIds.length;
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count件のExam Unit/Claimを作成しました')),
        );

        final duplicates = await ref
            .read(databaseProvider)
            .examUnitsDao
            .findDuplicateCandidates(limit: 20);
        final related = duplicates
            .where(
              (p) =>
                  createdUnitIds.contains(p.left.id) ||
                  createdUnitIds.contains(p.right.id),
            )
            .toList();
        if (!mounted || related.isEmpty) return;
        showDialog(
          context: context,
          builder: (_) => _PostGenerateDuplicateDialog(candidates: related),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 760,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<SegmentUnitDraft>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final drafts = snapshot.data ?? const <SegmentUnitDraft>[];
              if (drafts.isEmpty) {
                return Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Exam Unit候補生成',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Expanded(child: Center(child: Text('候補を抽出できませんでした'))),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('閉じる'),
                      ),
                    ),
                  ],
                );
              }

              if (_selected.isEmpty) {
                final initial = drafts.length < 5 ? drafts.length : 5;
                _selected.addAll(List.generate(initial, (i) => i));
                for (var i = 0; i < drafts.length; i++) {
                  _unitTypeByIndex[i] = drafts[i].unitType;
                  _problemFormatByIndex[i] = drafts[i].problemFormat;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exam Unit候補生成（チェックした候補のみ作成）',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: drafts.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFF2E3340)),
                      itemBuilder: (context, i) {
                        final d = drafts[i];
                        final checked = _selected.contains(i);
                        final unitType = _unitTypeByIndex[i] ?? d.unitType;
                        final problemFormat =
                            _problemFormatByIndex[i] ?? d.problemFormat;
                        return CheckboxListTile(
                          value: checked,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected.add(i);
                              } else {
                                _selected.remove(i);
                              }
                            });
                          },
                          title: Text(
                            d.title,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'p.${d.pageNumber}  ${d.claimContent}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  SizedBox(
                                    width: 130,
                                    child: DropdownButtonFormField<String>(
                                      value: unitType,
                                      isDense: true,
                                      decoration: const InputDecoration(
                                        labelText: 'UnitType',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                      ),
                                      items: _unitTypes
                                          .map(
                                            (v) => DropdownMenuItem(
                                              value: v,
                                              child: Text(
                                                v,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _unitTypeByIndex[i] = v);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: DropdownButtonFormField<String>(
                                      value: problemFormat,
                                      isDense: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Format',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                      ),
                                      items: _problemFormats
                                          .map(
                                            (v) => DropdownMenuItem(
                                              value: v,
                                              child: Text(
                                                v,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(
                                          () => _problemFormatByIndex[i] = v,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('選択: ${_selected.length}件'),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('キャンセル'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: (_creating || _selected.isEmpty)
                            ? null
                            : () => _create(drafts),
                        child: _creating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('作成'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PostGenerateDuplicateDialog extends ConsumerWidget {
  const _PostGenerateDuplicateDialog({required this.candidates});
  final List<UnitDuplicateCandidate> candidates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('重複候補が見つかりました'),
      content: SizedBox(
        width: 620,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: candidates.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final c = candidates[i];
            return ListTile(
              dense: true,
              title: Text('${c.left.title}  <>  ${c.right.title}'),
              subtitle: Text(
                '類似度 ${(c.score * 100).toStringAsFixed(1)}% / ${c.overlapTokens.join(', ')}',
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        FilledButton(
          onPressed: () {
            final target = candidates.first.left.id;
            ref.read(selectedExamUnitIdProvider.notifier).state = target;
            ref.read(selectedDestinationProvider.notifier).state =
                AppDestination.examUnits;
            Navigator.of(context).pop();
          },
          child: const Text('Exam Unitsで確認'),
        ),
      ],
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({required this.segment});
  final SourceSegment segment;

  @override
  Widget build(BuildContext context) {
    final hasText = segment.content.isNotEmpty;
    final preview = hasText
        ? segment.content.length > 200
              ? '${segment.content.substring(0, 200)}…'
              : segment.content
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ページ番号バッジ
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2D3440),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'p.${segment.pageNumber}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // テキストプレビュー
          Expanded(
            child: hasText
                ? Text(
                    preview!,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 14,
                        color: Colors.white24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '画像ページ（テキストなし）',
                        style: TextStyle(
                          color: Colors.white.withAlpha(40),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
          ),
          // 文字数
          if (hasText)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '${segment.content.length}字',
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
