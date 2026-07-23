import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../index/index_main.dart';

/// A labelled value shown as a KPI card or a table row in the export.
typedef PdfKpi = ({String label, String value});

/// A titled block of label→value rows in the export.
typedef PdfSection = ({String heading, List<PdfKpi> rows});

const _slate = PdfColor.fromInt(0xFF64748B);
const _ink = PdfColor.fromInt(0xFF1E293B);
const _line = PdfColor.fromInt(0xFFE2E8F0);
const _brand = PdfColor.fromInt(0xFF4F46E5);

/// Renders and shares a branded A4 PDF for any owner analytics report: a nursery
/// header, a KPI strip, then one table per [sections] entry. RTL + Arabic font,
/// mirroring the parent report PDFs. Resolves the nursery name/logo itself so
/// report controllers stay presentation-free.
Future<void> shareAnalyticsPdf({
  required String title,
  required String subtitle,
  required List<PdfKpi> kpis,
  required List<PdfSection> sections,
  required String filename,
}) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'),
  );
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  final nursery = await _loadNursery();
  pw.ImageProvider? logo;
  if ((nursery.logo ?? '').trim().isNotEmpty) {
    try {
      logo = await networkImage(nursery.logo!.trim());
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
        _header(nursery.name, title, subtitle, logo, bold, regular),
        pw.SizedBox(height: 18),
        if (kpis.isNotEmpty) _kpiStrip(kpis, bold, regular),
        for (final s in sections) ...[
          pw.SizedBox(height: 16),
          pw.Text(s.heading,
              style: pw.TextStyle(font: bold, fontSize: 12, color: _ink)),
          pw.SizedBox(height: 8),
          _table(s.rows, bold, regular),
        ],
        pw.SizedBox(height: 20),
        pw.Center(
          child: pw.Text('KidTrack',
              style: pw.TextStyle(font: regular, fontSize: 9, color: _slate)),
        ),
      ],
    ),
  );

  await Printing.sharePdf(bytes: await doc.save(), filename: filename);
}

pw.Widget _header(String nursery, String title, String subtitle,
    pw.ImageProvider? logo, pw.Font bold, pw.Font regular) {
  final name = nursery.trim().isEmpty ? 'KidTrack' : nursery.trim();
  return pw.Row(
    children: [
      pw.Container(
        width: 46,
        height: 46,
        decoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFEEF2FF),
          shape: pw.BoxShape.circle,
        ),
        child: logo != null
            ? pw.ClipOval(
                child: pw.Image(logo,
                    fit: pw.BoxFit.cover, width: 46, height: 46))
            : pw.Center(
                child: pw.Text(name.isNotEmpty ? name[0] : 'K',
                    style: pw.TextStyle(font: bold, fontSize: 20))),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(name, style: pw.TextStyle(font: bold, fontSize: 14)),
            pw.Text(title,
                style: pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
          ],
        ),
      ),
      pw.Text(subtitle,
          style: pw.TextStyle(font: bold, fontSize: 11, color: _brand)),
    ],
  );
}

pw.Widget _kpiStrip(List<PdfKpi> kpis, pw.Font bold, pw.Font regular) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFFF8FAFC),
      borderRadius: pw.BorderRadius.circular(14),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        for (final k in kpis)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(k.label,
                  style:
                      pw.TextStyle(font: regular, fontSize: 9, color: _slate)),
              pw.SizedBox(height: 3),
              pw.Text(k.value,
                  style: pw.TextStyle(font: bold, fontSize: 16, color: _ink)),
            ],
          ),
      ],
    ),
  );
}

pw.Widget _table(List<PdfKpi> rows, pw.Font bold, pw.Font regular) {
  final children = <pw.Widget>[];
  for (var i = 0; i < rows.length; i++) {
    children.add(pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(rows[i].label,
                style: pw.TextStyle(font: regular, fontSize: 10, color: _ink)),
          ),
          pw.Text(rows[i].value,
              style: pw.TextStyle(font: bold, fontSize: 10, color: _ink)),
        ],
      ),
    ));
    if (i != rows.length - 1) {
      children.add(pw.Divider(height: 1, color: const PdfColor.fromInt(0xFFF1F5F9)));
    }
  }
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Column(children: children),
  );
}

Future<({String name, String? logo})> _loadNursery() {
  final c = Completer<({String name, String? logo})>();
  final id = SessionService().nurseryId ?? '';
  Get.find<NurseryParentService>().getAll(
    callBack: (list) {
      if (c.isCompleted) return;
      final all = list.whereType<NurseryModel>();
      if (all.isEmpty) {
        c.complete((name: '', logo: null));
        return;
      }
      final n = all.firstWhere((e) => e.key == id, orElse: () => all.first);
      c.complete((name: n.name, logo: n.logo));
    },
  );
  return c.future;
}
