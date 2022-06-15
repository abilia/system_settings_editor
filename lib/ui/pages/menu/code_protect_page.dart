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
  late final TextEditingController controller;

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
        title: translate.enterCode,
        iconData: AbiliaIcons.unlock,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PinCodeWidget(
              controller: controller,
              fieldMessage: '${translate.enterYourCodeToAccess} ${widget.name}',
              onEditingComplete: () {
                _verifyCode();
              },
            ),
            SizedBox(height: layout.formPadding.groupBottomDistance),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: PreviousButton(),
      ),
    );
  }

  Future _verifyCode() async {
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

const _pinLength = 4;
const _dash = '-';

class PinCodeWidget extends StatelessWidget {
  const PinCodeWidget({
    required this.controller,
    this.fieldMessage,
    this.onEditingComplete,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final VoidCallback? onEditingComplete;
  final String? fieldMessage;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final message = fieldMessage;
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubHeading(translate.code),
            SizedBox(
              width: layout.timeInput.width,
              child: TextField(
                controller: controller,
                autofocus: true,
                readOnly: true,
                showCursor: false,
                autocorrect: false,
                textAlign: TextAlign.center,
                toolbarOptions: const ToolbarOptions(),
                keyboardType: TextInputType.number,
                enableSuggestions: false,
                enableInteractiveSelection: false,
                style: Theme.of(context).textTheme.headline4,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: layout.borders.medium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(
            height: 24,
          ),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: AbiliaColors.black60),
          )
        ],
        const SizedBox(
          height: 96,
        ),
        AbiliaNumPad(delete: () {
          controller.text = ''.padRight(_pinLength, _dash);
        }, onClear: () {
          final code = controller.text.replaceAll('-', '');
          final n =
              code.substring(0, code.length - 1).padRight(_pinLength, _dash);
          controller.text = n;
        }, onNumPress: (n) {
          final code = controller.text.replaceAll('-', '');
          if (code.length >= 4) {
            return;
          }
          final newCode = code + n;
          controller.text = newCode.padRight(_pinLength, _dash);
          if (newCode.length >= 4) {
            onEditingComplete?.call();
          }
        }),
      ],
    );
  }
}

class CodeProtectTextEditController extends TextEditingController {
  CodeProtectTextEditController() : super(text: _dash * _pinLength);

  @override
  void clear() {
    text = _dash * _pinLength;
  }
}

String formatEditUpdate(String newV) => newV.padRight(_pinLength, _dash);
