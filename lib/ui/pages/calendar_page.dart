// @dart=2.9

import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  ScrollPositionBloc _scrollPositionBloc;

  @override
  void initState() {
    _scrollPositionBloc = ScrollPositionBloc(
      dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
      clockBloc: context.read<ClockBloc>(),
      timepillarBloc: context.read<TimepillarBloc>(),
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _scrollPositionBloc.add(GoToNow());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrollPositionBloc>.value(
      value: _scrollPositionBloc,
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (old, fresh) =>
            old.runtimeType != fresh.runtimeType ||
            old.calendarCount != fresh.calendarCount ||
            old.displayBottomBar != fresh.displayBottomBar,
        builder: (context, settingsState) => DefaultTabController(
          initialIndex: 0,
          length: settingsState.calendarCount,
          child: Scaffold(
            bottomNavigationBar: settingsState is MemoplannerSettingsLoaded &&
                    settingsState.displayBottomBar
                ? const CalendarBottomBar()
                : null,
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const DayCalendar(),
                if (settingsState.displayWeekCalendar) const WeekCalendarTab(),
                if (settingsState.displayMonthCalendar) const MonthCalendar()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
