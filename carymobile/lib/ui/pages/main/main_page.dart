import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/cubit/agenda_cubit.dart';
import 'package:carymessenger/cubit/alarm_cubit.dart';
import 'package:carymessenger/ui/widgets/abilia_image.dart';
import 'package:carymessenger/ui/widgets/buttons/android_settings_button.dart';
import 'package:carymessenger/ui/widgets/buttons/google_play_button.dart';
import 'package:carymessenger/ui/widgets/buttons/logout_button.dart';
import 'package:carymessenger/ui/widgets/tts.dart';
import 'package:carymessenger/ui/widgets/version_text.dart';
import 'package:collection/collection.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:seagull_clock/seagull_clock.dart';
import 'package:utils/date_time_extensions.dart';

part 'agenda.dart';

part 'hidden_extra.dart';

part 'clock_and_date.dart';

class MainPage extends StatelessWidget {
  final Authenticated authenticated;

  const MainPage({
    required this.authenticated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: HiddenExtra(),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              ClockAndDate(),
              Expanded(child: Agenda()),
            ],
          ),
        ),
      ),
    );
  }
}
