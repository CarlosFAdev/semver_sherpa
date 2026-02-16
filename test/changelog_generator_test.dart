import 'package:test/test.dart';
import 'package:release_tool/changelog_generator.dart';
import 'package:release_tool/release_executor.dart';
import 'package:release_tool/logger.dart';

class _FakeReleaseExecutor implements ReleaseExecutor {
  _FakeReleaseExecutor(this._commits);

  final List<String> _commits;

  @override
  Future<String?> getLastTag() async => null;

  @override
  Future<List<String>> getCommitsSince(String? tag) async => _commits;

  @override
  String getCurrentVersion() => '1.0.0';

  @override
  Future<void> updateVersion(String newVersion) async {}

  @override
  Future<void> commit(String message) async {}

  @override
  Future<void> createTag(String tag) async {}

  @override
  Future<void> push() async {}

  @override
  Logger get getLogger => Logger();
}

void main() {
  group('ChangelogGenerator', () {
    test('uses provided date and empty section when no changes', () async {
      final executor = _FakeReleaseExecutor(['chore: release 1.0.0']);
      final generator = ChangelogGenerator(
        executor,
        now: () => DateTime(2024, 1, 2),
      );

      final output = await generator.generate('1.0.1');

      expect(output, contains('## [1.0.1] - 2024-01-02'));
      expect(output, contains('_No significant changes._'));
    });

    test('categorizes commits with deterministic date', () async {
      final executor = _FakeReleaseExecutor([
        'feat: add thing',
        'fix: handle error',
        'docs: update readme',
      ]);
      final generator = ChangelogGenerator(
        executor,
        now: () => DateTime(2024, 2, 3),
      );

      final output = await generator.generate('1.1.0');

      expect(output, contains('## [1.1.0] - 2024-02-03'));
      expect(output, contains('### Added'));
      expect(output, contains('- add thing'));
      expect(output, contains('### Fixed'));
      expect(output, contains('- handle error'));
      expect(output, contains('### Changed'));
      expect(output, contains('- update readme'));
    });
  });
}
