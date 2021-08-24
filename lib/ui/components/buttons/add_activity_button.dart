// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/edit_activity/activity_wizard_page.dart';

class AddActivityButton extends StatelessWidget {
  const AddActivityButton({
    Key key,
    @required this.day,
  }) : super(key: key);

  final DateTime day;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, state) => ActionButtonLight(
          onPressed: () => Navigator.of(context).push(
            state.addActivityType == NewActivityMode.stepByStep
                ? MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: BlocProvider(
                        create: (context) => ActivityWizardCubit(
                          memoplannerSettingsState: state,
                          editActivityBloc: context.read<EditActivityBloc>(),
                        ),
                        child: ActivityWizardPage(),
                      ),
                    ),
                  )
                : state.advancedActivityTemplate
                    ? MaterialPageRoute(
                        builder: (_) => CopiedAuthProviders(
                          blocContext: context,
                          child: CreateActivityPage(day: day),
                        ),
                        settings: RouteSettings(name: 'CreateActivityPage'),
                      )
                    : EditActivityPage.route(context, day),
          ),
          child: Icon(AbiliaIcons.plus),
        ),
      );
}
