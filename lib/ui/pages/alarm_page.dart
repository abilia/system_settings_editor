import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class AlarmPage extends StatelessWidget {
  final Activity activity;
  final bool atStartTime, atEndTime;
  const AlarmPage(
      {Key key,
      @required this.activity,
      this.atStartTime = false,
      this.atEndTime = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline;
    final translate = Translator.of(context).translate;
    return Scaffold(
      key: TestKey.onScreenAlarm,
      appBar: AbiliaAppBar(title: translate.alarm),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            padding24,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TimeText(
                  date: activity.start,
                  active: atStartTime,
                ),
                if (activity.hasEndTime)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child:
                        Text('-', style: Theme.of(context).textTheme.headline),
                  ),
                if (activity.hasEndTime)
                  TimeText(
                    date: activity.end,
                    active: atEndTime,
                  ),
              ],
            ),
            padding24,
            Expanded(
              flex: 48,
              child: Container(
                decoration: BoxDecoration(
                    color: AbiliaColors.white,
                    border: Border.all(
                      color: AbiliaColors.transparantBlack[20],
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (activity.title?.isNotEmpty == true)
                        Text(
                          activity.title ?? '',
                          style: textStyle,
                        ),
                      if (activity.fileId?.isNotEmpty == true)
                        SizedBox(height: 32.0),
                      if (activity.fileId?.isNotEmpty == true)
                        Expanded(
                          child: FadeInCalenderImage(
                            imageFileId: activity.fileId,
                            width: 287.0,
                            height: 274.0,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
            padding32,
          ],
        ),
      ),
      bottomNavigationBar: OkBottomBar(),
    );
  }

  Spacer get padding24 => const Spacer(flex: 3);
  Spacer get padding32 => const Spacer(flex: 4);
}

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
      constraints: BoxConstraints(minWidth: 92.0, minHeight: 52.0),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AbiliaColors.red,
            width: 2.0,
            style: active ? BorderStyle.solid : BorderStyle.none),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Center(
          child: Text(
            timeFormat.format(date),
            style: Theme.of(context).textTheme.headline,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AlarmNavigator {
  static final LinkedHashMap<String, Route<dynamic>> routes = LinkedHashMap();

  static Future<T> push<T extends Object>(
      BuildContext context, Route<T> route, String id) {
    print('Put route $id');
    routes.putIfAbsent(id, () => route);
    return Navigator.of(context).push(route);
  }

  static void removeRoute(BuildContext context, String id) {
    final route = routes.remove(id);
    if (route != null) {
      print('Removing route: $id');
      Navigator.of(context).removeRoute(route);
      print('Route $id is removed');
    } else {
      print('No route to remove!');
    }
  }

  static bool pop<T extends Object>(BuildContext context) {
    final firstKey = routes.keys.first;
    if (firstKey != null) {
      print('Popping $firstKey');
      routes.remove(firstKey);
    } else {
      print('No route when popping');
    }
    return Navigator.of(context).pop();
  }
}
