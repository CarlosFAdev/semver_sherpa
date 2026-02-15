import 'dart:io';

class PodspecService {
  File? _findPodspec() {
    final dir = Directory('ios');
    if (!dir.existsSync()) return null;

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.podspec'));

    return files.isEmpty ? null : files.first;
  }

  String? getCurrentVersion() {
    final file = _findPodspec();
    if (file == null) return null;

    final content = file.readAsStringSync();
    final match =
    RegExp(r"s\.version\s*=\s*'(.+)'").firstMatch(content);

    return match?.group(1);
  }

  void updateVersion(String newVersion) {
    final file = _findPodspec();
    if (file == null) return;

    final content = file.readAsStringSync();
    final updated = content.replaceFirst(
      RegExp(r"s\.version\s*=\s*'.+'"),
      "s.version = '$newVersion'",
    );

    file.writeAsStringSync(updated);
  }
}
