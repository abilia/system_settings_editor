import 'package:seagull/models/all.dart';

extension AlarmExtension on Iterable<AbiliaTimer> {
  Iterable<TimerAlarm> toAlarm() {
    return map(TimerAlarm.new);
  }
}
