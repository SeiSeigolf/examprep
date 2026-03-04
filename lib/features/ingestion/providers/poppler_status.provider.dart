import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/text_extraction/poppler_extractor.dart';

final popplerAvailableProvider = FutureProvider<bool>((ref) async {
  return PopplerExtractor.isAvailable();
});
