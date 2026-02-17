import 'package:args/command_runner.dart';
import '../release_executor.dart';
import '../services/version_service.dart';
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

    if (!isValidVersionWithBuild(version)) {
      throw UsageException(
        'Invalid version: "$version". Must include build metadata (e.g., 1.2.3+4)',
        usage,
      );
    }

    final executor = dryRun ? DryRunReleaseExecutor() : RealReleaseExecutor();
    final service = VersionService(executor);

    await service.setVersion(
      version,
      noCommit: noCommit,
      noTag: noTag,
      push: push,
    );

    print('Version set to $version');
  }
}
