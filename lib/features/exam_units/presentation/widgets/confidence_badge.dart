import 'package:flutter/material.dart';

class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge(this.level, {super.key});
  final String level; // 'high' | 'medium' | 'low'

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      'high' => ('H', const Color(0xFF4CAF50)),
      'low' => ('L', const Color(0xFFEF5350)),
      _ => ('M', const Color(0xFFFFC107)),
    };
    return _Badge(label: label, color: color);
  }
}

class AuditBadge extends StatelessWidget {
  const AuditBadge(this.status, {super.key});
  final String status; // 'covered' | 'uncovered' | 'conflict'

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'covered' => ('Covered', const Color(0xFF4CAF50)),
      'conflict' => ('Conflict', const Color(0xFFFF9800)),
      _ => ('Uncovered', const Color(0xFF607D8B)),
    };
    return _Badge(label: label, color: color);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
