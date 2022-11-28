import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/models/all.dart';

class MonthAppBarSettingsTab extends StatelessWidget {
  const MonthAppBarSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final monthCalendarSettings =
        context.watch<MonthCalendarSettingsCubit>().state;
    return SettingsTab(
      children: [
        Tts(child: Text(t.topField)),
        const _MonthAppBarPreview(),
        SwitchField(
          value: monthCalendarSettings.showBrowseButtons,
          onChanged: (v) => context
              .read<MonthCalendarSettingsCubit>()
              .changeMonthCalendarSettings(
                  monthCalendarSettings.copyWith(showBrowseButtons: v)),
          child: Text(t.showBrowseButtons),
        ),
        SwitchField(
          value: monthCalendarSettings.showYear,
          onChanged: (v) => context
              .read<MonthCalendarSettingsCubit>()
              .changeMonthCalendarSettings(
                  monthCalendarSettings.copyWith(showYear: v)),
          child: Text(t.showYear),
        ),
        SwitchField(
          value: monthCalendarSettings.showClock,
          onChanged: (v) => context
              .read<MonthCalendarSettingsCubit>()
              .changeMonthCalendarSettings(
                  monthCalendarSettings.copyWith(showClock: v)),
          child: Text(t.showClock),
        ),
      ],
    );
  }
}

class _MonthAppBarPreview extends StatelessWidget {
  const _MonthAppBarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarSettingsCubit, MonthCalendarSettings>(
      builder: (context, monthCalendarSettings) =>
          BlocBuilder<ClockBloc, DateTime>(
        builder: (context, currentTime) => AppBarPreview(
          showBrowseButtons: monthCalendarSettings.showBrowseButtons,
          showClock: monthCalendarSettings.showClock,
          rows: AppBarTitleRows.month(
            currentTime: currentTime,
            langCode: Localizations.localeOf(context).toLanguageTag(),
            showYear: monthCalendarSettings.showYear,
            showDay: true,
          ),
        ),
      ),
    );
  }
}