// ignore_for_file: unnecessary_library_name

/// Changelog generation utilities backed by git commit history.
library changelog_generator;

import 'release_executor.dart';

typedef DateTimeProvider = DateTime Function();

/// Builds Keep a Changelog sections from categorized commit history.
class ChangelogGenerator {
  final ReleaseExecutor executor;
  final DateTimeProvider _now;

  /// Creates a changelog generator with an optional deterministic clock.
  ChangelogGenerator(this.executor, {DateTimeProvider? now})
    : _now = now ?? DateTime.now;

  /// Generates a versioned changelog section for [newVersion].
  Future<String> generate(String newVersion) async {
    final lastTag = await executor.getLastTag();
    final commits = await executor.getCommitsSince(lastTag);

    final filtered = commits.where((c) => !_isReleaseCommit(c)).toList();

    if (filtered.isEmpty) {
      return _emptySection(newVersion);
    }

    final categorized = _categorize(filtered);

    return _buildSection(newVersion, categorized);
  }

  /// Generates the `Unreleased` changelog section.
  Future<String> generateUnreleased() async {
    final lastTag = await executor.getLastTag();
    final commits = await executor.getCommitsSince(lastTag);

    final filtered = commits.where((c) => !_isReleaseCommit(c)).toList();

    if (filtered.isEmpty) {
      return _emptyUnreleased();
    }

    final categorized = _categorize(filtered);
    return _buildUnreleasedSection(categorized);
  }

  bool _isReleaseCommit(String message) {
    final lower = message.toLowerCase().trim();

    return lower.startsWith('chore(release)') ||
        lower.startsWith('chore: release') ||
        lower.startsWith('release:') ||
        lower.startsWith('build: release') ||
        RegExp(r'^v?\d+\.\d+\.\d+').hasMatch(lower);
  }

  Map<String, List<String>> _categorize(List<String> commits) {
    final categories = {
      'Added': <String>[],
      'Changed': <String>[],
      'Deprecated': <String>[],
      'Removed': <String>[],
      'Fixed': <String>[],
      'Security': <String>[],
    };

    for (final commit in commits) {
      final clean = _cleanMessage(commit);

      if (commit.startsWith('feat')) {
        categories['Added']!.add(clean);
      } else if (commit.startsWith('fix')) {
        categories['Fixed']!.add(clean);
      } else if (commit.startsWith('refactor') ||
          commit.startsWith('perf') ||
          commit.startsWith('style')) {
        categories['Changed']!.add(clean);
      } else if (commit.startsWith('docs')) {
        categories['Changed']!.add(clean);
      } else if (commit.startsWith('remove')) {
        categories['Removed']!.add(clean);
      }
    }

    return categories;
  }

  String _cleanMessage(String message) {
    return message.replaceFirst(RegExp(r'^\w+(\(.+\))?:\s*'), '').trim();
  }

  String _buildSection(String version, Map<String, List<String>> categories) {
    final buffer = StringBuffer();
    final today = _formatDate(_now());

    buffer.writeln('## [$version] - $today');
    buffer.writeln();

    categories.forEach((title, items) {
      if (items.isEmpty) return;

      buffer.writeln('### $title');
      for (final item in items) {
        buffer.writeln('- $item');
      }
      buffer.writeln();
    });

    return buffer.toString();
  }

  String _buildUnreleasedSection(Map<String, List<String>> categories) {
    final buffer = StringBuffer();

    buffer.writeln('## [Unreleased]');
    buffer.writeln();

    categories.forEach((title, items) {
      if (items.isEmpty) return;

      buffer.writeln('### $title');
      for (final item in items) {
        buffer.writeln('- $item');
      }
      buffer.writeln();
    });

    if (buffer.toString().trim() == '## [Unreleased]') {
      return _emptyUnreleased();
    }

    return buffer.toString();
  }

  String _emptySection(String version) {
    final today = _formatDate(_now());

    return '''
## [$version] - $today

_No significant changes._

''';
  }

  String _emptyUnreleased() {
    return '''
## [Unreleased]

_No significant changes._

''';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
