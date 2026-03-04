import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import '../providers/study_plan.provider.dart';
import '../services/study_plan_exporter.dart';

class StudyPlanPage extends ConsumerStatefulWidget {
  const StudyPlanPage({super.key});

  @override
  ConsumerState<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends ConsumerState<StudyPlanPage> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final path = await StudyPlanExporter.export(
        ref.read(databaseProvider),
        topN: ref.read(studyPlanTopNProvider),
        mode: ref.read(cramModeProvider),
        examDate: ref.read(examDateProvider),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Markdownを保存しました: $path')));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- ヘッダー ----
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '学習プラン',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '信頼度の低いユニットから優先的に学習しましょう',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white38),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _exporting ? null : _export,
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

        // ---- デイリー目標スライダー ----
        const _DailyGoalSlider(),
        const SizedBox(height: 8),
        const _CramModeBar(),
        const SizedBox(height: 8),

        // ---- 推奨リスト ----
        Expanded(child: _RecommendedList()),
      ],
    );
  }
}

class _CramModeBar extends ConsumerWidget {
  const _CramModeBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(cramModeProvider);
    final examDate = ref.watch(examDateProvider);
    final topN = ref.watch(studyPlanTopNProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2D3440)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, size: 18, color: Colors.white54),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: examDate ?? now.add(const Duration(days: 7)),
                firstDate: now.subtract(const Duration(days: 1)),
                lastDate: now.add(const Duration(days: 365 * 2)),
              );
              if (picked != null) {
                ref.read(examDateProvider.notifier).state = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  9,
                );
              }
            },
            icon: const Icon(Icons.calendar_today, size: 14),
            label: Text(
              examDate == null
                  ? '試験日を設定'
                  : '試験日: ${examDate.toLocal().toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          ChoiceChip(
            label: const Text('Off'),
            selected: mode == CramMode.off,
            onSelected: (_) =>
                ref.read(cramModeProvider.notifier).state = CramMode.off,
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('72h'),
            selected: mode == CramMode.h72,
            onSelected: (_) =>
                ref.read(cramModeProvider.notifier).state = CramMode.h72,
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('7d'),
            selected: mode == CramMode.d7,
            onSelected: (_) =>
                ref.read(cramModeProvider.notifier).state = CramMode.d7,
          ),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: topN,
            dropdownColor: const Color(0xFF1E2530),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            items: const [10, 20, 30, 50]
                .map(
                  (n) => DropdownMenuItem<int>(value: n, child: Text('上位$n件')),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(studyPlanTopNProvider.notifier).state = v;
              }
            },
          ),
        ],
      ),
    );
  }
}

// ---- デイリー目標スライダー ----

class _DailyGoalSlider extends ConsumerWidget {
  const _DailyGoalSlider();

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes分';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h時間' : '$h時間$m分';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(dailyGoalMinutesProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2D3440)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: Colors.white54),
          const SizedBox(width: 10),
          const Text(
            '1日の目標',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Expanded(
            child: Slider(
              value: goal.toDouble(),
              min: 0,
              max: 840,
              divisions: 28, // 30分刻み
              activeColor: const Color(0xFF4A90D9),
              inactiveColor: const Color(0xFF2D3440),
              onChanged: (v) {
                ref.read(dailyGoalMinutesProvider.notifier).state = v.round();
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              _formatMinutes(goal),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- 推奨リスト ----

class _RecommendedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(recommendedUnitsProvider);
    final methodsByKey = ref.watch(studyMethodsByKeyProvider);
    final methodsByUnitType = ref.watch(studyMethodsByUnitTypeProvider);
    final goal = ref.watch(dailyGoalMinutesProvider);

    return unitsAsync.when(
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
                Icon(Icons.checklist_outlined, size: 64, color: Colors.white12),
                SizedBox(height: 16),
                Text(
                  'Exam Unit がまだありません',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          );
        }

        // 目標時間内に収まるユニット数を計算（代表メソッドの推定時間を使用）
        int accumulated = 0;
        final withinBudget = <int>{};
        for (final unit in units) {
          final method = resolveRecommendedMethod(methodsByKey, unit);
          final mins = method?.estimatedMinutes ?? 30;
          if (goal == 0 || accumulated + mins <= goal) {
            withinBudget.add(unit.id);
            accumulated += mins;
          } else {
            break;
          }
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          itemCount: units.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final unit = units[i];
            final methods = methodsByUnitType[unit.unitType] ?? [];
            final inBudget = withinBudget.contains(unit.id);
            return _UnitPlanTile(
              unit: unit,
              methods: methods,
              inBudget: inBudget,
            );
          },
        );
      },
    );
  }
}

// ---- 個別ユニットタイル ----

class _UnitPlanTile extends ConsumerWidget {
  const _UnitPlanTile({
    required this.unit,
    required this.methods,
    required this.inBudget,
  });
  final ExamUnit unit;
  final List<StudyMethod> methods;
  final bool inBudget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: inBudget
              ? const Color(0xFF4A90D9).withAlpha(80)
              : const Color(0xFF2D3440),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 上段: タイトル + 信頼度バッジ ----
            Row(
              children: [
                if (inBudget)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.today_outlined,
                      size: 14,
                      color: Color(0xFF4A90D9),
                    ),
                  ),
                Expanded(
                  child: Text(
                    unit.title,
                    style: TextStyle(
                      color: inBudget ? Colors.white : Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // 信頼度バッジ（タップで3択ダイアログ）
                _ConfidenceBadge(unit: unit),
              ],
            ),

            // ---- 下段: タイプ + 全推奨学習法 ----
            if (methods.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3440),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      unit.unitType,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: methods
                          .map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    size: 11,
                                    color: Color(0xFFFFD54F),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${m.methodName}（${m.estimatedMinutes}分）— ${m.problemFormat}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- 信頼度バッジ（タップで3択ダイアログ） ----

class _ConfidenceBadge extends ConsumerWidget {
  const _ConfidenceBadge({required this.unit});
  final ExamUnit unit;

  static const _confidenceColors = {
    'low': Color(0xFFEF5350),
    'medium': Color(0xFFFF9800),
    'high': Color(0xFF4CAF50),
  };

  static const _confidenceLabels = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
  };

  static const _levels = ['high', 'medium', 'low'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confColor =
        _confidenceColors[unit.confidenceLevel] ?? const Color(0xFF607D8B);
    final confLabel =
        _confidenceLabels[unit.confidenceLevel] ?? unit.confidenceLevel;

    return Tooltip(
      message: '信頼度を変更',
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _showDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: confColor.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: confColor.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                confLabel,
                style: TextStyle(
                  color: confColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 12, color: confColor),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('信頼度を設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _levels.map((level) {
            final color =
                _confidenceColors[level] ?? const Color(0xFF607D8B);
            final label = _confidenceLabels[level] ?? level;
            final isCurrent = unit.confidenceLevel == level;
            return ListTile(
              dense: true,
              leading: Icon(
                isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isCurrent ? color : Colors.white38,
                size: 20,
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: isCurrent ? color : null,
                  fontWeight:
                      isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: isCurrent
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(databaseProvider)
                          .examUnitsDao
                          .updateConfidenceLevel(unit.id, level);
                    },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
