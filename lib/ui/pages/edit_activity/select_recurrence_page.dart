import 'package:flutter/material.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SelectRecurrencePage extends StatefulWidget {
  final RecurrentType recurrentType;

  const SelectRecurrencePage({Key key, @required this.recurrentType})
      : super(key: key);

  @override
  _SelectRecurrencePageState createState() =>
      _SelectRecurrencePageState(recurrentType);
}

class _SelectRecurrencePageState extends State<SelectRecurrencePage> {
  RecurrentType newType;

  _SelectRecurrencePageState(this.newType);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.recurrence,
        iconData: AbiliaIcons.repeat,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 24,
        ),
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
                  groupValue: newType,
                  onChanged: (v) {
                    setState(() {
                      newType = v;
                    });
                  },
                  value: type,
                  leading: Icon(type.iconData()),
                  text: Text(type.text(translate)),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).maybePop(newType),
        ),
      ),
    );
  }
}
