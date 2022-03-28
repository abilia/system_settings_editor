import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class IntervalsSettingsTab extends StatelessWidget {
  static const dayparts = [
    DayPart.morning,
    DayPart.day,
    DayPart.evening,
    DayPart.night,
  ];
  const IntervalsSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: EdgeInsets.only(
          top:
              layout.templates.m1.top - layout.formPadding.verticalItemDistance,
          bottom: layout.templates.m1.bottom,
        ),
        itemBuilder: (context, index) => IntervalStepper(part: dayparts[index]),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: dayparts.length,
      );
}

class IntervalStepper extends StatelessWidget {
  final DayPart part;

  static Key leftStepKey(DayPart part) => Key('$part-Left');
  static Key rightStepKey(DayPart part) => Key('$part-Right');

  const IntervalStepper({Key? key, required this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralCalendarSettingsCubit,
        GeneralCalendarSettingsState>(
      buildWhen: (previous, current) => previous.dayParts != current.dayParts,
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(height: layout.formPadding.verticalItemDistance),
            Tts(
              child: Text(_title(part, Translator.of(context).translate)),
            ),
            SizedBox(height: layout.formPadding.verticalItemDistance),
            SizedBox(
              width: layout.settings.intervalStepperWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconActionButtonDark(
                    key: leftStepKey(part),
                    onPressed: state.dayParts.atMin(part)
                        ? null
                        : () => context
                            .read<GeneralCalendarSettingsCubit>()
                            .decrement(part),
                    child: const Icon(AbiliaIcons.cursorLeft),
                  ),
                  Tts(
                    child: Text(
                      hourAndMinuteFormat(context)(
                        state.dayParts
                            .fromDayPart(part)
                            .fromMillisecondsSinceEpoch(isUtc: true),
                      ),
                      style: abiliaTextTheme.headline5,
                    ),
                  ),
                  IconActionButtonDark(
                    key: rightStepKey(part),
                    onPressed: state.dayParts.atMax(part)
                        ? null
                        : () => context
                            .read<GeneralCalendarSettingsCubit>()
                            .increment(part),
                    child: const Icon(AbiliaIcons.cursorRight),
                  ),
                ],
              ),
            ),
            SizedBox(height: layout.formPadding.verticalItemDistance),
          ],
        );
      },
    );
  }

  String _title(
    DayPart part,
    Translated translator,
  ) {
    switch (part) {
      case DayPart.morning:
        return translator.earyMorning;
      case DayPart.day:
        return translator.day;
      case DayPart.evening:
        return translator.evening;
      case DayPart.night:
        return translator.night;
      default:
        return '';
    }
  }
}
