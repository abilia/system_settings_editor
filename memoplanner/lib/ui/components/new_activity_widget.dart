import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class NewActivityWidget extends StatelessWidget with ActivityNavigation {
  const NewActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Translator.of(context).translate;
    final addActivitySettings = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.addActivity);
    return Column(
      children: [
        if (addActivitySettings.newActivityOption)
          PickField(
            key: TestKey.newActivityChoice,
            leading: const Icon(AbiliaIcons.basicActivity),
            text: Text(t.newActivity),
            onTap: () => navigateToActivityWizardWithContext(
              context,
              authProviders,
            ),
          ).pad(layout.templates.m1.withoutBottom),
        if (addActivitySettings.basicActivityOption)
          PickField(
            key: TestKey.basicActivityChoice,
            leading: const Icon(AbiliaIcons.basicActivities),
            text: Text(t.fromTemplate),
            onTap: () => navigateToBasicActivityPicker(
              context,
              authProviders,
              addActivitySettings.defaults,
            ),
          ).pad(m1ItemPadding),
      ],
    );
  }
}