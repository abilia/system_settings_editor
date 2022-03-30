import 'package:seagull/ui/all.dart';

class ChangeCodeProtectPage extends StatefulWidget {
  const ChangeCodeProtectPage({Key? key}) : super(key: key);

  @override
  State<ChangeCodeProtectPage> createState() => _ChangeCodeProtectPageState();
}

class _ChangeCodeProtectPageState extends State<ChangeCodeProtectPage> {
  late final CodeProtectTextEditController controller;

  String? firstCode;
  bool get isAtFirstCode => firstCode == null;
  @override
  void initState() {
    super.initState();
    controller = CodeProtectTextEditController();
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: isAtFirstCode ? translate.enterNewCode : translate.confirmCode,
        label: translate.codeProtect,
        iconData: AbiliaIcons.unlock,
      ),
      body: Padding(
        padding: layout.templates.l4,
        child: Column(
          children: [
            PinCodeWidget(
              controller: controller,
              onEditingComplete: onPressed,
            ),
            const Spacer(),
            BottomNavigation(
              backNavigationWidget: const CancelButton(),
              forwardNavigationWidget: GreenButton(
                icon: AbiliaIcons.ok,
                text: translate.next,
                onPressed: onPressed,
              ),
            )
          ],
        ),
      ),
    );
  }

  void onPressed() {
    final textEditValue = controller.text;
    if (int.tryParse(textEditValue) != null) {
      if (firstCode == null) {
        return setState(() {
          firstCode = textEditValue;
          controller.clear();
        });
      } else if (firstCode == textEditValue) {
        return Navigator.pop(context, firstCode);
      }
    }
    showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(text: Translator.of(context).translate.incorrectCode),
    );
  }
}
