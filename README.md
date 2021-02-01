# seagull

A new calendar app.

## Getting Started

The project is built with flutter.

## Working with translations strings
The translations are written in `lib/i18n/translations.tsv` as tab **(	)** seperated values
The first column is the id and need to be unique, then each column is each languauge as define by the first line in that column (the first row).

The translations are automaticly generated as the file `lib/i18n/translations.g.dart` when running the command  `$ flutter packages pub run build_runner build --delete-conflicting-outputs` or when changing `lib/i18n/translations.tsv` if running `$ flutter packages pub run build_runner watch --delete-conflicting-outputs`

To add new strings for translation:
 - add a unique id to a new row
 - seperate with a `	`(tab)
 - write the english translation 
- run `$ flutter packages pub run build_runner build --delete-conflicting-outputs`

To add a new language:
 - Add the language code to the header row
 - Add the supported langauge to `ios/Runner/Info.plist` - see https://flutter.dev/docs/development/accessibility-and-localization/internationalization#appendix-updating-the-ios-app-bundle

Missing translations will fallback to the english translation
All missing translations will be written to the file `lib/i18n/translation.missing.tsv`

##### Special cases
- If you want an empty string, put **&empty&** as placeholder
- **\\** needs to be escaped with another **\\** as such: **\\\\**
- The character **(	)**(tab) is not supported
- Comments line starts with **#**

## Test coverage
For test coverage run
`$ flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html`

## Integration tests
To run the tests:
`$ flutter drive --driver=test_driver/integration_test.dart --target=integration_test/integration_tests.dart`