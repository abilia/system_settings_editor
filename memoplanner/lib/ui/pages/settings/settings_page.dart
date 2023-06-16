import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final fakeTime = context
        .watch<FeatureToggleCubit>()
        .state
        .isToggleEnabled(FeatureToggle.fakeTime);
    return SettingsBasePage(
      icon: AbiliaIcons.settings,
      title: translate.settings,
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.month,
          text: translate.calendar,
          navigateTo: const CalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.menuSetup,
          text: translate.functions,
          navigateTo: const FunctionSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.myPhotos,
          text: translate.imagePicker,
          navigateTo: const ImagePickerSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.appMenu,
          text: translate.menu,
          navigateTo: const MenuSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.technicalSettings,
          text: translate.system,
          navigateTo: const SystemSettingsPage(),
        ),
        if (fakeTime) const FakeTicker(),
        if (Config.dev)
          const MenuItemPickField(
            icon: AbiliaIcons.commands,
            text: 'Feature toggles',
            navigateTo: FeatureTogglesPage(),
          ),
      ],
    );
  }
}
