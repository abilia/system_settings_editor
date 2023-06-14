import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

extension ActivityExtensions on ActivityOccasion {
  String subtitle(BuildContext context, [bool tts = false]) {
    final t = Lt.of(context);
    if (activity.fullDay) return t.fullDay;
    final timeFormat = hourAndMinuteFormat(context);
    final timeBinding = tts ? t.timeTo : '-';
    if (activity.hasEndTime) {
      return '${timeFormat(activity.startTime)} $timeBinding ${timeFormat(activity.noneRecurringEnd)}';
    }
    return timeFormat(activity.startTime);
  }

  SemanticsProperties semanticsProperties(BuildContext context) {
    final t = Lt.of(context);
    final label = [
      if (activity.hasTitle) activity.title,
      subtitle(context, true),
      if (activity.checkable)
        if (isSignedOff) t.completed else t.notCompleted
    ].join(', ');
    return SemanticsProperties(
      button: true,
      image: hasImage,
      label: label,
    );
  }
}

extension TimerExtensions on AbiliaTimer {
  SemanticsProperties semanticsProperties(BuildContext context) =>
      SemanticsProperties(
        button: true,
        image: hasImage,
        label: !hasTitle ? duration.toUntilString(Lt.of(context)) : title,
      );
}
