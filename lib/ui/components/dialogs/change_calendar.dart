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
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.calendarView, style: theme.textTheme.title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PickField(
            key: TestKey.timePillarButton,
            leading: Icon(AbiliaIcons.timeline),
            label: Text(
              translate.timePillarView,
              style: abiliaTheme.textTheme.body2,
            ),
            active: currentViewType == CalendarViewType.TIMEPILLAR,
            showTrailingArrow: currentViewType != CalendarViewType.TIMEPILLAR,
            onTap: () =>
                Navigator.of(context).maybePop(CalendarViewType.TIMEPILLAR),
          ),
          SizedBox(height: 8.0),
          PickField(
            leading: Icon(AbiliaIcons.list_order),
            label: Text(
              translate.listView,
              style: abiliaTheme.textTheme.body2,
            ),
            active: currentViewType == CalendarViewType.LIST,
            showTrailingArrow: currentViewType != CalendarViewType.LIST,
            onTap: () =>
                Navigator.of(context).maybePop(CalendarViewType.TIMEPILLAR),
          ),
        ],
      ),
    );
  }
}
