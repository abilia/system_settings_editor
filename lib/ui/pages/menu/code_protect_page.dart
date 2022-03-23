import 'package:flutter/services.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/all.dart';
import 'package:seagull/ui/all.dart';

Future<bool> codeProtectAccess(
  BuildContext context, {
  required bool Function(CodeProtectSettings codeProtectSettings) restricted,
  required String name,
}) async {
  final codeProtectSettings =
      context.read<MemoplannerSettingBloc>().state.settings.codeProtect;
  final notRestricted = !restricted(codeProtectSettings);
  return notRestricted ||
      (await Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (context) =>
                  CodeProtectPage(code: codeProtectSettings.code, name: name),
            ),
          ) ??
          false);
}

class CodeProtectPage extends StatefulWidget {
  final String code, name;
  const CodeProtectPage({required this.code, required this.name, Key? key})
      : super(key: key);

  @override
  State<CodeProtectPage> createState() => _CodeProtectPageState();
}

class _CodeProtectPageState extends State<CodeProtectPage> {
  late final CodeProtextTextEditController controller;

  @override
  void initState() {
    super.initState();
    controller = CodeProtextTextEditController();
    controller.addListener(_listener);
  }

  Future _listener() async {
    if (controller.selection.baseOffset == _pinLenght) {
      if (controller.text == widget.code) {
        return Navigator.of(context).pop(true);
      }
      await showViewDialog(
        context: context,
        wrapWithAuthProviders: false,
        builder: (context) => ErrorDialog(
          text: Translator.of(context).translate.incorrectCode,
        ),
      );
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.enterCode,
        iconData: AbiliaIcons.unlock,
      ),
      body: Padding(
        padding: layout.bodyTemplateL4,
        child: Column(
          children: [
            PinCodeWidget(
              controller: controller,
              onEditingComplete: () {
                Navigator.of(context).pop(true);
              },
            ),
            SizedBox(height: layout.formPadding.groupBottomDistance),
            Tts(
              child: Text(
                '${translate.enterYourCodeToAccess} ${widget.name}',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: AbiliaColors.black60),
              ),
            ),
            const Spacer(),
            const BottomNavigation(backNavigationWidget: PreviousButton())
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }
}

const _pinLenght = 4;
const _dash = '-';

class PinCodeWidget extends StatelessWidget {
  const PinCodeWidget({
    required this.controller,
    this.onEditingComplete,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(translate.code),
        SizedBox(
          width: layout.timeInput.width,
          child: TextField(
            controller: controller,
            autofocus: true,
            showCursor: false,
            autocorrect: false,
            textAlign: TextAlign.center,
            toolbarOptions: const ToolbarOptions(),
            keyboardType: TextInputType.number,
            enableSuggestions: false,
            enableInteractiveSelection: false,
            onEditingComplete: onEditingComplete,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(_pinLenght),
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
    );
  }
}

class CodeProtextTextEditController extends TextEditingController {
  CodeProtextTextEditController()
      : super(
          text: _dash * _pinLenght,
        ) {
    selection = const TextSelection.collapsed(offset: 0);
  }

  @override
  void clear() {
    text = _dash * _pinLenght;
    selection = const TextSelection.collapsed(offset: 0);
  }
}

class DashedInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.padRight(_pinLenght, _dash));
}
