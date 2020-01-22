import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/calendar/list_view_button.dart';
import 'package:seagull/ui/components/calendar/timepillar_view_button.dart';
import 'package:seagull/ui/theme.dart';

class ChangeCalendarViewDialog extends StatelessWidget {
  final BuildContext outerContext;
  final CalendarViewType currentViewType;

  const ChangeCalendarViewDialog(
      {Key key, @required this.outerContext, @required this.currentViewType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: Material(
          color: Colors.transparent,
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          type: MaterialType.card,
          child: dialogContent(context),
        ),
      ),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 33.0),
              decoration: BoxDecoration(
                color: AbiliaColors.white[110],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimePillarViewButton(
                      onPressed: () {
                        BlocProvider.of<CalendarViewBloc>(outerContext).add(
                            CalendarViewChanged(CalendarViewType.TIMEPILLAR));
                        Navigator.of(context).maybePop();
                      },
                      themeData: currentViewType == CalendarViewType.TIMEPILLAR
                          ? alreadySelectedChoiceButtonTheme
                          : availableToSelectButtonTheme,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: ListViewButton(
                        onPressed: () {
                          BlocProvider.of<CalendarViewBloc>(outerContext)
                              .add(CalendarViewChanged(CalendarViewType.LIST));
                          Navigator.of(context).maybePop();
                        },
                        themeData: currentViewType == CalendarViewType.LIST
                            ? alreadySelectedChoiceButtonTheme
                            : availableToSelectButtonTheme,
                      )),
                ],
              ),
            ),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: AbiliaColors.white[110],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AbiliaColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
