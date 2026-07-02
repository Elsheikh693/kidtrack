import 'package:flutter/material.dart';
import 'journal_meta.dart';

/// Small titled header used above the homework / notes blocks.
class JournalSectionHeader extends StatelessWidget {
  const JournalSectionHeader({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: kJInk),
          ),
        ],
      ),
    );
  }
}
