import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/bloc/activities/edit_activity/edit_activity_cubit.dart';
import 'package:memoplanner/ui/all.dart';

class CheckableWiz extends StatelessWidget {
  const CheckableWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) => WizardScaffold(
        iconData: AbiliaIcons.handiCheck,
        title: translate.checkable,
        body: Padding(
          padding: layout.templates.m1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RadioField<bool?>(
                key: TestKey.checkableRadio,
                groupValue: state.activity.checkable,
                onChanged: (value) => context
                    .read<EditActivityCubit>()
                    .replaceActivity(state.activity.copyWith(checkable: value)),
                value: true,
                text: Text(translate.checkable),
              ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              RadioField<bool?>(
                groupValue: state.activity.checkable,
                onChanged: (value) => context
                    .read<EditActivityCubit>()
                    .replaceActivity(state.activity.copyWith(checkable: value)),
                value: false,
                text: Text(translate.notCheckable),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
