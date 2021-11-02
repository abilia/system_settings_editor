import 'package:flutter/services.dart';
import 'package:seagull/ui/all.dart';

class ChangeCodeProtectPage extends StatefulWidget {
  const ChangeCodeProtectPage({Key? key}) : super(key: key);

  @override
  State<ChangeCodeProtectPage> createState() => _ChangeCodeProtectPageState();
}

const _fourDash = '----';
const _dash = '-';

class _ChangeCodeProtectPageState extends State<ChangeCodeProtectPage> {
  late final TextEditingController controller;

  String? firstCode;
  bool get isAtFirstCode => firstCode == null;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: _fourDash);
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 0);
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: isAtFirstCode ? translate.enterNewCode : translate.confirmCode,
        iconData: AbiliaIcons.unlock,
      ),
      body: Column(
        children: [
          SizedBox(height: 64.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubHeading(translate.code),
              SizedBox(
                width: 120.s,
                height: 64.s,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  showCursor: false,
                  autocorrect: false,
                  textAlign: TextAlign.center,
                  toolbarOptions: const ToolbarOptions(),
                  keyboardType: TextInputType.number,
                  enableSuggestions: false,
                  onEditingComplete: onPressed,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    DashedInputFormatter(),
                  ],
                  style: Theme.of(context).textTheme.headline4,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2.s,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: GreenButton(
              icon: AbiliaIcons.ok,
              text: Translator.of(context).translate.next,
              onPressed: onPressed,
            ),
          )
        ],
      ),
    );
  }

  void onPressed() {
    final textEditValue = controller.text;
    if (int.tryParse(textEditValue) != null) {
      if (firstCode == null) {
        return setState(() {
          firstCode = textEditValue;
          controller.text = _fourDash;
          controller.selection =
              const TextSelection(baseOffset: 0, extentOffset: 0);
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

class DashedInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.padRight(4, _dash));
}
