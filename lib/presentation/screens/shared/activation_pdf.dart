import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../index/index_main.dart';

/// One printable activation card. [holderName] is whoever the card is for — a
/// child's name (print-all flow) or the account holder (single flow).
class ActivationCard {
  final String code;
  final String holderName;
  final String nurseryName;
  const ActivationCard({
    required this.code,
    required this.holderName,
    required this.nurseryName,
  });
}

/// Single-card share (from the activation sheet).
Future<void> shareActivationCardPdf({
  required String code,
  required String holderName,
  required String nurseryName,
  String? nurseryLogoUrl,
}) async {
  await _shareCards(
    [ActivationCard(code: code, holderName: holderName, nurseryName: nurseryName)],
    'kidtrack-$code',
    nurseryLogoUrl,
  );
}

/// Bulk share — a grid of cards (2 per row) across as many A4 pages as needed.
Future<void> shareActivationCardsPdf({
  required List<ActivationCard> cards,
  String? nurseryLogoUrl,
}) async {
  if (cards.isEmpty) return;
  await _shareCards(cards, 'kidtrack-cards', nurseryLogoUrl);
}

Future<void> _shareCards(
  List<ActivationCard> cards,
  String filename,
  String? logoUrl,
) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'),
  );
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  // Load the nursery logo once and reuse it on every card.
  pw.ImageProvider? logo;
  if (logoUrl != null && logoUrl.trim().isNotEmpty) {
    try {
      logo = await networkImage(logoUrl.trim());
    } catch (_) {
      logo = null;
    }
  }

  // Two cards per row; MultiPage flows the rows onto new pages automatically.
  final rows = <pw.Widget>[];
  for (var i = 0; i < cards.length; i += 2) {
    final right = i + 1 < cards.length ? cards[i + 1] : null;
    rows.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _cardWidget(cards[i], bold, regular, logo)),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: right == null
                  ? pw.SizedBox()
                  : _cardWidget(right, bold, regular, logo),
            ),
          ],
        ),
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => rows,
    ),
  );

  await Printing.sharePdf(bytes: await doc.save(), filename: '$filename.pdf');
}

pw.Widget _cardWidget(
  ActivationCard card,
  pw.Font bold,
  pw.Font regular,
  pw.ImageProvider? logo,
) {
  const primary = PdfColor.fromInt(0xFF5E35B1);
  const primaryDark = PdfColor.fromInt(0xFF4527A0);
  const primaryLight = PdfColor.fromInt(0xFFEDE7F6);

  final nursery =
      card.nurseryName.trim().isEmpty ? 'KidTrack' : card.nurseryName.trim();
  final initial = nursery.isNotEmpty ? nursery[0] : 'K';
  final link = '${Strings.activationLinkBase}${card.code}';

  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(18),
        border: pw.Border.all(color: primaryLight, width: 1.5),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 17,
        verticalRadius: 17,
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Header band ─────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(colors: [primary, primaryDark]),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 38,
                    height: 38,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                    ),
                    child: logo != null
                        ? pw.ClipOval(
                            child: pw.Image(logo,
                                fit: pw.BoxFit.cover, width: 38, height: 38),
                          )
                        : pw.Center(
                            child: pw.Text(
                              initial,
                              style: pw.TextStyle(
                                  font: bold, fontSize: 18, color: primary),
                            ),
                          ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          nursery,
                          maxLines: 1,
                          style: pw.TextStyle(
                              font: bold, fontSize: 13, color: PdfColors.white),
                        ),
                        pw.Text(
                          'KidTrack',
                          style: pw.TextStyle(
                            font: regular,
                            fontSize: 8,
                            color: const PdfColor.fromInt(0xCCFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ────────────────────────────────────────────────────
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: pw.Column(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: primaryLight, width: 1),
                    ),
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: link,
                      width: 118,
                      height: 118,
                      drawText: false,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Container(
                    padding:
                        const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: primaryLight,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      card.code,
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 16,
                          letterSpacing: 2,
                          color: primary),
                    ),
                  ),
                  if (card.holderName.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      card.holderName.trim(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: bold, fontSize: 12),
                    ),
                  ],
                  pw.SizedBox(height: 10),
                  pw.Divider(color: primaryLight, thickness: 1, height: 1),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'shared30_activation_card_instructions'.tr,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        font: regular, fontSize: 8, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
