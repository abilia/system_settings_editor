part of 'main_page.dart';

class HiddenExtra extends StatelessWidget {
  const HiddenExtra({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const VersionText(),
          FakeTime(),
          const AndroidSettingsButton(),
          const GooglePlayButton(),
          const LogoutButton(),
        ],
      ),
    );
  }
}

class FakeTime extends StatelessWidget {
  FakeTime({super.key});
  late final Ticker ticker = GetIt.I<Ticker>();
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
      ]
          .map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: w,
            ),
          )
          .toList(),
    );
  }
}
