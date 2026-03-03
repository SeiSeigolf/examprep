import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

/// ソース管理画面で選択中のソース ID（null = 未選択）
final selectedSourceIdProvider = StateProvider<int?>((ref) => null);

/// 選択中ソースのセグメント一覧（ページ順）
final segmentsForSourceProvider =
    StreamProvider.family<List<SourceSegment>, int>((ref, sourceId) {
  return ref.watch(databaseProvider).sourcesDao.watchSegmentsForSource(sourceId);
});
