// import '../../../../../index/index_main.dart';
// import '../controller.dart';
//
// class ImportantAlertsSection extends StatelessWidget {
//   const ImportantAlertsSection({super.key, required this.controller});
//   final ParentDashboardController controller;
//
//   @override
//   Widget build(BuildContext context) {
//     final alerts = controller.importantAlerts;
//     if (alerts.isEmpty) return const SizedBox.shrink();
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: alerts.map((a) => _AlertBanner(alert: a)).toList(),
//       ),
//     );
//   }
// }
//
// class _AlertBanner extends StatelessWidget {
//   const _AlertBanner({required this.alert});
//   final ParentAlert alert;
//
//   Color get _color {
//     switch (alert.type) {
//       case 'fees_due':         return const Color(0xFFD97706);
//       case 'child_health':     return const Color(0xFFDC2626);
//       case 'parent_approval':  return const Color(0xFF2563EB);
//       default:                 return const Color(0xFF7C3AED);
//     }
//   }
//
//   IconData get _icon {
//     switch (alert.type) {
//       case 'fees_due':         return Icons.warning_amber_rounded;
//       case 'child_health':     return Icons.local_hospital_rounded;
//       case 'parent_approval':  return Icons.campaign_rounded;
//       default:                 return Icons.info_rounded;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//       decoration: BoxDecoration(
//         color: _color.withValues(alpha: 0.07),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _color.withValues(alpha: 0.3)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               color: _color.withValues(alpha: 0.12),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(_icon, color: _color, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   alert.title,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: _color,
//                   ),
//                 ),
//                 if (alert.subtitle != null) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     alert.subtitle!,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: _color.withValues(alpha: 0.75),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           Icon(
//             Icons.arrow_back_ios_new_rounded,
//             size: 13,
//             color: _color.withValues(alpha: 0.5),
//           ),
//         ],
//       ),
//     );
//   }
// }
