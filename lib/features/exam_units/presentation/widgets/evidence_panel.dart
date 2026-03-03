import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/claims.provider.dart';
import '../../../../features/ingestion/presentation/widgets/pdf_viewer_dialog.dart';

class EvidencePanel extends ConsumerWidget {
  const EvidencePanel({super.key, required this.claimId});
  final int claimId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceAsync = ref.watch(evidenceForClaimProvider(claimId));

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
          child: evidenceAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('エラー: $e',
                style: const TextStyle(color: Colors.redAccent)),
            data: (evidences) {
              if (evidences.isEmpty) {
                return const Center(
                  child: Text(
                    'Evidence なし',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                );
              }
              return ListView.separated(
                itemCount: evidences.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                itemBuilder: (context, i) {
                  final ev = evidences[i];
                  return _EvidenceCard(
                    sourceName: ev.source.fileName,
                    filePath: ev.source.filePath,
                    pageNumber: ev.segment.pageNumber,
                    content: ev.segment.content,
                    note: ev.link.note,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
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
              const Icon(Icons.picture_as_pdf,
                  size: 14, color: Colors.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sourceName,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
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
                    height: 1.5),
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
                const Icon(Icons.note_outlined,
                    size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    note!,
                    style: const TextStyle(
                        color: Colors.amber, fontSize: 11),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
