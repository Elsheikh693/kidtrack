import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../../index/index_main.dart';

const _slate = PdfColor.fromInt(0xFF64748B);
const _ink = PdfColor.fromInt(0xFF1E293B);
const _line = PdfColor.fromInt(0xFFE2E8F0);
const _cyan = PdfColor.fromInt(0xFF0891B2);
const _green = PdfColor.fromInt(0xFF16A34A);

Future<void> shareWeeklyLearningPdf(WeeklyLearningController c) async {
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
        ...c.groups.map((g) => _subject(g, bold, regular)),
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
    filename: 'learning-${c.childName}.pdf',
  );
}

pw.Widget _header(WeeklyLearningController c, pw.ImageProvider? logo,
    pw.Font bold, pw.Font regular) {
  final nursery = c.nurseryName.trim().isEmpty ? 'KidTrack' : c.nurseryName;
  return pw.Row(
    children: [
      pw.Container(
        width: 44,
        height: 44,
        decoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFCFFAFE),
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
            pw.Text('report_learning_title'.tr,
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

pw.Widget _summary(WeeklyLearningController c, pw.Font bold, pw.Font regular) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFFF8FAFC),
      borderRadius: pw.BorderRadius.circular(14),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _metric('${c.topicsCount.value}', 'report_learning_topics'.tr, bold, regular),
        _metric('${c.subjectsCount.value}', 'report_learning_subjects'.tr, bold, regular),
      ],
    ),
  );
}

pw.Widget _metric(String value, String label, pw.Font bold, pw.Font regular) {
  return pw.Column(
    children: [
      pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 22, color: _cyan)),
      pw.Text(label,
          style: pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
    ],
  );
}

pw.Widget _subject(
    LearningSubjectGroup g, pw.Font bold, pw.Font regular) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(10),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(g.subjectName,
            style: pw.TextStyle(font: bold, fontSize: 12, color: _ink)),
        pw.SizedBox(height: 6),
        ...g.topics.map((t) => _topicRow(t, bold, regular)),
      ],
    ),
  );
}

pw.Widget _topicRow(LearningTopicItem t, pw.Font bold, pw.Font regular) {
  final note = t.note?.trim();
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ',
                style: pw.TextStyle(font: bold, fontSize: 10, color: _green)),
            pw.Expanded(
              child: pw.Text(t.title,
                  style: pw.TextStyle(font: regular, fontSize: 10, color: _ink)),
            ),
          ],
        ),
        if (note != null && note.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 12, top: 1),
            child: pw.Text(
              '${'report_learning_teacher_note_label'.tr}: $note',
              style: pw.TextStyle(font: regular, fontSize: 9, color: _slate),
            ),
          ),
      ],
    ),
  );
}
