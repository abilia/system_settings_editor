import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class RecurringWiz extends StatelessWidget {
  const RecurringWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      buildWhen: (previous, current) =>
          previous.activity.recurs.recurrance !=
          current.activity.recurs.recurrance,
      builder: (context, state) {
        return WizardScaffold(
          title: translate.recurrence,
          iconData: AbiliaIcons.repeat,
          body: Padding(
            padding: ordinaryPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...[
                  RecurrentType.none,
                  RecurrentType.weekly,
                  RecurrentType.monthly,
                  RecurrentType.yearly
                ].map(
                  (type) => Padding(
                    padding: EdgeInsets.only(bottom: 8.0.s),
                    child: RadioField<RecurrentType>(
                      groupValue: state.activity.recurs.recurrance,
                      onChanged: (v) => context.read<EditActivityBloc>().add(
                            ReplaceActivity(
                              state.activity.copyWith(
                                recurs: _newType(
                                  type,
                                  state.activity.startTime,
                                ),
                              ),
                            ),
                          ),
                      value: type,
                      leading: Icon(type.iconData()),
                      text: Text(type.text(translate)),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Recurs _newType(RecurrentType type, DateTime startdate) {
    switch (type) {
      case RecurrentType.weekly:
        return Recurs.weeklyOnDay(startdate.weekday);
      case RecurrentType.monthly:
        return Recurs.monthly(startdate.day);
      case RecurrentType.yearly:
        return Recurs.yearly(startdate);
      default:
        return Recurs.not;
    }
  }
}
