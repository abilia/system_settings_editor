# seagull

## Building for android

The following environmental variables needs to be defined:

- APPCENTER_KEYSTORE_PASSWORD
- APPCENTER_KEY_PASSWORD

### Running MEMOplanner Go

`$ flutter run --flavor mpgo`

### Running MEMOplanner

`$ flutter run --flavor mp --dart-define flavor=mp`

#### Setting Device admin for MEMOplanner

`$ adb shell dpm set-device-owner com.abilia.memoplanner/.DeviceAdminReceiver`
`$ adb shell am startservice -n com.abilia.memoplanner/.LockService`

## Working with translations strings

The translations are written in `lib/i18n/translations.tsv` as tab separated values
The first column is the id and need to be unique, then each column is each language as define by the first line in that column (the first row).

The translations are automatically generated as the file `lib/i18n/translations.g.dart` when running the command

`$ flutter packages pub run build_runner build --delete-conflicting-outputs`

or when changing `lib/i18n/translations.tsv` if running

`$ flutter packages pub run build_runner watch --delete-conflicting-outputs`

To add new strings for translation:

- add a unique id to a new row
- separated with a tab
- write the english translation
- run

`$ flutter packages pub run build_runner build --delete-conflicting-outputs`

To add a new language:

- Add the language code to the header row
- Add the supported language to `ios/Runner/Info.plist` - see <https://flutter.dev/docs/development/accessibility-and-localization/internationalization#appendix-updating-the-ios-app-bundle>

Missing translations will fallback to the english translation
All missing translations will be written to the file `lib/i18n/translation.missing.tsv`

### Special cases

- If you want an empty string, put **&empty&** as placeholder
- **\\** needs to be escaped with another **\\** as such: **\\\\**
- The character tab is not supported
- Comments line starts with **#**

## Tests

### Test coverage

For test coverage run

`$ flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html`

### Integration tests

To run the tests:

`$ flutter drive --driver=test_driver/integration_test.dart --target=integration_test/integration_tests.dart`

### Testing flavor specific code

All tests are run as config MEMOplanner Go flavor as default.
For flavor specific tests, add skip to test: `skip: !Config.isMP,` and add tag: `tags: Flavor.mp.tag`
Example:

```dart
test('runs only on mp', () {
  expect(Config.flavor, Flavor.mp);
}, skip: !Config.isMP, tags: Flavor.mp.tag);

test('runs only on mpgo', () {
  expect(Config.flavor, Flavor.mpgo);
}, skip: !Config.isMP, tags: Flavor.mp.tag);
```

To run a tests as a flavor:

`$ flutter test --dart-define flavor=mp`

running only flavor test:

`$ flutter test --dart-define flavor=mp --tags mp`
