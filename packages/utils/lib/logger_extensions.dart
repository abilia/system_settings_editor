import 'package:logging/logging.dart';

extension OnError on Logger {
  // ignore: prefer_void_to_null
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
