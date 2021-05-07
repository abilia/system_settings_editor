import 'dart:async';
import 'dart:collection';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityViewSettingsPage extends StatelessWidget {
  const ActivityViewSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider(
      create: (context) => ActivityViewSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: BlocBuilder<ActivityViewSettingsCubit, ActivityViewSettingsState>(
        builder: (context, state) => SettingsBasePage(
          icon: AbiliaIcons.full_screen,
          title: Translator.of(context).translate.activityView,
          widgets: [
            const _FakeMemoplannerSetting(
              child: ActivityPagePreview(),
            ),
            SizedBox(height: 16.s),
            SwitchField(
              leading: Icon(AbiliaIcons.handi_alarm_vibration),
              text: Text(t.alarm),
              value: state.alarm,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(state.copyWith(alarm: v)),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.delete_all_clear),
              text: Text(t.delete),
              value: state.delete,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(state.copyWith(delete: v)),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.edit),
              text: Text(t.edit),
              value: state.edit,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(state.copyWith(edit: v)),
            ),
            const SizedBox.shrink(),
            SwitchField(
              leading: Icon(AbiliaIcons.timeline),
              text: Text(t.showQuarterHourWatchBar),
              value: state.quarterHour,
              onChanged: (v) => context
                  .read<ActivityViewSettingsCubit>()
                  .changeSettings(state.copyWith(quarterHour: v)),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.clock),
              text: Text(t.timeOnQuarterHourBar),
              value: state.quarterHour && state.timeOnQuarterHour,
              onChanged: state.quarterHour
                  ? (v) => context
                      .read<ActivityViewSettingsCubit>()
                      .changeSettings(state.copyWith(timeOnQuarterHour: v))
                  : null,
            )
          ],
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(),
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
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericBloc, GenericState>(
      builder: (context, genericState) => BlocProvider(
        create: (context) => MemoplannerSettingBloc()
          ..add(
            _updateSettings(
              genericState,
              context.read<ActivityViewSettingsCubit>().state,
            ),
          ),
        child:
            BlocListener<ActivityViewSettingsCubit, ActivityViewSettingsState>(
          listener: (context, state) =>
              context.read<MemoplannerSettingBloc>().add(
                    _updateSettings(
                      genericState,
                      state,
                    ),
                  ),
          child: child,
        ),
      ),
    );
  }

  UpdateMemoplannerSettings _updateSettings(
    GenericState genericState,
    ActivityViewSettingsState activityViewSettingsState,
  ) =>
      UpdateMemoplannerSettings(
        MapView(
          (genericState is GenericsLoaded
              ? Map<String, Generic>.from(genericState.generics)
              : Map<String, Generic>.identity())
            ..addAll(activityViewSettingsState.memoplannerSettingData
                .map((data) =>
                    Generic.createNew<MemoplannerSettingData>(data: data))
                .toGenericKeyMap()),
        ),
      );
}

class ActivityPagePreview extends StatelessWidget {
  const ActivityPagePreview({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = context.read<ClockBloc>().state.onlyDays();
    final startTime = day.add(const Duration(hours: 17));
    final time = startTime.subtract(const Duration(hours: 1, minutes: 4));
    return AbsorbPointer(
      child: Column(
        children: [
          Material(
            borderRadius: BorderRadius.all(Radius.circular(4.s)),
            elevation: 3,
            shadowColor: Colors.black,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: 256.s,
              child: FittedBox(
                child: SizedBox(
                  width: 450.0.s,
                  height: 800.0.s,
                  child: BlocProvider(
                    create: (context) => ClockBloc(
                      StreamController<DateTime>().stream,
                      initialTime: time,
                    ),
                    child: ActivityPage(
                      occasion: ActivityOccasion(
                        Activity.createNew(
                            title: Translator.of(context)
                                .translate
                                .previewActivityTitle,
                            startTime: startTime,
                            duration: const Duration(hours: 1)),
                        startTime,
                        Occasion.future,
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
        ],
      ),
    );
  }
}
