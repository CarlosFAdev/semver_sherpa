import 'dart:io';
import 'package:args/command_runner.dart';

import 'commands/bump_command.dart';
import 'commands/set_command.dart';
import 'commands/validate_command.dart';

class ReleaseTool {
  final CommandRunner<void> _runner;

  ReleaseTool()
      : _runner = CommandRunner<void>(
    'release-tool',
    'A CLI tool to manage versions and releases',
  ) {
    _runner
      ..addCommand(BumpCommand())
      ..addCommand(SetCommand())
      ..addCommand(ValidateCommand());
  }

  Future<void> run(List<String> arguments) async {
    try {
      await _runner.run(arguments);
    } on UsageException catch (e) {
      print(e);
      exit(64);
    } catch (e) {
      print('Error: $e');
      exit(1);
    }
  }
}
