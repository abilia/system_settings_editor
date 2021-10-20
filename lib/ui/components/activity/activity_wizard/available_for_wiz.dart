import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_bloc.dart';
import 'package:seagull/ui/all.dart';

class AvailableForWiz extends StatelessWidget {
  const AvailableForWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.unlock,
          title: translate.availableFor,
          label: translate.newActivity,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RadioField<bool?>(
                groupValue: state.activity.secret,
                onChanged: (value) => context.read<EditActivityBloc>().add(
                    ReplaceActivity(state.activity.copyWith(secret: value))),
                value: true,
                leading: const Icon(AbiliaIcons.password_protection),
                text: Text(translate.onlyMe),
              ),
              SizedBox(height: 8.0.s),
              RadioField<bool?>(
                groupValue: state.activity.secret,
                onChanged: (value) => context.read<EditActivityBloc>().add(
                    ReplaceActivity(state.activity.copyWith(secret: value))),
                value: false,
                leading: const Icon(AbiliaIcons.user_group),
                text: Text(translate.meAndSupportPersons),
              ),
            ],
          ),
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
  }
}
