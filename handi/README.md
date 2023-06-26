# Handi6

## Translations

We're using [lokalise](https://app.lokalise.com) and [lokalise_flutter_sdk](https://pub.dev/packages/lokalise_flutter_sdk) for our translations.

To add translations after a newly added string or language, download all languages as .arb files and put them in the l10n folder. They should be formatted as `intl_%LANG_ISO%.arb`. Then run

`$ dart pub run lokalise_flutter_sdk:gen-lok-l10n`

To generate the translations as a dart file.

## Run app

`$ flutter run`

## Run tests

`$ flutter test`
