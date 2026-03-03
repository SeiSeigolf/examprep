import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/daos/audit_dao.dart';
import '../../../db/database.provider.dart';

/// 全セグメントのカバレッジ監視
final coverageProvider =
    StreamProvider<List<SegmentCoverageResult>>((ref) {
  return ref.watch(databaseProvider).auditDao.watchCoverage();
});

/// フィルター状態: 'all' | 'covered' | 'uncovered' | 'conflict'
final auditFilterProvider = StateProvider<String>((ref) => 'all');
