import 'package:flutter/widgets.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

extension ActivityExtensions on Activity {
  String subtitle(BuildContext context) {
    final t = Translator.of(context).translate;
    if (fullDay) return t.fullDay;
    final timeFormat = hourAndMinuteFormat(context);
    if (hasEndTime) {
      return '${timeFormat(startTime)} ${t.timeTo} ${timeFormat(noneRecurringEnd)}';
    }
    return timeFormat(startTime);
  }

  SemanticsProperties semanticsProperties(BuildContext context) =>
      SemanticsProperties(
        button: true,
        image: hasImage,
        label: !hasTitle ? subtitle(context) : '$title, ${subtitle(context)}',
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
