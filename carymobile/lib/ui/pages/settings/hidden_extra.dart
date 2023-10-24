import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:seagull_clock/seagull_clock.dart';
import 'package:utils/date_time_extensions.dart';

class FakeTime extends StatelessWidget {
  const FakeTime({super.key});

  final aYear = const Duration(days: 365);

  @override
  Widget build(BuildContext context) {
    final now = context.watch<ClockCubit>().state;
    return Column(
      children: [
        FilledButton(
          child: Text(DateFormat.Hm().format(now)),
          onPressed: () async {
            final t = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (t != null) {
              GetIt.I<Ticker>().setFakeTime(now.withTime(t));
            }
          },
        ),
        const SizedBox(height: 8),
        FilledButton(
          child: Text(DateFormat.yMMMMd().format(now)),
          onPressed: () async {
            final t = await showDatePicker(
              firstDate: DateTime.now().subtract(aYear),
              initialDate: DateTime.now(),
              lastDate: DateTime.now().add(aYear),
              context: context,
            );
            if (t != null) {
              GetIt.I<Ticker>()
                  .setFakeTime(t.withTime(TimeOfDay.fromDateTime(now)));
            }
          },
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: GetIt.I<Ticker>().reset,
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
