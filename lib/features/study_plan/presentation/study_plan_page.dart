import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';
import '../providers/study_plan.provider.dart';

class StudyPlanPage extends ConsumerWidget {
  const StudyPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                '学習プラン',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '信頼度の低いユニットから優先的に学習しましょう',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---- デイリー目標スライダー ----
        const _DailyGoalSlider(),
        const SizedBox(height: 8),

        // ---- 推奨リスト ----
        Expanded(child: _RecommendedList()),
      ],
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
              min: 30,
              max: 480,
              divisions: 15, // 30分刻み
              activeColor: const Color(0xFF4A90D9),
              inactiveColor: const Color(0xFF2D3440),
              onChanged: (v) {
                ref.read(dailyGoalMinutesProvider.notifier).state =
                    v.round();
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
    final methodsByType = ref.watch(studyMethodsByTypeProvider);
    final goal = ref.watch(dailyGoalMinutesProvider);

    return unitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
                Icon(Icons.checklist_outlined,
                    size: 64, color: Colors.white12),
                SizedBox(height: 16),
                Text(
                  'Exam Unit がまだありません',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          );
        }

        // 目標時間内に収まるユニット数を計算
        int accumulated = 0;
        final withinBudget = <int>{};
        for (final unit in units) {
          final method = methodsByType[unit.unitType];
          final mins = method?.estimatedMinutes ?? 30;
          if (accumulated + mins <= goal) {
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
            final method = methodsByType[unit.unitType];
            final inBudget = withinBudget.contains(unit.id);
            return _UnitPlanTile(
              unit: unit,
              method: method,
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
    required this.method,
    required this.inBudget,
  });
  final ExamUnit unit;
  final StudyMethod? method;
  final bool inBudget;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confColor =
        _confidenceColors[unit.confidenceLevel] ?? const Color(0xFF607D8B);
    final confLabel =
        _confidenceLabels[unit.confidenceLevel] ?? unit.confidenceLevel;

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
                    child: Icon(Icons.today_outlined,
                        size: 14, color: Color(0xFF4A90D9)),
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
                // 信頼度バッジ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: confColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: confColor.withAlpha(80)),
                  ),
                  child: Text(
                    confLabel,
                    style: TextStyle(
                        color: confColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                // 信頼度アップグレードボタン
                if (unit.confidenceLevel != 'high')
                  _UpgradeButton(unit: unit),
              ],
            ),

            // ---- 下段: タイプ + 推奨学習法 ----
            if (method != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3440),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      unit.unitType,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.lightbulb_outline,
                      size: 12, color: Color(0xFFFFD54F)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${method!.methodName}（${method!.estimatedMinutes}分）',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
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

// ---- 信頼度アップグレードボタン ----

class _UpgradeButton extends ConsumerWidget {
  const _UpgradeButton({required this.unit});
  final ExamUnit unit;

  String get _nextLevel =>
      unit.confidenceLevel == 'low' ? 'medium' : 'high';

  String get _nextLabel =>
      unit.confidenceLevel == 'low' ? 'Medium' : 'High';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: '信頼度を $_nextLabel に上げる',
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _showUpgradeDialog(context, ref),
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(Icons.arrow_upward_rounded,
              size: 14, color: Colors.white38),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('信頼度を更新'),
        content: Text(
          '「${unit.title}」の信頼度を $_nextLabel に上げますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(databaseProvider)
                  .examUnitsDao
                  .updateConfidenceLevel(unit.id, _nextLevel);
            },
            child: Text('$_nextLabel に上げる'),
          ),
        ],
      ),
    );
  }
}
