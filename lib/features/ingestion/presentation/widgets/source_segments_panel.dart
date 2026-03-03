import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
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
              const Icon(Icons.picture_as_pdf,
                  size: 16, color: Colors.redAccent),
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
                data: (segs) => Text(
                  '${segs.length} ページ',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        // ---- セグメント一覧 ----
        Expanded(
          child: segmentsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('エラー: $e',
                  style: const TextStyle(color: Colors.redAccent)),
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
                itemBuilder: (context, i) =>
                    _SegmentTile(segment: segments[i]),
              );
            },
          ),
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
                  fontWeight: FontWeight.w600),
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
                      const Icon(Icons.image_outlined,
                          size: 14, color: Colors.white24),
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
                style:
                    const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
