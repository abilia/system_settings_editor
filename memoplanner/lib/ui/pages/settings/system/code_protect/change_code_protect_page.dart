import 'package:memoplanner/ui/all.dart';

class ChangeCodeProtectPage extends StatefulWidget {
  const ChangeCodeProtectPage({super.key});

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
    final translate = Lt.of(context);
    return Scaffold(
      appBar: AbiliaAppBar(
        title: isAtFirstCode ? translate.enterNewCode : translate.confirmCode,
        label: Config.isMP ? translate.codeProtect : null,
        iconData: AbiliaIcons.unlock,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PinCodeWidget(
              controller: controller,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: GreenButton(
          icon: AbiliaIcons.ok,
          text: translate.next,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Future<void> onPressed() async {
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
    final translate = Lt.of(context);
    await showDialog(
      context: context,
      builder: (context) => ErrorDialog(
          text: firstCode == null
              ? translate.enterNewCode
              : translate.incorrectCode),
    );
  }
}
