import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

class AlarmPage extends StatelessWidget {
  final Activity activity;
  final DateTime day;
  final bool atStartTime, atEndTime;
  const AlarmPage(
      {Key key,
      @required this.activity,
      @required this.day,
      this.atStartTime = false,
      this.atEndTime = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(title: Translator.of(context).translate.alarm),
      body: Padding(
        padding: const EdgeInsets.all(ActivityInfo.margin),
        child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
          builder: (context, activitiesState) => ActivityInfo(
            activity: activitiesState.newActivityFromLoadedOrGiven(activity),
            day: day,
          ),
        ),
      ),
    );
  }
}
