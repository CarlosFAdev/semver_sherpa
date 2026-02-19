import 'package:test/test.dart';
import 'package:args/command_runner.dart';
import 'package:semver_sherpa/commands/bump_command.dart';

void main() {
  late CommandRunner<void> runner;

  setUp(() {
    runner = CommandRunner<void>('semver_sherpa', 'Test CLI')
      ..addCommand(BumpCommand());
  });

  group('BumpCommand validation', () {
    test('throws UsageException when no bump type is provided', () async {
      expect(
            () => runner.run(['bump']),
        throwsA(isA<UsageException>()),
      );
    });

    test('throws UsageException for invalid bump type', () async {
      expect(
            () => runner.run(['bump', 'invalid']),
        throwsA(isA<UsageException>()),
      );
    });
  });

  group('BumpCommand valid flows', () {
    test('accepts patch bump', () async {
      expect(
            () => runner.run(['bump', 'patch', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts minor bump', () async {
      expect(
            () => runner.run(['bump', 'minor', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts major bump', () async {
      expect(
            () => runner.run(['bump', 'major', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts --no-commit flag', () async {
      expect(
            () => runner.run(['bump', 'patch', '--no-commit', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts --no-tag flag', () async {
      expect(
            () => runner.run(['bump', 'patch', '--no-tag', '--dry-run']),
        returnsNormally,
      );
    });

    test('accepts --push flag', () async {
      expect(
            () => runner.run(['bump', 'patch', '--push', '--dry-run']),
        returnsNormally,
      );
    });
  });
}
