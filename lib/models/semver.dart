class SemVer {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final String? buildMetadata;

  SemVer(
      this.major,
      this.minor,
      this.patch, {
        this.preRelease,
        this.buildMetadata,
      });

  factory SemVer.parse(String input) {
    final regex = RegExp(
      r'^(\d+)\.(\d+)\.(\d+)'
      r'(?:-([0-9A-Za-z\-.]+))?'
      r'(?:\+([0-9A-Za-z\-.]+))?$',
    );

    final match = regex.firstMatch(input);

    if (match == null) {
      throw FormatException('Invalid version. Must follow SemVer.');
    }

    return SemVer(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      preRelease: match.group(4),
      buildMetadata: match.group(5),
    );
  }

  int get buildNumber =>
      buildMetadata == null ? 0 : int.tryParse(buildMetadata!) ?? 0;

  SemVer bumpMajor() => SemVer(major + 1, 0, 0);

  SemVer bumpMinor() => SemVer(major, minor + 1, 0);

  SemVer bumpPatch() => SemVer(major, minor, patch + 1);

  SemVer bumpPrerelease() {
    if (preRelease == null || preRelease!.isEmpty) {
      return copyWith(preRelease: 'alpha.1');
    }

    // If the prerelease ends with a number, increment it.
    final segments = preRelease!.split('.');
    final last = segments.last;
    final number = int.tryParse(last);

    if (number != null) {
      segments[segments.length - 1] = '${number + 1}';
      return copyWith(preRelease: segments.join('.'));
    }

    return copyWith(preRelease: '$preRelease.1');
  }

  SemVer withBuildNumber(int buildNumber) {
    return copyWith(buildMetadata: buildNumber.toString());
  }

  SemVer copyWith({
    int? major,
    int? minor,
    int? patch,
    String? preRelease,
    String? buildMetadata,
  }) {
    return SemVer(
      major ?? this.major,
      minor ?? this.minor,
      patch ?? this.patch,
      preRelease: preRelease ?? this.preRelease,
      buildMetadata: buildMetadata ?? this.buildMetadata,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('$major.$minor.$patch');

    if (preRelease != null) {
      buffer.write('-$preRelease');
    }

    if (buildMetadata != null) {
      buffer.write('+$buildMetadata');
    }

    return buffer.toString();
  }
}
