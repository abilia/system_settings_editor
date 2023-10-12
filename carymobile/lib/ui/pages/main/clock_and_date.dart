part of 'main_page.dart';

class ClockAndDate extends StatelessWidget {
  const ClockAndDate({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),

      child: BlocBuilder<ClockCubit, DateTime>(
        builder: (context, time) => Tts.data(
          data: DateFormat.yMMMMd().add_EEEE().add_Hm().format(time),
          child: Row(
            children: [
              TimeDateText(time: time),
              const Spacer(),
              SizedBox.square(
                dimension: 136,
                child: AnalogClock(time),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeDateText extends StatelessWidget {
  final DateTime time;
  const TimeDateText({required this.time, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: headlineSmall,
      child: Column(
        children: [
          Text(
            DateFormat.Hm().format(time),
            style: headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Time of day'),
          const SizedBox(height: 8),
          Text(DateFormat.EEEE().format(time)),
          const SizedBox(height: 8),
          Text(DateFormat.yMMMMd().format(time)),
        ],
      ),
    );
  }
}
