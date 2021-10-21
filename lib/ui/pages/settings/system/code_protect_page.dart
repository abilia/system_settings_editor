import 'package:seagull/ui/all.dart';

class CodeProtectPage extends StatelessWidget {
  const CodeProtectPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: const [],
      icon: AbiliaIcons.numericKeyboard,
      title: Translator.of(context).translate.codeProtect,
    );
  }
}
