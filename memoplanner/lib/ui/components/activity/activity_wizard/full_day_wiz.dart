import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class FullDayWiz extends StatelessWidget {
  const FullDayWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.restore,
      title: Translator.of(context).translate.allDay,
      body: Padding(
        padding: layout.templates.m1,
        child: const _FullDayWidget(),
      ),
    );
  }
}

class _FullDayWidget extends StatelessWidget {
  const _FullDayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullDay = context
        .select((EditActivityCubit cubit) => cubit.state.activity.fullDay);
    final editActivityCubit = context.read<EditActivityCubit>();
    final activity = editActivityCubit.state.activity;
    return Column(
      children: <Widget>[
        SwitchField(
          padding: layout.supportPerson.switchFieldPadding,
          value: fullDay,
          leading: Icon(
            AbiliaIcons.restore,
            size: layout.icon.small,
          ),
          onChanged: (v) =>
              editActivityCubit.replaceActivity(activity.copyWith(fullDay: v)),
          child: Text(
            Translator.of(context).translate.fullDay,
          ),
        ),
      ],
    );
  }
}
