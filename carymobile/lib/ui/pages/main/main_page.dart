import 'dart:math';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/cubit/agenda_cubit.dart';
import 'package:carymessenger/cubit/alarm_cubit.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/themes/cary_theme.dart';
import 'package:carymessenger/ui/themes/colors.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:carymessenger/ui/widgets/abilia_image.dart';
import 'package:carymessenger/ui/widgets/buttons/android_settings_button.dart';
import 'package:carymessenger/ui/widgets/buttons/google_play_button.dart';
import 'package:carymessenger/ui/widgets/buttons/logout_button.dart';
import 'package:carymessenger/ui/widgets/clock/analog_clock.dart';
import 'package:carymessenger/ui/widgets/cross_over.dart';
import 'package:carymessenger/ui/widgets/tts.dart';
import 'package:carymessenger/ui/widgets/version_text.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:seagull_clock/seagull_clock.dart';
import 'package:utils/date_time_extensions.dart';

part 'agenda.dart';

part 'agenda_header.dart';

part 'agenda_list.dart';

part 'agenda_tile.dart';

part 'clock_and_date.dart';

part 'hidden_extra.dart';

class MainPage extends StatefulWidget {
  final Authenticated authenticated;

  const MainPage({
    required this.authenticated,
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HiddenExtra(),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClockAndDate(expanded: expanded),
            Agenda(
              expanded: expanded,
              onTap: (s) => setState(() => expanded = s),
            ),
          ],
        ),
      ),
    );
  }
}
