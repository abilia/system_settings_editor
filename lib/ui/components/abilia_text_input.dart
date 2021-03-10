import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

final errorDecoration = InputDecoration(
  suffixIcon: Padding(
    padding: EdgeInsetsDirectional.only(end: 16.0.s),
    child: Icon(
      AbiliaIcons.ir_error,
      color: AbiliaColors.red,
      size: smallIconSize,
    ),
  ),
);

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
  final bool autoCorrect;
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
    this.autoCorrect = true,
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
            onTap: () async {
              final newText = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (context) => DefaultTextInputPage(
                    inputHeading: inputHeading,
                    icon: icon,
                    text: controller.text,
                    heading: heading,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    textCapitalization: textCapitalization,
                    maxLines: maxLines,
                    autocorrect: autoCorrect,
                    inputValid: inputValid ?? (s) => true,
                  ),
                ),
              );

              if (newText != null) {
                controller.text = newText;
              }
            },
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
                  decoration: errorState ? errorDecoration : null,
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
    @required this.text,
    @required this.heading,
    @required this.keyboardType,
    @required this.inputFormatters,
    @required this.textCapitalization,
    @required this.maxLines,
    @required this.inputValid,
    @required this.autocorrect,
  }) : super(key: key);

  final String inputHeading;
  final IconData icon;
  final String text;
  final String heading;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool autocorrect;
  final bool Function(String) inputValid;

  @override
  _DefaultInputPageState createState() => _DefaultInputPageState();
}

class _DefaultInputPageState
    extends _StateWithFocusOnResume<DefaultTextInputPage> {
  TextEditingController controller;
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
    return Scaffold(
      appBar: AbiliaAppBar(
        title: widget.inputHeading,
        iconData: widget.icon,
      ),
      bottomSheet: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: _validInput ? _returnNewText : null,
        ),
      ),
      body: Tts.fromSemantics(
        SemanticsProperties(label: widget.heading),
        child: Padding(
          padding: ordinaryPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SubHeading(widget.heading),
              TextField(
                key: TestKey.input,
                controller: controller,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textCapitalization: widget.textCapitalization,
                style: Theme.of(context).textTheme.bodyText1,
                autofocus: true,
                focusNode: focusNode,
                onEditingComplete: _validInput ? _returnNewText : () {},
                maxLines: widget.maxLines,
                minLines: 1,
                smartDashesType: SmartDashesType.disabled,
                smartQuotesType: SmartQuotesType.disabled,
                autocorrect: widget.autocorrect,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _returnNewText() {
    Navigator.of(context).maybePop(controller.text);
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
                  onTap: () async {
                    final newPassword =
                        await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (context) => PasswordInputPage(
                          password: controller.text,
                          loginFormBloc: loginFormBloc,
                          context: context,
                        ),
                      ),
                    );

                    if (newPassword != null) {
                      controller.text = newPassword;
                    } else {
                      loginFormBloc
                          .add(PasswordChanged(password: controller.text));
                    }
                  },
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
                        decoration: errorState ? errorDecoration : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            HidePasswordButton(
              padding: EdgeInsets.only(left: 12.s),
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
    @required this.password,
    @required this.loginFormBloc,
    @required this.context,
  }) : super(key: key);

  final String password;
  final LoginFormBloc loginFormBloc;
  final BuildContext context;

  @override
  _PasswordInputPageState createState() => _PasswordInputPageState();
}

class _PasswordInputPageState
    extends _StateWithFocusOnResume<PasswordInputPage> {
  TextEditingController controller;
  bool _validInput = false;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.password);
    controller.text = widget.password;
    controller.addListener(onTextValueChanged);
    _validInput = widget.loginFormBloc.isPasswordValid(controller.text);
  }

  @override
  void dispose() {
    controller.removeListener(onTextValueChanged);
    controller.dispose();
    super.dispose();
  }

  void onTextValueChanged() {
    final valid = widget.loginFormBloc.isPasswordValid(controller.text);
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
      appBar: AbiliaAppBar(
        title: heading,
        iconData: AbiliaIcons.lock,
      ),
      bottomSheet: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget:
            OkButton(onPressed: _validInput ? _returnNewPassword : null),
      ),
      body: Tts.fromSemantics(
        SemanticsProperties(
          label: heading,
          value: controller.value.text,
          textField: true,
          obscured: true,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            leftPadding,
            verticalPadding,
            0,
            verticalPadding,
          ),
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
                        controller: controller,
                        obscureText: state.hidePassword,
                        keyboardType: TextInputType.visiblePassword,
                        style: theme.textTheme.bodyText1,
                        autofocus: true,
                        focusNode: focusNode,
                        onEditingComplete:
                            _validInput ? _returnNewPassword : () {},
                        onChanged: (s) => widget.loginFormBloc
                            .add(PasswordChanged(password: s)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.s),
                  HidePasswordButton(
                    loginFormBloc: widget.loginFormBloc,
                    padding: EdgeInsets.only(
                      right: horizontalPadding,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _returnNewPassword() {
    Navigator.of(context).maybePop(controller.text);
  }
}

class HidePasswordButton extends StatelessWidget {
  const HidePasswordButton({
    Key key,
    @required this.loginFormBloc,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final LoginFormBloc loginFormBloc;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormBloc, LoginFormState>(
      cubit: loginFormBloc,
      builder: (context, state) => CollapsableWidget(
        collapsed: state.password.isEmpty,
        padding: padding,
        axis: Axis.horizontal,
        child: ActionButtonDark(
          onPressed: _onHidePasswordChanged,
          child: Icon(
            state.hidePassword ? AbiliaIcons.show : AbiliaIcons.hide,
          ),
        ),
      ),
    );
  }

  void _onHidePasswordChanged() {
    loginFormBloc.add(HidePasswordToggle());
  }
}

abstract class _StateWithFocusOnResume<T extends StatefulWidget>
    extends State<T> with WidgetsBindingObserver {
  FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    if (Platform.isAndroid) WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (Platform.isAndroid) WidgetsBinding.instance.removeObserver(this);
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
