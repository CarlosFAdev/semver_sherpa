import 'package:release_tool/release_tool.dart';

Future<void> main(List<String> arguments) async {
  final tool = ReleaseTool();
  await tool.run(arguments);
}
