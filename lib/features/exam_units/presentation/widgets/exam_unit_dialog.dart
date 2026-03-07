import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
import '../../../../db/database.provider.dart';

// 全セクション一覧プロバイダ（ExamUnitDialog用）
final _allSectionsProvider = FutureProvider<List<ExamSection>>((ref) async {
  return ref.watch(databaseProvider).examsDao.getAllSections();
});

const _unitTypes = ['定義', '機序', '鑑別', '画像所見', 'その他'];

/// 新規作成 or 編集ダイアログ。[unit] が null なら新規作成。
class ExamUnitDialog extends ConsumerStatefulWidget {
  const ExamUnitDialog({super.key, this.unit});
  final ExamUnit? unit;

  @override
  ConsumerState<ExamUnitDialog> createState() => _ExamUnitDialogState();
}

class _ExamUnitDialogState extends ConsumerState<ExamUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _unitType;
  late String _confidenceLevel;
  int? _sectionId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.unit?.title ?? '');
    _descCtrl = TextEditingController(text: widget.unit?.description ?? '');
    _unitType = widget.unit?.unitType ?? '定義';
    _confidenceLevel = widget.unit?.confidenceLevel ?? 'medium';
    _sectionId = widget.unit?.sectionId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    if (widget.unit == null) {
      final maxOrder = await db.examUnitsDao.getMaxSortOrder();
      await db.examUnitsDao.insertUnit(ExamUnitsCompanion.insert(
        title: _titleCtrl.text.trim(),
        unitType: Value(_unitType),
        description: Value(_descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim()),
        confidenceLevel: Value(_confidenceLevel),
        sectionId: Value(_sectionId),
        updatedAt: Value(now),
        sortOrder: Value(maxOrder + 1),
      ));
    } else {
      await db.examUnitsDao.updateUnit(ExamUnitsCompanion(
        id: Value(widget.unit!.id),
        title: Value(_titleCtrl.text.trim()),
        unitType: Value(_unitType),
        description: Value(_descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim()),
        confidenceLevel: Value(_confidenceLevel),
        sectionId: Value(_sectionId),
        updatedAt: Value(now),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.unit != null;
    final sectionsAsync = ref.watch(_allSectionsProvider);
    return AlertDialog(
      title: Text(isEdit ? 'Exam Unit を編集' : '新規 Exam Unit'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              TextFormField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'タイトル *',
                  hintText: '例: 心房細動の定義',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'タイトルは必須です' : null,
              ),
              const SizedBox(height: 16),
              // unitType
              DropdownButtonFormField<String>(
                value: _unitType,
                decoration: const InputDecoration(labelText: 'ユニットタイプ'),
                items: _unitTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _unitType = v!),
              ),
              const SizedBox(height: 16),
              // 信頼度
              DropdownButtonFormField<String>(
                value: _confidenceLevel,
                decoration: const InputDecoration(labelText: '信頼度'),
                items: const [
                  DropdownMenuItem(value: 'high', child: Text('High (H)')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium (M)')),
                  DropdownMenuItem(value: 'low', child: Text('Low (L)')),
                ],
                onChanged: (v) => setState(() => _confidenceLevel = v!),
              ),
              const SizedBox(height: 16),
              // セクション選択
              const SizedBox(height: 16),
              sectionsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (sections) => DropdownButtonFormField<int?>(
                  value: sections.any((s) => s.id == _sectionId)
                      ? _sectionId
                      : null,
                  decoration: const InputDecoration(labelText: 'セクション（任意）'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('未割り当て'),
                    ),
                    ...sections.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s.id,
                        child: Text(s.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _sectionId = v),
                ),
              ),
              const SizedBox(height: 16),
              // 説明
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '説明（任意）',
                  hintText: '概要や備考を入力',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? '更新' : '作成'),
        ),
      ],
    );
  }
}
