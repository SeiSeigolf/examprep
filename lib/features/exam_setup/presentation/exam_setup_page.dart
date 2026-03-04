import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import '../providers/exams.provider.dart';
import '../services/coverage_exporter.dart';
import 'widgets/section_dialog.dart';
import 'widgets/pool_dialog.dart';
import 'widgets/section_coverage_card.dart';

class ExamSetupPage extends ConsumerStatefulWidget {
  const ExamSetupPage({super.key});

  @override
  ConsumerState<ExamSetupPage> createState() => _ExamSetupPageState();
}

class _ExamSetupPageState extends ConsumerState<ExamSetupPage> {
  bool _exporting = false;

  Future<void> _export(int examId) async {
    setState(() => _exporting = true);
    try {
      final path = await CoverageExporter.export(
        ref.read(databaseProvider),
        examId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Markdownを保存しました: $path')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エクスポート失敗: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(examsProvider);
    final selectedExamId = ref.watch(selectedExamIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- ヘッダー ----
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '試験設定',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'セクション・出題プールを登録して「これだけ見れば合格」を生成します',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedExamId != null)
                FilledButton.tonalIcon(
                  onPressed: _exporting ? null : () => _export(selectedExamId),
                  icon: _exporting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Markdown出力'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- 左: 試験一覧 ----
              SizedBox(
                width: 240,
                child: _ExamList(
                  examsAsync: examsAsync,
                  selectedId: selectedExamId,
                  onSelect: (id) {
                    ref.read(selectedExamIdProvider.notifier).state = id;
                  },
                ),
              ),
              const VerticalDivider(width: 1),
              // ---- 右: セクション + カバレッジ ----
              Expanded(
                child: selectedExamId == null
                    ? const _NoExamSelected()
                    : _ExamDetail(examId: selectedExamId),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 左ペイン: 試験リスト
// ============================================================

class _ExamList extends ConsumerWidget {
  const _ExamList({
    required this.examsAsync,
    required this.selectedId,
    required this.onSelect,
  });

  final AsyncValue<List<Exam>> examsAsync;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 追加ボタン
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('試験を追加'),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: examsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'エラー: $e',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
            data: (exams) {
              if (exams.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '試験を追加してください',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: exams.length,
                itemBuilder: (context, i) {
                  final exam = exams[i];
                  final isSelected = exam.id == selectedId;
                  return _ExamTile(
                    exam: exam,
                    isSelected: isSelected,
                    onTap: () => onSelect(exam.id),
                    onDelete: () async {
                      final confirmed = await _confirmDelete(
                        context,
                        exam.name,
                      );
                      if (confirmed) {
                        await ref
                            .read(databaseProvider)
                            .examsDao
                            .deleteExam(exam.id);
                        if (selectedId == exam.id) {
                          ref.read(selectedExamIdProvider.notifier).state =
                              null;
                        }
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => _ExamCreateDialog(
        onCreated: (id) => ref.read(selectedExamIdProvider.notifier).state = id,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('試験を削除'),
            content: Text(
              '「$name」とその全セクション・プールを削除しますか？',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('削除'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _ExamTile extends StatelessWidget {
  const _ExamTile({
    required this.exam,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final Exam exam;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? const Color(0xFF2D3440) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (exam.date != null)
                    Text(
                      exam.date!.toLocal().toString().substring(0, 10),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 14),
              color: Colors.white38,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: onDelete,
              tooltip: '削除',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCreateDialog extends ConsumerStatefulWidget {
  const _ExamCreateDialog({required this.onCreated});
  final ValueChanged<int> onCreated;

  @override
  ConsumerState<_ExamCreateDialog> createState() => _ExamCreateDialogState();
}

class _ExamCreateDialogState extends ConsumerState<_ExamCreateDialog> {
  final _nameCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '100');
  DateTime? _date;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final points = int.tryParse(_pointsCtrl.text) ?? 100;
    final id = await ref.read(databaseProvider).examsDao.insertExam(
      ExamsCompanion.insert(
        name: name,
        totalPoints: Value(points),
        date: Value(_date),
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
      widget.onCreated(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('試験を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: '試験名（例: 解剖学期末）'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pointsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '総配点（点）'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white38),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date ?? now.add(const Duration(days: 7)),
                    firstDate: now.subtract(const Duration(days: 1)),
                    lastDate: now.add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(
                  _date == null
                      ? '試験日を選択'
                      : '試験日: ${_date!.toString().substring(0, 10)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _save, child: const Text('追加')),
      ],
    );
  }
}

// ============================================================
// 右ペイン: 試験詳細（セクション + プール + カバレッジ）
// ============================================================

class _NoExamSelected extends StatelessWidget {
  const _NoExamSelected();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.white12),
          SizedBox(height: 16),
          Text(
            '左の一覧から試験を選択するか、新しい試験を追加してください',
            style: TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExamDetail extends ConsumerWidget {
  const _ExamDetail({required this.examId});
  final int examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(sectionsForSelectedExamProvider);
    final coverageAsync = ref.watch(sectionCoverageProvider(examId));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- セクション一覧 ----
          Row(
            children: [
              const Text(
                'セクション',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => SectionDialog(examId: examId),
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('セクション追加', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          sectionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              'エラー: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
            data: (sections) {
              if (sections.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'セクションを追加してください（例: 解剖学、生理学）',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                );
              }
              return Column(
                children: sections
                    .map((s) => _SectionTile(section: s))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2D3440)),
          const SizedBox(height: 16),

          // ---- セクション別カバレッジ ----
          const Text(
            'カバレッジ・保証得点',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          coverageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              'エラー: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
            data: (stats) {
              if (stats.isEmpty) {
                return const Text(
                  'セクションを追加するとカバレッジが表示されます',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                );
              }
              return Column(
                children: stats
                    .map((s) => SectionCoverageCard(stat: s))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends ConsumerWidget {
  const _SectionTile({required this.section});
  final ExamSection section;

  static const _approachColors = {
    '暗記': Color(0xFF7B61FF),
    '理解': Color(0xFF4A90D9),
    '計算': Color(0xFFFF9800),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approachColor =
        _approachColors[section.studyApproach] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D3440)),
      ),
      child: Column(
        children: [
          // セクションヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: approachColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: approachColor.withAlpha(80)),
                  ),
                  child: Text(
                    section.studyApproach,
                    style: TextStyle(
                      color: approachColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${section.points}点',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  color: Colors.white38,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  tooltip: '編集',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => SectionDialog(
                      examId: section.examId,
                      section: section,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 14),
                  color: Colors.white38,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  tooltip: '削除',
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('セクションを削除'),
                        content: Text(
                          '「${section.name}」とその全プールを削除しますか？',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('キャンセル'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('削除'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref
                          .read(databaseProvider)
                          .examsDao
                          .deleteSection(section.id);
                    }
                  },
                ),
              ],
            ),
          ),

          // プール一覧
          _PoolList(section: section),
        ],
      ),
    );
  }
}

class _PoolList extends ConsumerWidget {
  const _PoolList({required this.section});
  final ExamSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolsAsync = ref.watch(
      StreamProvider<List<ExamPool>>(
        (ref) => ref
            .watch(databaseProvider)
            .examsDao
            .watchPoolsForSection(section.id),
      ),
    );

    return poolsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (pools) => Column(
        children: [
          const Divider(height: 1, color: Color(0xFF2D3440)),
          ...pools.map((p) => _PoolTile(pool: p, sectionId: section.id)),
          // プール追加ボタン
          InkWell(
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => PoolDialog(sectionId: section.id),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.add, size: 13, color: Colors.white38),
                  SizedBox(width: 6),
                  Text(
                    '出題プール追加',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PoolTile extends ConsumerWidget {
  const _PoolTile({required this.pool, required this.sectionId});
  final ExamPool pool;
  final int sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      child: Row(
        children: [
          const Icon(
            Icons.format_list_numbered,
            size: 12,
            color: Colors.white38,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              pool.totalItems > 0
                  ? '${pool.description}：全${pool.totalItems}個 / 保証${pool.guaranteedItems}問'
                  : pool.description,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 13),
            color: Colors.white38,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            tooltip: '編集',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => PoolDialog(sectionId: sectionId, pool: pool),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 13),
            color: Colors.white38,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            tooltip: '削除',
            onPressed: () async {
              await ref.read(databaseProvider).examsDao.deletePool(pool.id);
            },
          ),
        ],
      ),
    );
  }
}
