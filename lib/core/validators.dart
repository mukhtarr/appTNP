class AppValidators {
  static void requireNonEmpty(String label, String value) {
    if (value.trim().isEmpty) {
      throw FormatException('$label is required.');
    }
  }

  static void validatePercentage(String label, double? value, {bool allowNull = true}) {
    if (value == null && allowNull) {
      return;
    }
    if (value == null || value < 0 || value > 100) {
      throw FormatException('$label must be between 0 and 100.');
    }
  }

  static void validatePhone(String label, String value) {
    final normalized = value.replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 10 || normalized.length > 13) {
      throw FormatException('$label must be a valid mobile number.');
    }
  }

  static void validateEmail(String value) {
    final email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!email.hasMatch(value.trim())) {
      throw FormatException('Personal Email ID must be valid.');
    }
  }

  static void validateUrl(String label, String value, {bool allowEmpty = true}) {
    if (value.trim().isEmpty && allowEmpty) {
      return;
    }
    final url = RegExp(r'^(https?:\/\/)?[\w.-]+\.[a-zA-Z]{2,}.*$');
    if (!url.hasMatch(value.trim())) {
      throw FormatException('$label must be a valid URL.');
    }
  }

  static void validatePhoto(String value) {
    if (value.trim().isEmpty) {
      return;
    }
    final photo = value.toLowerCase();
    if (!(photo.endsWith('.png') || photo.endsWith('.jpg') || photo.endsWith('.jpeg') || photo.startsWith('http'))) {
      throw FormatException('Photo must be a supported image path or URL.');
    }
  }

  static List<String> parseListField(String value) {
    return value
        .split(';')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
