import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String Function(DateTime) hourAndMinuteFormat(BuildContext context) {
  final language = Localizations.localeOf(context).toLanguageTag();
  final use24 = MediaQuery.of(context).alwaysUse24HourFormat;
  return use24 ? DateFormat.Hm().format : DateFormat('h:mm a', language).format;
}

String Function(DateTime) onlyHourFormat(BuildContext context) {
  final use24 = MediaQuery.of(context).alwaysUse24HourFormat;
  return use24 ? DateFormat('H').format : DateFormat('h').format;
}
