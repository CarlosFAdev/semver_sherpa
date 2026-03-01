// ignore_for_file: unnecessary_library_name

/// Command library for changelog generation operations.
library changelog_command;

import 'package:args/command_runner.dart';
import '../changelog_generator.dart';
import '../release_executor.dart';
import '../services/changelog_service.dart';

/// Generates or previews the `Unreleased` changelog section.
class ChangelogCommand extends Command<void> {
  @override
  String get name => 'changelog';
  @override
  String get description =>
      'Generate Unreleased changelog entries from commits since the last tag';

  /// Creates the `changelog` command and its options.
  ChangelogCommand() {
    argParser.addFlag(
      'dry-run',
      negatable: false,
      help: 'Print the Unreleased section without writing to CHANGELOG.md',
    );
  }

  @override
  /// Builds changelog content from git history and writes it to `CHANGELOG.md`.
  Future<void> run() async {
    final dryRun = argResults!['dry-run'] as bool;
    final executor = RealReleaseExecutor();
    final generator = ChangelogGenerator(executor);
    final section = await generator.generateUnreleased();

    if (dryRun) {
      print(section);
      return;
    }

    final service = ChangelogService();
    await service.upsertUnreleased(section);
    print('Updated CHANGELOG.md with Unreleased changes.');
  }
}
