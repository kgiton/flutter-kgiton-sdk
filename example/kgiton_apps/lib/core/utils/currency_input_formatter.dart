import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Custom TextInputFormatter for Indonesian Rupiah currency formatting
/// Formats input with thousand separators (e.g., 15000 -> 15.000)
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Parse to number
    final int value = int.tryParse(digitsOnly) ?? 0;

    // Format with thousand separators
    final String formatted = _formatter.format(value).trim();

    // Calculate new cursor position
    int newOffset = formatted.length;

    // If user is typing (not deleting), move cursor to end
    if (newValue.text.length >= oldValue.text.length) {
      newOffset = formatted.length;
    } else {
      // If deleting, try to maintain relative position
      final int oldDigitCount = oldValue.text.replaceAll(RegExp(r'[^\d]'), '').length;
      final int newDigitCount = digitsOnly.length;
      final int deletedDigits = oldDigitCount - newDigitCount;

      // Move cursor back proportionally
      if (deletedDigits > 0) {
        newOffset = (formatted.length - deletedDigits).clamp(0, formatted.length);
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Helper method to get the numeric value from formatted text
  static double getNumericValue(String formattedText) {
    final String digitsOnly = formattedText.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(digitsOnly) ?? 0;
  }
}
