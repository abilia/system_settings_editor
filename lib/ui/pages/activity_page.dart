import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/utils/all.dart';

class ActivityPage extends StatelessWidget {
  final ActivityOccasion occasion;

  const ActivityPage({Key key, @required this.occasion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = weekDayTheme[occasion.day.weekday];
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: buildAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              decoration: BoxDecoration(
                  color: AbiliaColors.white,
                  borderRadius: BorderRadius.all(
                    const Radius.circular(10.0),
                  )),
              constraints: BoxConstraints.expand(),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
        ),
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    final themeData = weekDayTheme[occasion.day.weekday];
    return PreferredSize(
      preferredSize: Size.fromHeight(68),
      child: AppBar(
        brightness: getThemeAppBarBrightness()[occasion.day.weekday],
        elevation: 0.0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ActionButton(
                  child: Icon(
                    AbiliaIcons.navigation_previous,
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMM', langCode).format(occasion.day),
                      style: themeData.textTheme.title,
                    ),
                    Text(
                      '${Translator.of(context).translate.week} ${occasion.day.getWeekNumber()}',
                      style: themeData.textTheme.subhead,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
