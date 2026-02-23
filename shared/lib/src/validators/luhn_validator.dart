/// Validates a card number using the Luhn algorithm.
///
/// Returns `true` if the card number passes the Luhn check.
/// The input should contain only digits (spaces and dashes are stripped).
bool isValidLuhn(String cardNumber) {
  // Strip spaces and dashes
  final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

  // Must be all digits and at least 2 characters
  if (cleaned.isEmpty || !RegExp(r'^\d+$').hasMatch(cleaned)) {
    return false;
  }

  if (cleaned.length < 2) {
    return false;
  }

  var sum = 0;
  final isEvenLength = cleaned.length % 2 == 0;

  for (var i = 0; i < cleaned.length; i++) {
    var digit = int.parse(cleaned[i]);

    // Double every second digit from the right (starting from second-to-last)
    final shouldDouble = isEvenLength ? i % 2 == 0 : i % 2 == 1;

    if (shouldDouble) {
      digit *= 2;
      if (digit > 9) {
        digit -= 9;
      }
    }

    sum += digit;
  }

  return sum % 10 == 0;
}

/// Returns an error message if the card number fails Luhn validation,
/// or `null` if valid.
String? validateCardNumber(String? cardNumber) {
  if (cardNumber == null || cardNumber.isEmpty) {
    return 'Card number is required';
  }
  if (!isValidLuhn(cardNumber)) {
    return 'Invalid card number';
  }
  return null;
}
