import 'dart:collection';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityViewSettingsPage extends StatelessWidget {
  const ActivityViewSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider(
      create: (context) => ActivityViewSettingsCubit(
        activityViewSettings:
            context.read<MemoplannerSettingBloc>().state.settings.activityView,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: BlocBuilder<ActivityViewSettingsCubit, ActivityViewSettings>(
        builder: (context, activityViewSettings) => SettingsBasePage(
          icon: AbiliaIcons.fullScreen,
          title: t.activityView,
          label: Config.isMP ? t.calendar : null,
          widgets: [
            const _FakeMemoplannerSetting(
              child: ActivityPagePreview(),
            ),
            SizedBox(height: layout.formPadding.groupBottomDistance),
            SwitchField(
              key: TestKey.activityViewAlarmSwitch,
              leading: const Icon(AbiliaIcons.handiAlarmVibration),
              value: activityViewSettings.displayAlarmButton,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(
                      activityViewSettings.copyWith(displayAlarmButton: v)),
              child: Text(t.alarm),
            ),
            SwitchField(
              key: TestKey.activityViewRemoveSwitch,
              leading: const Icon(AbiliaIcons.deleteAllClear),
              value: activityViewSettings.displayDeleteButton,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(activityViewSettings.copyWith(displayDeleteButton: v)),
              child: Text(t.delete),
            ),
            SwitchField(
              key: TestKey.activityViewEditSwitch,
              leading: const Icon(AbiliaIcons.edit),
              value: activityViewSettings.displayEditButton,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(activityViewSettings.copyWith(displayEditButton: v)),
              child: Text(t.edit),
            ),
            const SizedBox.shrink(),
            SwitchField(
              leading: const Icon(AbiliaIcons.timeline),
              value: activityViewSettings.displayQuarterHour,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(
                      activityViewSettings.copyWith(displayQuarterHour: v)),
              child: Text(t.showQuarterHourWatchBar),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.clock),
              value: activityViewSettings.displayQuarterHour &&
                  activityViewSettings.displayTimeLeft,
              onChanged: activityViewSettings.displayQuarterHour
                  ? (v) => context
                      .read<ActivityViewSettingsCubit>()
                      .changeSettings(
                          activityViewSettings.copyWith(displayTimeLeft: v))
                  : null,
              child: Text(t.timeOnQuarterHourBar),
            )
          ],
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () {
                  context.read<ActivityViewSettingsCubit>().save();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeMemoplannerSetting extends StatelessWidget {
  final Widget child;

  const _FakeMemoplannerSetting({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericCubit, GenericState>(
      builder: (context, genericState) => BlocProvider(
        create: (context) => MemoplannerSettingBloc()
          ..add(
            _updateSettings(
              genericState,
              context.read<ActivityViewSettingsCubit>().state,
            ),
          ),
        child: BlocListener<ActivityViewSettingsCubit, ActivityViewSettings>(
          listener: (context, activityViewSettings) =>
              context.read<MemoplannerSettingBloc>().add(
                    _updateSettings(
                      genericState,
                      activityViewSettings,
                    ),
                  ),
          child: child,
        ),
      ),
    );
  }

  UpdateMemoplannerSettings _updateSettings(
    GenericState genericState,
    ActivityViewSettings activityViewSettings,
  ) =>
      UpdateMemoplannerSettings(
        MapView(
          (genericState is GenericsLoaded
              ? Map<String, Generic>.from(genericState.generics)
              : Map<String, Generic>.identity())
            ..addAll(activityViewSettings.memoplannerSettingData
                .map((data) =>
                    Generic.createNew<MemoplannerSettingData>(data: data))
                .toGenericKeyMap()),
        ),
      );
}

class ActivityPagePreview extends StatelessWidget {
  const ActivityPagePreview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = context.read<ClockBloc>().state.onlyDays();
    final startTime = day.add(const Duration(hours: 17));
    final time = startTime.subtract(const Duration(hours: 1, minutes: 4));
    return AbsorbPointer(
      child: Center(
        child: Material(
          borderRadius:
              BorderRadius.all(Radius.circular(layout.activityPreview.radius)),
          elevation: 3,
          shadowColor: Colors.black,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            height: layout.activityPreview.height,
            child: FittedBox(
              child: SizedBox(
                width: layout.activityPreview.activityWidth,
                height: layout.activityPreview.activityHeight,
                child: BlocProvider(
                  create: (context) => ClockBloc.fixed(time),
                  child: ActivityPage(
                    activityDay: ActivityDay(
                      Activity(
                        title: Translator.of(context)
                            .translate
                            .previewActivityTitle,
                        startTime: startTime,
                        duration: const Duration(hours: 1),
                        calendarId: '',
                        timezone: '',
                      ),
                      startTime,
                    ),
                    previewImage: const Image(
                      image: AssetImage('assets/graphics/cake.gif'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
