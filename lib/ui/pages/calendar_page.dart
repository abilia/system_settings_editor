import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  DayPickerBloc _dayPickerBloc;
  ScrollPositionBloc _scrollPositionBloc;

  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _scrollPositionBloc = ScrollPositionBloc(
      dayPickerBloc: _dayPickerBloc,
      clockBloc: context.read<ClockBloc>(),
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
      child: BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, pickedDay) =>
            BlocBuilder<CalendarViewBloc, CalendarViewState>(
          builder: (context, calendarViewState) =>
              BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            builder: (context, memoSettingsState) {
              return DefaultTabController(
                initialIndex: 0,
                length: 3,
                child: Scaffold(
                  body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DayCalendar(
                        calendarViewState: calendarViewState,
                        dayPickerBloc: _dayPickerBloc,
                        memoSettingsState: memoSettingsState,
                        pickedDay: pickedDay,
                      ),
                      WeekCalendar(),
                      MonthCalendar()
                    ],
                  ),
                  bottomNavigationBar: CalendarBottomBar(
                    day: pickedDay.day,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
