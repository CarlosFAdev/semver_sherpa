import 'package:test/test.dart';
import 'package:release_tool/services/changelog_service.dart';

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
}
