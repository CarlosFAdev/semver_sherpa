# Usage Example (pub.dev)

This example shows a typical flow for Dart/Flutter projects.

## Installation

```bash
dart pub global activate semver_sherpa
```

## Preparation
Your project must have a `pubspec.yaml` with a `version:` field.

## Bump version and changelog

```bash
semver_sherpa bump patch
```

Common options:
- `--dry-run` simulate without changing files
- `--no-commit` update files without committing
- `--no-tag` skip tag creation
- `--no-changelog` skip changelog generation

## Generate changelog without writing files

```bash
semver_sherpa changelog --dry-run
```

## Validate repository state

```bash
semver_sherpa validate
```
