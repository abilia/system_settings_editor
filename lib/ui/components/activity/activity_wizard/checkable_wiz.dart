import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_bloc.dart';
import 'package:seagull/ui/all.dart';

class CheckableWiz extends StatelessWidget {
  const CheckableWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.handi_check,
          title: translate.checkable,
          label: translate.newActivity,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RadioField<bool?>(
                key: TestKey.checkableRadio,
                groupValue: state.activity.checkable,
                onChanged: (value) => context.read<EditActivityBloc>().add(
                    ReplaceActivity(state.activity.copyWith(checkable: value))),
                value: true,
                text: Text(translate.checkable),
              ),
              SizedBox(height: 8.0.s),
              RadioField<bool?>(
                groupValue: state.activity.checkable,
                onChanged: (value) => context.read<EditActivityBloc>().add(
                    ReplaceActivity(state.activity.copyWith(checkable: value))),
                value: false,
                text: Text(translate.notCheckable),
              ),
            ],
          ),
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
  }
}
