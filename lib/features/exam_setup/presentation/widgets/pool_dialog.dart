import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
import '../../../../db/database.provider.dart';

/// 出題プール作成/編集ダイアログ
class PoolDialog extends ConsumerStatefulWidget {
  const PoolDialog({super.key, required this.sectionId, this.pool});

  final int sectionId;
  final ExamPool? pool; // null = 新規作成

  @override
  ConsumerState<PoolDialog> createState() => _PoolDialogState();
}

class _PoolDialogState extends ConsumerState<PoolDialog> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _guaranteedCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(
      text: widget.pool?.description ?? '',
    );
    _totalCtrl = TextEditingController(
      text: (widget.pool?.totalItems ?? 0).toString(),
    );
    _guaranteedCtrl = TextEditingController(
      text: (widget.pool?.guaranteedItems ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _totalCtrl.dispose();
    _guaranteedCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) return;
    final total = int.tryParse(_totalCtrl.text) ?? 0;
    final guaranteed = int.tryParse(_guaranteedCtrl.text) ?? 0;
    final db = ref.read(databaseProvider);

    if (widget.pool == null) {
      await db.examsDao.insertPool(
        ExamPoolsCompanion.insert(
          sectionId: widget.sectionId,
          description: desc,
          totalItems: Value(total),
          guaranteedItems: Value(guaranteed),
        ),
      );
    } else {
      await db.examsDao.updatePool(
        ExamPoolsCompanion(
          id: Value(widget.pool!.id),
          sectionId: Value(widget.sectionId),
          description: Value(desc),
          totalItems: Value(total),
          guaranteedItems: Value(guaranteed),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.pool == null;
    return AlertDialog(
      title: Text(isNew ? '出題プール追加' : '出題プール編集'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '説明（例: 骨格名称100文）',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '出題総数 N'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _guaranteedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '保証出題数 M'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '全N個を習得すると最低M問が確実に得点できる設定です',
            style: TextStyle(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _save, child: Text(isNew ? '追加' : '保存')),
      ],
    );
  }
}
