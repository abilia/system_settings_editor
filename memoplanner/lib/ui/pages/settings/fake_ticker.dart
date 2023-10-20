import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FakeTicker extends StatefulWidget {
  const FakeTicker({super.key});

  @override
  State createState() => _FakeTickerState();
}

class _FakeTickerState extends State<FakeTicker> {
  late final Ticker ticker = GetIt.I<Ticker>();
  bool get useMockTime => ticker.ticksPerSecond != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: layout.formPadding.groupTopDistance),
      child: Column(
        children: [
          SwitchField(
            value: useMockTime,
            onChanged: (v) {
              if (!v) {
                ticker.reset();
              } else {
                ticker.setFakeTicker(1);
              }
              setState(() => {});
            },
            child: const Text('Fake time'),
          ),
          CollapsableWidget(
            collapsed: !useMockTime,
            child: Padding(
              padding: EdgeInsets.all(layout.formPadding.verticalItemDistance),
              child: BlocBuilder<ClockCubit, DateTime>(
                builder: (context, state) {
                  final time = TimeOfDay.fromDateTime(state);
                  return Column(
                    children: [
                      DatePicker(
                        state,
                        onChange: (newDate) async {
                          ticker.setFakeTime(newDate.withTime(time));
                        },
                      ),
                      TimePicker(
                        '${ticker.ticksPerSecond?.toInt() ?? 1} min/min',
                        TimeInput(time, null),
                        onTap: () async {
                          final newTime = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (newTime != null) {
                            ticker.setFakeTime(state.withTime(newTime));
                          }
                        },
                      ),
                      Slider(
                        value: ticker.ticksPerSecond ?? 1,
                        divisions: 300,
                        onChanged: (v) {
                          ticker.setFakeTicker(v);
                          setState(() {});
                        },
                        max: 300,
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
