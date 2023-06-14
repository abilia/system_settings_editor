import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class RecurringWiz extends StatelessWidget {
  const RecurringWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      buildWhen: (previous, current) =>
          previous.activity.recurs.recurrence !=
          current.activity.recurs.recurrence,
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
                      groupValue: state.activity.recurs.recurrence,
                      onChanged: (v) => context
                          .read<EditActivityCubit>()
                          .changeRecurrentType(type),
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
}
