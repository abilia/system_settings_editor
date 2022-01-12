import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_cubit.dart';
import 'package:seagull/ui/all.dart';

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
          padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0),
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
              SizedBox(height: 8.0.s),
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
