import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';
import 'package:seagull/utils/all.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with WidgetsBindingObserver {
  DayPickerBloc _dayPickerBloc;
  ActivitiesBloc _activitiesBloc;
  ScrollPositionBloc _scrollPositionBloc;

  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _activitiesBloc = BlocProvider.of<ActivitiesBloc>(context);
    _scrollPositionBloc = ScrollPositionBloc();
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
      _activitiesBloc.add(LoadActivities());
      _jumpToActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    return BlocProvider<ScrollPositionBloc>(
      create: (context) => _scrollPositionBloc,
      child: BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) => BlocBuilder<DayPickerBloc, DateTime>(
          builder: (context, pickedDay) => AnimatedTheme(
            data: weekDayTheme(context)[pickedDay.weekday],
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ActionButton(
                      child: Icon(AbiliaIcons.return_to_previous_page),
                      onPressed: () => _dayPickerBloc.add(PreviousDay()),
                    ),
                    Column(
                      children: [
                        Text(DateFormat('EEEE, d MMM', langCode)
                            .format(pickedDay)),
                        Opacity(
                          opacity: 0.7,
                          child: Text(
                              '${Translator.of(context).translate.week} ${pickedDay.getWeekNumber()}'),
                        ),
                      ],
                    ),
                    ActionButton(
                      child: Icon(AbiliaIcons.go_to_next_page),
                      onPressed: () => _dayPickerBloc.add(NextDay()),
                    ),
                  ],
                ),
                centerTitle: true,
              ),
              body: Agenda(),
              bottomNavigationBar: BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GoToNowButton(
                        onPressed: () => _jumpToActivity(),
                      ),
                      ActionButton(
                        width: 48,
                        height: 48,
                        child: Icon(
                          AbiliaIcons.menu,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LogoutPage()),
                        ),
                        themeData: menuButtonTheme(context),
                      ),
                      const SizedBox(
                        width: 48,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _jumpToActivity() async {
    final scrollState = await _scrollPositionBloc.first;
    if (scrollState is OutOfView) {
      final sc = scrollState.scrollController;
      sc.jumpTo(min(sc.initialScrollOffset, sc.position.maxScrollExtent));
    } else if (scrollState is WrongDay) {
      _dayPickerBloc.add(CurrentDay());
    }
  }
}
