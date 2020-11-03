import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ChangeCalendarDialog extends StatelessWidget {
  final CalendarType currentViewType;

  const ChangeCalendarDialog({Key key, @required this.currentViewType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = darkButtonTheme;
    return Theme(
      data: theme,
      child: ViewDialog(
        heading: Text(translate.calendarView, style: theme.textTheme.headline6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: RadioField(
                    key: TestKey.timePillarButton,
                    leading: Icon(AbiliaIcons.timeline),
                    text: Text(
                      translate.timePillarView,
                      style: abiliaTheme.textTheme.bodyText1,
                    ),
                    value: CalendarType.TIMEPILLAR,
                    groupValue: currentViewType,
                    trailing: currentViewType != CalendarType.TIMEPILLAR
                        ? PickField.trailingArrow
                        : null,
                    onChanged: Navigator.of(context).maybePop,
                  ),
                ),
                Padding(
                  key: TestKey.timePillarSettingsButton,
                  padding: const EdgeInsets.only(left: 8),
                  child: ActionButton(
                    child: Icon(AbiliaIcons.settings),
                    onPressed: () async {
                      await Navigator.of(context).maybePop();
                      await showViewDialog(
                          context: context,
                          builder: (context) => TimePillarSettings());
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            RadioField(
              key: TestKey.agendaListButton,
              leading: Icon(AbiliaIcons.list_order),
              text: Text(
                translate.listView,
                style: abiliaTheme.textTheme.bodyText1,
              ),
              value: CalendarType.LIST,
              groupValue: currentViewType,
              trailing: currentViewType != CalendarType.LIST
                  ? PickField.trailingArrow
                  : null,
              onChanged: Navigator.of(context).maybePop,
            ),
          ],
        ),
      ),
    );
  }
}
