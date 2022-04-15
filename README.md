# MEMOplanner generation 4

## Building for android

The following environmental variables needs to be defined:

- APPCENTER_KEYSTORE_PASSWORD
- APPCENTER_KEY_PASSWORD

## Running MEMOplanner Go

`$ flutter run --flavor mpgo`

## Running MEMOplanner

`$ flutter run --flavor mp --dart-define flavor=mp`

## Running with beta or alpha

Add

`--dart-define release=alpha`

for building with alpha features such as fake time and to be able to skip initial startup guide for MEMOplanner

## Workflow

[see wiki](https://github.com/abilia/seagull/wiki/Work-flow)

## Working with translations

[see wiki](https://github.com/abilia/seagull/wiki/Translations)

## Tests

[see wiki](https://github.com/abilia/seagull/wiki/Tests)
