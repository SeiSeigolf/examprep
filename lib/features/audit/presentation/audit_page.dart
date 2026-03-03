import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/daos/audit_dao.dart';
import '../providers/audit.provider.dart';
import '../../../shared/providers/navigation.provider.dart';
import '../../exam_units/providers/exam_units.provider.dart';
import 'widgets/coverage_summary_bar.dart';
import 'widgets/segment_coverage_tile.dart';

class AuditPage extends ConsumerWidget {
  const AuditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverageAsync = ref.watch(coverageProvider);
    final filter = ref.watch(auditFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- ヘッダー ----
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coverage Audit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '各ソースセグメントの網羅状況を確認します',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---- サマリーバー ----
        coverageAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (results) => CoverageSummaryBar(results: results),
        ),

        // ---- フィルタータブ ----
        _FilterBar(current: filter),

        // ---- セグメント一覧 ----
        Expanded(
          child: coverageAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('読み込みエラー: $e',
                  style: const TextStyle(color: Colors.redAccent)),
            ),
            data: (results) {
              if (results.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.white12),
                      SizedBox(height: 16),
                      Text(
                        'ソースがまだ取り込まれていません',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                );
              }

              // フィルター適用
              final filtered = filter == 'all'
                  ? results
                  : results
                      .where((r) => r.auditStatus == filter)
                      .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    '"$filter" のセグメントはありません',
                    style: const TextStyle(color: Colors.white38),
                  ),
                );
              }

              // ソースごとにグループ化
              return _GroupedList(
                results: filtered,
                onTapUnit: (unitId) {
                  debugPrint('[Audit] onTapUnit called: unitId=$unitId');
                  // unitId を先にセットしてから destination を変更する。
                  // ExamUnitsPage が初回 build 時に selectedId を参照できる。
                  ref.read(selectedExamUnitIdProvider.notifier).state = unitId;
                  ref.read(selectedDestinationProvider.notifier).state =
                      AppDestination.examUnits;
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---- フィルタータブバー ----

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.current});
  final String current;

  static const _filters = [
    ('all', 'すべて'),
    ('covered', 'Covered'),
    ('uncovered', 'Uncovered'),
    ('conflict', 'Conflict'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: _filters.map((f) {
          final (value, label) = f;
          final isSelected = current == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(auditFilterProvider.notifier).state = value;
              },
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              selectedColor: const Color(0xFF2D5A8E),
              backgroundColor: const Color(0xFF2D3440),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF4A90D9)
                    : Colors.transparent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---- ソースごとグループ表示 ----

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.results, required this.onTapUnit});
  final List<SegmentCoverageResult> results;
  final ValueChanged<int> onTapUnit;

  @override
  Widget build(BuildContext context) {
    // fileName でグループ化
    final grouped = <String, List<SegmentCoverageResult>>{};
    for (final r in results) {
      (grouped[r.fileName] ??= []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: grouped.length,
      itemBuilder: (context, i) {
        final fileName = grouped.keys.elementAt(i);
        final segments = grouped[fileName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ソースヘッダー
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf,
                      size: 14, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${segments.length} ページ',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2E3340)),
            // セグメント一覧
            ...segments.map(
              (r) => Column(
                children: [
                  SegmentCoverageTile(result: r, onTapUnit: onTapUnit),
                  const Divider(
                      height: 1,
                      indent: 16,
                      color: Color(0xFF252830)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
