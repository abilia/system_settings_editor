import 'package:memoplanner/l10n/all.dart';
import 'package:memoplanner/utils/all.dart';

const iOSPersistentNotificationMaxDuration = Duration(seconds: 30),
    iOSUnlockedPhoneNotificationMaxDuration = Duration(seconds: 5);

const Duration maxScreenTimeoutDuration = Duration(milliseconds: 2147483647);

extension DurationExtensions on Duration {
  String toDurationString(Lt translate, {bool shortMin = true}) {
    if (inDays > 1) return '$inDays ${translate.days}';
    if (inDays == 1) return '$inDays ${translate.day}';
    if (inHours > 1) return '$inHours ${translate.hours}';
    if (inHours == 1) return '$inHours ${translate.hour}';
    if (inMinutes < 1) return '$inSeconds ${translate.seconds}';
    if (inSeconds == 1) return '$inSeconds ${translate.second}';
    if (shortMin) return '$inMinutes ${translate.min}';
    if (inMinutes == 1) return '$inMinutes ${translate.minute}';
    return '$inMinutes ${translate.minutes}';
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

  String toUntilString(Lt translate) {
    final sb = StringBuffer();
    if (inHours > 0) {
      sb.writeln('$inHours ${translate.h}');
    }
    final minutes = inMinutes % Duration.minutesPerHour;
    if (minutes > 0) {
      sb.writeln('$minutes ${translate.min}');
    }
    return sb.toString();
  }

  String comparedToNowString(
    Lt translate,
    bool before, {
    bool daysOnly = false,
  }) {
    final sb = StringBuffer();

    // https://en.wikipedia.org/wiki/Inessive_case
    if (before &&
        (inDays >= 1 || daysOnly) &&
        translate.dayInessive.isNotEmpty) {
      sb.write('$inDays ${translate.dayInessive} ');
    } else {
      if (inDays > 1 || (daysOnly && inDays == 0)) {
        sb.write('$inDays ${translate.days} ');
      }
      if (inDays == 1) sb.write('$inDays ${translate.day} ');
    }

    if (!daysOnly) {
      final hours = inHours % Duration.hoursPerDay;

      if (before && hours >= 1 && translate.hourInessive.isNotEmpty) {
        sb.write('$hours ${translate.hourInessive} ');
      } else {
        if (hours > 1) sb.write('$hours ${translate.hours} ');
        if (hours == 1) sb.write('$hours ${translate.hour} ');
      }

      final minutes = inMinutes % Duration.minutesPerHour;
      if (before && minutes >= 1 && translate.minuteInessive.isNotEmpty) {
        sb.write('$minutes ${translate.minuteInessive} ');
      } else {
        if (minutes > 1) sb.write('$minutes ${translate.minutes} ');
        if (minutes == 1) sb.write('$minutes ${translate.minute} ');
      }
    }

    final inOrAgo = before ? translate.inTime : translate.timeAgo;
    return inOrAgo(sb.toString().trim());
  }

  int inDots(int minutesPerDot, roundingMinute) =>
      (inMinutes ~/ minutesPerDot) +
      (inMinutes % minutesPerDot > roundingMinute ? 1 : 0);

  Duration roundUpToClosestHour() => Duration(hours: inHours);

  Duration roundDownToClosestDot() => Duration(
        minutes: (inMinutes / minutesPerDot).floor() * minutesPerDot,
      );
}
