import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_bloc.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/ui/all.dart';

class AvailableForWiz extends StatefulWidget {
  const AvailableForWiz({Key? key}) : super(key: key);

  @override
  _AvailableForWizState createState() => _AvailableForWizState();
}

class _AvailableForWizState extends State<AvailableForWiz> {
  _AvailableForWizState();
  late final Activity activity;
  bool? secret;
  void _onSelected(bool? value) => setState(() => secret = value);

  @override
  void initState() {
    super.initState();
    secret = BlocProvider.of<EditActivityBloc>(context).state.activity.secret;
    activity = context.read<EditActivityBloc>().state.activity;
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.unlock,
        title: translate.availableFor,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField<bool?>(
              groupValue: secret,
              onChanged: _onSelected,
              value: true,
              leading: const Icon(AbiliaIcons.password_protection),
              text: Text(translate.onlyMe),
            ),
            SizedBox(height: 8.0.s),
            RadioField<bool?>(
              groupValue: secret,
              onChanged: _onSelected,
              value: false,
              leading: const Icon(AbiliaIcons.user_group),
              text: Text(translate.meAndSupportPersons),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomNavigation(
        beforeOnNext: () {
          BlocProvider.of<EditActivityBloc>(context)
              .add(ReplaceActivity(activity.copyWith(secret: secret)));
        },
      ),
    );
  }
}
