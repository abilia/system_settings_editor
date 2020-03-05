import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class NewActivityPage extends StatelessWidget {
  final DateTime today;

  const NewActivityPage({@required this.today, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return BlocBuilder<AddActivityBloc, AddActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        return Scaffold(
          appBar: AbiliaAppBar(
            title: translator.newActivity,
            trailing: ActionButton(
              key: TestKey.finishNewActivityButton,
              child: Icon(
                AbiliaIcons.ok,
                size: 32,
              ),
              onPressed: state.canSave
                  ? () async {
                      BlocProvider.of<AddActivityBloc>(context)
                          .add(SaveActivity());
                      await Navigator.of(context).maybePop();
                    }
                  : null,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(0, 4.0, 12, 52.0),
            children: <Widget>[
              separated(NameAndPictureWidget(activity)),
              separated(DateAndTimeWidget(activity, today: today)),
              separated(CategoryWidget(activity)),
              CollapsableWidget(
                child: separated(AlarmWidget(activity)),
                collapsed: activity.fullDay,
              ),
              separated(CheckableAndDeleteAfterWidget(activity)),
              padded(AvailibleForWidget(activity)),
            ],
          ),
        );
      },
    );
  }

  Widget separated(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AbiliaColors.transparantBlack[10]),
        ),
      ),
      child: padded(child),
    );
  }

  Widget padded(Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 4.0, 16.0),
      child: child,
    );
  }
}
