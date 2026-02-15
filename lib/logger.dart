enum LogLevel { info, warn, error, debug }

class Logger {
  final bool debugMode;

  Logger({this.debugMode = false});

  void info(String message) => _log(LogLevel.info, message);
  void warn(String message) => _log(LogLevel.warn, message);
  void error(String message) => _log(LogLevel.error, message);
  void debug(String message) {
    if (debugMode) _log(LogLevel.debug, message);
  }

  void _log(LogLevel level, String message) {
    final prefix = {
      LogLevel.info: '[INFO]',
      LogLevel.warn: '[WARN]',
      LogLevel.error: '[ERROR]',
      LogLevel.debug: '[DEBUG]',
    }[level]!;

    final color = {
      LogLevel.info: '\x1B[34m', // blue
      LogLevel.warn: '\x1B[33m', // yellow
      LogLevel.error: '\x1B[31m', // red
      LogLevel.debug: '\x1B[90m', // grey
    }[level]!;

    final reset = '\x1B[0m';
    print('$color$prefix $message$reset');
  }
}
