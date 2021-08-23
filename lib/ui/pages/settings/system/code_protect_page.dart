import 'package:seagull/ui/all.dart';

class CodeProtectPage extends StatelessWidget {
  const CodeProtectPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.numeric_keyboard,
      title: Translator.of(context).translate.codeProtect,
    );
  }
}
