# seagull

A new calendar app.

## Getting Started

The project is built with flutter.

## Working with translations strings
The translations are written in `lib/i18n/translations.csv` as semicolon (**;**) seperated values
The first column is the id and need to be unique, then each column is each languauge as define by the first line in that column (the first row).

The translations are automaticly generated as the file `lib/i18n/translations.g.dart` when running the command  `$ flutter packages pub run build_runner build --delete-conflicting-outputs` or when changing `lib/i18n/translations.csv` if running `$ flutter packages pub run build_runner watch --delete-conflicting-outputs`

To add new strings for translation:
 - add a unique id to a new row
 - seperate with a _`;`_
 - write the english translation 
- run `$ flutter packages pub run build_runner build --delete-conflicting-outputs`

To add a new language:
 - Add the language code to the header row
 - Add the supported langauge to `ios/Runner/Info.plist` - see https://flutter.dev/docs/development/accessibility-and-localization/internationalization#appendix-updating-the-ios-app-bundle

Missing translations will be shown as **n/a**
All missing translations will be written to the file `lib/i18n/translation.missing.csv`

##### Special cases
- If you want an empty string, put **&empty&** as placeholder
- **\\** needs to be escaped with another **\\** as such: **\\\\**
- The character **;** is not supported