import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

/// Exam Unit 一覧（更新日時降順）
final examUnitsListProvider = StreamProvider<List<ExamUnit>>((ref) {
  return ref.watch(databaseProvider).examUnitsDao.watchAll();
});

/// 詳細画面を表示する Exam Unit の ID（null = 一覧表示）
final selectedExamUnitIdProvider = StateProvider<int?>((ref) => null);

/// Exam Unit ごとの Claim 件数（unitId → count）
final claimCountsProvider = StreamProvider<Map<int, int>>((ref) =>
    ref.watch(databaseProvider).claimsDao.watchClaimCountsPerUnit());
