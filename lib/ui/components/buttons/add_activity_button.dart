// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityButton extends StatelessWidget {
  const AddActivityButton({
    Key key,
    @required this.day,
  }) : super(key: key);

  final DateTime day;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.advancedActivityTemplate !=
            current.advancedActivityTemplate,
        builder: (context, state) => ActionButtonLight(
          onPressed: () => Navigator.of(context).push(
            state.advancedActivityTemplate
                ? MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                        blocContext: context,
                        child: CreateActivityPage(day: day)),
                    settings: RouteSettings(name: 'CreateActivityPage'),
                  )
                : EditActivityPage.route(context, day),
          ),
          child: Icon(AbiliaIcons.plus),
        ),
      );
}
