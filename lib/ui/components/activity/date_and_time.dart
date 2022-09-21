import 'package:intl/intl.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DateAndTimeWidget extends StatelessWidget {
  const DateAndTimeWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    final editActivityState = context.watch<EditActivityCubit>().state;
    final isFullDay = editActivityState.activity.fullDay;
    final showFullDay = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.addActivity.editActivity.fullDay);
    final showTimeWidgets = !isFullDay || showFullDay;
    final canEditDate = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.addActivity.editActivity.date);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (context.read<WizardCubit>() is! TemplateActivityWizardCubit) ...[
            SubHeading(translator.date),
            DatePicker(
              editActivityState.timeInterval.startDate,
              onChange: canEditDate
                  ? (newDate) =>
                      context.read<EditActivityCubit>().changeStartDate(newDate)
                  : null,
            ),
          ],
          if (showTimeWidgets) ...[
            SizedBox(height: layout.formPadding.groupTopDistance),
            SubHeading(translator.time),
            if (showFullDay)
              SwitchField(
                key: TestKey.fullDaySwitch,
                leading: Icon(
                  AbiliaIcons.restore,
                  size: layout.icon.small,
                ),
                value: isFullDay,
                onChanged: (v) =>
                    context.read<EditActivityCubit>().replaceActivity(
                          editActivityState.activity.copyWith(fullDay: v),
                        ),
                child: Text(translator.fullDay),
              ),
            CollapsableWidget(
              collapsed: isFullDay,
              padding: EdgeInsets.only(
                top: showFullDay ? layout.formPadding.verticalItemDistance : 0,
              ),
              child: BlocBuilder<WizardCubit, WizardState>(
                builder: (context, wizState) => TimeIntervalPicker(
                  editActivityState.timeInterval,
                  startTimeError: wizState.saveErrors.any(
                    {
                      SaveError.noStartTime,
                      SaveError.startTimeBeforeNow,
                    }.contains,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ReminderSwitch extends StatelessWidget {
  const ReminderSwitch({
    required this.activity,
    Key? key,
  }) : super(key: key);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return SwitchField(
      leading: Icon(
        AbiliaIcons.handiReminder,
        size: layout.icon.small,
      ),
      value: activity.reminders.isNotEmpty,
      onChanged: (switchOn) {
        final reminders = switchOn ? [15.minutes().inMilliseconds] : <int>[];
        context
            .read<EditActivityCubit>()
            .replaceActivity(activity.copyWith(reminderBefore: reminders));
      },
      child: Text(Translator.of(context).translate.reminders),
    );
  }
}

class DatePicker extends StatelessWidget {
  final DateTime date;
  final Function(DateTime)? onChange;
  final DateTime? notBefore;
  final bool emptyText;
  final bool errorState;
  const DatePicker(
    this.date, {
    required this.onChange,
    this.notBefore,
    this.emptyText = false,
    this.errorState = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final timeFormat = DateFormat.yMMMMd(locale.toLanguageTag());
    return BlocBuilder<ClockBloc, DateTime>(
      buildWhen: (previous, current) => previous.day != current.day,
      builder: (context, time) => PickField(
        onTap: onChange == null
            ? null
            : () async {
                final newDate = await Navigator.of(context).push<DateTime>(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => DayPickerBloc(
                            clockBloc: context.read<ClockBloc>(),
                            initialDay: date,
                          ),
                        ),
                        BlocProvider(
                          create: (context) => MonthCalendarCubit(
                            clockBloc: context.read<ClockBloc>(),
                            initialDay: date,
                            dayPickerBloc: context.read<DayPickerBloc>(),
                          ),
                        ),
                        BlocProvider.value(
                          value: context.read<MemoplannerSettingBloc>(),
                        ),
                      ],
                      child: DatePickerPage(
                        date: date,
                        notBefore: notBefore,
                      ),
                    ),
                  ),
                );
                if (newDate != null) {
                  onChange?.call(newDate);
                }
              },
        leading: const Icon(AbiliaIcons.calendar),
        text: Text(
          emptyText
              ? ''
              : (time.isAtSameDay(date)
                      ? '(${Translator.of(context).translate.today}) '
                      : '') +
                  timeFormat.format(date),
        ),
        errorState: errorState,
      ),
    );
  }
}

class TimeIntervalPicker extends StatelessWidget {
  final TimeInterval timeInterval;
  final bool startTimeError;
  const TimeIntervalPicker(this.timeInterval,
      {this.startTimeError = false, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final translator = Translator.of(context).translate;
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState, bool>(
      selector: (state) => state.settings.addActivity.general.showEndTime,
      builder: (context, showEndTime) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 148,
            child: TimePicker(
              translator.time,
              TimeInput(
                timeInterval.startTime,
                timeInterval.sameTime ? null : timeInterval.endTime,
              ),
              errorState: startTimeError,
              onTap: () async {
                final editActivityCubit = context.read<EditActivityCubit>();
                final newTimeInterval =
                    await Navigator.of(context).push<TimeInput>(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
                      child: TimeInputPage(
                        timeInput: TimeInput(
                            timeInterval.startTime,
                            timeInterval.sameTime || !showEndTime
                                ? null
                                : timeInterval.endTime),
                      ),
                    ),
                    settings: const RouteSettings(name: 'TimeInputPage'),
                  ),
                );

                if (newTimeInterval != null) {
                  editActivityCubit.changeTimeInterval(
                    startTime: newTimeInterval.startTime,
                    endTime: newTimeInterval.endTime,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TimePicker extends StatelessWidget {
  final String text;
  final TimeInput timeInput;
  final GestureTapCallback onTap;
  final bool errorState;
  const TimePicker(
    this.text,
    this.timeInput, {
    required this.onTap,
    this.errorState = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = hourAndMinuteFormat(context);
    final startTime = timeInput.startTime;
    final endTime = timeInput.endTime;
    final time = startTime == null
        ? ''
        : timeFormat(DateTime(0, 0, 0, startTime.hour, startTime.minute)) +
            (endTime == null
                ? ''
                : ' - ${timeFormat(DateTime(0, 0, 0, endTime.hour, endTime.minute))}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PickField(
          semanticsLabel: text,
          onTap: onTap,
          errorState: errorState,
          leading: const Icon(AbiliaIcons.clock),
          text: Text(time),
          trailing: errorState
              ? Icon(
                  AbiliaIcons.irError,
                  color: AbiliaColors.red,
                  size: layout.icon.small,
                )
              : PickField.trailingArrow,
        )
      ],
    );
  }
}

class Reminders extends StatelessWidget {
  final Activity activity;
  final bool expanded;

  const Reminders({
    required this.activity,
    this.expanded = false,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Wrap(
      spacing: layout.formPadding.horizontalItemDistance,
      runSpacing: layout.formPadding.verticalItemDistance,
      children: [
        5.minutes(),
        15.minutes(),
        30.minutes(),
        1.hours(),
        2.hours(),
        1.days(),
      ]
          .map(
            (r) => SelectableField(
              width: expanded ? double.infinity : null,
              text: Text(
                r.toDurationString(translator),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(height: 1.5),
              ),
              selected: activity.reminders.contains(r),
              onTap: () =>
                  context.read<EditActivityCubit>().addOrRemoveReminder(r),
            ),
          )
          .toList(),
    );
  }
}
