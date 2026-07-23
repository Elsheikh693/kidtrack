import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../../index/index_main.dart';

const _slate = PdfColor.fromInt(0xFF64748B);
const _ink = PdfColor.fromInt(0xFF1E293B);
const _line = PdfColor.fromInt(0xFFE2E8F0);
const _green = PdfColor.fromInt(0xFF16A34A);

Future<void> shareFinancialReportPdf(FinancialReportController c) async {
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
        _summary(c, currency, bold, regular),
        pw.SizedBox(height: 16),
        pw.Text('report_financial_history'.tr,
            style: pw.TextStyle(font: bold, fontSize: 12, color: _ink)),
        pw.SizedBox(height: 8),
        _table(c, currency, bold, regular),
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
    filename: 'financial-${c.childName}.pdf',
  );
}

pw.Widget _header(FinancialReportController c, pw.ImageProvider? logo,
    pw.Font bold, pw.Font regular) {
  final nursery = c.nurseryName.trim().isEmpty ? 'KidTrack' : c.nurseryName;
  return pw.Row(
    children: [
      pw.Container(
        width: 44,
        height: 44,
        decoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFDCFCE7),
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
            pw.Text('report_financial_title'.tr,
                style:
                    pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
          ],
        ),
      ),
      pw.Text(c.childName,
          style: pw.TextStyle(font: bold, fontSize: 13, color: _ink)),
    ],
  );
}

pw.Widget _summary(FinancialReportController c, String currency, pw.Font bold,
    pw.Font regular) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFFF8FAFC),
      borderRadius: pw.BorderRadius.circular(14),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('report_financial_total_paid'.tr,
                style:
                    pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
            pw.Text('${c.totalPaid.value.toStringAsFixed(0)} $currency',
                style: pw.TextStyle(font: bold, fontSize: 24, color: _green)),
          ],
        ),
        pw.Text(
          'report_financial_payments'.tr + ': ${c.paymentsCount.value}',
          style: pw.TextStyle(font: regular, fontSize: 11, color: _slate),
        ),
      ],
    ),
  );
}

pw.Widget _table(FinancialReportController c, String currency, pw.Font bold,
    pw.Font regular) {
  final rows = <pw.Widget>[];
  final items = c.items;
  for (var i = 0; i < items.length; i++) {
    final t = items[i];
    rows.add(pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
                t.categoryName.trim().isEmpty
                    ? 'report_financial_other'.tr
                    : t.categoryName.trim(),
                style: pw.TextStyle(font: bold, fontSize: 10, color: _ink)),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(FinancialReportController.formatDate(t.date),
                style:
                    pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text('${t.amount.toStringAsFixed(0)} $currency',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(font: bold, fontSize: 10, color: _green)),
          ),
        ],
      ),
    ));
    if (i != items.length - 1) {
      rows.add(pw.Divider(height: 1, color: const PdfColor.fromInt(0xFFF1F5F9)));
    }
  }
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Column(children: rows),
  );
}
