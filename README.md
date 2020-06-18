# seagull

A new calendar app.

## Getting Started

The project is built with flutter.


## Working with translations strings

To add new strings for translation, in lib/i18n/translations.csv:
 - add a unique id to a new row
 - seperate with a ;
 - write english translation 
- run > flutter packages pub run build_runner build
without a id and an english translation, nothing will be generated in lib/i18n/translations.dart

Missing strings will be replaced with N/A(language code) for that language
If you want an empty string, put &empty& as placeholder
All missing translations will be written to the file lib/i18n/translation.missing.csv
To add a new language, add the language code to the header row in lib/i18n/translations.csv

You can also run 
> flutter packages pub run build_runner watch 
to auto generate the lib/i18n/translations.dart when changing lib/i18n/translations.csv