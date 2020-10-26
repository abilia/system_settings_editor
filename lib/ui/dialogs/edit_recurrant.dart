import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditRecurrentDialog extends StatefulWidget {
  final bool allDaysVisible;

  const EditRecurrentDialog({Key key, this.allDaysVisible = false})
      : super(key: key);
  @override
  _EditRecurrentDialogState createState() => _EditRecurrentDialogState();
}

class _EditRecurrentDialogState extends State<EditRecurrentDialog> {
  ApplyTo applyTo = ApplyTo.onlyThisDay;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      heading: Text(translate.appyTo, style: abiliaTheme.textTheme.headline6),
      onOk: () => Navigator.of(context).pop(applyTo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RadioField(
            key: TestKey.onlyThisDay,
            leading: Icon(AbiliaIcons.day),
            text: Text(translate.onlyThisDay),
            value: ApplyTo.onlyThisDay,
            groupValue: applyTo,
            onChanged: _radioChanged,
          ),
          if (widget.allDaysVisible) SizedBox(height: 8.0),
          if (widget.allDaysVisible)
            RadioField(
              key: TestKey.allDays,
              leading: Icon(AbiliaIcons.month),
              text: Text(translate.allDays),
              value: ApplyTo.allDays,
              groupValue: applyTo,
              onChanged: _radioChanged,
            ),
          SizedBox(height: 8.0),
          RadioField(
            key: TestKey.thisDayAndForward,
            leading: Icon(AbiliaIcons.week),
            text: Text(translate.thisDayAndForward),
            value: ApplyTo.thisDayAndForward,
            groupValue: applyTo,
            onChanged: _radioChanged,
          ),
        ],
      ),
    );
  }

  void _radioChanged(v) => setState(() => {applyTo = v});
}
