import 'package:process_run/process_run.dart';

class GitService {
  final _shell = Shell(throwOnError: true);

  Future<void> addAndCommit(String message) async {
    await _shell.run('''
      git add .
      git commit -m "$message"
    ''');
  }

  Future<void> createTag(String version) async {
    await _shell.run('git tag $version');
  }

  Future<bool> isWorkingTreeClean() async {
    final result = await _shell.run('git status --porcelain');
    return result.first.stdout.toString().trim().isEmpty;
  }

  Future<String> currentBranch() async {
    final result =
    await _shell.run('git rev-parse --abbrev-ref HEAD');
    return result.first.stdout.toString().trim();
  }
}
