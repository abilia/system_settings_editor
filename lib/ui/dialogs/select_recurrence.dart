import 'package:flutter/material.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SelectRecurrenceDialog extends StatelessWidget {
  final RecurrentType recurrentType;

  const SelectRecurrenceDialog({Key key, @required this.recurrentType})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      heading: Text(translate.recurrence,
          style: Theme.of(context).textTheme.headline6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...[
            RecurrentType.none,
            RecurrentType.weekly,
            RecurrentType.monthly,
            RecurrentType.yearly
          ].map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RadioField(
                groupValue: recurrentType,
                onChanged: Navigator.of(context).maybePop,
                value: type,
                leading: Icon(type.iconData()),
                text: Text(type.text(translate)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
