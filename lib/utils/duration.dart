import 'package:seagull/i18n/all.dart';

extension IntToDuration on int {
  Duration days() => Duration(days: this);
  Duration hours() => Duration(hours: this);
  Duration minutes() => Duration(minutes: this);
  Duration seconds() => Duration(seconds: this);
  Duration milliseconds() => Duration(milliseconds: this);
}

const iOSMaxAlarmDuration = Duration(seconds: 30);

Duration maxDuration(Duration a, Duration b) => a > b ? a : b;

extension DurationExtensions on Duration {
  String toDurationString(Translated translator, {bool shortMin = true}) {
    if (inDays > 1) return '$inDays ${translator.days}';
    if (inDays == 1) return '$inDays ${translator.day}';
    if (inHours > 1) return '$inHours ${translator.hours}';
    if (inHours == 1) return '$inHours ${translator.hour}';
    if (inMinutes < 1) return '$inSeconds ${translator.seconds}';
    if (inSeconds == 1) return '$inSeconds ${translator.second}';
    if (shortMin) return '$inMinutes ${translator.min}';
    if (inMinutes == 1) return '$inMinutes ${translator.minute}';
    return '$inMinutes ${translator.minutes}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  String toHMS() {
    String twoDigitMinutes = _twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _twoDigits(inSeconds.remainder(60));
    return '${_twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  String toHMSorMS() {
    if (inHours > 0) return toHMS();
    return '${_twoDigits(inMinutes)}:${_twoDigits(inSeconds.remainder(60))}';
  }

  String toUntilString(Translated translater) {
    final sb = StringBuffer();
    if (inHours > 0) {
      sb.writeln('$inHours ${translater.h}');
    }
    final minutes = inMinutes % Duration.minutesPerHour;
    if (minutes > 0) {
      sb.writeln('$minutes ${translater.min}');
    }
    return sb.toString();
  }

  String toReminderHeading(Translated translater, bool before) {
    final sb = StringBuffer();

    // https://en.wikipedia.org/wiki/Inessive_case
    if (before && inDays >= 1 && translater.dayInessive.isNotEmpty) {
      sb.write('$inDays ${translater.dayInessive} ');
    } else {
      if (inDays > 1) sb.write('$inDays ${translater.days} ');
      if (inDays == 1) sb.write('$inDays ${translater.day} ');
    }

    final hours = inHours % Duration.hoursPerDay;

    if (before && hours >= 1 && translater.hourInessive.isNotEmpty) {
      sb.write('$hours ${translater.hourInessive} ');
    } else {
      if (hours > 1) sb.write('$hours ${translater.hours} ');
      if (hours == 1) sb.write('$hours ${translater.hour} ');
    }

    final minutes = inMinutes % Duration.minutesPerHour;
    if (before && minutes >= 1 && translater.minuteInessive.isNotEmpty) {
      sb.write('$minutes ${translater.minuteInessive} ');
    } else {
      if (minutes > 1) sb.write('$minutes ${translater.minutes} ');
      if (minutes == 1) sb.write('$minutes ${translater.minute} ');
    }

    final inOrAgo = before ? translater.inTime : translater.timeAgo;
    return inOrAgo(sb.toString().trim());
  }

  int inDots(int minutesPerDot, roundingMinute) =>
      (inMinutes ~/ minutesPerDot) +
      (inMinutes % minutesPerDot > roundingMinute ? 1 : 0);
}
