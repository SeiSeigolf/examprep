import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/daos/search_dao.dart';
import '../../db/database.provider.dart';

/// 現在の検索クエリ（空文字 = 検索していない）
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 検索結果（クエリが空の場合は空リスト）
final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return [];
  return ref.read(databaseProvider).searchDao.search(query);
});
