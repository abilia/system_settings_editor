import 'package:flutter/widgets.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

extension ActivityExtensions on Activity {
  String subtitle(BuildContext context, [bool tts = false]) {
    final t = Translator.of(context).translate;
    if (fullDay) return t.fullDay;
    final timeFormat = hourAndMinuteFormat(context);
    final timeBinding = tts ? t.timeTo : '-';
    if (hasEndTime) {
      return '${timeFormat(startTime)} $timeBinding ${timeFormat(noneRecurringEnd)}';
    }
    return timeFormat(startTime);
  }

  SemanticsProperties semanticsProperties(BuildContext context) =>
      SemanticsProperties(
        button: true,
        image: hasImage,
        label: !hasTitle
            ? subtitle(context, true)
            : '$title, ${subtitle(context, true)}',
      );
}

extension TimerExtensions on AbiliaTimer {
  SemanticsProperties semanticsProperties(BuildContext context) =>
      SemanticsProperties(
        button: true,
        image: hasImage,
        label: !hasTitle
            ? duration.toUntilString(Translator.of(context).translate)
            : title,
      );
}
