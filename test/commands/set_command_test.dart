import 'package:test/test.dart';
import 'package:args/command_runner.dart';
import 'package:semver_sherpa/commands/set_command.dart';

void main() {
  late CommandRunner<void> runner;

  setUp(() {
    runner = CommandRunner<void>('semver_sherpa', 'Test CLI')
      ..addCommand(SetCommand());
  });

  group('SetCommand validation', () {
    test('throws UsageException when no version is provided', () async {
      expect(
            () => runner.run(['set']),
        throwsA(isA<UsageException>()),
      );
    });

    test('throws UsageException for invalid version format', () async {
      expect(
            () => runner.run(['set', 'invalid_version']),
        throwsA(isA<UsageException>()),
      );
    });

    test('throws UsageException for incomplete version', () async {
      expect(
            () => runner.run(['set', '1.0']),
        throwsA(isA<UsageException>()),
      );
    });
  });

  group('SetCommand valid flows', () {
    test('accepts valid semantic version with build metadata', () async {
      expect(
            () => runner.run(['set', '1.2.3+4', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts prerelease version with build metadata', () async {
      expect(
            () => runner.run(['set', '1.2.3-alpha.1+5', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts build metadata', () async {
      expect(
            () => runner.run(['set', '1.2.3+4', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts --no-commit flag', () async {
      expect(
            () => runner.run(['set', '2.0.0+1', '--no-commit', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts --no-tag flag', () async {
      expect(
            () => runner.run(['set', '2.0.0+1', '--no-tag', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts --push flag', () async {
      expect(
            () => runner.run(['set', '2.0.0+1', '--push', '--dry-run']),
        returnsNormally,
      );
    });
  });
}
