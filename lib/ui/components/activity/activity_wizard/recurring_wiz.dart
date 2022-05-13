import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class RecurringWiz extends StatelessWidget {
  const RecurringWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      buildWhen: (previous, current) =>
          previous.activity.recurs.recurrance !=
          current.activity.recurs.recurrance,
      builder: (context, state) {
        return WizardScaffold(
          title: translate.recurrence,
          iconData: AbiliaIcons.repeat,
          body: Padding(
            padding: layout.templates.m1,
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
                    padding: EdgeInsets.only(
                        bottom: layout.formPadding.verticalItemDistance),
                    child: RadioField<RecurrentType>(
                      groupValue: state.activity.recurs.recurrance,
                      onChanged: (v) =>
                          context.read<EditActivityCubit>().replaceActivity(
                                state.activity.copyWith(
                                  recurs: _newRecurs(
                                    type,
                                    state.activity.startTime,
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

  Recurs _newRecurs(RecurrentType type, DateTime startDate) {
    switch (type) {
      case RecurrentType.weekly:
        return Recurs.weeklyOnDay(startDate.weekday, ends: startDate);
      case RecurrentType.monthly:
        return Recurs.monthly(startDate.day, ends: startDate);
      case RecurrentType.yearly:
        return Recurs.yearly(startDate);
      default:
        return Recurs.not;
    }
  }
}
