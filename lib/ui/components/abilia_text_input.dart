import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/buttons/ok_cancel_buttons.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class AbiliaTextInput extends StatelessWidget {
  final TextEditingController controller;
  final bool errorState;
  final TextInputType keyboardType;
  final Key formKey;
  final IconData icon;
  final String heading;
  final String inputHeading;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;
  final bool Function(String) inputValid;

  const AbiliaTextInput({
    Key key,
    this.formKey,
    @required this.icon,
    @required this.heading,
    @required this.inputHeading,
    @required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters = const <TextInputFormatter>[],
    this.errorState = false,
    this.maxLines = 1,
    this.inputValid,
  })  : assert(icon != null),
        assert(heading != null),
        assert(inputHeading != null),
        assert(controller != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(heading),
        Tts(
          data: controller.text.isNotEmpty ? controller.text : heading,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DefaultTextInputPage(
                  inputHeading: inputHeading,
                  icon: icon,
                  controller: controller,
                  heading: heading,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  textCapitalization: textCapitalization,
                  maxLines: maxLines,
                  inputValid: inputValid ?? (s) => true,
                ),
              ),
            ),
            child: Container(
              color: Colors.transparent,
              child: IgnorePointer(
                child: TextFormField(
                  key: formKey,
                  maxLines: maxLines,
                  minLines: 1,
                  readOnly: true,
                  controller: controller,
                  style: theme.textTheme.bodyText1,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (_) => errorState ? '' : null,
                  decoration: errorState
                      ? InputDecoration(
                          suffixIcon: Icon(
                            AbiliaIcons.ir_error,
                            color: theme.errorColor,
                          ),
                        )
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

class DefaultTextInputPage extends StatefulWidget {
  DefaultTextInputPage({
    Key key,
    @required this.inputHeading,
    @required this.icon,
    @required this.controller,
    @required this.heading,
    @required this.keyboardType,
    @required this.inputFormatters,
    @required this.textCapitalization,
    @required this.maxLines,
    @required this.inputValid,
  })  : onBuildValue = controller.value,
        super(key: key);

  final String inputHeading;
  final IconData icon;
  final TextEditingController controller;
  final TextEditingValue onBuildValue;
  final String heading;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool Function(String) inputValid;

  @override
  _DefaultInputPageState createState() => _DefaultInputPageState();
}

class _DefaultInputPageState extends State<DefaultTextInputPage> {
  bool _validInput = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onTextValueChanged);
    _validInput = widget.inputValid(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onTextValueChanged);
    super.dispose();
  }

  void onTextValueChanged() {
    final valid = widget.inputValid(widget.controller.text);
    if (valid != _validInput) {
      setState(() {
        _validInput = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewAbiliaAppBar(
        title: widget.inputHeading,
        iconData: widget.icon,
      ),
      bottomSheet: BottomSheet(
          builder: (context) => BottomNavigation(
                backNavigationWidget:
                    CancelButton(onPressed: () => _onClose(context)),
                forwardNavigationWidget: OkButton(
                  onPressed:
                      _validInput ? Navigator.of(context).maybePop : null,
                ),
              ),
          onClosing: () => _onClose(context)),
      body: Tts.fromSemantics(
        SemanticsProperties(label: widget.heading),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SubHeading(widget.heading),
              TextField(
                key: TestKey.input,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textCapitalization: widget.textCapitalization,
                style: Theme.of(context).textTheme.bodyText1,
                autofocus: true,
                onEditingComplete: Navigator.of(context).maybePop,
                maxLines: widget.maxLines,
                minLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onClose(BuildContext context) {
    widget.controller.value = widget.onBuildValue;
    Navigator.of(context).maybePop();
  }
}

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final bool errorState, obscureText;
  final LoginFormBloc loginFormBloc;

  const PasswordInput({
    Key key,
    @required this.controller,
    @required this.errorState,
    @required this.loginFormBloc,
    @required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = Translator.of(context).translate.password;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(heading),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Tts.fromSemantics(
                SemanticsProperties(
                  label: heading,
                  value: controller.value.text,
                  textField: true,
                  obscured: true,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PasswordInputPage(
                        controller: controller,
                        loginFormBloc: loginFormBloc,
                        context: context,
                      ),
                    ),
                  ),
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        key: TestKey.passwordInput,
                        readOnly: true,
                        controller: controller,
                        obscureText: obscureText,
                        style: theme.textTheme.bodyText1,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (_) => errorState ? '' : null,
                        decoration: errorState
                            ? InputDecoration(
                                suffixIcon: Icon(
                                  AbiliaIcons.ir_error,
                                  color: theme.errorColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            HidePasswordButton(
              loginFormBloc: loginFormBloc,
            )
          ],
        ),
      ],
    );
  }
}

class PasswordInputPage extends StatefulWidget {
  PasswordInputPage({
    Key key,
    @required this.controller,
    @required this.loginFormBloc,
    @required this.context,
  })  : onBuildValue = controller.value,
        super(key: key);

  final TextEditingController controller;
  final LoginFormBloc loginFormBloc;
  final BuildContext context;
  final TextEditingValue onBuildValue;

  @override
  _PasswordInputPageState createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends State<PasswordInputPage> {
  bool _validInput = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onTextValueChanged);
    _validInput = widget.loginFormBloc.isPasswordValid(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onTextValueChanged);
    super.dispose();
  }

  void onTextValueChanged() {
    final valid = widget.loginFormBloc.isPasswordValid(widget.controller.text);
    if (valid != _validInput) {
      setState(() {
        _validInput = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = Translator.of(context).translate.password;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        title: heading,
        iconData: AbiliaIcons.lock,
      ),
      bottomSheet: BottomSheet(builder: (ctx) {
        return Container(
          color: AbiliaColors.black80,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CancelButton(
                    onPressed: () {
                      widget.controller.value = widget.onBuildValue;
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: OkButton(
                      onPressed:
                          _validInput ? Navigator.of(context).maybePop : null),
                ),
              ],
            ),
          ),
        );
      }, onClosing: () {
        widget.controller.value = widget.onBuildValue;
        Navigator.of(context).maybePop();
      }),
      body: Tts.fromSemantics(
        SemanticsProperties(
          label: heading,
          value: widget.controller.value.text,
          textField: true,
          obscured: true,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SubHeading(Translator.of(context).translate.password),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BlocBuilder<LoginFormBloc, LoginFormState>(
                    cubit: widget.loginFormBloc,
                    builder: (context, state) => Expanded(
                      child: TextFormField(
                        key: TestKey.input,
                        controller: widget.controller,
                        obscureText: state.hidePassword,
                        keyboardType: TextInputType.visiblePassword,
                        style: theme.textTheme.bodyText1,
                        autofocus: true,
                        onEditingComplete: Navigator.of(context).maybePop,
                      ),
                    ),
                  ),
                  HidePasswordButton(
                    key: TestKey.hidePassword,
                    loginFormBloc: widget.loginFormBloc,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HidePasswordButton extends StatelessWidget {
  const HidePasswordButton({
    Key key,
    @required this.loginFormBloc,
  }) : super(key: key);
  final LoginFormBloc loginFormBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormBloc, LoginFormState>(
      cubit: loginFormBloc,
      builder: (context, state) => Padding(
        padding: state.password.isNotEmpty
            ? const EdgeInsets.only(left: 12)
            : EdgeInsets.zero,
        child: AnimatedContainer(
          duration: 150.milliseconds(),
          width: state.password.isNotEmpty ? ActionButton.size : 0.0,
          child: ActionButton(
            child: state.password.isNotEmpty
                ? Icon(
                    state.hidePassword ? AbiliaIcons.show : AbiliaIcons.hide,
                    size: defaultIconSize,
                    color: AbiliaColors.black,
                  )
                : null,
            onPressed: _onHidePasswordChanged,
            themeData: darkButtonTheme,
          ),
        ),
      ),
    );
  }

  void _onHidePasswordChanged() {
    loginFormBloc.add(HidePasswordToggle());
  }
}
