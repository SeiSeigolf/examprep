import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/daos/exam_units_dao.dart';
import '../providers/exam_units.provider.dart';
import '../providers/claims.provider.dart';
import '../../../db/database.provider.dart';
import '../../../shared/providers/exam_profile.provider.dart';
import '../../../shared/widgets/active_exam_profile_badge.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存完了: $path'),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      debugPrint('[Export] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エクスポートエラー: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '学習の最小単位（定義・機序・鑑別・画像所見）',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white38),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: _exporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined, size: 16),
                label: const Text('エクスポート'),
                onPressed: _exporting ? null : _export,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.hub_outlined, size: 16),
                label: const Text('重複候補'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const _DuplicateCandidatesDialog(),
                ),
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
          const SizedBox(height: 8),
          const ActiveExamProfileBadge(),
          const SizedBox(height: 24),

          // ---- 一覧 ----
          Expanded(
            child: unitsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '読み込みエラー: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (units) {
                if (units.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 64,
                          color: Colors.white12,
                        ),
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
                      onTap: () =>
                          ref.read(selectedExamUnitIdProvider.notifier).state =
                              unit.id,
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
        content: const Text('この Exam Unit と関連する Claim・Evidence を全て削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(databaseProvider).examUnitsDao.deleteUnit(unitId);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

class _DuplicateCandidatesDialog extends ConsumerStatefulWidget {
  const _DuplicateCandidatesDialog();

  @override
  ConsumerState<_DuplicateCandidatesDialog> createState() =>
      _DuplicateCandidatesDialogState();
}

class _DuplicateCandidatesDialogState
    extends ConsumerState<_DuplicateCandidatesDialog> {
  bool _merging = false;
  bool _undoing = false;
  late Future<List<_PairViewData>> _future;
  late Future<List<UnitMergeHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _historyFuture = _loadHistory();
  }

  Future<List<_PairViewData>> _load() async {
    final db = ref.read(databaseProvider);
    final pairs = await db.examUnitsDao.findDuplicateCandidates(
      limit: 20,
      examProfileId: ref.read(activeExamProfileIdProvider),
    );
    final result = <_PairViewData>[];
    for (final pair in pairs) {
      final left = await db.examUnitsDao.getUnitMergeSummary(pair.left.id);
      final right = await db.examUnitsDao.getUnitMergeSummary(pair.right.id);
      result.add(_PairViewData(pair: pair, left: left, right: right));
    }
    return result;
  }

  Future<List<UnitMergeHistoryEntry>> _loadHistory() {
    return ref
        .read(databaseProvider)
        .examUnitsDao
        .getRecentMergeHistory(limit: 10);
  }

  Future<void> _merge({
    required int parentUnitId,
    required int childUnitId,
  }) async {
    setState(() => _merging = true);
    try {
      final result = await ref
          .read(databaseProvider)
          .examUnitsDao
          .mergeUnits(parentUnitId: parentUnitId, childUnitId: childUnitId);
      setState(() {
        _future = _load();
        _historyFuture = _loadHistory();
      });
      ref.read(selectedExamUnitIdProvider.notifier).state = parentUnitId;
      ref.read(selectedClaimIdProvider.notifier).state = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '統合完了: claims ${result.movedClaimIds.length}件 / evidence ${result.movedEvidenceCount}件 を移動',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _merging = false);
    }
  }

  Future<void> _undo() async {
    setState(() => _undoing = true);
    try {
      final parentId = await ref
          .read(databaseProvider)
          .examUnitsDao
          .undoLatestMerge();
      setState(() {
        _future = _load();
        _historyFuture = _loadHistory();
      });
      if (parentId != null) {
        ref.read(selectedExamUnitIdProvider.notifier).state = parentId;
      }
      ref.read(selectedClaimIdProvider.notifier).state = null;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('直近の統合をUndoしました')));
      }
    } finally {
      if (mounted) setState(() => _undoing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 980,
        height: 680,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<_PairViewData>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? const <_PairViewData>[];
              if (items.isEmpty) {
                return Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          '重複候補（上位20件）',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Expanded(
                      child: Center(child: Text('重複候補は見つかりませんでした')),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        '重複候補（上位20件）',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_merging)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<UnitMergeHistoryEntry>>(
                    future: _historyFuture,
                    builder: (context, historySnapshot) {
                      final history =
                          historySnapshot.data ??
                          const <UnitMergeHistoryEntry>[];
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF1A1D23),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                history.isEmpty
                                    ? '統合履歴なし'
                                    : '履歴: ${history.take(3).map((h) => '${h.parentId}<-${h.childId}${h.undoneAt != null ? '(undo)' : ''}').join(' / ')}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: (_undoing || history.isEmpty)
                                  ? null
                                  : _undo,
                              child: _undoing
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Undo'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return _DuplicatePairCard(
                          data: item,
                          onMergeToLeft: _merging
                              ? null
                              : () => _merge(
                                  parentUnitId: item.pair.left.id,
                                  childUnitId: item.pair.right.id,
                                ),
                          onMergeToRight: _merging
                              ? null
                              : () => _merge(
                                  parentUnitId: item.pair.right.id,
                                  childUnitId: item.pair.left.id,
                                ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PairViewData {
  const _PairViewData({
    required this.pair,
    required this.left,
    required this.right,
  });
  final UnitDuplicateCandidate pair;
  final UnitMergeSummary left;
  final UnitMergeSummary right;
}

class _DuplicatePairCard extends StatelessWidget {
  const _DuplicatePairCard({
    required this.data,
    required this.onMergeToLeft,
    required this.onMergeToRight,
  });

  final _PairViewData data;
  final VoidCallback? onMergeToLeft;
  final VoidCallback? onMergeToRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1E2128),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '類似度 ${(data.pair.score * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.pair.overlapTokens.join(', '),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _UnitCompareCard(
                  unit: data.pair.left,
                  summary: data.left,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UnitCompareCard(
                  unit: data.pair.right,
                  summary: data.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: onMergeToLeft,
                child: Text('「${data.pair.left.title}」へ統合'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: onMergeToRight,
                child: Text('「${data.pair.right.title}」へ統合'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitCompareCard extends StatelessWidget {
  const _UnitCompareCard({required this.unit, required this.summary});
  final ExamUnit unit;
  final UnitMergeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unit.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'claims=${summary.claimCount} / evidence=${summary.evidenceCount} / conflicts=${summary.conflictCount} / audit=${summary.auditStatus}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
