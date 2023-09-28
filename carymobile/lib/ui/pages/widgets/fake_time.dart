import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:seagull_clock/seagull_clock.dart';
import 'package:utils/date_time_extensions.dart';

class FakeTime extends StatelessWidget {
  FakeTime({super.key});
  late final Ticker ticker = GetIt.I<Ticker>();
  final aYear = const Duration(days: 365);

  @override
  Widget build(BuildContext context) {
    final now = context.watch<ClockCubit>().state;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          child: Text(DateFormat.Hm().format(now)),
          onPressed: () async {
            final t = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (t != null) {
              ticker.setFakeTime(now.withTime(t));
            }
          },
        ),
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
              ticker.setFakeTime(t.withTime(TimeOfDay.fromDateTime(now)));
            }
          },
        ),
        FilledButton(
          onPressed: ticker.reset,
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
