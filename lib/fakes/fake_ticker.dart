import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FakeTicker extends StatefulWidget {
  const FakeTicker({Key? key}) : super(key: key);

  @override
  _FakeTickerState createState() => _FakeTickerState();
}

class _FakeTickerState extends State<FakeTicker> {
  double? minPerMin;
  bool get useMockTime => minPerMin != null;
  @override
  void initState() {
    minPerMin = context.read<ClockBloc>().minPerMin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 32.0.s),
      child: Column(
        children: [
          SwitchField(
            value: useMockTime,
            onChanged: (v) {
              setState(() => minPerMin = v ? 1 : null);
              final cb = context.read<ClockBloc>();
              if (!v) {
                cb.resetTicker(GetIt.I<Ticker>());
              }
            },
            child: const Text('Fake time'),
          ),
          CollapsableWidget(
            collapsed: !useMockTime,
            child: Padding(
              padding: EdgeInsets.all(8.0.s),
              child: BlocBuilder<ClockBloc, DateTime>(
                builder: (context, state) {
                  final time = TimeOfDay.fromDateTime(state);
                  return Column(
                    children: [
                      DatePicker(
                        state,
                        onChange: (newDate) async {
                          context.read<ClockBloc>().setFakeTicker(
                                initTime: newDate
                                    .withTime(TimeOfDay.fromDateTime(state)),
                              );
                        },
                      ),
                      TimePicker(
                        '${minPerMin?.toInt() ?? 1} min/min',
                        TimeInput(time, null),
                        onTap: () async {
                          final newTime = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (newTime != null) {
                            context.read<ClockBloc>().setFakeTicker(
                                  initTime: state.withTime(newTime),
                                );
                          }
                        },
                      ),
                      Slider(
                        value: minPerMin ?? 1,
                        divisions: 599,
                        onChanged: (v) {
                          setState(() => minPerMin = v);
                          context
                              .read<ClockBloc>()
                              .setFakeTicker(ticksPerMin: v);
                        },
                        max: 600,
                        min: 1,
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
