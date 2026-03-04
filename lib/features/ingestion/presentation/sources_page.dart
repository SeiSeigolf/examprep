import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ingestion.provider.dart';
import '../providers/poppler_status.provider.dart';
import '../providers/sources_list.provider.dart';
import '../providers/selected_source.provider.dart';
import '../services/text_extraction/quality_score.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import 'widgets/source_segments_panel.dart';

class SourcesPage extends ConsumerWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Row(
      children: [
        // 左列: ソース一覧 (280px 固定)
        SizedBox(width: 280, child: _SourceListPanel()),
        VerticalDivider(width: 1),
        // 右列: 選択ソースのページプレビュー
        Expanded(child: SourceSegmentsPanel()),
      ],
    );
  }
}

// ---- 左列: ソース一覧 ----

class _SourceListPanel extends ConsumerWidget {
  const _SourceListPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingestion = ref.watch(ingestionProvider);
    final sourcesAsync = ref.watch(sourcesListProvider);
    final selectedId = ref.watch(selectedSourceIdProvider);
    final popplerAvailableAsync = ref.watch(popplerAvailableProvider);

    final isLoading =
        ingestion.status == IngestionStatus.picking ||
        ingestion.status == IngestionStatus.extracting ||
        ingestion.status == IngestionStatus.inserting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- ヘッダー ----
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1D23),
            border: Border(bottom: BorderSide(color: Color(0xFF2E3340))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ソース管理',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => ref
                            .read(ingestionProvider.notifier)
                            .pickAndImport(),
                  icon: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add, size: 16),
                  label: Text(
                    _statusLabel(ingestion),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---- エラー表示 ----
        if (ingestion.status == IngestionStatus.error)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'エラー: ${ingestion.errorMessage}',
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        if ((ingestion.errorMessage ?? '').toLowerCase().contains('pdftotext'))
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              'Poppler未導入の可能性があります: brew install poppler',
              style: TextStyle(color: Colors.amber, fontSize: 12),
            ),
          ),
        popplerAvailableAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (ok) => ok
              ? const SizedBox.shrink()
              : const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text(
                    'Poppler未導入: brew install poppler',
                    style: TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                ),
        ),

        // ---- ソース一覧 ----
        Expanded(
          child: sourcesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '読み込みエラー: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            data: (sources) {
              if (sources.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.white12,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'PDF がまだありません',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: sources.length,
                itemBuilder: (context, i) {
                  final source = sources[i];
                  final isSelected = source.id == selectedId;
                  return _SourceListItem(
                    source: source,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedSourceIdProvider.notifier).state =
                          source.id;
                    },
                    onDelete: () => _confirmDelete(context, ref, source.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _statusLabel(IngestionState s) => switch (s.status) {
    IngestionStatus.picking => 'ファイルを選択中...',
    IngestionStatus.extracting => 'テキスト抽出中: ${s.currentFile ?? ''}',
    IngestionStatus.inserting => 'DB 保存中...',
    _ => 'PDF を追加',
  };

  void _confirmDelete(BuildContext context, WidgetRef ref, int sourceId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ソースを削除'),
        content: const Text('このソースと関連するセグメント・Evidence を全て削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(context).pop();
              if (ref.read(selectedSourceIdProvider) == sourceId) {
                ref.read(selectedSourceIdProvider.notifier).state = null;
              }
              await ref
                  .read(databaseProvider)
                  .sourcesDao
                  .deleteSource(sourceId);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

// ---- ソースリストアイテム ----

class _SourceListItem extends StatelessWidget {
  const _SourceListItem({
    required this.source,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final Source source;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String _formatBytes(int? bytes) {
    if (bytes == null) return '—';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      color: isSelected ? const Color(0xFF2D3A4D) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: isSelected
                          ? Colors.redAccent
                          : Colors.redAccent.withAlpha(120),
                      size: 18,
                    ),
                    Positioned(
                      right: -3,
                      bottom: -3,
                      child: Icon(
                        (source.pageCount != null && source.pageCount! > 0)
                            ? Icons.check_circle
                            : Icons.warning_rounded,
                        size: 9,
                        color:
                            (source.pageCount != null && source.pageCount! > 0)
                            ? Colors.green.withAlpha(180)
                            : Colors.amber.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.fileName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (source.pageCount != null) '${source.pageCount}p',
                        _formatBytes(source.fileSize),
                      ].join('  •  '),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _QualityBadge(score: source.lastQualityScore),
                        const SizedBox(width: 6),
                        Text(
                          source.lastExtractionMethod ?? 'unknown',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: Colors.white24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: onDelete,
                tooltip: '削除',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.score});
  final double? score;

  @override
  Widget build(BuildContext context) {
    final value = score ?? 0;
    final label = qualityLabel(value);
    Color color;
    switch (label) {
      case 'Good':
        color = const Color(0xFF2E7D32);
        break;
      case 'OK':
        color = const Color(0xFFEF6C00);
        break;
      default:
        color = const Color(0xFFC62828);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white, fontSize: 9),
      ),
    );
  }
}
