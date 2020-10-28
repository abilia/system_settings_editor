import 'package:seagull/logging.dart';

extension OnError on Logger {
  Null logAndReturnNull(e, t) {
    severe('Corrupt data, could not apply function to $t', e);
    return null;
  }
}
