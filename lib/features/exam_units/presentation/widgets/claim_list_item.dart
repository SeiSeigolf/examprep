import 'package:flutter/material.dart';
import '../../../../db/database.dart';
import 'confidence_badge.dart';

class ClaimListItem extends StatelessWidget {
  const ClaimListItem({
    super.key,
    required this.claim,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final Claim claim;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2D3A4D)
            : const Color(0xFF1E2128),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF4A90D9).withAlpha(150)
              : Colors.white12,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.content,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ConfidenceBadge(claim.confidenceLevel),
                        const SizedBox(width: 6),
                        if (claim.createdBy == 'ai')
                          const _AiBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: Colors.white24),
                onPressed: onDelete,
                tooltip: '削除',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.purple.withAlpha(80)),
      ),
      child: const Text(
        'AI',
        style: TextStyle(
            fontSize: 10, color: Colors.purpleAccent, fontWeight: FontWeight.w600),
      ),
    );
  }
}
