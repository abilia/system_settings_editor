import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/components/all.dart';

class TextFormInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool errorState;
  final TextInputType keyboardType;
  final Key formKey;
  final String heading;
  final bool obscureText;
  final Widget trailing;
  final String initialValue;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> inputFormatters;

  const TextFormInput({
    Key key,
    this.formKey,
    this.heading,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters = const <TextInputFormatter>[],
    this.errorState = false,
  })  : assert(controller != null || onChanged != null),
        super(key: key);
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
                key: formKey,
                initialValue: initialValue,
                controller: controller,
                onChanged: onChanged,
                obscureText: obscureText,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                textCapitalization: textCapitalization,
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
}
