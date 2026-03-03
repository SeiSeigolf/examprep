import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/daos/dashboard_dao.dart';
import '../../../db/database.dart';
import '../../audit/providers/audit.provider.dart';
import '../providers/dashboard.provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- ヘッダー ----
          Text(
            'ダッシュボード',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'ExamOS — 医学部期末テスト最適化システム',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 24),

          // ---- 統計カード ----
          const _StatsRow(),
          const SizedBox(height: 20),

          // ---- Coverage サマリー ----
          const _CoverageSummaryCard(),
          const SizedBox(height: 20),

          // ---- 最近のアクティビティ + 信頼度の分布 ----
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(flex: 3, child: _RecentActivityCard()),
                SizedBox(width: 16),
                Expanded(flex: 2, child: _ConfidenceDistributionCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 統計カード行
// ============================================================

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    final stats = statsAsync.valueOrNull ??
        const DashboardStats(
          sourceCount: 0,
          totalPages: 0,
          examUnitCount: 0,
          claimCount: 0,
        );

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.folder_open_outlined,
            label: '取り込みソース数',
            value: '${stats.sourceCount}',
            color: const Color(0xFF4A90D9),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.description_outlined,
            label: '総ページ数',
            value: '${stats.totalPages}',
            color: const Color(0xFF50C878),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.library_books_outlined,
            label: 'Exam Unit 数',
            value: '${stats.examUnitCount}',
            color: const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.format_list_bulleted,
            label: 'Claim 数',
            value: '${stats.claimCount}',
            color: const Color(0xFF9C27B0),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Coverage Audit サマリー
// ============================================================

class _CoverageSummaryCard extends ConsumerWidget {
  const _CoverageSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverageAsync = ref.watch(coverageProvider);

    return _SectionCard(
      title: 'Coverage Audit サマリー',
      icon: Icons.rule_outlined,
      child: coverageAsync.when(
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (results) {
          if (results.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'ソースがまだ取り込まれていません',
                style: TextStyle(color: Colors.white38),
              ),
            );
          }

          final total = results.length;
          final covered =
              results.where((r) => r.auditStatus == 'covered').length;
          final uncovered =
              results.where((r) => r.auditStatus == 'uncovered').length;
          final conflict =
              results.where((r) => r.auditStatus == 'conflict').length;
          final pct = total > 0 ? covered / total : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    '${(pct * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: const Color(0xFF2D3440),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF4CAF50),
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _CoverageStat(
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF4CAF50),
                    label: 'Covered',
                    count: covered,
                  ),
                  const SizedBox(width: 28),
                  _CoverageStat(
                    icon: Icons.radio_button_unchecked,
                    color: const Color(0xFF607D8B),
                    label: 'Uncovered',
                    count: uncovered,
                  ),
                  const SizedBox(width: 28),
                  _CoverageStat(
                    icon: Icons.warning_amber_outlined,
                    color: const Color(0xFFFF9800),
                    label: 'Conflict',
                    count: conflict,
                  ),
                  const Spacer(),
                  Text(
                    '全 $total セグメント',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoverageStat extends StatelessWidget {
  const _CoverageStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 最近のアクティビティ
// ============================================================

class _RecentActivityCard extends ConsumerWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentUnitsAsync = ref.watch(recentExamUnitsProvider);
    final recentSourcesAsync = ref.watch(recentSourcesProvider);

    return _SectionCard(
      title: '最近のアクティビティ',
      icon: Icons.history,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SubSectionLabel(label: 'Exam Units'),
          const SizedBox(height: 6),
          recentUnitsAsync.when(
            loading: () => const _LoadingRow(),
            error: (_, __) => const SizedBox.shrink(),
            data: (units) => units.isEmpty
                ? const _EmptyHint('まだ作成されていません')
                : Column(
                    children: units
                        .map((u) => _RecentUnitRow(unit: u))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          const _SubSectionLabel(label: 'ソース'),
          const SizedBox(height: 6),
          recentSourcesAsync.when(
            loading: () => const _LoadingRow(),
            error: (_, __) => const SizedBox.shrink(),
            data: (srcs) => srcs.isEmpty
                ? const _EmptyHint('まだ取り込まれていません')
                : Column(
                    children: srcs
                        .map((s) => _RecentSourceRow(source: s))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecentUnitRow extends StatelessWidget {
  const _RecentUnitRow({required this.unit});
  final ExamUnit unit;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (unit.confidenceLevel) {
      'high' => const Color(0xFF4CAF50),
      'low' => const Color(0xFF607D8B),
      _ => const Color(0xFFFF9800),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              unit.title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            unit.unitType,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RecentSourceRow extends StatelessWidget {
  const _RecentSourceRow({required this.source});
  final Source source;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, size: 14, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              source.fileName,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (source.pageCount != null)
            Text(
              '${source.pageCount}p',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 信頼度の分布
// ============================================================

class _ConfidenceDistributionCard extends ConsumerWidget {
  const _ConfidenceDistributionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distAsync = ref.watch(confidenceDistributionProvider);

    return _SectionCard(
      title: '信頼度の分布',
      icon: Icons.bar_chart,
      child: distAsync.when(
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (dist) {
          int countFor(String level) => dist
              .firstWhere((c) => c.level == level,
                  orElse: () => ConfidenceCount(level: level, count: 0))
              .count;

          final high = countFor('high');
          final medium = countFor('medium');
          final low = countFor('low');
          final total = high + medium + low;

          if (total == 0) {
            return const _EmptyHint('Exam Unit がまだありません');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConfidenceBar(
                label: 'High',
                count: high,
                total: total,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 14),
              _ConfidenceBar(
                label: 'Medium',
                count: medium,
                total: total,
                color: const Color(0xFFFF9800),
              ),
              const SizedBox(height: 14),
              _ConfidenceBar(
                label: 'Low',
                count: low,
                total: total,
                color: const Color(0xFF607D8B),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '合計 $total',
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: const Color(0xFF2D3440),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 16,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 共通ヘルパーウィジェット
// ============================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 15,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF2D3440), height: 1),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 32,
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
