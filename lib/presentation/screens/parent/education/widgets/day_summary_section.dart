import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';
import 'journal_meta.dart';

/// End-of-page recap: counts, overall rating, and skills covered today.
class DaySummarySection extends StatelessWidget {
  const DaySummarySection({super.key, required this.summary});
  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final m = dayOverallMeta(summary.overallEval);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kJBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_rounded, size: 18, color: kJMuted),
              const SizedBox(width: 8),
              Text(
                'parenteduc23_day_summary'.tr,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: kJInk),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatBox(
                value: '${summary.activityCount}',
                label: 'parenteduc23_activities_label'.tr,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 10),
              _StatBox(
                value: '${summary.homeworkDone}/${summary.homeworkTotal}',
                label: 'parenteduc23_homework'.tr,
                color: const Color(0xFF8E44AD),
              ),
              const SizedBox(width: 10),
              _StatBox(
                value: m.label,
                label: 'parenteduc23_overall_eval'.tr,
                color: m.color,
                small: true,
              ),
            ],
          ),
          if (summary.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'parenteduc23_skills_gained'.tr,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: kJInk),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in summary.skills) _SkillChip(label: s),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
    this.small = false,
  });
  final String value;
  final String label;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: small ? 13 : 18,
                  fontWeight: FontWeight.w800,
                  color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: kJMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 13, color: Color(0xFF059669)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
          ),
        ],
      ),
    );
  }
}
