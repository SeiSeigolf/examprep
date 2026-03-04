import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
import '../../../../db/database.provider.dart';
import '../../../../shared/constants/source_weights.dart';

class SourceListTile extends ConsumerWidget {
  const SourceListTile({
    super.key,
    required this.source,
    required this.onDelete,
  });

  final Source source;
  final VoidCallback onDelete;

  String _formatBytes(int? bytes) {
    if (bytes == null) return '—';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = sourceTypeLabels[source.sourceType] ?? source.sourceType;
    final weight = sourceTypeWeights[source.sourceType] ?? 0.5;
    final weightStr = weight.toStringAsFixed(1);

    // 重みに応じた色
    final weightColor = weight >= 0.9
        ? const Color(0xFF4CAF50)
        : weight >= 0.7
        ? const Color(0xFF4A90D9)
        : weight >= 0.5
        ? const Color(0xFFFF9800)
        : const Color(0xFF607D8B);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        title: Row(
          children: [
            Expanded(
              child: Text(
                source.fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            // source_type バッジ
            _TypeBadge(label: label, weight: weight, color: weightColor),
            const SizedBox(width: 4),
            // source_type 変更ドロップダウン
            _SourceTypeDropdown(source: source),
          ],
        ),
        subtitle: Text(
          '${_formatBytes(source.fileSize)}  •  '
          '${source.importedAt.toLocal().toString().substring(0, 16)}  •  '
          '重み $weightStr',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white38),
          tooltip: '削除',
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.label,
    required this.weight,
    required this.color,
  });

  final String label;
  final double weight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SourceTypeDropdown extends ConsumerWidget {
  const _SourceTypeDropdown({required this.source});
  final Source source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: 'タイプ変更',
      icon: const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white38),
      iconSize: 16,
      padding: EdgeInsets.zero,
      onSelected: (newType) async {
        await ref
            .read(databaseProvider)
            .sourcesDao
            .updateSourceType(source.id, newType);
      },
      itemBuilder: (_) => sourceTypeValues.map((t) {
        final lbl = sourceTypeLabels[t] ?? t;
        final w = sourceTypeWeights[t] ?? 0.5;
        final isCurrent = t == source.sourceType;
        return PopupMenuItem<String>(
          value: t,
          child: Row(
            children: [
              if (isCurrent)
                const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFF4A90D9),
                )
              else
                const SizedBox(width: 14),
              const SizedBox(width: 6),
              Text(lbl),
              const Spacer(),
              Text(
                '★${w.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
