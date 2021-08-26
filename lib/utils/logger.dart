import 'package:seagull/logging.dart';

extension OnError on Logger {
  Null logAndReturnNull(
    Object exception,
    StackTrace stacktrace,
    element,
    function,
  ) {
    severe('Corrupt data, could not apply $function to $element', exception,
        stacktrace);
    return null;
  }
}
