import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/bloc/activities/edit_activity/edit_activity_cubit.dart';
import 'package:memoplanner/ui/all.dart';

class RemoveAfterWiz extends StatelessWidget {
  const RemoveAfterWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) => WizardScaffold(
        iconData: AbiliaIcons.deleteAllClear,
        title: translate.deleteAfter,
        body: Padding(
          padding: layout.templates.m1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RadioField<bool?>(
                key: TestKey.removeAfterRadio,
                groupValue: state.activity.removeAfter,
                onChanged: (value) =>
                    context.read<EditActivityCubit>().replaceActivity(
                          state.activity.copyWith(removeAfter: value),
                        ),
                value: true,
                text: Text(translate.deleteAfter),
              ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              RadioField<bool?>(
                groupValue: state.activity.removeAfter,
                onChanged: (value) => context
                    .read<EditActivityCubit>()
                    .replaceActivity(
                        state.activity.copyWith(removeAfter: value)),
                value: false,
                text: Text(translate.dontDeleteAfter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
