import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppDestination {
  examSetup,
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
