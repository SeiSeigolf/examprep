import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/claims.provider.dart';
import '../../../../db/database.dart';
import '../../../../db/daos/claims_dao.dart';
import '../../../../features/ingestion/presentation/widgets/pdf_viewer_dialog.dart';

class EvidencePanel extends ConsumerWidget {
  const EvidencePanel({super.key, required this.claimId});
  final int claimId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packAsync = ref.watch(evidencePackForClaimProvider(claimId));
    final evidenceAsync = ref.watch(evidenceForClaimProvider(claimId));
    final segmentsAsync = ref.watch(allSegmentsWithSourceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Row(
            children: [
              Icon(Icons.link, size: 16, color: Colors.white38),
              SizedBox(width: 6),
              Text(
                '根拠（Evidence）',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              const Text(
                'EvidencePack (bundle)',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              packAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'エラー: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                data: (bundle) {
                  if (bundle == null || bundle.items.isEmpty) {
                    return const Text(
                      'Bundle なし',
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    );
                  }

                  return segmentsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '参照情報を読み込み中...',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ),
                    error: (e, _) => Text(
                      '参照情報の取得エラー: $e',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    data: (segments) {
                      final segmentMap = {
                        for (final s in segments) s.segment.id: s,
                      };
                      return Column(
                        children: bundle.items
                            .map(
                              (item) => _EvidencePackItemCard(
                                item: item,
                                segmentWithSource:
                                    segmentMap[item.sourceSegmentId],
                              ),
                            )
                            .toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 12),
              const Text(
                '従来 evidence_links（比較用）',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              evidenceAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'エラー: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                data: (evidences) {
                  if (evidences.isEmpty) {
                    return const Text(
                      'Evidence なし',
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    );
                  }
                  return Column(
                    children: evidences
                        .map(
                          (ev) => _EvidenceCard(
                            sourceName: ev.source.fileName,
                            filePath: ev.source.filePath,
                            pageNumber: ev.segment.pageNumber,
                            content: ev.segment.content,
                            note: ev.link.note,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EvidencePackItemCard extends StatelessWidget {
  const _EvidencePackItemCard({
    required this.item,
    required this.segmentWithSource,
  });

  final EvidencePackItem item;
  final SegmentWithSource? segmentWithSource;

  @override
  Widget build(BuildContext context) {
    final pageFromPack = item.pageNumber;
    final pageFromSegment = segmentWithSource?.segment.pageNumber;
    final pageForViewer = pageFromPack ?? pageFromSegment;
    final snippet = _effectiveSnippet(item.snippet, segmentWithSource?.segment.content);
    final sourceName = segmentWithSource?.source.fileName ?? 'Unknown source';
    final canOpen =
        segmentWithSource != null && pageForViewer != null && pageForViewer > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: Colors.white54,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'sourceSegmentId=${item.sourceSegmentId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              Text(
                'weight=${item.weight}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'page=${pageForViewer?.toString() ?? '-'}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            'snippet=${snippet.isEmpty ? '-' : snippet}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 13,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sourceName,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: canOpen
                    ? () => showDialog(
                        context: context,
                        builder: (_) => PdfViewerDialog(
                          filePath: segmentWithSource!.source.filePath,
                          pageNumber: pageForViewer!,
                          fileName: segmentWithSource!.source.fileName,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.open_in_new, size: 13),
                label: const Text('元ページを開く', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white38,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _effectiveSnippet(String? itemSnippet, String? segmentContent) {
    final snippet = itemSnippet?.trim() ?? '';
    if (snippet.isNotEmpty) return snippet;
    final content = segmentContent?.trim() ?? '';
    if (content.isEmpty) return '';
    return content.length <= 200 ? content : content.substring(0, 200);
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({
    required this.sourceName,
    required this.filePath,
    required this.pageNumber,
    required this.content,
    required this.note,
  });

  final String sourceName;
  final String filePath;
  final int pageNumber;
  final String content;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ソース名 + ページ
          Row(
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 14,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sourceName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'p.$pageNumber',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          // 抽出テキスト（あれば）
          if (content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // ノート（あれば）
          if (note != null && note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note_outlined, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    note!,
                    style: const TextStyle(color: Colors.amber, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
          // 元ページを開くボタン
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => PdfViewerDialog(
                  filePath: filePath,
                  pageNumber: pageNumber,
                  fileName: sourceName,
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 13),
              label: const Text('元ページを開く', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white38,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
