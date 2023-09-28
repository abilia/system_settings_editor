import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/cubit/agenda_cubit.dart';
import 'package:collection/collection.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:repository_base/db/baseurl_db.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/seagull_clock.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:user_files/user_files.dart';

part 'agenda.dart';

part 'clock_and_date.dart';

class HomePage extends StatelessWidget {
  final Authenticated authenticated;

  const HomePage({
    required this.authenticated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              const ClockAndDate(),
              Expanded(
                child: BlocProvider(
                  create: (context) => AgendaCubit(
                    onActivityUpdate: context.read<ActivitiesCubit>().stream,
                    clock: context.read<ClockCubit>(),
                    activityRepository: context.read<ActivityRepository>(),
                  ),
                  child: const Agenda(),
                ),
              ),
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
