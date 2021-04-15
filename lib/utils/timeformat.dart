import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String Function(DateTime) hourAndMinuteFormat(BuildContext context) {
  final language = Localizations.localeOf(context).toLanguageTag();
  final use24 = MediaQuery.of(context).alwaysUse24HourFormat;
  return hourAndMinuteFromUse24(use24, language);
}

String Function(DateTime) onlyHourFormat(BuildContext context,
    {bool use12h = false}) {
  if (!use12h && MediaQuery.of(context).alwaysUse24HourFormat) {
    return DateFormat('H').format;
  }
  return DateFormat('h').format;
}

String Function(DateTime) hourAndMinuteFromUse24(
    bool use24HourFormat, String language) {
  return use24HourFormat
      ? DateFormat.Hm().format
      : DateFormat('h:mm a', language).format;
}
