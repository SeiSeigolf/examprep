import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../db/database.dart';
import '../../../../db/database.provider.dart';
import '../../providers/claims.provider.dart';

class AddClaimDialog extends ConsumerStatefulWidget {
  const AddClaimDialog({super.key, required this.examUnitId});
  final int examUnitId;

  @override
  ConsumerState<AddClaimDialog> createState() => _AddClaimDialogState();
}

class _AddClaimDialogState extends ConsumerState<AddClaimDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  String _confidence = 'medium';
  final Set<int> _selectedSegmentIds = {};
  bool _saving = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSegmentIds.isEmpty) {
      // Evidence-first: 根拠なしは保存不可
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('根拠（Evidence）を最低1つ選択してください（Evidence-first）'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    await ref.read(databaseProvider).claimsDao.insertClaimWithEvidence(
          ClaimsCompanion.insert(
            examUnitId: widget.examUnitId,
            content: _contentCtrl.text.trim(),
            confidenceLevel: Value(_confidence),
          ),
          _selectedSegmentIds.toList(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final segmentsAsync = ref.watch(allSegmentsWithSourceProvider);

    return AlertDialog(
      title: const Text('Claim を追加'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Claim 内容 ----
                TextFormField(
                  controller: _contentCtrl,
                  autofocus: true,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Claim 内容 *',
                    hintText: '例: 心房細動は不規則な心房の電気活動による不整脈である',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '内容は必須です' : null,
                ),
                const SizedBox(height: 16),

                // ---- 信頼度 ----
                DropdownButtonFormField<String>(
                  value: _confidence,
                  decoration: const InputDecoration(labelText: '信頼度'),
                  items: const [
                    DropdownMenuItem(value: 'high', child: Text('High (H)')),
                    DropdownMenuItem(
                        value: 'medium', child: Text('Medium (M)')),
                    DropdownMenuItem(value: 'low', child: Text('Low (L)')),
                  ],
                  onChanged: (v) => setState(() => _confidence = v!),
                ),
                const SizedBox(height: 20),

                // ---- 根拠選択（Evidence-first） ----
                Row(
                  children: [
                    const Text(
                      '根拠（Evidence） *',
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedSegmentIds.isEmpty)
                      const Text(
                        '最低1つ必須',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                segmentsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('エラー: $e',
                      style: const TextStyle(color: Colors.redAccent)),
                  data: (segments) {
                    if (segments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'ソースがまだ取り込まれていません。\n先に「ソース管理」からPDFを追加してください。',
                          style: TextStyle(color: Colors.white38),
                        ),
                      );
                    }
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: segments.length,
                        itemBuilder: (context, i) {
                          final seg = segments[i];
                          final isSelected =
                              _selectedSegmentIds.contains(seg.segment.id);
                          return CheckboxListTile(
                            dense: true,
                            value: isSelected,
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                _selectedSegmentIds.add(seg.segment.id);
                              } else {
                                _selectedSegmentIds.remove(seg.segment.id);
                              }
                            }),
                            title: Text(
                              seg.source.fileName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                            subtitle: Text(
                              'p.${seg.segment.pageNumber}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                            secondary: const Icon(Icons.picture_as_pdf,
                                color: Colors.redAccent, size: 20),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
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
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('保存'),
        ),
      ],
    );
  }
}
