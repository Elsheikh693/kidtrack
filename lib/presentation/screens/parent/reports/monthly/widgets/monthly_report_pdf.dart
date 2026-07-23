import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../../index/index_main.dart';

const _slate = PdfColor.fromInt(0xFF64748B);
const _ink = PdfColor.fromInt(0xFF1E293B);
const _line = PdfColor.fromInt(0xFFE2E8F0);
const _green = PdfColor.fromInt(0xFF16A34A);

PdfColor _rateColor(int rate) =>
    rate >= 90 ? _green : (rate >= 75 ? const PdfColor.fromInt(0xFFD97706) : const PdfColor.fromInt(0xFFDC2626));

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

Future<void> shareMonthlyReportPdf(MonthlyReportController c) async {
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

  final currency = 'currency'.tr;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      textDirection: pw.TextDirection.rtl,
      build: (context) => [
        _header(c, logo, bold, regular),
        pw.SizedBox(height: 20),
        _attendance(c, bold, regular),
        pw.SizedBox(height: 14),
        _evaluation(c, bold, regular),
        pw.SizedBox(height: 14),
        _financial(c, currency, bold, regular),
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
    filename: 'monthly-${c.childName}.pdf',
  );
}

pw.Widget _header(MonthlyReportController c, pw.ImageProvider? logo,
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
            pw.Text('report_monthly_title'.tr,
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
          pw.Text(c.monthLabel,
              style: pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
        ],
      ),
    ],
  );
}

pw.Widget _section(String title, pw.Widget child, pw.Font bold) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 12, color: _ink)),
        pw.SizedBox(height: 8),
        child,
      ],
    ),
  );
}

pw.Widget _attendance(
    MonthlyReportController c, pw.Font bold, pw.Font regular) {
  final rate = c.attendanceRate.value;
  final color = _rateColor(rate);
  return _section(
    'report_attendance_title'.tr,
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('$rate%',
            style: pw.TextStyle(font: bold, fontSize: 26, color: color)),
        pw.Text(
          '${'report_status_present'.tr}: ${c.presentCount.value}   '
          '${'report_status_late'.tr}: ${c.lateCount.value}   '
          '${'report_status_absent'.tr}: ${c.absentCount.value}',
          style: pw.TextStyle(font: regular, fontSize: 10, color: _slate),
        ),
      ],
    ),
    bold,
  );
}

pw.Widget _evaluation(
    MonthlyReportController c, pw.Font bold, pw.Font regular) {
  final rating = c.dominant.value;
  final total = c.evalTotal;
  return _section(
    'report_evaluation_title'.tr,
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
            total == 0 ? 'report_eval_not_assessed'.tr : _ratingLabelKey(rating).tr,
            style: pw.TextStyle(
                font: bold,
                fontSize: 16,
                color: total == 0 ? _slate : _ratingColor(rating))),
        if (total > 0)
          pw.Text(
            'report_eval_assessed_short'.trParams({'n': '$total'}),
            style: pw.TextStyle(font: regular, fontSize: 10, color: _slate),
          ),
      ],
    ),
    bold,
  );
}

pw.Widget _financial(MonthlyReportController c, String currency, pw.Font bold,
    pw.Font regular) {
  return _section(
    'report_financial_title'.tr,
    pw.Text('${c.monthPaid.value.toStringAsFixed(0)} $currency',
        style: pw.TextStyle(font: bold, fontSize: 18, color: _green)),
    bold,
  );
}
