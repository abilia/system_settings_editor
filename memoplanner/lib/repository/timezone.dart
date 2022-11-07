import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:memoplanner/logging.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

export 'package:timezone/timezone.dart' show Location, TZDateTime, local;

Future<void> configureLocalTimeZone({Logger? log}) async {
  initializeTimeZones();
  final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  final location = tryGetLocation(currentTimeZone, log: log);
  setLocalLocation(location);
}

Location tryGetLocation(String timezone, {Logger? log}) {
  try {
    return getLocation(timezone);
  } on LocationNotFoundException {
    log?.warning(
      'could not find timezone named: $timezone, falls back to $local',
    );
    return local;
  }
}
