import 'package:drift/native.dart';
import 'package:exam_os/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _makeInMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;

  setUp(() {
    db = _makeInMemoryDb();
  });

  tearDown(() => db.close());

  test('sources に insert → watch で取得できる', () async {
    await db.sourcesDao.insertSource(
      SourcesCompanion.insert(fileName: 'test.pdf', filePath: '/tmp/test.pdf'),
    );

    final sources = await db.sourcesDao.watchAllSources().first;
    expect(sources.length, 1);
    expect(sources.first.fileName, 'test.pdf');
  });

  test('source を削除すると一覧から消える', () async {
    final id = await db.sourcesDao.insertSource(
      SourcesCompanion.insert(
          fileName: 'delete_me.pdf', filePath: '/tmp/delete_me.pdf'),
    );

    await db.sourcesDao.deleteSource(id);
    final sources = await db.sourcesDao.watchAllSources().first;
    expect(sources, isEmpty);
  });
}
