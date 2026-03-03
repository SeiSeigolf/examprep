import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../db/database.dart';
import '../../../db/database.provider.dart';

class UnitReviewSettings {
  const UnitReviewSettings({
    required this.pointWeight,
    required this.frequency,
    required this.frequencyManualOverride,
  });

  final int pointWeight;
  final int frequency;
  final bool frequencyManualOverride;
}

final unitReviewSettingsProvider =
    StreamProvider.family<UnitReviewSettings, int>((ref, unitId) {
      final db = ref.watch(databaseProvider);
      return db
          .customSelect(
            '''
        SELECT point_weight, frequency, frequency_manual_override
        FROM unit_stats
        WHERE exam_unit_id = ?
        LIMIT 1
        ''',
            variables: [Variable.withInt(unitId)],
            readsFrom: {db.unitStats},
          )
          .watchSingleOrNull()
          .map(
            (row) => UnitReviewSettings(
              pointWeight: row?.read<int>('point_weight') ?? 1,
              frequency: row?.read<int>('frequency') ?? 1,
              frequencyManualOverride:
                  (row?.read<int>('frequency_manual_override') ?? 0) == 1,
            ),
          );
    });

final saveUnitReviewSettingsProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return ({
    required int examUnitId,
    required int pointWeight,
    required int frequency,
    required bool frequencyManualOverride,
  }) async {
    await db
        .into(db.unitStats)
        .insertOnConflictUpdate(
          UnitStatsCompanion.insert(
            examUnitId: examUnitId,
            pointWeight: Value(pointWeight),
            frequency: Value(frequency),
            frequencyManualOverride: Value(frequencyManualOverride),
            updatedAt: Value(DateTime.now()),
          ),
        );

    await db.sourcesDao.recalculatePastExamFrequency();
  };
});
