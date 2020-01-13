import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/action_button.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';
import 'package:seagull/utils/all.dart';

class AllDayList extends StatelessWidget {
  const AllDayList(
      {Key key,
      @required this.pickedDay,
      @required this.allDayActivities,
      @required this.cardHeight})
      : super(key: key);

  final DateTime pickedDay;
  final List<ActivityOccasion> allDayActivities;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    return Theme(
      data: allDayTheme()[pickedDay.weekday],
      child: Scaffold(
        body: ListView.builder(
          itemExtent: this.cardHeight,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          itemCount: allDayActivities.length,
          itemBuilder: (context, index) => ActivityCard(
            activityOccasion: allDayActivities[index],
            height: this.cardHeight,
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(68),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            brightness: getThemeAppBarBrightness()[pickedDay.weekday],
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ActionButton(
                      child: Text("Close"),
                      width: 65,
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        navigator.pop();
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMM', langCode).format(pickedDay),
                          style: Theme.of(context).textTheme.title,
                        ),
                        Text(
                          '${Translator.of(context).translate.week} ${pickedDay.getWeekNumber()}',
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 56,
                      width: 65,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
