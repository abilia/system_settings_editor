import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

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
    final theme = Theme.of(context);
    return ViewDialog(
      heading: Text(translate.appyTo, style: theme.textTheme.headline6),
      onOk: () => Navigator.of(context).pop(applyTo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RadioField(
            key: TestKey.onlyThisDay,
            child: Row(
              children: <Widget>[
                Icon(AbiliaIcons.day),
                const SizedBox(width: 12),
                Text(translate.onlyThisDay)
              ],
            ),
            value: ApplyTo.onlyThisDay,
            groupValue: applyTo,
            onChanged: _radioChanged,
          ),
          if (widget.allDaysVisible) SizedBox(height: 8.0),
          if (widget.allDaysVisible)
            RadioField(
              key: TestKey.allDays,
              child: Row(
                children: <Widget>[
                  Icon(AbiliaIcons.month),
                  const SizedBox(width: 12),
                  Text(translate.allDays)
                ],
              ),
              value: ApplyTo.allDays,
              groupValue: applyTo,
              onChanged: _radioChanged,
            ),
          SizedBox(height: 8.0),
          RadioField(
            key: TestKey.thisDayAndForward,
            child: Row(
              children: <Widget>[
                Icon(AbiliaIcons.week),
                const SizedBox(width: 12),
                Text(translate.thisDayAndForward)
              ],
            ),
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
