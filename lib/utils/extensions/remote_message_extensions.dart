import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';

extension AlarmKeyExtension on RemoteMessage {
  int? get alarmKey {
    final idString = data[AlarmCanceler.cancelAlarmKey];
    if (idString is String) {
      return int.tryParse(idString);
    }
    return null;
  }
}
