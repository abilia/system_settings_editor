import 'package:calendar_events/calendar_events.dart';
import 'package:intl/intl.dart';
import 'package:utils/utils.dart';

final yMd = DateFormat('y-MM-dd').format;
final hm = DateFormat.Hm().format;

extension OccasionExtensions on DateTime {
  Occasion occasion(DateTime now) => isAfter(now)
      ? Occasion.future
      : isBefore(now)
          ? Occasion.past
          : Occasion.current;

  Occasion dayOccasion(DateTime now) => isAtSameDay(now)
      ? Occasion.current
      : isAfter(now)
          ? Occasion.future
          : Occasion.past;
}
