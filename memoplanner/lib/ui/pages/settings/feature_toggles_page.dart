import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class FeatureTogglesPage extends StatelessWidget {
  const FeatureTogglesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureToggleCubit, FeatureToggleState>(
      builder: (context, toggles) => SettingsBasePage(
        widgets: FeatureToggle.values
            .map((toggle) => SwitchField(
                  value: toggles.isToggleEnabled(toggle),
                  onChanged: (v) {
                    context.read<FeatureToggleCubit>().toggleFeature(toggle);
                  },
                  child: Text(toggle.name),
                ))
            .toList(),
        icon: AbiliaIcons.commands,
        title: 'Feature Toggles',
      ),
    );
  }
}
