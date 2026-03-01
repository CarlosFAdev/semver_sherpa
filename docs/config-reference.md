# Configuration and Behavior Reference

`semver_sherpa` is command-driven and does not require a dedicated config file.

## Required project files

- `pubspec.yaml` with a valid `version:` field
- `CHANGELOG.md` following Keep a Changelog conventions
- a git repository for changelog-from-history features

## Core behavior

- `bump` updates version and changelog sections by SemVer semantics
- `set` applies an explicit version
- `changelog` updates `Unreleased` content from git history
- `validate` enforces clean working tree constraints
