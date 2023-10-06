part of 'main_page.dart';

class ClockAndDate extends StatelessWidget {
  const ClockAndDate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, DateTime>(
      builder: (context, time) => Tts.data(
        data: DateFormat.yMMMMd().add_EEEE().add_Hm().format(time),
        child: Column(
          children: [
            Text(DateFormat.Hm().format(time)),
            Text(DateFormat.EEEE().format(time)),
            Text(DateFormat.yMMMMd().format(time)),
          ],
        ),
      ),
    );
  }
}
