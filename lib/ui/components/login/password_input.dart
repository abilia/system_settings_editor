// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class PasswordInput extends StatelessWidget {
  final String password;
  final Function(String) onPasswordChange;
  final bool Function(String value) validator;
  final bool errorState;
  final String inputHeading;

  const PasswordInput({
    Key key,
    @required this.password,
    @required this.onPasswordChange,
    @required this.errorState,
    @required this.validator,
    this.inputHeading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _subheading =
        inputHeading ?? Translator.of(context).translate.password;
    return BlocProvider(
      create: (_) => PasswordCubit(password, validator),
      child: BlocBuilder<PasswordCubit, PasswordState>(
        buildWhen: (previous, current) => previous.hide != current.hide,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(_subheading),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Tts.fromSemantics(
                    SemanticsProperties(
                      label: _subheading,
                      value: password,
                      textField: true,
                      obscured: state.hide,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final newPassword =
                            await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider<PasswordCubit>.value(
                              value: context.read<PasswordCubit>(),
                              child: PasswordInputPage(
                                password: password,
                                inputHeading: _subheading,
                              ),
                            ),
                          ),
                        );
                        if (newPassword != null) {
                          onPasswordChange(newPassword);
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: IgnorePointer(
                          child: TextFormField(
                            controller: TextEditingController(text: password),
                            readOnly: true,
                            obscureText: state.hide,
                            validator: (_) => errorState ? '' : null,
                            style: theme.textTheme.bodyText1,
                            autovalidateMode: AutovalidateMode.always,
                            decoration:
                                errorState ? inputErrorDecoration : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                HidePasswordButton(
                  padding: EdgeInsets.only(left: 12.s),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordInputPage extends StatefulWidget {
  PasswordInputPage({
    Key key,
    @required this.password,
    @required this.inputHeading,
  }) : super(key: key);

  final String password, inputHeading;

  @override
  _PasswordInputPageState createState() => _PasswordInputPageState();
}

class _PasswordInputPageState
    extends StateWithFocusOnResume<PasswordInputPage> {
  TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _subheading =
        widget.inputHeading ?? Translator.of(context).translate.password;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.password,
        iconData: AbiliaIcons.lock,
      ),
      body: BlocBuilder<PasswordCubit, PasswordState>(
        builder: (context, state) => Column(
          children: [
            Tts.fromSemantics(
              SemanticsProperties(
                label: _subheading,
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
                    SubHeading(_subheading),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            key: TestKey.input,
                            controller: controller,
                            onChanged: (s) =>
                                context.read<PasswordCubit>().changePassword(s),
                            obscureText: state.hide,
                            keyboardType: TextInputType.visiblePassword,
                            style: Theme.of(context).textTheme.bodyText1,
                            autofocus: true,
                            focusNode: focusNode,
                            onEditingComplete: () async {
                              if (state.valid) {
                                await Navigator.of(context)
                                    .maybePop(controller.text);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.s),
                        HidePasswordButton(
                          padding: EdgeInsets.only(right: horizontalPadding),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            BottomNavigation(
              backNavigationWidget: CancelButton(
                onPressed: Navigator.of(context).maybePop,
              ),
              forwardNavigationWidget: OkButton(
                key: TestKey.inputOk,
                onPressed: state.valid
                    ? () => Navigator.of(context).maybePop(controller.text)
                    : null,
              ),
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
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordCubit, PasswordState>(
      builder: (context, state) => CollapsableWidget(
        collapsed: state.password.isEmpty,
        padding: padding,
        axis: Axis.horizontal,
        child: ActionButtonDark(
          onPressed: () => context.read<PasswordCubit>().toggleHidden(),
          child: Icon(
            state.hide ? AbiliaIcons.show : AbiliaIcons.hide,
          ),
        ),
      ),
    );
  }
}
