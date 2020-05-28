import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

class AlarmPage extends StatelessWidget {
  final ActivityDay activityDay;
  const AlarmPage({Key key, @required this.activityDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(title: Translator.of(context).translate.alarm),
      body: Padding(
        padding: const EdgeInsets.all(ActivityInfo.margin),
        child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
          builder: (context, activitiesState) =>
              ActivityInfo(activityDay.fromActivitiesState(activitiesState)),
        ),
      ),
    );
  }
}
