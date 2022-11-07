import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

extension AlarmKeyExtension on RemoteMessage {
  String? get popAlarmKey {
    final idString = data[RemoteAlarm.popKey];
    if (idString is String) {
      return idString;
    }
    return null;
  }

  int? get stopAlarmSoundKey {
    final idString = data[RemoteAlarm.stopSoundKey];
    if (idString is String) {
      return int.tryParse(idString);
    }
    return null;
  }
}
