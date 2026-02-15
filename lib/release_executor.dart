import 'dart:io';
import 'package:yaml/yaml.dart';
import 'logger.dart';

abstract class GitHistoryProvider {
  Future<String?> getLastTag();
  Future<List<String>> getCommitsSince(String? tag);
}

abstract class VersionReader {
  String getCurrentVersion();
}

abstract class ReleaseExecutor extends VersionReader implements GitHistoryProvider {
  Future<void> updateVersion(String newVersion);
  Future<void> commit(String message);
  Future<void> createTag(String tag);
  Future<void> push();

  Logger get getLogger;
}

/// Real executor that modifies files and runs git commands
class RealReleaseExecutor implements ReleaseExecutor {
  final Logger logger;

  RealReleaseExecutor({Logger? logger}) : logger = logger ?? Logger();

  @override
  Logger get getLogger => logger;

  @override
  Future<String?> getLastTag() async {
    final result =
    await Process.run('git', ['describe', '--tags', '--abbrev=0']);

    if (result.exitCode != 0) {
      return null; // No tags yet
    }

    return (result.stdout as String).trim();
  }

  @override
  Future<List<String>> getCommitsSince(String? tag) async {
    final args = tag == null
        ? ['log', '--pretty=format:%s']
        : ['log', '$tag..HEAD', '--pretty=format:%s'];

    final result = await Process.run('git', args);

    if (result.exitCode != 0) {
      return [];
    }

    return (result.stdout as String)
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }


  @override
  String getCurrentVersion() {
    final file = File('pubspec.yaml');
    if (!file.existsSync()) {
      logger.error('pubspec.yaml not found');
      throw Exception('pubspec.yaml not found');
    }
    final content = file.readAsStringSync();
    final yaml = loadYaml(content);
    return yaml['version'];
  }

  @override
  Future<void> updateVersion(String newVersion) async {
    final file = File('pubspec.yaml');
    if (!file.existsSync()) {
      logger.error('pubspec.yaml not found');
      throw Exception('pubspec.yaml not found');
    }

    final content = file.readAsStringSync();
    final updated = content.replaceFirst(
      RegExp(r'version:\s*.*'),
      'version: $newVersion',
    );
    file.writeAsStringSync(updated);
    logger.info('Updated pubspec.yaml to version $newVersion');
  }

  @override
  Future<void> commit(String message) async {
    await _runGitOrThrow(['add', '.'], failureMessage: 'Failed to stage changes.');
    final result =
    await _runGitOrThrow(['commit', '-m', message], failureMessage: 'Failed to create commit.');
    if (result.stdout.toString().isNotEmpty) {
      logger.info(result.stdout.toString());
    }
  }

  @override
  Future<void> createTag(String tag) async {
    final result =
    await _runGitOrThrow(['tag', tag], failureMessage: 'Failed to create tag.');
    logger.info(result.stdout.toString());
  }

  Future<bool> _hasCommitsToPush() async {
    final result = await Process.run('git', ['cherry', '-v']);
    if (result.exitCode != 0) {
      logger.warn('Failed to check local commits: ${result.stderr.toString().trim()}');
      return true;
    }
    return (result.stdout as String).trim().isNotEmpty;
  }

  Future<bool> _hasTagsToPush() async {
    final localResult = await Process.run('git', ['tag']);
    final remoteResult = await Process.run('git', ['ls-remote', '--tags', 'origin']);

    final localTags = (localResult.stdout as String)
        .trim()
        .split('\n')
        .where((t) => t.isNotEmpty)
        .toList();

    if (remoteResult.exitCode != 0) {
      logger.warn('Failed to check remote tags: ${remoteResult.stderr.toString().trim()}');
      return true;
    }

    final remoteTags = (remoteResult.stdout as String)
        .trim()
        .split('\n')
        .where((t) => t.isNotEmpty)
        .map((line) => line.split('\t').last)
        .where((ref) => ref.startsWith('refs/tags/'))
        .map((ref) => ref.substring('refs/tags/'.length))
        .map((tag) => tag.endsWith('^{}') ? tag.substring(0, tag.length - 3) : tag)
        .toSet();

    return localTags.any((t) => !remoteTags.contains(t));
  }

  @override
  Future<void> push() async {
    final commitsToPush = await _hasCommitsToPush();
    final tagsToPush = await _hasTagsToPush();

    if (!commitsToPush && !tagsToPush) {
      logger.info('Nothing to push: no new commits or tags.');
      return;
    }

    if (commitsToPush) {
      final result = await _runGitOrThrow(['push'], failureMessage: 'Failed to push commits.');
      logger.info(result.stdout.toString());
    }

    if (tagsToPush) {
      final result =
      await _runGitOrThrow(['push', '--tags'], failureMessage: 'Failed to push tags.');
      logger.info(result.stdout.toString());
    }

    logger.info('Push completed.');
  }

  Future<ProcessResult> _runGitOrThrow(
    List<String> args, {
    required String failureMessage,
  }) async {
    final result = await Process.run('git', args);
    if (result.exitCode != 0) {
      final error = result.stderr.toString().trim();
      throw Exception('$failureMessage ${error.isEmpty ? '' : '($error)'}'.trim());
    }
    if (result.stderr.toString().trim().isNotEmpty) {
      logger.warn(result.stderr.toString());
    }
    return result;
  }
}

/// Dry-run executor that only logs actions
class DryRunReleaseExecutor implements ReleaseExecutor {
  final Logger logger;

  DryRunReleaseExecutor({Logger? logger}) : logger = logger ?? Logger();

  @override
  Logger get getLogger => logger;

  @override
  Future<String?> getLastTag() async {
    logger.info('[DRY RUN] Would retrieve last git tag');
    return null;
  }

  @override
  Future<List<String>> getCommitsSince(String? tag) async {
    logger.info('[DRY RUN] Would retrieve commits since ${tag ?? "start"}');
    return [];
  }

  @override
  String getCurrentVersion() {
    final file = File('pubspec.yaml');
    if (!file.existsSync()) {
      logger.error('pubspec.yaml not found');
      throw Exception('pubspec.yaml not found');
    }
    final content = file.readAsStringSync();
    final yaml = loadYaml(content);
    return yaml['version'];
  }

  @override
  Future<void> updateVersion(String newVersion) async {
    logger.info('[DRY RUN] Would update pubspec.yaml to version $newVersion');
  }

  @override
  Future<void> commit(String message) async {
    logger.info('[DRY RUN] Would create commit: "$message"');
  }

  @override
  Future<void> createTag(String tag) async {
    logger.info('[DRY RUN] Would create tag: $tag');
  }

  @override
  Future<void> push() async {
    logger.info('[DRY RUN] Would push commits and tags (if any exist)');
  }
}
