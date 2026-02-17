/// Minimum required password length.
const int minPasswordLength = 8;

/// Validates password strength and returns a list of failure messages.
///
/// Returns an empty list if the password meets all requirements:
/// - At least 8 characters
/// - At least 1 uppercase letter
/// - At least 1 lowercase letter
/// - At least 1 digit
/// - At least 1 special character
List<String> validatePasswordStrength(String password) {
  final failures = <String>[];

  if (password.length < minPasswordLength) {
    failures.add('Password must be at least $minPasswordLength characters');
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    failures.add('Password must contain at least 1 uppercase letter');
  }

  if (!RegExp(r'[a-z]').hasMatch(password)) {
    failures.add('Password must contain at least 1 lowercase letter');
  }

  if (!RegExp(r'[0-9]').hasMatch(password)) {
    failures.add('Password must contain at least 1 digit');
  }

  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;]').hasMatch(password)) {
    failures.add('Password must contain at least 1 special character');
  }

  return failures;
}

/// Returns `true` if the password meets all strength requirements.
bool isValidPassword(String password) {
  return validatePasswordStrength(password).isEmpty;
}

/// Returns an error message if the password is invalid, or `null` if valid.
String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Password is required';
  }

  final failures = validatePasswordStrength(password);
  if (failures.isNotEmpty) {
    return failures.first;
  }

  return null;
}
