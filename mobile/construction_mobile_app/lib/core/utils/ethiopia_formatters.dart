import 'package:intl/intl.dart';

class EthiopiaFormatters {
  /// Formats a double value as ETB currency.
  /// Example: 1250.0 -> ETB 1,250.00
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'ETB ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formats a double value as ETB currency without decimals if possible.
  /// Example: 45000.0 -> ETB 45,000
  static String formatCurrencyCompact(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'ETB ',
      decimalDigits: amount == amount.toInt() ? 0 : 2,
    );
    return formatter.format(amount);
  }

  /// Validates an Ethiopian phone number.
  /// Supports:
  /// +2519XXXXXXXX
  /// +2517XXXXXXXX
  /// 09XXXXXXXX
  /// 07XXXXXXXX
  /// 2519XXXXXXXX
  /// 2517XXXXXXXX
  static bool isValidPhoneNumber(String phone) {
    // Remove spaces, hyphens, and parentheses
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Regular expression for Ethiopian phone numbers
    // Supports +251, 251, or 0 prefix followed by 9 or 7 and 8 digits
    final ethPhoneRegex = RegExp(r'^(\+251|251|0)?[97]\d{8}$');

    return ethPhoneRegex.hasMatch(cleanPhone);
  }

  /// Normalizes a phone number to +251XXXXXXXXX format for backend/consistency.
  static String normalizePhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.startsWith('+')) return cleanPhone;
    if (cleanPhone.startsWith('251')) return '+$cleanPhone';
    if (cleanPhone.startsWith('0')) return '+251${cleanPhone.substring(1)}';
    if (cleanPhone.length == 9) return '+251$cleanPhone';
    return cleanPhone;
  }

  /// Formats a DateTime as an Ethiopian date string.
  /// Uses a simplified conversion (approximate) for display purposes.
  static String formatEthiopianDate(DateTime gregorian) {
    // Ethiopian calendar is approximately 7-8 years behind Gregorian.
    // Simple approximation: subtract 7 or 8 years depending on the date.
    // Ethiopian new year falls on Sep 11 (or Sep 12 in leap year).
    final gregorianYear = gregorian.year;
    final gregorianMonth = gregorian.month;
    final gregorianDay = gregorian.day;

    // Determine Ethiopian year
    int ethYear;
    if (gregorianMonth > 9 || (gregorianMonth == 9 && gregorianDay >= 11)) {
      ethYear = gregorianYear - 7;
    } else {
      ethYear = gregorianYear - 8;
    }

    // Ethiopian months: Meskerem(1)-Pagume(13)
    // Simplified mapping for display
    const ethMonths = [
      'Meskerem',
      'Tikimt',
      'Hidar',
      'Tahsas',
      'Tir',
      'Yekatit',
      'Megabit',
      'Miazia',
      'Ginbot',
      'Sene',
      'Hamle',
      'Nehase',
      'Pagume',
    ];

    // Approximate day-of-year conversion
    int dayOfYear = _dayOfYear(gregorian);
    // Ethiopian new year starts on Sep 11 (day ~254 of Gregorian year)
    int ethDayOfYear = dayOfYear - 254;
    if (ethDayOfYear < 0) ethDayOfYear += 365;

    int ethMonth = (ethDayOfYear / 30).floor() + 1;
    if (ethMonth > 13) ethMonth = 13;
    int ethDay = (ethDayOfYear % 30) + 1;
    if (ethMonth == 13) {
      ethDay = ethDayOfYear - 360;
      if (ethDay <= 0) ethDay = 1;
    }

    final monthName =
        ethMonth <= ethMonths.length ? ethMonths[ethMonth - 1] : 'Pagume';

    return '$ethDay $monthName $ethYear';
  }

  static int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }

  /// List of major Ethiopian cities for suggestions.
  static const List<String> majorCities = [
    'Addis Ababa',
    'Dire Dawa',
    'Adama',
    'Hawassa',
    'Bahir Dar',
    'Mekelle',
    'Gondar',
    'Jimma',
    'Dessie',
    'Harar',
  ];
}
