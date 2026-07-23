/// The platform's own collection accounts that nurseries pay their monthly
/// subscription TO. A single global record stored at `platformPaymentInfo`,
/// edited only by the SuperAdmin and shown read-only to owners/managers on the
/// "My subscription" screen.
class PlatformPaymentInfoModel {
  final String instapayNumber;
  final String walletNumber;
  final String instapayLink;
  final int? updatedAt;

  const PlatformPaymentInfoModel({
    this.instapayNumber = '',
    this.walletNumber = '',
    this.instapayLink = '',
    this.updatedAt,
  });

  /// True when at least one payment method is filled — used to decide whether
  /// to render the payment-methods card at all.
  bool get hasAny =>
      instapayNumber.isNotEmpty ||
      walletNumber.isNotEmpty ||
      instapayLink.isNotEmpty;

  factory PlatformPaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PlatformPaymentInfoModel(
      instapayNumber: json['instapayNumber']?.toString() ?? '',
      walletNumber: json['walletNumber']?.toString() ?? '',
      instapayLink: json['instapayLink']?.toString() ?? '',
      updatedAt: json['updatedAt'] is int
          ? json['updatedAt'] as int
          : int.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'instapayNumber': instapayNumber,
        'walletNumber': walletNumber,
        'instapayLink': instapayLink,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };

  PlatformPaymentInfoModel copyWith({
    String? instapayNumber,
    String? walletNumber,
    String? instapayLink,
    int? updatedAt,
  }) {
    return PlatformPaymentInfoModel(
      instapayNumber: instapayNumber ?? this.instapayNumber,
      walletNumber: walletNumber ?? this.walletNumber,
      instapayLink: instapayLink ?? this.instapayLink,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
