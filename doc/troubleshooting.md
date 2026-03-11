# Troubleshooting

## `validate` fails on dirty repository

Commit or stash local changes before running release-oriented commands.

## Missing `version:` in `pubspec.yaml`

Add a SemVer-compliant `version` entry before running `bump` or `set`.

## Changelog update produces no entries

Ensure there are commits since the most recent tag and that commit history is reachable from current HEAD.
