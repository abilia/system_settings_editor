import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:seagull_clock/clock_cubit.dart';

class ClockAndDate extends StatelessWidget {
  const ClockAndDate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, DateTime>(
      builder: (context, time) => Column(
        children: [
          Text(DateFormat.Hm().format(time)),
          Text(DateFormat.EEEE().format(time)),
          Text(DateFormat.yMMMMd().format(time)),
        ],
      ),
    );
  }
}
