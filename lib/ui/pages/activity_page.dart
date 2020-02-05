import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/activity/activity_info.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/calendar/day_app_bar.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/utils/all.dart';

class ActivityPage extends StatelessWidget {
  final ActivityOccasion occasion;

  const ActivityPage({Key key, @required this.occasion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = weekDayTheme[occasion.day.weekday];
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(68),
            child: DayAppBar(
              day: occasion.day,
              leftAction: ActionButton(
                key: TestKey.activityBackButton,
                child: Icon(
                  AbiliaIcons.navigation_previous,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )),
        body: ActivityInfo(
          occasion: occasion,
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ActionButton(
                      themeData: menuButtonTheme,
                      child: Icon(
                        AbiliaIcons.handi_vibration,
                        size: 32,
                      ),
                      onPressed: () {},
                    ),
                    ActionButton(
                      themeData: menuButtonTheme,
                      child: Icon(
                        AbiliaIcons.handi_reminder,
                        size: 32,
                      ),
                      onPressed: () {},
                    ),
                    ActionButton(
                      themeData: menuButtonTheme,
                      child: Icon(
                        AbiliaIcons.edit,
                        size: 32,
                      ),
                      onPressed: () {},
                    ),
                    ActionButton(
                      themeData: menuButtonTheme,
                      child: Icon(
                        AbiliaIcons.delete_all_clear,
                        size: 32,
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              )),
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
                  key: TestKey.activityBackButton,
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
