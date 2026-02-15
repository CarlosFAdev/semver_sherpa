import 'dart:io';

import '../changelog_generator.dart';
import '../release_executor.dart';
import '../utils/version_validator.dart';

class VersionService {
  final ReleaseExecutor executor;

  VersionService(this.executor);

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
        await ChangelogGenerator(executor).generate(nextVersion);

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

    if (!noCommit) {
      await executor.commit('chore: set version to $version');
    }

    if (!noTag) {
      await executor.createTag('v$version');
    }

    if (push) {
      await executor.push();
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

    final buildParts = current.split('+');
    final versionCoreAndPrerelease = buildParts[0];
    final build = buildParts.length > 1 ? int.tryParse(buildParts[1]) ?? 0 : 0;

    final prereleaseSplit = versionCoreAndPrerelease.split('-');
    final core = prereleaseSplit[0];
    final prerelease =
    prereleaseSplit.length > 1 ? prereleaseSplit[1] : null;

    final parts = core.split('.');
    int major = int.parse(parts[0]);
    int minor = int.parse(parts[1]);
    int patch = int.parse(parts[2]);

    String nextVersion;

    switch (bumpType) {
      case 'major':
        nextVersion = '${major + 1}.0.0';
        break;

      case 'minor':
        nextVersion = '$major.${minor + 1}.0';
        break;

      case 'patch':
        nextVersion = '$major.$minor.${patch + 1}';
        break;

      case 'prerelease':
        nextVersion = _nextPrerelease(major, minor, patch, prerelease);
        break;

      default:
        throw ArgumentError('Invalid bump type');
    }
    
    final nextBuild = build + 1;
    return '$nextVersion+$nextBuild';
  }

  String _nextPrerelease(
      int major,
      int minor,
      int patch,
      String? prerelease,
      ) {
    if (prerelease == null) {
      return '$major.$minor.$patch-alpha.1';
    }

    final segments = prerelease.split('.');
    final last = segments.last;

    final number = int.tryParse(last);

    if (number != null) {
      segments[segments.length - 1] = '${number + 1}';
      return '$major.$minor.$patch-${segments.join('.')}';
    }

    return '$major.$minor.$patch-$prerelease.1';
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

abstract class VersionReader {
  Future<String> getCurrentVersion();
}
