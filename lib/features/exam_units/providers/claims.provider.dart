import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/daos/claims_dao.dart';
import '../../../db/database.provider.dart';

/// 指定 Exam Unit の Claim 一覧
final claimsForUnitProvider =
    StreamProvider.family<List<Claim>, int>((ref, unitId) {
  return ref.watch(databaseProvider).claimsDao.watchClaimsForUnit(unitId);
});

/// 詳細画面で選択中の Claim ID
final selectedClaimIdProvider = StateProvider<int?>((ref) => null);

/// 選択中 Claim の Evidence 一覧（join済み）
final evidenceForClaimProvider =
    StreamProvider.family<List<EvidenceWithSource>, int>((ref, claimId) {
  return ref.watch(databaseProvider).claimsDao.watchEvidenceForClaim(claimId);
});

/// Claim 追加ダイアログ用: 全セグメント + ソース名
final allSegmentsWithSourceProvider =
    StreamProvider<List<SegmentWithSource>>((ref) {
  return ref.watch(databaseProvider).claimsDao.watchAllSegmentsWithSource();
});
