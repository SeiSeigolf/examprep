import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

final sourcesListProvider = StreamProvider<List<Source>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.sourcesDao.watchAllSources();
});
