import 'dart:io';

class ChangelogService {
  final File _file;

  ChangelogService({File? file}) : _file = file ?? File('CHANGELOG.md');

  Future<void> upsertUnreleased(String section) async {
    if (!_file.existsSync()) {
      await _file.writeAsString(_initialChangelog(section));
      return;
    }

    final existing = await _file.readAsString();
    final updated = upsertUnreleasedInContent(existing, section);
    await _file.writeAsString(updated);
  }

  String upsertUnreleasedInContent(String content, String section) {
    final normalizedSection = section.trimRight();
    final unreleasedPattern =
        RegExp(r'## \[Unreleased\][\s\S]*?(?=\n## \[|$)');

    if (unreleasedPattern.hasMatch(content)) {
      return content.replaceFirst(unreleasedPattern, normalizedSection);
    }

    final sectionMatch = RegExp(r'\n## \[').firstMatch(content);
    if (sectionMatch != null) {
      final insertIndex = sectionMatch.start;
      final prefix = content.substring(0, insertIndex).trimRight();
      final suffix = content.substring(insertIndex);
      return '$prefix\n\n$normalizedSection\n$suffix';
    }

    final trimmed = content.trimRight();
    if (trimmed.isEmpty) {
      return _initialChangelog(normalizedSection);
    }

    return '$trimmed\n\n$normalizedSection\n';
  }

  String _initialChangelog(String section) {
    return '''# Changelog
All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

${section.trimRight()}
''';
  }
}
