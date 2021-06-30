// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import 'all.dart';

class EyeButtonMonthDialog extends StatefulWidget {
  final MonthCalendarType currentCalendarType;

  const EyeButtonMonthDialog({
    Key key,
    @required this.currentCalendarType,
  }) : super(key: key);

  @override
  _EyeButtonMonthDialogState createState() => _EyeButtonMonthDialogState(
        calendarType: currentCalendarType,
      );
}

class _EyeButtonMonthDialogState extends State<EyeButtonMonthDialog> {
  MonthCalendarType calendarType;
  ScrollController _controller;

  _EyeButtonMonthDialogState({
    @required this.calendarType,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return ViewDialog(
      heading: AppBarHeading(
        text: t.display,
        iconData: AbiliaIcons.show,
      ),
      body: AbiliaScrollBar(
        controller: _controller,
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.s, 24.s, 16.s, 8.s),
              child: Selector<MonthCalendarType>(
                heading: t.viewMode,
                groupValue: calendarType,
                items: [
                  SelectorItem(
                    t.listView,
                    AbiliaIcons.scanning_field_by_field,
                    MonthCalendarType.grid,
                  ),
                  SelectorItem(
                    t.timePillarView,
                    AbiliaIcons.calendar_list,
                    MonthCalendarType.preview,
                  ),
                ],
                onChanged: (type) => setState(() => calendarType = type),
              ),
            ),
          ],
        ),
      ),
      bodyPadding: EdgeInsets.zero,
      expanded: true,
      backNavigationWidget: CancelButton(),
      forwardNavigationWidget: OkButton(
        onPressed: () => Navigator.of(context).maybePop(calendarType),
      ),
    );
  }
}
