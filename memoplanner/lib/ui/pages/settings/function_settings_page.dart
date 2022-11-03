import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FunctionSettingsPage extends StatelessWidget {
  const FunctionSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final settings = context.read<MemoplannerSettingsBloc>().state;
    return BlocProvider<FunctionSettingsCubit>(
      create: (context) => FunctionSettingsCubit(
        functionSettings: settings.functions,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.functions,
            label: Config.isMP ? t.settings : null,
            iconData: AbiliaIcons.menuSetup,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(t.toolbar, AbiliaIcons.shortcutMenu),
                TabItem(t.homeScreen, AbiliaIcons.browserHome),
                TabItem(t.timeout, AbiliaIcons.restore),
              ],
            ),
          ),
          body: const TabBarView(children: [
            ToolbarSettingsTab(),
            HomeScreenSettingsTab(),
            TimeoutSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () async {
                  final functionSettingsCubit =
                      context.read<FunctionSettingsCubit>();
                  final navigator = Navigator.of(context);
                  final displayMenuChangedToDisabled =
                      !functionSettingsCubit.state.display.menuValue &&
                          settings.functions.display.menuValue;
                  if (displayMenuChangedToDisabled) {
                    final answer = await showViewDialog<bool>(
                      context: context,
                      builder: (context) => YesNoDialog(
                        heading: t.functions,
                        text: t.menuRemovalWarning,
                      ),
                    );
                    if (answer != true) return;
                  }
                  functionSettingsCubit.save();
                  navigator.pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.hint,
    this.children = const [],
    Key? key,
  }) : super(key: key);
  final List<Widget> children;
  final String hint;
  @override
  Widget build(BuildContext context) => SettingsTab(children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: layout.formPadding.verticalItemDistance),
          child: Tts(child: Text(hint)),
        ),
        ...children,
      ]);
}

class ToolbarSettingsTab extends StatelessWidget {
  const ToolbarSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;

    final display =
        context.select((FunctionSettingsCubit s) => s.state.display);

    return _SettingsTab(
      hint: t.toolbarSettingsHint,
      children: [
        SwitchField(
          leading: const Icon(AbiliaIcons.plus),
          value: display.newActivity,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(newActivity: v)),
          child: Text(t.newActivity),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.stopWatch),
          value: display.newTimer,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(newTimer: v)),
          child: Text(t.newTimer),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.day),
          value: true,
          child: Text(t.calendarView),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.week),
          value: display.week,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(week: v)),
          child: Text(t.weekCalendar),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.month),
          value: display.month,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(month: v)),
          child: Text(t.monthCalendar),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.appMenu),
          value: display.menuValue,
          onChanged: display.allMenuItemsDisabled
              ? null
              : (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeDisplaySettings(display.copyWith(menuValue: v)),
          child: Text(
            '${t.menu}${display.allMenuItemsDisabled ? ' (${t.menuItemsDisabled})' : ''}',
          ),
        ),
      ],
    );
  }
}

class HomeScreenSettingsTab extends StatelessWidget {
  const HomeScreenSettingsTab({Key? key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<FunctionSettingsCubit, FunctionsSettings>(
      builder: (context, functions) {
        void onChange(v) => context
            .read<FunctionSettingsCubit>()
            .changeFunctionSettings(functions.copyWith(startView: v));
        return _SettingsTab(
          hint: t.homeScreenSettingsHint,
          children: [
            RadioField(
              leading: const Icon(AbiliaIcons.day),
              text: Text(t.calendarView),
              value: StartView.dayCalendar,
              groupValue: functions.startView,
              onChanged: onChange,
            ),
            if (functions.display.week)
              RadioField(
                leading: const Icon(AbiliaIcons.week),
                text: Text(t.weekCalendar),
                value: StartView.weekCalendar,
                groupValue: functions.startView,
                onChanged: onChange,
              ),
            if (functions.display.month)
              RadioField(
                leading: const Icon(AbiliaIcons.month),
                text: Text(t.monthCalendar),
                value: StartView.monthCalendar,
                groupValue: functions.startView,
                onChanged: onChange,
              ),
            if (functions.display.menuValue)
              RadioField(
                leading: const Icon(AbiliaIcons.appMenu),
                text: Text(t.menu),
                value: StartView.menu,
                groupValue: functions.startView,
                onChanged: onChange,
              ),
            RadioField(
              leading: const Icon(AbiliaIcons.photoCalendar),
              text: Text(t.photoCalendar.singleLine),
              value: StartView.photoAlbum,
              groupValue: functions.startView,
              onChanged: onChange,
            ),
          ],
        );
      },
    );
  }
}

class TimeoutSettingsTab extends StatelessWidget {
  const TimeoutSettingsTab({Key? key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final timeoutSettings = context.select(
      (FunctionSettingsCubit value) => value.state.timeout,
    );

    return _SettingsTab(
      hint: t.timeoutSettingsHint,
      children: [
        ...TimeoutSettings.timeoutOptions.map((d) => d.minutes()).map(
              (d) => RadioField<Duration>(
                text: Text(
                  d == Duration.zero
                      ? t.noTimeout
                      : d.toDurationString(t, shortMin: false),
                ),
                value: d,
                groupValue: timeoutSettings.duration,
                onChanged: (v) => context
                    .read<FunctionSettingsCubit>()
                    .changeTimeoutSettings(
                        timeoutSettings.copyWith(duration: v)),
              ),
            ),
        const Divider(),
        SwitchField(
          leading: const Icon(AbiliaIcons.screensaver),
          value: timeoutSettings.shouldUseScreensaver,
          onChanged: timeoutSettings.hasDuration
              ? (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeTimeoutSettings(
                      timeoutSettings.copyWith(screensaver: v))
              : null,
          child: Text(t.activateScreensaver),
        ),
        CollapsableWidget(
          collapsed: !timeoutSettings.shouldUseScreensaver,
          child: SwitchField(
            leading: const Icon(AbiliaIcons.screensaverNight),
            value: timeoutSettings.screensaverOnlyDuringNight,
            onChanged: timeoutSettings.hasDuration
                ? (v) => context
                    .read<FunctionSettingsCubit>()
                    .changeTimeoutSettings(
                        timeoutSettings.copyWith(screensaverOnlyDuringNight: v))
                : null,
            child: Text(t.onlyActivateScreensaverDuringNight),
          ),
        ),
      ],
    );
  }
}
