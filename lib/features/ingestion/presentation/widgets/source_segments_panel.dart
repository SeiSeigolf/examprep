import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
import '../../../../db/database.provider.dart';
import '../../../../db/daos/sources_dao.dart';
import '../../providers/selected_source.provider.dart';
import '../../providers/sources_list.provider.dart';

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
                    Text(
                      '${segs.length} ページ',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
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
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: segments.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFF2E3340)),
                itemBuilder: (context, i) => _SegmentTile(segment: segments[i]),
              );
            },
          ),
        ),
      ],
    );
  }
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
      final selectedDrafts = drafts
          .where((d) => _selected.contains(d.segmentId))
          .toList();
      final count = await ref
          .read(databaseProvider)
          .sourcesDao
          .createExamUnitsFromDrafts(selectedDrafts);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count件のExam Unit/Claimを作成しました')),
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
                _selected.addAll(drafts.take(5).map((d) => d.segmentId));
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
                        final checked = _selected.contains(d.segmentId);
                        return CheckboxListTile(
                          value: checked,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected.add(d.segmentId);
                              } else {
                                _selected.remove(d.segmentId);
                              }
                            });
                          },
                          title: Text(
                            d.title,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            'p.${d.pageNumber}  ${d.claimContent}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
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
