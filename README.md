# Release Tool

Release Tool is a Dart CLI that manages SemVer versions for Flutter/Dart projects
and keeps your CHANGELOG.md in a Keep a Changelog-compatible format.

## Features
- bump versions (major/minor/patch) with build metadata
- set an explicit version
- generate or update an Unreleased changelog section from git history
- validate a clean git working tree before releases

## Requirements
- Dart SDK 3.11+
- git
- a `pubspec.yaml` with a `version:` field

## Install
This repo is not published to pub.dev. Install from source:

```bash
dart pub global activate --source path .
```

The executable name is `release`:

```bash
release --help
```

Alternatively, run directly from the repo:

```bash
dart run bin/release_tool.dart --help
```

## Usage

### Bump a version

```bash
release bump patch
```

Options:
- `--dry-run` simulate without changing files
- `--no-commit` update files without committing
- `--no-tag` skip git tag creation
- `--no-changelog` skip changelog generation
- `--push` push commits and tags after a successful release

### Set a version

```bash
release set 1.2.3+4
```

Options:
- `--dry-run` simulate without changing files
- `--no-commit` update files without committing
- `--no-tag` skip git tag creation
- `--push` push changes after setting a version

### Generate changelog entries

```bash
release changelog
```

This command updates the `## [Unreleased]` section using commits since the last
Git tag. Use `--dry-run` to print the section without writing.

### Validate repository state

```bash
release validate
```

Fails if there are uncommitted changes.

## Changelog format
Entries are grouped into the Keep a Changelog categories (Added, Fixed, Changed,
Removed, Deprecated, Security). Commits are inferred by prefix:
- `feat:` -> Added
- `fix:` -> Fixed
- `docs:`, `refactor:`, `perf:`, `style:` -> Changed
- `remove:` -> Removed

## Licensing
See `LICENSING.md` for the personal-use and professional-use terms.
