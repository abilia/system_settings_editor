import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/bloc/activities/edit_activity/edit_activity_cubit.dart';
import 'package:memoplanner/ui/all.dart';

class RemindersWiz extends StatelessWidget {
  const RemindersWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) => WizardScaffold(
        iconData: AbiliaIcons.handiReminder,
        title: translate.reminders,
        body: Padding(
          padding: layout.templates.m1,
          child: Reminders(
            activity: state.activity,
            expanded: true,
          ),
        ),
      ),
    );
  }
}
