# MEMOplanner generation 4

Code name seagull

## Building for android

The following environmental variables needs to be defined:

- APPCENTER_KEYSTORE_PASSWORD
- APPCENTER_KEY_PASSWORD

Ask a developer for the keys

## Running MEMOplanner Go

`$ flutter run --flavor mpgo`

## Running MEMOplanner

`$ flutter run --flavor mp --dart-define flavor=mp`

## Running with dev

Add

`--dart-define release=dev`

for building with dev features such as fake time and to be able to skip initial startup guide for MEMOplanner

## Workflow

We will roughly follow the following branching model: [a-successful-git-branching-model](https://nvie.com/posts/a-successful-git-branching-model/)

There are two main branches in the repository: **master** and **release**.

Each commit to the **master** branch should create and distribute an dev version for internal testing on both platforms.

Each commit to the **release** branch should create a release candidate and should distribute a new version for testing

### Flow

When starting implementing a story a new branch is created that starts with the story id of the JIRA story. The story is then reviewed and merged to the **master** branch. A new dev version is built from **master**. If the story fails testing it is moved back to in progress and a new branch is created that fixes the bugs found in test. When the story pass test it is moved do done.

Squash commits for feature branches are permitted if there are trivial commits that clutter the history. Developer or reviewer can suggest squash, and it should be agreed on by both parties.

## Version numbering

[major].[minor].[patch]

- Major will probably never be increased.
- Minor is a version where new features are release.
- Patch fixes bug in release.

## Releasing

### Prerequisite for creating a release candidate

- When a release period starts there should not be any stories in "Ready for test" or "Test".

- All strings are translated, e.i. the file [translations.missing.tsv](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.missing.tsv) should not exist.

### Creating the release candidate

The **master** branch is then merged to the **release** branch.

After first release candidate the version in the **master** branch should be increased to the next major or minor version.

#### Fixes in release candidate

If bugs are found in the release candidate that needs to be fixed, a release candidate branch is created starting with **release-rcX**, like **release-rc2**.

When all fixes are added to the **release-rcX** branch, the branch is merge down to **release** where a new release candidate is created.

### Releasing the app

Once a release is created the last commit is tagged with the version number.

## Fixing a bug in release

A fix in release is is the same as fixing a bug in release candidate, with the exception of that the patch version is increased. Only fixes in released version will increase the patch version.

## Translations

### How it works

The translations are written in [lib/i18n/translations.tsv](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.tsv) as tab separated values.

The first column is the id and need to be unique, then each column [lib/i18n/translations.g.dart](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.g.dart) is each language as define by the first line in that column (the first row).

The translations are automatically generated as the file [lib/i18n/translations.g.dart](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.g.dart) when running the command  

`$ flutter packages pub run build_runner build --delete-conflicting-outputs`

Missing translations will fallback to the english translation.

All missing translations will be written to the file [lib/i18n/translation.missing.tsv](https://github.com/abilia/seagull/blob/master/lib/i18n/translations.missing.tsv)

### Add new string

To add new strings for translation:

- add a unique id to a new row
- separate with a tab
- write the english translation
- run `$ flutter packages pub run build_runner build --delete-conflicting-outputs`

### Add new language

To add a new language:

- Add the language code to the header row
- Add the supported language to [`ios/Runner/Info.plist`](https://github.com/abilia/seagull/blob/master/ios/Runner/Info.plist) - see <https://flutter.dev/docs/development/accessibility-and-localization/internationalization#localizing-for-ios-updating-the-ios-app-bundle>

#### Special cases

- If you want an empty string, put **&empty&** as placeholder
- **\\** needs to be escaped with another **\\** as such: **\\\\**
- The character **( )**(tab) is not supported
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

`$ flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`

or

`$ flutter test  --dart-define flavor=mp --coverage && genhtml coverage/lcov.info -o coverage/html`

### Integration tests

To run the tests:

`$ flutter drive --driver=test_driver/integration_test.dart --target=integration_test/integration_tests.dart`

### Screenshots
To take automatic screenshots a specific integration test is setup in the file integration_test/screenshots.dart
To run the screenshot integration test connect to a device and run the following command:

`$ flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshots.dart --flavor mp --dart-define="flavor=mp" --dart-define="release=dev"`