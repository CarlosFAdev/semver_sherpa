import 'dart:io';
import 'package:args/command_runner.dart';

class ValidateCommand extends Command<void> {
  @override
  String get name => 'validate';
  @override
  String get description => 'Validate the status of the repository';

  @override
  Future<void> run() async {
    final result = await Process.run('git', ['status', '--porcelain']);

    if ((result.stdout as String).trim().isNotEmpty) {
      throw Exception('The repository has uncommitted changes.');
    }

    print('Clean repository ✅');
  }
}
