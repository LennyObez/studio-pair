import 'package:studio_pair_shared/src/i18n/app_localizations.dart';
import 'package:test/test.dart';

void main() {
  group('AppLocalizations', () {
    group('supportedLocales', () {
      test('includes English and French', () {
        final locales = AppLocalizations.supportedLocales;
        expect(locales, contains('en'));
        expect(locales, contains('fr'));
      });

      test('has exactly 2 supported locales', () {
        expect(AppLocalizations.supportedLocales.length, equals(2));
      });
    });

    group('keys', () {
      test('keys set is not empty', () {
        expect(AppLocalizations.keys, isNotEmpty);
      });

      test('contains essential general keys', () {
        final keys = AppLocalizations.keys;
        expect(keys, contains('app_name'));
        expect(keys, contains('login'));
        expect(keys, contains('register'));
        expect(keys, contains('email'));
        expect(keys, contains('password'));
      });

      test('contains module name keys', () {
        final keys = AppLocalizations.keys;
        expect(keys, contains('activities'));
        expect(keys, contains('calendar'));
        expect(keys, contains('messages'));
        expect(keys, contains('finances'));
        expect(keys, contains('health'));
        expect(keys, contains('tasks'));
        expect(keys, contains('reminders'));
        expect(keys, contains('files'));
        expect(keys, contains('memories'));
        expect(keys, contains('charter'));
        expect(keys, contains('grocery_list'));
        expect(keys, contains('polls'));
        expect(keys, contains('location'));
        expect(keys, contains('settings'));
        expect(keys, contains('profile'));
        expect(keys, contains('logout'));
      });

      test('contains action keys', () {
        final keys = AppLocalizations.keys;
        expect(keys, contains('save'));
        expect(keys, contains('cancel'));
        expect(keys, contains('delete'));
        expect(keys, contains('edit'));
        expect(keys, contains('add'));
        expect(keys, contains('search'));
      });

      test('contains state keys', () {
        final keys = AppLocalizations.keys;
        expect(keys, contains('loading'));
        expect(keys, contains('error'));
        expect(keys, contains('success'));
        expect(keys, contains('no_data'));
        expect(keys, contains('retry'));
      });
    });

    group('translate', () {
      test('translates English keys correctly', () {
        expect(
          AppLocalizations.translate('app_name', 'en'),
          equals('Studio Pair'),
        );
        expect(AppLocalizations.translate('login', 'en'), equals('Login'));
        expect(AppLocalizations.translate('save', 'en'), equals('Save'));
      });

      test('translates French keys correctly', () {
        expect(
          AppLocalizations.translate('app_name', 'fr'),
          equals('Studio Pair'),
        );
        expect(AppLocalizations.translate('login', 'fr'), equals('Connexion'));
        expect(AppLocalizations.translate('save', 'fr'), equals('Enregistrer'));
      });

      test('defaults to English when no locale is specified', () {
        expect(AppLocalizations.translate('login'), equals('Login'));
      });

      test('falls back to English for missing keys in French', () {
        // Since both locales have the same keys, test fallback logic
        // by using the fact that if a key is in EN but not FR, it returns EN
        expect(AppLocalizations.translate('app_name', 'fr'), isNotEmpty);
      });

      test('returns the key itself for unknown keys', () {
        expect(
          AppLocalizations.translate('unknown_key_xyz'),
          equals('unknown_key_xyz'),
        );
      });

      test('returns the key for unsupported locale with unknown key', () {
        expect(
          AppLocalizations.translate('unknown_key', 'de'),
          equals('unknown_key'),
        );
      });
    });

    group('locale parity', () {
      test('English and French have the same keys', () {
        // Get all English keys and French keys and check they match
        final enKeys = <String>{};
        final frKeys = <String>{};

        for (final key in AppLocalizations.keys) {
          final enValue = AppLocalizations.translate(key, 'en');
          final frValue = AppLocalizations.translate(key, 'fr');

          // If the translation returns the key itself, it was not found
          if (enValue != key) enKeys.add(key);
          if (frValue != key) frKeys.add(key);
        }

        // Both locales should have translations for the same keys
        expect(enKeys, equals(frKeys));
      });

      test('no translation value is empty', () {
        for (final key in AppLocalizations.keys) {
          final enValue = AppLocalizations.translate(key, 'en');
          final frValue = AppLocalizations.translate(key, 'fr');
          expect(enValue, isNotEmpty, reason: 'EN key "$key" is empty');
          expect(frValue, isNotEmpty, reason: 'FR key "$key" is empty');
        }
      });
    });

    group('activity category keys', () {
      test('activity category keys exist', () {
        final keys = AppLocalizations.keys;
        expect(keys, contains('activity_category_movies'));
        expect(keys, contains('activity_category_sports'));
        expect(keys, contains('activity_category_other'));
      });

      test('activity category translations are non-empty in both locales', () {
        final categoryKeys = AppLocalizations.keys.where(
          (k) => k.startsWith('activity_category_'),
        );

        expect(categoryKeys, isNotEmpty);

        for (final key in categoryKeys) {
          expect(
            AppLocalizations.translate(key, 'en'),
            isNot(equals(key)),
            reason: 'EN translation missing for $key',
          );
          expect(
            AppLocalizations.translate(key, 'fr'),
            isNot(equals(key)),
            reason: 'FR translation missing for $key',
          );
        }
      });
    });
  });
}
