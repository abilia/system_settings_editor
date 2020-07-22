import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

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
                  child: PickField(
                    key: TestKey.timePillarButton,
                    leading: Icon(AbiliaIcons.timeline),
                    label: Text(
                      translate.timePillarView,
                      style: abiliaTheme.textTheme.bodyText1,
                    ),
                    active: currentViewType == CalendarViewType.TIMEPILLAR,
                    showTrailingArrow:
                        currentViewType != CalendarViewType.TIMEPILLAR,
                    onTap: () => Navigator.of(context)
                        .maybePop(CalendarViewType.TIMEPILLAR),
                  ),
                ),
                Padding(
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
            PickField(
              key: TestKey.agendaListButton,
              leading: Icon(AbiliaIcons.list_order),
              label: Text(
                translate.listView,
                style: abiliaTheme.textTheme.bodyText1,
              ),
              active: currentViewType == CalendarViewType.LIST,
              showTrailingArrow: currentViewType != CalendarViewType.LIST,
              onTap: () =>
                  Navigator.of(context).maybePop(CalendarViewType.LIST),
            ),
          ],
        ),
      ),
    );
  }
}
