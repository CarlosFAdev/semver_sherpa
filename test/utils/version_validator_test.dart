import 'package:test/test.dart';
import 'package:release_tool/utils/version_validator.dart';

void main() {
  group('isValidVersion', () {
    test('accepts standard versions', () {
      expect(isValidVersion('1.2.3'), isTrue);
    });

    test('accepts prerelease versions', () {
      expect(isValidVersion('1.2.3-alpha.1'), isTrue);
    });

    test('accepts build metadata', () {
      expect(isValidVersion('1.2.3+4'), isTrue);
      expect(isValidVersion('1.2.3+build.5'), isTrue);
    });

    test('rejects invalid versions', () {
      expect(isValidVersion('1.2'), isFalse);
      expect(isValidVersion('1.2.3.4'), isFalse);
      expect(isValidVersion('1.2.3+'), isFalse);
    });
  });

  group('isValidVersionWithBuild', () {
    test('accepts versions with build metadata', () {
      expect(isValidVersionWithBuild('1.2.3+4'), isTrue);
      expect(isValidVersionWithBuild('1.2.3-alpha.1+build.5'), isTrue);
    });

    test('rejects versions without build metadata', () {
      expect(isValidVersionWithBuild('1.2.3'), isFalse);
      expect(isValidVersionWithBuild('1.2.3-alpha.1'), isFalse);
    });
  });
}
