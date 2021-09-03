# MEMOPlanner gen 4

## Building for android

The following environmental variables needs to be defined:

- APPCENTER_KEYSTORE_PASSWORD
- APPCENTER_KEY_PASSWORD

## Running MEMOplanner Go

`$ flutter run --flavor mpgo`

## Running MEMOplanner

`$ flutter run --flavor mp --dart-define flavor=mp`

## Working with translations strings

The translations are written in [lib/i18n/translations.tsv](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.tsv) as tab separated values
The first column is the id and need to be unique, then each column is each language as define by the first line in that column (the first row).

The translations are automatically generated as the file [lib/i18n/translations.g.dart](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.g.dart) when running the command

`$ flutter packages pub run build_runner build --delete-conflicting-outputs`

or when changing [lib/i18n/translations.tsv](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.tsv) if running

`$ flutter packages pub run build_runner watch --delete-conflicting-outputs`

To add new strings for translation:

- add a unique id to a new row
- separated with a tab
- write the english translation
- run

`$ flutter packages pub run build_runner build --delete-conflicting-outputs`

To add a new language:

- Add the language code to the header row
- Add the supported language to [ios/Runner/Info.plist](https://github.com/abilia/seagull/blob/master/ios/Runner/Info.plist) - see <https://flutter.dev/docs/development/accessibility-and-localization/internationalization#appendix-updating-the-ios-app-bundle>

Missing translations will fallback to the english translation
All missing translations will be written to the file [lib/i18n/translation.missing.tsv](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.missing.tsv)
### Special cases

- If you want an empty string, put **&empty&** as placeholder
- **\\** needs to be escaped with another **\\** as such: **\\\\**
- The character tab is not supported
- Comments line starts with **#**

## Tests

### Testing flavor specific code

All tests are run as config MEMOplanner Go flavor as default.

To run a tests as a MEMOplanner:
`$ flutter test --dart-define flavor=mp`

For adding flavor specific tests, add skip to test or group: `skip: !Config.isMP);` or `skip: !Config.isMPGO);`

Example:

```dart
test('runs only on mpgo', () {
  expect(Config.flavor, Flavor.mpgo);
}, skip: !Config.isMPGO);

group('group runs only on mp', () {
  test('mp test', () {
    expect(Config.flavor, Flavor.mp);
  });
}, skip: !Config.isMP);
```

### Test coverage

For test coverage run

`$ flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html`

or

`$ flutter test  --dart-define flavor=mp --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html`

### Integration tests

To run the tests:

`$ flutter drive --driver=test_driver/integration_test.dart --target=integration_test/integration_tests.dart`
