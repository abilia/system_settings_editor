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
        final tiles = <Widget>[
          NameAndPictureWidget(state.activity),
          DateAndTimeWidget(
            state.activity,
            today: today,
          ),
          CategoryWidget(state.activity),
          AlarmWidget(state.activity),
          CheckableAndDeleteAfterWidget(state.activity),
          AvailibleForWidget(),
        ];
        return Form(
          child: Scaffold(
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
            body: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 20, 16, 72),
              itemCount: tiles.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: tiles[index],
              ),
              separatorBuilder: (context, index) =>
                  Divider(color: AbiliaColors.transparantBlack[10], height: 32),
            ),
          ),
        );
      },
    );
  }
}
