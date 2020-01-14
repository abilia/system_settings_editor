import 'dart:collection';

import 'package:flutter/material.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(translate.alarm),
      ),
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
                  textStyle: textStyle,
                ),
                if (activity.hasEndTime)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('-', style: textStyle),
                  ),
                if (activity.hasEndTime)
                  TimeText(
                    date: activity.end,
                    active: atEndTime,
                    textStyle: textStyle,
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
                      color: AbiliaColors.transparantBlack[5],
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16)),
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
                        Expanded(
                          child:
                              FadeInCalenderImage(imageFileId: activity.fileId),
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FractionallySizedBox(
            widthFactor: 0.55,
            child: FlatButton(
              color: AbiliaColors.green,
              child: Text(
                translate.ok,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: AbiliaColors.white),
              ),
              onPressed: () => AlarmNavigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }

  Spacer get padding24 => const Spacer(flex: 3);
  Spacer get padding32 => const Spacer(flex: 4);
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
