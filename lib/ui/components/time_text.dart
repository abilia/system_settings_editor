import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:intl/intl.dart';

class TimeText extends StatelessWidget {
  const TimeText({
    Key key,
    @required this.date,
    this.textStyle,
    this.active = false,
  }) : super(key: key);
  final DateTime date;
  final bool active;
  final TextStyle textStyle;
  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
            color: AbiliaColors.red,
            width: 2.0,
            style: active ? BorderStyle.solid : BorderStyle.none),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Text(
          timeFormat.format(date),
          style: textStyle,
      ),
    );
  }
}
