import 'dart:io';
import 'package:yaml/yaml.dart';

class PubspecService {
  final _file = File('pubspec.yaml');

  String getCurrentVersion() {
    final content = _file.readAsStringSync();
    final yaml = loadYaml(content);
    return yaml['version'];
  }

  void updateVersion(String newVersion) {
    final content = _file.readAsStringSync();
    final updated = content.replaceFirst(
      RegExp(r'version:\s.+'),
      'version: $newVersion',
    );
    _file.writeAsStringSync(updated);
  }
}
