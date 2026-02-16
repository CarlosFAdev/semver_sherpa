import 'dart:io';

import '../changelog_generator.dart';
import '../models/semver.dart';
import '../release_executor.dart';
import '../utils/version_validator.dart';

class VersionService {
  final ReleaseExecutor executor;
  final DateTimeProvider _now;

  VersionService(this.executor, {DateTimeProvider? now})
      : _now = now ?? DateTime.now;

  Future<void> runRelease(
      String bumpType, {
        bool noCommit = false,
        bool noTag = false,
        bool push = false,
        bool noChangelog = false,
      }) async {
    if (!_isValidBumpType(bumpType)) {
      throw ArgumentError('Invalid bump type: $bumpType');
    }

    final nextVersion = await _calculateNextVersion(bumpType);

    await executor.updateVersion(nextVersion);

    // Tag only if commit is created
    final canTag = !noCommit && !noTag;

    if (!noCommit) {
      if (!noChangelog) {
        final changelog =
        await ChangelogGenerator(executor, now: _now).generate(nextVersion);

        await _appendToChangelog(changelog);
      }

      await executor.commit('chore: release $nextVersion');
    } else if (!noTag) {
      executor.getLogger.warn('[WARNING] Cannot generate changelog because commit was skipped.');
      executor.getLogger.warn('[WARNING] Cannot create tag because commit was skipped.');
    }

    if (canTag) {
      await executor.createTag('v$nextVersion');
    }

    if (!noCommit) {
      if (push) await executor.push();
    } else if (push) {
      executor.getLogger.warn('[WARNING] Cannot push because commit was skipped.');
    }
  }

  Future<void> setVersion(
      String version, {
        bool noCommit = false,
        bool noTag = false,
        bool push = false,
      }) async {
    if (!isValidVersion(version)) {
      throw ArgumentError('Invalid semantic version format');
    }

    await executor.updateVersion(version);

    final canTag = !noCommit && !noTag;

    if (!noCommit) {
      await executor.commit('chore: set version to $version');
    } else if (!noTag) {
      executor.getLogger.warn('[WARNING] Cannot create tag because commit was skipped.');
    }

    if (canTag) {
      await executor.createTag('v$version');
    }

    if (!noCommit) {
      if (push) await executor.push();
    } else if (push) {
      executor.getLogger.warn('[WARNING] Cannot push because commit was skipped.');
    }
  }

  SemVer _bumpVersion(SemVer current, String bumpType) {
    switch (bumpType) {
      case 'major':
        return current.bumpMajor();
      case 'minor':
        return current.bumpMinor();
      case 'patch':
        return current.bumpPatch();
      case 'prerelease':
        return current.bumpPrerelease();
      default:
        throw ArgumentError('Invalid bump type');
    }
  }

  bool _isValidBumpType(String type) {
    return type == 'major' ||
        type == 'minor' ||
        type == 'patch' ||
        type == 'prerelease';
  }

  Future<String> _calculateNextVersion(String bumpType) async {
    final current = await _getCurrentVersionSafe();
    final parsed = SemVer.parse(current);
    final next = _bumpVersion(parsed, bumpType);
    // Always advance build metadata for each release, even on prerelease bumps.
    final nextBuild = parsed.buildNumber + 1;
    return next.withBuildNumber(nextBuild).toString();
  }

  Future<String> _getCurrentVersionSafe() async {
    // Directly call getCurrentVersion on the executor, as both RealReleaseExecutor
    // and DryRunReleaseExecutor implement it.
    return executor.getCurrentVersion();
  }

  Future<void> _appendToChangelog(String content) async {
    final file = File('CHANGELOG.md');

    if (!file.existsSync()) {
      await file.writeAsString('# Changelog\n\n$content');
      return;
    }

    final existing = await file.readAsString();
    final updated = existing.replaceFirst(
      '# Changelog',
      '# Changelog\n\n$content',
    );

    await file.writeAsString(updated);
  }
}
