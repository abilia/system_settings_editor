import 'package:seagull/config.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/image_picker_settings_page.dart';
import 'package:seagull/ui/pages/settings/menu_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.month,
          text: Translator.of(context).translate.calendar,
          navigateTo: CalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.menu_setup,
          text: Translator.of(context).translate.functions,
          navigateTo: FunctionSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.my_photos,
          text: Translator.of(context).translate.imagePicker,
          navigateTo: ImagePickerSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.app_menu,
          text: Translator.of(context).translate.menu,
          navigateTo: MenuSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.stop_watch,
          text: Translator.of(context).translate.countdown,
          navigateTo: CountdownSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.technical_settings,
          text: Translator.of(context).translate.system,
          navigateTo: SystemSettingsPage(),
        ),
        if (Config.alpha) const FakeTicker(),
      ],
      icon: AbiliaIcons.settings,
      title: Translator.of(context).translate.settings,
    );
  }
}
