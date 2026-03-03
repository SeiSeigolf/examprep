import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppDestination {
  dashboard,
  sources,
  examUnits,
  reviewQueue,
  coverageAudit,
  studyPlan,
}

final selectedDestinationProvider = StateProvider<AppDestination>(
  (ref) => AppDestination.dashboard,
);
