import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exam_units.provider.dart';
import '../../../db/database.provider.dart';
import '../services/exam_exporter.dart';
import 'exam_unit_detail_page.dart';
import 'widgets/exam_unit_list_tile.dart';
import 'widgets/exam_unit_dialog.dart';

class ExamUnitsPage extends ConsumerWidget {
  const ExamUnitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedExamUnitIdProvider);

    // 詳細画面を優先表示
    if (selectedId != null) {
      return ExamUnitDetailPage(examUnitId: selectedId);
    }
    return const _ExamUnitListView();
  }
}

class _ExamUnitListView extends ConsumerStatefulWidget {
  const _ExamUnitListView();

  @override
  ConsumerState<_ExamUnitListView> createState() => _ExamUnitListViewState();
}

class _ExamUnitListViewState extends ConsumerState<_ExamUnitListView> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final path = await ExamExporter.export(ref.read(databaseProvider));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('保存完了: $path'),
          duration: const Duration(seconds: 8),
        ));
      }
    } catch (e) {
      debugPrint('[Export] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('エクスポートエラー: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(examUnitsListProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- ヘッダー ----
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam Units',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '学習の最小単位（定義・機序・鑑別・画像所見）',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white38),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: _exporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_outlined, size: 16),
                label: const Text('エクスポート'),
                onPressed: _exporting ? null : _export,
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('新規作成'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ExamUnitDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- 一覧 ----
          Expanded(
            child: unitsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('読み込みエラー: $e',
                    style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (units) {
                if (units.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.library_books_outlined,
                            size: 64, color: Colors.white12),
                        SizedBox(height: 16),
                        Text(
                          'Exam Unit がまだありません\n「新規作成」から追加してください',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  );
                }
                final claimCounts =
                    ref.watch(claimCountsProvider).valueOrNull ?? {};
                return ReorderableListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, i) {
                    final unit = units[i];
                    return ExamUnitListTile(
                      key: ValueKey(unit.id),
                      unit: unit,
                      index: i,
                      claimCount: claimCounts[unit.id] ?? 0,
                      onTap: () => ref
                          .read(selectedExamUnitIdProvider.notifier)
                          .state = unit.id,
                      onEdit: () => showDialog(
                        context: context,
                        builder: (_) => ExamUnitDialog(unit: unit),
                      ),
                      onDelete: () => _confirmDelete(context, ref, unit.id),
                    );
                  },
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex--;
                    final reordered = [...units];
                    final item = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, item);
                    await ref
                        .read(databaseProvider)
                        .examUnitsDao
                        .updateSortOrders(
                          reordered.indexed
                              .map((e) => (e.$2.id, e.$1))
                              .toList(),
                        );
                  },
                  proxyDecorator: (child, index, animation) => Material(
                    elevation: 4,
                    color: const Color(0xFF2D3440),
                    borderRadius: BorderRadius.circular(8),
                    child: child,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int unitId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exam Unit を削除'),
        content:
            const Text('この Exam Unit と関連する Claim・Evidence を全て削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(databaseProvider)
                  .examUnitsDao
                  .deleteUnit(unitId);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
