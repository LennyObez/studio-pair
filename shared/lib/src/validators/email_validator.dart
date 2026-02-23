/// Validates an email address format.
///
/// Returns `true` if the email is valid, `false` otherwise.
bool isValidEmail(String email) {
  if (email.isEmpty) return false;

  // RFC 5322 simplified email regex
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );

  return emailRegex.hasMatch(email);
}

/// Returns an error message if the email is invalid, or `null` if valid.
String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Email is required';
  }
  if (!isValidEmail(email)) {
    return 'Please enter a valid email address';
  }
  return null;
}
