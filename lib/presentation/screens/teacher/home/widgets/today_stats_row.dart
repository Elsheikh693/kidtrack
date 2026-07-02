// import 'package:flutter/material.dart';
//
// class TodayStatsRow extends StatelessWidget {
//   const TodayStatsRow({
//     super.key,
//     required this.present,
//     required this.total,
//     required this.classroomName,
//   });
//
//   final int present;
//   final int total;
//   final String classroomName;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           _StatCard(
//             label: 'حاضرون اليوم',
//             value: '$present',
//             icon: Icons.how_to_reg_rounded,
//             color: const Color(0xFF16A34A),
//           ),
//           const SizedBox(width: 12),
//           _StatCard(
//             label: 'إجمالي الفصل',
//             value: '$total',
//             icon: Icons.groups_rounded,
//             color: const Color(0xFF0284C7),
//           ),
//           const SizedBox(width: 12),
//           _StatCard(
//             label: 'الفصل',
//             value: classroomName.isEmpty ? '—' : classroomName,
//             icon: Icons.school_rounded,
//             color: const Color(0xFF7C3AED),
//             valueSmall: true,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatCard extends StatelessWidget {
//   const _StatCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//     this.valueSmall = false,
//   });
//
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final bool valueSmall;
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: color.withValues(alpha: 0.15),
//             width: 1.2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: color.withValues(alpha: 0.08),
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: color, size: 20),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 color: color,
//                 fontSize: valueSmall ? 13 : 22,
//                 fontWeight: FontWeight.w800,
//                 height: 1,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 3),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
