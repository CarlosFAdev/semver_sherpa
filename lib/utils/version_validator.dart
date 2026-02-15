final RegExp _semverRegex = RegExp(
  r'^(0|[1-9]\d*)\.' // major
  r'(0|[1-9]\d*)\.' // minor
  r'(0|[1-9]\d*)' // patch
  r'(?:-('
  r'[0-9A-Za-z-]+'
  r'(?:\.[0-9A-Za-z-]+)*'
  r'))?'
  r'(?:\+('
  r'[0-9A-Za-z-]+'
  r'(?:\.[0-9A-Za-z-]+)*'
  r'))?$',
);

bool isValidVersion(String version) {
  return _semverRegex.hasMatch(version);
}
