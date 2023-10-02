import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/cubit/agenda_cubit.dart';
import 'package:carymessenger/cubit/alarm_cubit.dart';
import 'package:carymessenger/ui/pages/widgets/abilia_image.dart';
import 'package:collection/collection.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:seagull_clock/seagull_clock.dart';
import 'package:utils/date_time_extensions.dart';

part 'agenda.dart';

part 'fake_time.dart';

part 'clock_and_date.dart';

class MainPage extends StatelessWidget {
  final Authenticated authenticated;

  const MainPage({
    required this.authenticated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FakeTime(),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              const ClockAndDate(),
              const Expanded(child: Agenda()),
              FilledButton(
                onPressed: () =>
                    context.read<AuthenticationBloc>().add(const LoggedOut()),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
