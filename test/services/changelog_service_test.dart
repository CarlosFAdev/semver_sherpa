import 'package:test/test.dart';
import 'package:semver_sherpa/services/changelog_service.dart';

void main() {
  group('ChangelogService upsertUnreleasedInContent', () {
    test('inserts Unreleased before first version section', () {
      final service = ChangelogService();
      final content = '''
# Changelog
All notable changes.

## [1.0.0] - 2024-01-01
- Initial release.
''';
      final section = '''
## [Unreleased]

### Added
- New feature.
''';

      final updated = service.upsertUnreleasedInContent(content, section);

      expect(updated, contains('## [Unreleased]'));
      expect(updated.indexOf('## [Unreleased]'),
          lessThan(updated.indexOf('## [1.0.0]')));
    });

    test('replaces existing Unreleased section', () {
      final service = ChangelogService();
      final content = '''
# Changelog

## [Unreleased]

### Added
- Old entry.

## [1.0.0] - 2024-01-01
- Initial release.
''';
      final section = '''
## [Unreleased]

### Added
- New entry.
''';

      final updated = service.upsertUnreleasedInContent(content, section);

      expect(updated, contains('- New entry.'));
      expect(updated.contains('- Old entry.'), isFalse);
    });

    test('creates initial changelog when empty', () {
      final service = ChangelogService();
      final section = '''
## [Unreleased]

_No significant changes._
''';

      final updated = service.upsertUnreleasedInContent('', section);

      expect(updated, contains('# Changelog'));
      expect(updated, contains('Keep a Changelog'));
      expect(updated, contains('## [Unreleased]'));
    });
  });

  group('ChangelogService insertReleaseInContent', () {
    test('inserts release after Unreleased section', () {
      final service = ChangelogService();
      final content = '''
# Changelog

## [Unreleased]

_No significant changes._

## [1.0.0] - 2024-01-01
- Initial release.
''';
      final section = '''
## [1.1.0] - 2024-02-01

### Added
- New feature.
''';

      final updated = service.insertReleaseInContent(content, section);

      expect(updated.indexOf('## [Unreleased]'),
          lessThan(updated.indexOf('## [1.1.0]')));
      expect(updated.indexOf('## [1.1.0]'),
          lessThan(updated.indexOf('## [1.0.0]')));
    });

    test('inserts release before first version when Unreleased is missing', () {
      final service = ChangelogService();
      final content = '''
# Changelog
All notable changes.

## [1.0.0] - 2024-01-01
- Initial release.
''';
      final section = '''
## [1.1.0] - 2024-02-01

### Added
- New feature.
''';

      final updated = service.insertReleaseInContent(content, section);

      expect(updated.indexOf('## [1.1.0]'),
          lessThan(updated.indexOf('## [1.0.0]')));
    });
  });
}
