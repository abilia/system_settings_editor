# The Seagull Project

[:calendar: memoplanner](https://github.com/abilia/seagull/tree/master/memoplanner/)

[:blue_book: handi](https://github.com/abilia/seagull/tree/master/handi/)

## Workflow

We will roughly follow the following branching model: [a-successful-git-branching-model](https://nvie.com/posts/a-successful-git-branching-model/)

There are two main branches in the repository: **master** and **release**.

Each push to the **master** branch should create and distribute an dev version for internal testing on both platforms.

Each build from the **release** branch should create a release candidate and should distribute a new version for testing. These builds are triggered manually from [GitHub actions](https://github.com/abilia/seagull/actions/workflows/mp-android-build.yaml).

### Flow

When starting implementing a story a new branch is created that starts with the story id of the JIRA story. The story is then reviewed and merged to the **master** branch. A new dev version is built from **master**. If the story fails testing it is moved back to in progress and a new branch is created that fixes the bugs found in test. When the story pass test it is moved do done.

Squash commits for feature branches are permitted if there are trivial commits that clutter the history. Developer or reviewer can suggest squash, and it should be agreed on by both parties.

## Version numbering

[major].[minor].[patch]

- _Major_ will probably never be increased.
- _Minor_ is a version where new features are release.
- _Patch_ fixes bug in release or smaller features not needing documentation.

## Releasing

### Ideal prerequisite for creating a release candidate

- When a release period starts there should not be any stories in "Ready for test" or "Test".

- All strings are translated, e.i. the files `translations.missing.tsv` [:calendar:](https://github.com/abilia/seagull/blob/master/memoplanner/lib/i18n/translations.missing.tsv) should not exist.

### Alternativly

A test candidate could also be created for testing waiting last translations or testing the latest merge.
Later the release candidate will be created with the final fixes.

### Creating the release candidate

The **master** branch is merged to the **release** branch.

- Either, if a new _minor_ version should be released, the version in the **master** branch should be increased to the next _minor_ version.
- Or, if the new version is a _patch_ version, the **release** branch version is changed to the next patched version, and the **master** branch is left as it is.

Then a manual build is triggered from [GitHub actions](https://github.com/abilia/seagull/actions/workflows/mp-android-build.yaml).

Each release candidate is released on Google Play on Closed testing - Alpha [:calendar:](https://play.google.com/console/u/0/developers/8640289046801512570/app/4973610386809775563/tracks/4698231159357572066)

#### Fixes in release candidate

If bugs are found in the release candidate that needs to be fixed, they are merged to the release branch and a new candidate is released manually when ready. The release branch is also merge into master.

#### After regression test

When the release candidate is approved, the alpha version on Google Play should be promoted to Closed track - Beta track [:calendar:](https://play.google.com/console/u/0/developers/8640289046801512570/app/4973610386809775563/tracks/4699652622759840581)

### Releasing the app

Once a release is created the last commit is tagged with the version number.

## Fixing a bug in release

A fix in release is is the same as fixing a bug in release candidate, with the exception of that the patch version is increased. Only fixes in released version will increase the patch version.
