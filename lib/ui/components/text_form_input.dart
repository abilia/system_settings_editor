import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/components/all.dart';

class TextFormInput extends StatelessWidget {
  final TextEditingController controller;
  final bool errorState;
  final TextInputType keyboardType;
  final Key formKey;
  final String heading;
  final bool obscureText;
  final Widget trailing;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> inputFormatters;

  const TextFormInput({
    Key key,
    this.formKey,
    this.heading,
    @required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters = const <TextInputFormatter>[],
    this.errorState = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (heading != null) SubHeading(heading),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextFormField(
                readOnly: true,
                onTap: () => showViewDialog(
                    context: context,
                    builder: (context) => buildViewDialog(context)),
                key: formKey,
                controller: controller,
                obscureText: obscureText,
                style: theme.textTheme.bodyText1,
                autovalidate: true,
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
            if (trailing != null) trailing
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (heading != null) SubHeading(heading),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  key: formKey,
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  textCapitalization: textCapitalization,
                  style: theme.textTheme.bodyText1,
                  autofocus: true,
                  onEditingComplete: Navigator.of(context).maybePop,
                ),
              ),
              if (trailing != null) trailing
            ],
          ),
        ],
      ),
    );
  }
}
