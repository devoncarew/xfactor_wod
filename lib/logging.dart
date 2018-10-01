import 'dart:convert';
import 'dart:developer' as developer;

import 'package:logs/logs.dart' as logging;

class Log {
  final String channelName;

  Log(this.channelName) {
    logging.registerLoggingChannel(channelName);
  }

  void enable() {
    logging.enableLogging(channelName);
  }

  bool get isEnabled => logging.shouldLog(channelName);

  void log(String message) {
    // TODO: this gets encoded when I don't want it to be
    logging.log(channelName, () => message);
  }

  /// [data] should be jsonable
  void logData(Object data, {Object toEncodable(Object nonEncodable)}) {
    if (isEnabled) {
      logging.log(channelName, () {
        return jsonEncode(data, toEncodable: toEncodable);
      });
    }
  }

  void logError(Object error, {StackTrace stackTrace, String message}) {
    if (isEnabled) {
      message ??= error.toString();

      developer.log(
        message,
        name: channelName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
