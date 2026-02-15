import 'package:args/command_runner.dart';
import '../release_executor.dart';
import '../services/version_service.dart';

class BumpCommand extends Command<void> {
  @override
  String get name => 'bump';
  @override
  String get description => 'Increment the version (major, minor, patch)';

  BumpCommand() {
    argParser
      ..addFlag('no-commit', negatable: false, help: 'Do not create a commit')
      ..addFlag('no-tag', negatable: false, help: 'Do not create a tag')
      ..addFlag('dry-run', negatable: false, help: 'Simulate the release without changes')
      ..addFlag('push', negatable: false, help: 'Push changes after the release')
      ..addFlag('no-changelog', negatable: false, help: 'Do not generate a Changelog');
  }

  @override
  Future<void> run() async {
    final noCommit = argResults!['no-commit'] as bool;
    final noTag = argResults!['no-tag'] as bool;
    final dryRun = argResults!['dry-run'] as bool;
    final push = argResults!['push'] as bool;
    final noChangelog = argResults!['no-changelog'] as bool;

    if (argResults!.rest.isEmpty) {
      throw UsageException('You must specify bump type: major, minor, or patch', usage);
    }

    final bumpType = argResults!.rest.first;
    final validBumps = ['major', 'minor', 'patch'];

    if (!validBumps.contains(bumpType)) {
      throw UsageException(
        'Invalid bump type: "$bumpType". Must be one of: major, minor, patch',
        usage,
      );
    }

    final executor = dryRun ? DryRunReleaseExecutor() : RealReleaseExecutor();
    final service = VersionService(executor);

    await service.runRelease(
      bumpType,
      noCommit: noCommit,
      noTag: noTag,
      push: push,
      noChangelog: noChangelog || dryRun
    );
  }
}
