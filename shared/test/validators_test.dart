import 'package:studio_pair_shared/src/validators/email_validator.dart';
import 'package:studio_pair_shared/src/validators/luhn_validator.dart';
import 'package:studio_pair_shared/src/validators/password_validator.dart';
import 'package:test/test.dart';

void main() {
  group('Email Validator', () {
    group('isValidEmail', () {
      test('returns true for standard email addresses', () {
        expect(isValidEmail('user@example.com'), isTrue);
        expect(isValidEmail('user.name@example.com'), isTrue);
        expect(isValidEmail('user+tag@example.com'), isTrue);
        expect(isValidEmail('user@sub.domain.com'), isTrue);
      });

      test('returns false for empty string', () {
        expect(isValidEmail(''), isFalse);
      });

      test('returns false for missing @ symbol', () {
        expect(isValidEmail('userexample.com'), isFalse);
      });

      test('returns false for missing domain', () {
        expect(isValidEmail('user@'), isFalse);
      });

      test('returns false for missing local part', () {
        expect(isValidEmail('@example.com'), isFalse);
      });

      test('returns false for spaces in email', () {
        expect(isValidEmail('user @example.com'), isFalse);
        expect(isValidEmail('user@ example.com'), isFalse);
      });
    });

    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(validateEmail('user@example.com'), isNull);
      });

      test('returns error for null email', () {
        expect(validateEmail(null), equals('Email is required'));
      });

      test('returns error for empty email', () {
        expect(validateEmail(''), equals('Email is required'));
      });

      test('returns error for invalid email format', () {
        expect(
          validateEmail('not-an-email'),
          equals('Please enter a valid email address'),
        );
      });
    });
  });

  group('Password Validator', () {
    group('validatePasswordStrength', () {
      test('returns empty list for a strong password', () {
        final failures = validatePasswordStrength('Str0ng!Pass');
        expect(failures, isEmpty);
      });

      test('reports password too short', () {
        final failures = validatePasswordStrength('Aa1!');
        expect(
          failures,
          contains('Password must be at least $minPasswordLength characters'),
        );
      });

      test('reports missing uppercase letter', () {
        final failures = validatePasswordStrength('lowercase1!');
        expect(
          failures,
          contains('Password must contain at least 1 uppercase letter'),
        );
      });

      test('reports missing lowercase letter', () {
        final failures = validatePasswordStrength('UPPERCASE1!');
        expect(
          failures,
          contains('Password must contain at least 1 lowercase letter'),
        );
      });

      test('reports missing digit', () {
        final failures = validatePasswordStrength('NoDigits!Here');
        expect(failures, contains('Password must contain at least 1 digit'));
      });

      test('reports missing special character', () {
        final failures = validatePasswordStrength('NoSpecial1Here');
        expect(
          failures,
          contains('Password must contain at least 1 special character'),
        );
      });

      test('reports all failures at once', () {
        final failures = validatePasswordStrength('aa');
        expect(failures.length, greaterThanOrEqualTo(3));
      });
    });

    group('isValidPassword', () {
      test('returns true for strong password', () {
        expect(isValidPassword('MyP@ssw0rd!'), isTrue);
      });

      test('returns false for weak password', () {
        expect(isValidPassword('weak'), isFalse);
      });
    });

    group('validatePassword', () {
      test('returns null for valid password', () {
        expect(validatePassword('ValidP@ss1'), isNull);
      });

      test('returns error for null password', () {
        expect(validatePassword(null), equals('Password is required'));
      });

      test('returns error for empty password', () {
        expect(validatePassword(''), equals('Password is required'));
      });

      test('returns first failure message for invalid password', () {
        final result = validatePassword('short');
        expect(result, isNotNull);
        expect(result, isA<String>());
      });
    });
  });

  group('Luhn Validator', () {
    group('isValidLuhn', () {
      test('returns true for valid card numbers', () {
        // Known valid card numbers (test numbers)
        expect(isValidLuhn('4539578763621486'), isTrue);
        expect(isValidLuhn('79927398713'), isTrue);
      });

      test('handles spaces and dashes in card number', () {
        expect(isValidLuhn('4539 5787 6362 1486'), isTrue);
        expect(isValidLuhn('4539-5787-6362-1486'), isTrue);
      });

      test('returns false for invalid card numbers', () {
        expect(isValidLuhn('1234567890123456'), isFalse);
        expect(isValidLuhn('0000000000000001'), isFalse);
      });

      test('returns false for empty string', () {
        expect(isValidLuhn(''), isFalse);
      });

      test('returns false for non-digit characters', () {
        expect(isValidLuhn('abcdefgh'), isFalse);
      });

      test('returns false for single digit', () {
        expect(isValidLuhn('5'), isFalse);
      });
    });

    group('validateCardNumber', () {
      test('returns null for valid card number', () {
        expect(validateCardNumber('79927398713'), isNull);
      });

      test('returns error for null card number', () {
        expect(validateCardNumber(null), equals('Card number is required'));
      });

      test('returns error for empty card number', () {
        expect(validateCardNumber(''), equals('Card number is required'));
      });

      test('returns error for invalid card number', () {
        expect(validateCardNumber('1234567890'), equals('Invalid card number'));
      });
    });
  });
}
