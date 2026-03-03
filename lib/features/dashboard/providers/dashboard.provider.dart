import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/daos/dashboard_dao.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

/// 統計カード用（ソース数・総ページ・Exam Unit数・Claim数）
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  return ref.watch(databaseProvider).dashboardDao.watchStats();
});

/// 信頼度の分布（high / medium / low の件数）
final confidenceDistributionProvider =
    StreamProvider<List<ConfidenceCount>>((ref) {
  return ref
      .watch(databaseProvider)
      .dashboardDao
      .watchConfidenceDistribution();
});

/// 直近 5件の Exam Unit（updatedAt 降順）
final recentExamUnitsProvider = StreamProvider<List<ExamUnit>>((ref) {
  return ref.watch(databaseProvider).dashboardDao.watchRecentExamUnits(5);
});

/// 直近 5件の取り込みソース（importedAt 降順）
final recentSourcesProvider = StreamProvider<List<Source>>((ref) {
  return ref.watch(databaseProvider).dashboardDao.watchRecentSources(5);
});
