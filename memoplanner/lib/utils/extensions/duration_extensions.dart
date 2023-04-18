import 'package:memoplanner/i18n/all.dart';
import 'package:memoplanner/utils/all.dart';

const iOSPersistentNotificationMaxDuration = Duration(seconds: 30),
    iOSUnlockedPhoneNotificationMaxDuration = Duration(seconds: 5);

const Duration maxScreenTimeoutDuration = Duration(milliseconds: 2147483647);

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
    final twoDigitMinutes = _twoDigits(inMinutes.remainder(60));
    final twoDigitSeconds = _twoDigits(inSeconds.remainder(60));
    return '${_twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  String toHMSorMS() {
    if (inHours > 0) return toHMS();
    return '${_twoDigits(inMinutes)}:${_twoDigits(inSeconds.remainder(60))}';
  }

  String toUntilString(Translated translator) {
    final sb = StringBuffer();
    if (inHours > 0) {
      sb.writeln('$inHours ${translator.h}');
    }
    final minutes = inMinutes % Duration.minutesPerHour;
    if (minutes > 0) {
      sb.writeln('$minutes ${translator.min}');
    }
    return sb.toString();
  }

  String comparedToNowString(
    Translated translator,
    bool before, {
    bool daysOnly = false,
  }) {
    final sb = StringBuffer();

    // https://en.wikipedia.org/wiki/Inessive_case
    if (before &&
        (inDays >= 1 || daysOnly) &&
        translator.dayInessive.isNotEmpty) {
      sb.write('$inDays ${translator.dayInessive} ');
    } else {
      if (inDays > 1 || (daysOnly && inDays == 0)) {
        sb.write('$inDays ${translator.days} ');
      }
      if (inDays == 1) sb.write('$inDays ${translator.day} ');
    }

    if (!daysOnly) {
      final hours = inHours % Duration.hoursPerDay;

      if (before && hours >= 1 && translator.hourInessive.isNotEmpty) {
        sb.write('$hours ${translator.hourInessive} ');
      } else {
        if (hours > 1) sb.write('$hours ${translator.hours} ');
        if (hours == 1) sb.write('$hours ${translator.hour} ');
      }

      final minutes = inMinutes % Duration.minutesPerHour;
      if (before && minutes >= 1 && translator.minuteInessive.isNotEmpty) {
        sb.write('$minutes ${translator.minuteInessive} ');
      } else {
        if (minutes > 1) sb.write('$minutes ${translator.minutes} ');
        if (minutes == 1) sb.write('$minutes ${translator.minute} ');
      }
    }

    final inOrAgo = before ? translator.inTime : translator.timeAgo;
    return inOrAgo(sb.toString().trim());
  }

  int inDots(int minutesPerDot, roundingMinute) =>
      (inMinutes ~/ minutesPerDot) +
      (inMinutes % minutesPerDot > roundingMinute ? 1 : 0);

  Duration roundUpToClosestHour() => Duration(hours: inHours);

  Duration roundToClosestDot() => Duration(
        minutes: (inMinutes / minutesPerDot).round() * minutesPerDot,
      );

  Duration roundDownToClosestDot() =>
      Duration(minutes: (inMinutes / minutesPerDot).floor() * minutesPerDot);
}
