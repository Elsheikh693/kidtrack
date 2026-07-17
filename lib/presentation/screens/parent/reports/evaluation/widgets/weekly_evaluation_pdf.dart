import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../../index/index_main.dart';

const _slate = PdfColor.fromInt(0xFF64748B);
const _ink = PdfColor.fromInt(0xFF1E293B);
const _line = PdfColor.fromInt(0xFFE2E8F0);

PdfColor _ratingColor(EvalLevel r) {
  switch (r) {
    case EvalLevel.excellent:
      return const PdfColor.fromInt(0xFF059669);
    case EvalLevel.needsFollow:
      return const PdfColor.fromInt(0xFF2563EB);
    case EvalLevel.needsAttention:
      return const PdfColor.fromInt(0xFFD97706);
  }
}

String _ratingLabelKey(EvalLevel r) {
  switch (r) {
    case EvalLevel.excellent:
      return 'report_rating_excellent';
    case EvalLevel.needsFollow:
      return 'report_rating_very_good';
    case EvalLevel.needsAttention:
      return 'report_rating_needs_support';
  }
}

Future<void> shareWeeklyEvaluationPdf(WeeklyEvaluationController c) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'),
  );
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  pw.ImageProvider? logo;
  final logoUrl = c.nurseryLogo;
  if (logoUrl != null && logoUrl.trim().isNotEmpty) {
    try {
      logo = await networkImage(logoUrl.trim());
    } catch (_) {
      logo = null;
    }
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      textDirection: pw.TextDirection.rtl,
      build: (context) => [
        _header(c, logo, bold, regular),
        pw.SizedBox(height: 20),
        _summary(c, bold, regular),
        pw.SizedBox(height: 16),
        ..._dayRows(c, bold, regular),
        if (c.insight.value.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF8FAFC),
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: _line),
            ),
            child: pw.Text(c.insight.value,
                style: pw.TextStyle(font: regular, fontSize: 11, color: _ink)),
          ),
        ],
        pw.SizedBox(height: 18),
        pw.Center(
          child: pw.Text('KidTrack',
              style: pw.TextStyle(font: regular, fontSize: 9, color: _slate)),
        ),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'evaluation-${c.childName}.pdf',
  );
}

pw.Widget _header(WeeklyEvaluationController c, pw.ImageProvider? logo,
    pw.Font bold, pw.Font regular) {
  final nursery = c.nurseryName.trim().isEmpty ? 'KidTrack' : c.nurseryName;
  return pw.Row(
    children: [
      pw.Container(
        width: 44,
        height: 44,
        decoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFEDE9FE),
          shape: pw.BoxShape.circle,
        ),
        child: logo != null
            ? pw.ClipOval(
                child:
                    pw.Image(logo, fit: pw.BoxFit.cover, width: 44, height: 44))
            : pw.Center(
                child: pw.Text(nursery.isNotEmpty ? nursery[0] : 'K',
                    style: pw.TextStyle(font: bold, fontSize: 20))),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(nursery, style: pw.TextStyle(font: bold, fontSize: 14)),
            pw.Text('report_evaluation_title'.tr,
                style:
                    pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
          ],
        ),
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(c.childName,
              style: pw.TextStyle(font: bold, fontSize: 13, color: _ink)),
          pw.Text(c.weekRangeLabel,
              style: pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
        ],
      ),
    ],
  );
}

pw.Widget _summary(
    WeeklyEvaluationController c, pw.Font bold, pw.Font regular) {
  final rating = c.dominant.value;
  final color = _ratingColor(rating);
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColor(color.red, color.green, color.blue, 0.08),
      borderRadius: pw.BorderRadius.circular(14),
      border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.3)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(_ratingLabelKey(rating).tr,
            style: pw.TextStyle(font: bold, fontSize: 18, color: color)),
        pw.Text(
          'report_eval_assessed'.trParams({
            'done': '${c.assessedCount.value}',
            'total': '${c.workingDaysCount.value}',
          }),
          style: pw.TextStyle(font: regular, fontSize: 11, color: _slate),
        ),
      ],
    ),
  );
}

List<pw.Widget> _dayRows(
    WeeklyEvaluationController c, pw.Font bold, pw.Font regular) {
  return c.days.map((d) {
    final level = d.level;
    final color = level == null ? _slate : _ratingColor(level);
    final comment = d.assessed
        ? 'report_eval_activities_count'.trParams({'count': '${d.count}'})
        : 'report_eval_not_assessed'.tr;
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _line),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text(d.dayKey.tr,
                style: pw.TextStyle(font: bold, fontSize: 11, color: _ink)),
          ),
          pw.SizedBox(
            width: 62,
            child: pw.Text(level == null ? '—' : _ratingLabelKey(level).tr,
                style: pw.TextStyle(font: bold, fontSize: 10, color: color)),
          ),
          pw.Expanded(
            child: pw.Text(comment,
                style:
                    pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
          ),
        ],
      ),
    );
  }).toList();
}
