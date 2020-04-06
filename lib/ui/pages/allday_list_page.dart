import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';
import 'package:seagull/utils/all.dart';

class AllDayList extends StatelessWidget {
  const AllDayList({
    Key key,
    @required this.pickedDay,
    @required this.allDayActivities,
    @required this.cardHeight,
    @required this.cardMargin,
  }) : super(key: key);

  final DateTime pickedDay;
  final List<ActivityOccasion> allDayActivities;
  final double cardHeight;
  final double cardMargin;

  @override
  Widget build(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    final theme = weekDayTheme[pickedDay.weekday].copyWith(
        scaffoldBackgroundColor: weekDayColor[pickedDay.weekday][120]);
    return Theme(
      data: theme,
      child: Scaffold(
        body: Scrollbar(
          child: ListView.builder(
            itemExtent: this.cardHeight + this.cardMargin,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: allDayActivities.length,
            itemBuilder: (context, index) => ActivityCard(
              activityOccasion: allDayActivities[index],
              cardMargin: this.cardMargin / 2,
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(68),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ActionButton(
                      child: Icon(
                        AbiliaIcons.close_program,
                        size: 32,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('EEEE, d MMM', langCode)
                                .format(pickedDay),
                            style: theme.textTheme.title,
                          ),
                          Text(
                            '${Translator.of(context).translate.week} ${pickedDay.getWeekNumber()}',
                            style: theme.textTheme.subhead,
                          ),
                        ],
                      ),
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
