import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/exam_profile.provider.dart';

class ActiveExamProfileBadge extends ConsumerWidget {
  const ActiveExamProfileBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(selectedExamProfileProvider);
    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () =>
              ref.read(activeExamProfileIdProvider.notifier).state = null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3440),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_alt, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  '現在の試験: ${profile.examName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.close, size: 12, color: Colors.white30),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
