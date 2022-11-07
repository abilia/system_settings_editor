import 'package:memoplanner/ui/all.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.settings,
      title: t.settings,
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.month,
          text: t.calendar,
          navigateTo: const CalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.menuSetup,
          text: t.functions,
          navigateTo: const FunctionSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.myPhotos,
          text: t.imagePicker,
          navigateTo: const ImagePickerSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.appMenu,
          text: t.menu,
          navigateTo: const MenuSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.technicalSettings,
          text: t.system,
          navigateTo: const SystemSettingsPage(),
        ),
        if (Config.dev) const FakeTicker(),
      ],
    );
  }
}
