import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../../index/index_main.dart';

const _green = PdfColor.fromInt(0xFF16A34A);
const _amber = PdfColor.fromInt(0xFFD97706);
const _red = PdfColor.fromInt(0xFFDC2626);
const _blue = PdfColor.fromInt(0xFF0284C7);
const _slate = PdfColor.fromInt(0xFF64748B);
const _ink = PdfColor.fromInt(0xFF1E293B);
const _line = PdfColor.fromInt(0xFFE2E8F0);

PdfColor _statusColor(String s) {
  switch (s) {
    case 'present':
      return _green;
    case 'late':
      return _amber;
    case 'absent':
      return _red;
    case 'excused':
      return _blue;
    default:
      return _slate;
  }
}

PdfColor _rateColor(int rate) =>
    rate >= 90 ? _green : (rate >= 75 ? _amber : _red);

/// Builds a print-fidelity A4 report from the controller's current week and
/// opens the native share sheet.
Future<void> shareWeeklyAttendancePdf(WeeklyAttendanceController c) async {
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

  final rate = c.rate.value;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      textDirection: pw.TextDirection.rtl,
      build: (context) => [
        _header(c, logo, bold, regular),
        pw.SizedBox(height: 20),
        _rateBlock(c, rate, bold, regular),
        pw.SizedBox(height: 16),
        _statsRow(c, bold, regular),
        pw.SizedBox(height: 16),
        _calendar(c, bold, regular),
        pw.SizedBox(height: 16),
        _details(c, bold, regular),
        if (c.insight.value.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _insight(c, rate, bold, regular),
        ],
        pw.SizedBox(height: 20),
        pw.Center(
          child: pw.Text('KidTrack',
              style: pw.TextStyle(font: regular, fontSize: 9, color: _slate)),
        ),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'attendance-${c.childName}.pdf',
  );
}

pw.Widget _header(WeeklyAttendanceController c, pw.ImageProvider? logo,
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
                child: pw.Image(logo, fit: pw.BoxFit.cover, width: 44, height: 44))
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
            pw.Text('report_attendance_title'.tr,
                style: pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
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

pw.Widget _rateBlock(
    WeeklyAttendanceController c, int rate, pw.Font bold, pw.Font regular) {
  final color = _rateColor(rate);
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFF8FAFC),
      borderRadius: pw.BorderRadius.circular(14),
      border: pw.Border.all(color: _line),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('report_attendance_rate'.tr,
                style: pw.TextStyle(font: regular, fontSize: 10, color: _slate)),
            pw.Text('$rate%',
                style: pw.TextStyle(font: bold, fontSize: 32, color: color)),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor(color.red, color.green, color.blue, 0.12),
            borderRadius: pw.BorderRadius.circular(20),
          ),
          child: pw.Text(_rateLabelKey(rate).tr,
              style: pw.TextStyle(font: bold, fontSize: 12, color: color)),
        ),
      ],
    ),
  );
}

String _rateLabelKey(int rate) => rate >= 90
    ? 'report_rate_excellent'
    : (rate >= 75 ? 'report_rate_good' : 'report_rate_low');

pw.Widget _statsRow(
    WeeklyAttendanceController c, pw.Font bold, pw.Font regular) {
  pw.Widget tile(String labelKey, int value, PdfColor color) => pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 4),
          padding: const pw.EdgeInsets.symmetric(vertical: 12),
          decoration: pw.BoxDecoration(
            color: PdfColor(color.red, color.green, color.blue, 0.08),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              pw.Text('$value',
                  style: pw.TextStyle(font: bold, fontSize: 18, color: color)),
              pw.SizedBox(height: 2),
              pw.Text(labelKey.tr,
                  style:
                      pw.TextStyle(font: regular, fontSize: 9, color: _slate)),
            ],
          ),
        ),
      );
  return pw.Row(
    children: [
      tile('report_status_present', c.presentCount.value, _green),
      tile('report_status_late', c.lateCount.value, _amber),
      tile('report_status_absent', c.absentCount.value, _red),
      tile('report_school_days', c.schoolDays.value, const PdfColor.fromInt(0xFF5E35B1)),
    ],
  );
}

pw.Widget _calendar(
    WeeklyAttendanceController c, pw.Font bold, pw.Font regular) {
  return pw.Wrap(
    spacing: 6,
    runSpacing: 6,
    children: c.days.map((d) {
      final color = _statusColor(d.status);
      final muted = d.status == 'none' || d.status == 'upcoming';
      return pw.Container(
        width: 66,
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        decoration: pw.BoxDecoration(
          color: muted
              ? const PdfColor.fromInt(0xFFF8FAFC)
              : PdfColor(color.red, color.green, color.blue, 0.08),
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: muted ? _line : color, width: 0.5),
        ),
        child: pw.Column(
          children: [
            pw.Text(d.dayKey.tr,
                style: pw.TextStyle(font: regular, fontSize: 9, color: _slate)),
            pw.Text('${d.date.day}',
                style: pw.TextStyle(font: bold, fontSize: 12, color: _ink)),
            pw.SizedBox(height: 2),
            pw.Text(_dot(d.status),
                style: pw.TextStyle(
                    fontSize: 10, color: muted ? _slate : color)),
          ],
        ),
      );
    }).toList(),
  );
}

String _dot(String status) {
  switch (status) {
    case 'present':
      return '✓';
    case 'late':
      return '⏱';
    case 'absent':
      return '✕';
    case 'excused':
      return '•';
    default:
      return '–';
  }
}

pw.Widget _details(
    WeeklyAttendanceController c, pw.Font bold, pw.Font regular) {
  final rows = <pw.Widget>[];
  final days = c.days;
  for (var i = 0; i < days.length; i++) {
    final d = days[i];
    final color = _statusColor(d.status);
    final time = d.checkInTime == null
        ? '—'
        : ShiftModel.formatMinutes(
            DateTime.fromMillisecondsSinceEpoch(d.checkInTime!).hour * 60 +
                DateTime.fromMillisecondsSinceEpoch(d.checkInTime!).minute);
    rows.add(pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      child: pw.Row(
        children: [
          pw.Expanded(
              flex: 3,
              child: pw.Text(d.dayKey.tr,
                  style: pw.TextStyle(font: bold, fontSize: 10, color: _ink))),
          pw.Expanded(
              flex: 3,
              child: pw.Text(_statusLabelKey(d.status).tr,
                  style: pw.TextStyle(font: regular, fontSize: 10, color: color))),
          pw.Expanded(
              flex: 2,
              child: pw.Text(time,
                  textAlign: pw.TextAlign.left,
                  style:
                      pw.TextStyle(font: regular, fontSize: 10, color: _slate))),
        ],
      ),
    ));
    if (i != days.length - 1) {
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

String _statusLabelKey(String status) {
  switch (status) {
    case 'present':
      return 'report_status_present';
    case 'late':
      return 'report_status_late';
    case 'absent':
      return 'report_status_absent';
    case 'excused':
      return 'report_status_excused';
    case 'upcoming':
      return 'report_status_upcoming';
    default:
      return 'report_status_none';
  }
}

pw.Widget _insight(
    WeeklyAttendanceController c, int rate, pw.Font bold, pw.Font regular) {
  final color = _rateColor(rate);
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfColor(color.red, color.green, color.blue, 0.08),
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.3)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('report_insight_title'.tr,
            style: pw.TextStyle(font: bold, fontSize: 10, color: color)),
        pw.SizedBox(height: 4),
        pw.Text(c.insight.value,
            style: pw.TextStyle(font: regular, fontSize: 11, color: _ink)),
      ],
    ),
  );
}
