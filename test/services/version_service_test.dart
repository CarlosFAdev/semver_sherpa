import 'package:test/test.dart';
import 'package:semver_sherpa/release_executor.dart';
import 'package:semver_sherpa/services/version_service.dart';
import 'package:semver_sherpa/logger.dart';

class _FakeReleaseExecutor implements ReleaseExecutor {
  _FakeReleaseExecutor(this._currentVersion);

  final String _currentVersion;
  String? updatedVersion;

  @override
  String getCurrentVersion() => _currentVersion;

  @override
  Future<void> updateVersion(String newVersion) async {
    updatedVersion = newVersion;
  }

  @override
  Future<void> commit(String message) async {}

  @override
  Future<void> createTag(String tag) async {}

  @override
  Future<void> push() async {}

  @override
  Logger get getLogger => Logger();

  @override
  Future<String?> getLastTag() async => null;

  @override
  Future<List<String>> getCommitsSince(String? tag) async => [];
}

void main() {
  group('VersionService runRelease', () {
    test('increments patch and build metadata', () async {
      final executor = _FakeReleaseExecutor('1.2.3+4');
      final service = VersionService(executor);

      await service.runRelease(
        'patch',
        noCommit: true,
        noTag: true,
        noChangelog: true,
      );

      expect(executor.updatedVersion, '1.2.4+5');
    });

    test('increments build metadata when missing', () async {
      final executor = _FakeReleaseExecutor('1.2.3');
      final service = VersionService(executor);

      await service.runRelease(
        'minor',
        noCommit: true,
        noTag: true,
        noChangelog: true,
      );

      expect(executor.updatedVersion, '1.3.0+1');
    });

    test('bumps prerelease and build metadata', () async {
      final executor = _FakeReleaseExecutor('1.2.3-alpha.1+7');
      final service = VersionService(executor);

      await service.runRelease(
        'prerelease',
        noCommit: true,
        noTag: true,
        noChangelog: true,
      );

      expect(executor.updatedVersion, '1.2.3-alpha.2+8');
    });
  });
}
