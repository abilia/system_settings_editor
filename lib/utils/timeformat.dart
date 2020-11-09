import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';

String Function(DateTime) hourAndMinuteFormat(BuildContext context) {
  final language = Localizations.localeOf(context).toLanguageTag();
  final use24 = MediaQuery.of(context).alwaysUse24HourFormat;
  return hourAndMinuteFromUse24(use24, language);
}

String Function(DateTime) onlyHourFormat(BuildContext context,
    {HourClockType clockType = HourClockType.useSystem}) {
  switch (clockType) {
    case HourClockType.useSystem:
      if (MediaQuery.of(context).alwaysUse24HourFormat) continue use24;
      break;
    use24:
    case HourClockType.use24:
      return DateFormat('H').format;
    default:
  }
  return DateFormat('h').format;
}

String Function(DateTime) hourAndMinuteFromUse24(
    bool use24HourFormat, String language) {
  return use24HourFormat
      ? DateFormat.Hm().format
      : DateFormat('h:mm a', language).format;
}
