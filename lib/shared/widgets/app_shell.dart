import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation.provider.dart';
import '../providers/search.provider.dart';
import '../../db/daos/search_dao.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/ingestion/presentation/sources_page.dart';
import '../../features/ingestion/providers/selected_source.provider.dart';
import '../../features/exam_units/presentation/exam_units_page.dart';
import '../../features/exam_units/providers/exam_units.provider.dart';
import '../../features/exam_units/providers/claims.provider.dart';
import '../../features/audit/presentation/audit_page.dart';
import '../../features/review_queue/presentation/review_queue_page.dart';
import '../../features/study_plan/presentation/study_plan_page.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDestinationProvider);

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            selected: selected,
            onSelect: (d) {
              ref.read(selectedDestinationProvider.notifier).state = d;
            },
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _body(selected)),
        ],
      ),
    );
  }

  Widget _body(AppDestination dest) => switch (dest) {
    AppDestination.dashboard => const DashboardPage(),
    AppDestination.sources => const SourcesPage(),
    AppDestination.examUnits => const ExamUnitsPage(),
    AppDestination.reviewQueue => const ReviewQueuePage(),
    AppDestination.coverageAudit => const AuditPage(),
    AppDestination.studyPlan => const StudyPlanPage(),
  };
}

// ============================================================
// Sidebar
// ============================================================

class _Sidebar extends ConsumerStatefulWidget {
  const _Sidebar({required this.selected, required this.onSelect});

  final AppDestination selected;
  final ValueChanged<AppDestination> onSelect;

  @override
  ConsumerState<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<_Sidebar> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _navigate(SearchResult result) {
    _clearSearch();
    switch (result.type) {
      case 'examUnit':
        ref.read(selectedDestinationProvider.notifier).state =
            AppDestination.examUnits;
        ref.read(selectedExamUnitIdProvider.notifier).state = result.id;
      case 'claim':
        ref.read(selectedDestinationProvider.notifier).state =
            AppDestination.examUnits;
        if (result.parentId != null) {
          ref.read(selectedExamUnitIdProvider.notifier).state =
              result.parentId!;
        }
        ref.read(selectedClaimIdProvider.notifier).state = result.id;
      case 'segment':
        ref.read(selectedDestinationProvider.notifier).state =
            AppDestination.sources;
        if (result.parentId != null) {
          ref.read(selectedSourceIdProvider.notifier).state = result.parentId!;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final isSearching = query.isNotEmpty;

    return SizedBox(
      width: 200,
      child: Container(
        color: const Color(0xFF1A1D23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- ロゴ ----
            const _AppLogo(),
            const Divider(height: 1),

            // ---- 検索バー ----
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: SizedBox(
                height: 34,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '検索...',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 15,
                      color: Colors.white38,
                    ),
                    suffixIcon: isSearching
                        ? GestureDetector(
                            onTap: _clearSearch,
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white38,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF2D3440),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 0,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 0,
                    ),
                  ),
                  onChanged: (v) {
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(
                      const Duration(milliseconds: 300),
                      () => ref.read(searchQueryProvider.notifier).state = v,
                    );
                  },
                ),
              ),
            ),

            // ---- ナビ or 検索結果 ----
            Expanded(
              child: isSearching
                  ? _SearchResultsList(onNavigate: _navigate)
                  : _NavList(
                      selected: widget.selected,
                      onSelect: widget.onSelect,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- ナビゲーションリスト ----

class _NavList extends StatelessWidget {
  const _NavList({required this.selected, required this.onSelect});

  final AppDestination selected;
  final ValueChanged<AppDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        _NavItem(
          icon: Icons.dashboard_outlined,
          label: 'ダッシュボード',
          dest: AppDestination.dashboard,
          selected: selected,
          onTap: onSelect,
        ),
        _NavItem(
          icon: Icons.folder_open_outlined,
          label: 'ソース管理',
          dest: AppDestination.sources,
          selected: selected,
          onTap: onSelect,
        ),
        _NavItem(
          icon: Icons.library_books_outlined,
          label: 'Exam Units',
          dest: AppDestination.examUnits,
          selected: selected,
          onTap: onSelect,
        ),
        _NavItem(
          icon: Icons.rule_outlined,
          label: 'Coverage Audit',
          dest: AppDestination.coverageAudit,
          selected: selected,
          onTap: onSelect,
        ),
        _NavItem(
          icon: Icons.playlist_add_check_circle_outlined,
          label: 'Review Queue',
          dest: AppDestination.reviewQueue,
          selected: selected,
          onTap: onSelect,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _NavItem(
          icon: Icons.calendar_today_outlined,
          label: '学習プラン',
          dest: AppDestination.studyPlan,
          selected: selected,
          onTap: onSelect,
        ),
      ],
    );
  }
}

// ---- 検索結果リスト ----

class _SearchResultsList extends ConsumerWidget {
  const _SearchResultsList({required this.onNavigate});

  final ValueChanged<SearchResult> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (results) {
        if (results.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '結果なし',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: results.length,
          itemBuilder: (context, i) =>
              _SearchResultTile(result: results[i], onTap: onNavigate),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result, required this.onTap});

  final SearchResult result;
  final ValueChanged<SearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (result.type) {
      'examUnit' => (Icons.library_books_outlined, const Color(0xFF4A90D9)),
      'claim' => (Icons.format_list_bulleted, const Color(0xFFFF9800)),
      _ => (Icons.description_outlined, const Color(0xFF607D8B)),
    };

    return InkWell(
      onTap: () => onTap(result),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ロゴ
// ============================================================

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        children: [
          Icon(
            Icons.biotech,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            'ExamOS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Nav Item
// ============================================================

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.dest,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AppDestination dest;
  final AppDestination selected;
  final ValueChanged<AppDestination> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = dest == selected;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.white54;

    return InkWell(
      onTap: () => onTap(dest),
      child: Container(
        color: isSelected ? const Color(0xFF2D3440) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
