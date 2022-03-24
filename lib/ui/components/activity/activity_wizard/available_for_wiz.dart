import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_cubit.dart';
import 'package:seagull/ui/all.dart';

class AvailableForWiz extends StatelessWidget {
  const AvailableForWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) => WizardScaffold(
        iconData: AbiliaIcons.unlock,
        title: translate.availableFor,
        body: Padding(
          padding: layout.templates.m1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RadioField<bool?>(
                groupValue: state.activity.secret,
                onChanged: (value) => context
                    .read<EditActivityCubit>()
                    .replaceActivity(state.activity.copyWith(secret: value)),
                value: true,
                leading: const Icon(AbiliaIcons.passwordProtection),
                text: Text(translate.onlyMe),
              ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              RadioField<bool?>(
                groupValue: state.activity.secret,
                onChanged: (value) => context
                    .read<EditActivityCubit>()
                    .replaceActivity(state.activity.copyWith(secret: value)),
                value: false,
                leading: const Icon(AbiliaIcons.userGroup),
                text: Text(translate.meAndSupportPersons),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
