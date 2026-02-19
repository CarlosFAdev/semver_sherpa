import 'package:semver_sherpa/semver_sherpa.dart';

Future<void> main(List<String> arguments) async {
  final tool = ReleaseTool();
  await tool.run(arguments);
}
