import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class AbiliaTextInput extends StatelessWidget {
  final TextEditingController controller;
  final bool errorState;
  final TextInputType keyboardType;
  final Key formKey;
  final String heading;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;

  const AbiliaTextInput({
    Key key,
    this.formKey,
    @required this.heading,
    @required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters = const <TextInputFormatter>[],
    this.errorState = false,
    this.maxLines = 1,
  })  : assert(heading != null),
        assert(controller != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (heading != null) SubHeading(heading),
        Tts(
          data: controller.text.isNotEmpty ? controller.text : heading,
          child: GestureDetector(
            onTap: () => showViewDialog(
              context: context,
              builder: buildViewDialog,
              wrapWithAuthProviders: false,
            ),
            child: Container(
              color: Colors.transparent,
              child: IgnorePointer(
                child: TextFormField(
                  maxLines: maxLines,
                  minLines: 1,
                  readOnly: true,
                  key: formKey,
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

  ViewDialog buildViewDialog(BuildContext context) {
    final theme = Theme.of(context);
    final onBuildValue = controller.value;
    return ViewDialog(
      onOk: Navigator.of(context).maybePop,
      onCancle: () {
        controller.value = onBuildValue;
        Navigator.of(context).maybePop();
      },
      child: Tts.fromSemantics(
        SemanticsProperties(label: heading),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (heading != null) SubHeading(heading),
            TextField(
              key: TestKey.input,
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textCapitalization: textCapitalization,
              style: theme.textTheme.bodyText1,
              autofocus: true,
              onEditingComplete: Navigator.of(context).maybePop,
              maxLines: maxLines,
              minLines: 1,
            ),
          ],
        ),
      ),
    );
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
                  onTap: () => showViewDialog(
                    context: context,
                    builder: buildViewDialog,
                    wrapWithAuthProviders: false,
                  ),
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: TextFormField(
                        readOnly: true,
                        onTap: () => showViewDialog(
                          context: context,
                          builder: buildViewDialog,
                          wrapWithAuthProviders: false,
                        ),
                        key: TestKey.passwordInput,
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

  Widget buildViewDialog(BuildContext context) {
    final theme = Theme.of(context);
    final onBuildValue = controller.value;
    final heading = Translator.of(context).translate.password;
    return ViewDialog(
      onOk: Navigator.of(context).maybePop,
      onCancle: () {
        controller.value = onBuildValue;
        Navigator.of(context).maybePop();
      },
      child: Tts.fromSemantics(
        SemanticsProperties(
          label: heading,
          value: controller.value.text,
          textField: true,
          obscured: true,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(Translator.of(context).translate.password),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                BlocBuilder<LoginFormBloc, LoginFormState>(
                  cubit: loginFormBloc,
                  builder: (context, state) => Expanded(
                    child: TextFormField(
                      key: TestKey.input,
                      controller: controller,
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
                  loginFormBloc: loginFormBloc,
                )
              ],
            ),
          ],
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
