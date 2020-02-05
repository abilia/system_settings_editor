import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class ActivityInfo extends StatelessWidget {
  final ActivityOccasion occasion;
  const ActivityInfo({Key key, this.occasion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = weekDayTheme[occasion.day.weekday];
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
          decoration: BoxDecoration(
              color: AbiliaColors.white,
              borderRadius: BorderRadius.all(
                const Radius.circular(12.0),
              )),
          constraints: BoxConstraints.expand(),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (occasion.activity.title != null &&
                  occasion.activity.title.isNotEmpty)
                Text(
                  occasion.activity.title,
                  style: themeData.textTheme.headline,
                ),
              Text(
                  occasion.activity.fullDay
                      ? Translator.of(context).translate.fullDay
                      : occasion.activity.hasEndTime
                          ? '${timeFormat.format(occasion.activity.start)} - ${timeFormat.format(occasion.activity.end)}'
                          : '${timeFormat.format(occasion.activity.start)}',
                  style: themeData.textTheme.subhead.copyWith(
                    color: AbiliaColors.black,
                  )),
            ],
          ))),
    );
  }
}
