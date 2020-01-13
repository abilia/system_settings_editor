import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:intl/intl.dart';
import 'package:seagull/ui/theme.dart';

class TimeText extends StatelessWidget {
  const TimeText({
    Key key,
    @required this.date,
    this.active = false,
  }) : super(key: key);
  final DateTime date;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    return Container(
      width: 92.0,
      height: 52.0,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AbiliaColors.red,
            width: 2.0,
            style: active ? BorderStyle.solid : BorderStyle.none),
      ),
      child: Center(
        child: Text(
          timeFormat.format(date),
          style: Theme.of(context).textTheme.headline,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
