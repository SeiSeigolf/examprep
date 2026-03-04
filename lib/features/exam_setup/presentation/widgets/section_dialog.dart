import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
import '../../../../db/database.provider.dart';

/// セクション作成/編集ダイアログ
class SectionDialog extends ConsumerStatefulWidget {
  const SectionDialog({super.key, required this.examId, this.section});

  final int examId;
  final ExamSection? section; // null = 新規作成

  @override
  ConsumerState<SectionDialog> createState() => _SectionDialogState();
}

class _SectionDialogState extends ConsumerState<SectionDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _pointsCtrl;
  late String _approach;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.section?.name ?? '');
    _pointsCtrl = TextEditingController(
      text: (widget.section?.points ?? 0).toString(),
    );
    _approach = widget.section?.studyApproach ?? '暗記';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final points = int.tryParse(_pointsCtrl.text) ?? 0;
    final db = ref.read(databaseProvider);

    if (widget.section == null) {
      await db.examsDao.insertSection(
        ExamSectionsCompanion.insert(
          examId: widget.examId,
          name: name,
          points: Value(points),
          studyApproach: Value(_approach),
        ),
      );
    } else {
      await db.examsDao.updateSection(
        ExamSectionsCompanion(
          id: Value(widget.section!.id),
          examId: Value(widget.examId),
          name: Value(name),
          points: Value(points),
          studyApproach: Value(_approach),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.section == null;
    return AlertDialog(
      title: Text(isNew ? 'セクション追加' : 'セクション編集'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'セクション名（例: 解剖学）'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pointsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '配点（点）'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _approach,
            decoration: const InputDecoration(labelText: '学習アプローチ'),
            items: const ['暗記', '理解', '計算'].map((a) {
              return DropdownMenuItem(value: a, child: Text(a));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _approach = v);
            },
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
