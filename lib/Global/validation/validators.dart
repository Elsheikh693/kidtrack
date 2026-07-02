class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (value.length < 6) return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال الاسم';
    if (value.length < 2) return 'يجب أن يكون الاسم حرفين على الأقل';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال رقم الهاتف';
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
      return 'يرجى إدخال رقم هاتف صالح';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال رقم';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'يجب أن يحتوي على أرقام فقط';
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'يرجى تأكيد كلمة المرور';
    if (value != password) return 'كلمات المرور غير متطابقة';
    return null;
  }

  static String? notEmpty(
    String? value, {
    String errorMessage = "هذا الحقل يجب ألا يكون فارغًا",
  }) {
    if (value == null || value.trim().isEmpty) return errorMessage;
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
