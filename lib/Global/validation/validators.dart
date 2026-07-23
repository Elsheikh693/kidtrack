import 'package:get/get.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'globalserv8_email_required'.tr;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'globalserv8_email_invalid'.tr;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'globalserv8_password_required'.tr;
    if (value.length < 6) return 'globalserv8_password_short'.tr;
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'globalserv8_name_required'.tr;
    if (value.length < 2) return 'globalserv8_name_short'.tr;
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'globalserv8_phone_required'.tr;
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
      return 'globalserv8_phone_invalid'.tr;
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'globalserv8_number_required'.tr;
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'globalserv8_number_only'.tr;
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'globalserv8_confirm_password_required'.tr;
    }
    if (value != password) return 'globalserv8_password_mismatch'.tr;
    return null;
  }

  static String? notEmpty(
    String? value, {
    String? errorMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'globalserv8_field_required'.tr;
    }
    return null;
  }

  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

String? notEmptyValidator(String? value) => Validators.notEmpty(value);
