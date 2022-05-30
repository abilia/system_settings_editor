import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class AbiliaTextInput extends StatelessWidget {
  final String initialValue, heading, inputHeading;
  final bool errorState, autoCorrect, wrapWithAuthProviders;
  final TextInputType? keyboardType;
  final Key? formKey;
  final IconData icon;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;
  final bool Function(String)? inputValid;
  final void Function(String)? onChanged;

  const AbiliaTextInput({
    Key? key,
    this.formKey,
    required this.icon,
    required this.heading,
    required this.inputHeading,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters = const <TextInputFormatter>[],
    this.errorState = false,
    this.maxLines = 1,
    this.autoCorrect = true,
    this.inputValid,
    this.wrapWithAuthProviders = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(heading),
        Tts.data(
          data: initialValue.isNotEmpty ? initialValue : heading,
          child: GestureDetector(
            onTap: onChanged == null
                ? null
                : () async {
                    final newText = await showAbiliaBottomSheet<String>(
                      context: context,
                      providers: wrapWithAuthProviders
                          ? copiedAuthProviders(context)
                          : null,
                      child: DefaultTextInput(
                        inputHeading: inputHeading,
                        icon: icon,
                        text: initialValue,
                        heading: heading,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        textCapitalization: textCapitalization,
                        maxLines: maxLines,
                        autocorrect: autoCorrect,
                        inputValid: inputValid ?? (s) => true,
                      ),
                    );

                    if (newText != null) {
                      onChanged?.call(newText);
                    }
                  },
            child: Container(
              color: Colors.transparent,
              child: IgnorePointer(
                child: TextFormField(
                  key: formKey,
                  controller: TextEditingController(text: initialValue),
                  maxLines: maxLines,
                  minLines: 1,
                  readOnly: true,
                  style: theme.textTheme.bodyText1,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (_) => errorState ? '' : null,
                  decoration: onChanged == null
                      ? inputDisabledDecoration
                      : errorState
                          ? inputErrorDecoration
                          : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DefaultTextInput extends StatefulWidget {
  const DefaultTextInput({
    Key? key,
    required this.inputHeading,
    required this.icon,
    required this.text,
    required this.heading,
    this.keyboardType,
    required this.inputFormatters,
    required this.textCapitalization,
    required this.maxLines,
    required this.inputValid,
    required this.autocorrect,
  }) : super(key: key);

  final String inputHeading;
  final IconData icon;
  final String text;
  final String heading;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool autocorrect;
  final bool Function(String) inputValid;

  @override
  _DefaultInputPageState createState() => _DefaultInputPageState();
}

class _DefaultInputPageState extends StateWithFocusOnResume<DefaultTextInput> {
  late TextEditingController controller;
  bool _validInput = false;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
    controller.addListener(onTextValueChanged);
    _validInput = widget.inputValid(controller.text);
  }

  @override
  void dispose() {
    controller.removeListener(onTextValueChanged);
    controller.dispose();
    super.dispose();
  }

  void onTextValueChanged() {
    final valid = widget.inputValid(controller.text);
    if (valid != _validInput) {
      setState(() {
        _validInput = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AbiliaAppBar(
      title: widget.inputHeading,
      iconData: widget.icon,
      roundedCorners: true,
    );

    return Tts.fromSemantics(
      SemanticsProperties(label: widget.heading),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: appBar.preferredSize.height,
            child: appBar,
          ),
          Container(
            color: AbiliaColors.white110,
            child: Padding(
              padding: layout.templates.m1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SubHeading(widget.heading),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: TestKey.input,
                          controller: controller,
                          keyboardType: widget.keyboardType,
                          inputFormatters: widget.inputFormatters,
                          textCapitalization: widget.textCapitalization,
                          style: Theme.of(context).textTheme.bodyText1,
                          autofocus: true,
                          focusNode: focusNode,
                          onEditingComplete:
                              _validInput ? _returnNewText : () {},
                          maxLines: widget.maxLines,
                          minLines: 1,
                          smartDashesType: SmartDashesType.disabled,
                          smartQuotesType: SmartQuotesType.disabled,
                          autocorrect: widget.autocorrect,
                        ),
                      ),
                      TtsPlayButton(
                        controller: controller,
                        padding: EdgeInsets.only(
                          left: layout.defaultTextInputPage
                              .textFieldActionButtonSpacing,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: OkButton(
              key: TestKey.inputOk,
              onPressed: _validInput ? _returnNewText : null,
            ),
          ),
        ],
      ),
    ).pad(EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom));
  }

  void _returnNewText() {
    Navigator.of(context).maybePop(controller.text);
  }
}

abstract class StateWithFocusOnResume<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  late FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    if (Platform.isAndroid) WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    if (Platform.isAndroid) WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      focusNode.requestFocus();
    } else if (state == AppLifecycleState.paused) {
      focusNode.unfocus();
    }
  }
}
