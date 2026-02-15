import 'package:args/command_runner.dart';
import '../release_executor.dart';
import '../utils/version_validator.dart';

class SetCommand extends Command<void> {
  @override
  String get name => 'set';
  @override
  String get description => 'Set the version explicitly';

  SetCommand() {
    argParser
      ..addFlag('no-commit', negatable: false, help: 'Do not create a commit')
      ..addFlag('no-tag', negatable: false, help: 'Do not create a tag')
      ..addFlag('dry-run', negatable: false, help: 'Simulate the change')
      ..addFlag('push', negatable: false, help: 'Push changes after setting version');
  }

  @override
  Future<void> run() async {
    final noCommit = argResults!['no-commit'] as bool;
    final noTag = argResults!['no-tag'] as bool;
    final dryRun = argResults!['dry-run'] as bool;
    final push = argResults!['push'] as bool;

    if (argResults!.rest.isEmpty) {
      throw UsageException('You must specify the version to set', usage);
    }

    final version = argResults!.rest.first;

    if (!isValidVersion(version)) {
      throw UsageException(
        'Invalid version: "$version". Must be valid SemVer (e.g., 1.2.3 or 1.2.3+4)',
        usage,
      );
    }

    final executor = dryRun ? DryRunReleaseExecutor() : RealReleaseExecutor();

    // Update version
    await executor.updateVersion(version);

    // Tag only if commit is created
    final canTag = !noCommit && !noTag;

    if (!noCommit) {
      await executor.commit('chore(release): $version');
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

    print('Version set to $version');
  }
}
