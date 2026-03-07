import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.provider.dart';

class ExamProfileOption {
  const ExamProfileOption({
    required this.id,
    required this.examName,
    required this.createdAt,
  });

  final int id;
  final String examName;
  final DateTime createdAt;
}

final activeExamProfileIdProvider = StateProvider<int?>((ref) => null);

final recentExamProfilesProvider = StreamProvider<List<ExamProfileOption>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return db
      .customSelect('''
        SELECT id, exam_name, created_at
        FROM exam_profiles
        ORDER BY id DESC
        LIMIT 10
        ''')
      .watch()
      .map(
        (rows) => rows
            .map(
              (r) => ExamProfileOption(
                id: r.read<int>('id'),
                examName: r.read<String>('exam_name'),
                createdAt:
                    DateTime.tryParse(r.read<String>('created_at')) ??
                    DateTime.fromMillisecondsSinceEpoch(0),
              ),
            )
            .toList(),
      );
});

final selectedExamProfileProvider =
    FutureProvider.autoDispose<ExamProfileOption?>((ref) async {
      final id = ref.watch(activeExamProfileIdProvider);
      if (id == null) return null;
      final db = ref.watch(databaseProvider);
      final row = await db
          .customSelect(
            '''
        SELECT id, exam_name, created_at
        FROM exam_profiles
        WHERE id = ?
        ''',
            variables: [Variable.withInt(id)],
          )
          .getSingleOrNull();
      if (row == null) return null;
      return ExamProfileOption(
        id: row.read<int>('id'),
        examName: row.read<String>('exam_name'),
        createdAt:
            DateTime.tryParse(row.read<String>('created_at')) ?? DateTime(0),
      );
    });
