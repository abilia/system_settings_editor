# MEMOplanner generation 4

## Getting started

To get started, first set up the environment keys:

1. Get the `.env` file from either Lastpass or from a developer and make sure the file name is `.env.key`.
2. Put the file in the `lib/env` folder.
3. Run `$ flutter pub get` to get packages.
4. Run `$ flutter pub run build_runner build --delete-conflicting-outputs` to generate keys.

## Building for android

The following environmental variables needs to be defined:

- KEYSTORE_PASSWORD
- KEY_PASSWORD

Ask a developer for the keys

## Running MEMOplanner Go

`$ flutter run --flavor mpgo`

## Running MEMOplanner

`$ flutter run --flavor mp --dart-define flavor=mp`

## Running with dev

Add

`--dart-define release=dev`

for building with dev features such as feature toggles and to be able to skip initial startup guide for MEMOplanner

## Translations

We're using [lokalise](https://app.lokalise.com) and [lokalise_flutter_sdk](https://pub.dev/packages/lokalise_flutter_sdk) for our translations.

To add translations after a newly added string or language, download all languages as .arb files and put them in the l10n folder. They should be formatted as `intl_%LANG_ISO%.arb`. Then run

`$ dart pub run lokalise_flutter_sdk:gen-lok-l10n`

To generate the translations as a dart file.

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

`$ flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`

or

`$ flutter test  --dart-define flavor=mp --coverage && genhtml coverage/lcov.info -o coverage/html`

### Integration tests

To run the tests:

`$ flutter drive --driver=test_driver/integration_test.dart --target=integration_test/integration_tests.dart`

### Screenshots

To take automatic screenshots a specific integration test is setup in the file integration_test/screenshots.dart.
To run the screenshot integration test connect to a device and run the following command:

`$ flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshots.dart --flavor mp --dart-define="flavor=mp" --dart-define="release=dev" --profile`

To be able run in profile mode and to get the most accurate screen dimensions, it's recommended to run the tests on a real device.

### Feature toggles

When developing a new feature that is not ready for production but wanted to be integrated with the rest of the code, or when something should be tested by a selected number of people, a feature toggle could be used. Feature toggles can be handled locally by just adding a toggle to the enum FeatureToggle. The feature toggle page is available for non release builds. Feature toggles can also be added for a specific user in the backend. That has to be done manually in the database or by superadmin post requests.
