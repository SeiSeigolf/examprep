import 'package:flutter/material.dart';
import '../../../../db/database.dart';

class SourceListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        title: Text(
          source.fileName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_formatBytes(source.fileSize)}  •  '
          '${source.importedAt.toLocal().toString().substring(0, 16)}',
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
