/// A nursery's OWN collection account that guardians transfer tuition TO.
///
/// Unlike [PlatformPaymentInfoModel] (a single global record the platform is
/// paid on), this is a nursery-scoped LIST: the owner/manager can add as many
/// InstaPay accounts and e-wallet numbers as they like, each with a display
/// name. Guardians see them on the invoice-payment sheet — they copy the
/// number or tap the InstaPay link, transfer, then upload a screenshot.
class PaymentAccountModel {
  final String? key;
  final String nurseryId;

  /// 'instapay' or 'wallet'.
  final String type;

  /// Account/holder name shown to the guardian (e.g. "حساب الحضانة الرئيسي"،
  /// or the wallet holder's name).
  final String title;

  /// The InstaPay handle/number or the e-wallet phone number.
  final String number;

  /// Optional InstaPay deep link that opens the account directly. Empty for
  /// wallets.
  final String link;

  final int? createdAt;
  final int? updatedAt;

  const PaymentAccountModel({
    this.key,
    required this.nurseryId,
    this.type = 'instapay',
    required this.title,
    this.number = '',
    this.link = '',
    this.createdAt,
    this.updatedAt,
  });

  bool get isInstapay => type == 'instapay';
  bool get isWallet => type == 'wallet';

  /// Whether this account exposes a tappable link.
  bool get hasLink => link.trim().isNotEmpty;

  factory PaymentAccountModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return PaymentAccountModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'instapay',
      title: json['title']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      if (key != null) 'key': key,
      'nurseryId': nurseryId,
      'type': type,
      'title': title,
      'number': number,
      'link': link,
      'createdAt': createdAt ?? now,
      'updatedAt': now,
    };
  }

  PaymentAccountModel copyWith({
    String? key,
    String? nurseryId,
    String? type,
    String? title,
    String? number,
    String? link,
    int? createdAt,
    int? updatedAt,
  }) => PaymentAccountModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        type: type ?? this.type,
        title: title ?? this.title,
        number: number ?? this.number,
        link: link ?? this.link,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
