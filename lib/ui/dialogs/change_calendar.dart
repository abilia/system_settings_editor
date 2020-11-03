import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class ChangeCalendarDialog extends StatelessWidget {
  final CalendarViewType currentViewType;

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
                    value: CalendarViewType.TIMEPILLAR,
                    groupValue: currentViewType,
                    trailing: currentViewType != CalendarViewType.TIMEPILLAR
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
              value: CalendarViewType.LIST,
              groupValue: currentViewType,
              trailing: currentViewType != CalendarViewType.LIST
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
