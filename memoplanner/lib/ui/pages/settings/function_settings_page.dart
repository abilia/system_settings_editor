import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FunctionSettingsPage extends StatelessWidget {
  const FunctionSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
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
            title: translate.functions,
            label: Config.isMP ? translate.settings : null,
            iconData: AbiliaIcons.menuSetup,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(translate.toolbar, AbiliaIcons.shortcutMenu),
                TabItem(translate.homeScreen, AbiliaIcons.browserHome),
                TabItem(translate.timeout, AbiliaIcons.restore),
              ],
            ),
          ),
          body: Builder(builder: (context) {
            return TrackableTabBarView(
              analytics: GetIt.I<SeagullAnalytics>(),
              children: const [
                ToolbarSettingsTab(),
                HomeScreenSettingsTab(),
                TimeoutSettingsTab(),
              ],
            );
          }),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () async {
                  final functionSettingsCubit =
                      context.read<FunctionSettingsCubit>();
                  final displayMenuChangedToDisabled =
                      !functionSettingsCubit.state.display.menuValue &&
                          settings.functions.display.menuValue;
                  if (displayMenuChangedToDisabled) {
                    final answer = await showViewDialog<bool>(
                      context: context,
                      builder: (context) => const MenuRemovalWarningDialog(),
                      routeSettings: (MenuRemovalWarningDialog).routeSetting(),
                    );
                    if (answer != true) return;
                  }
                  await functionSettingsCubit.save();
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuRemovalWarningDialog extends StatelessWidget {
  const MenuRemovalWarningDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return YesNoDialog(
      heading: translate.menu,
      text: translate.menuRemovalWarning,
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
    final translate = Lt.of(context);

    final display =
        context.select((FunctionSettingsCubit s) => s.state.display);

    return _SettingsTab(
      hint: translate.toolbarSettingsHint,
      children: [
        SwitchField(
          leading: const Icon(AbiliaIcons.plus),
          value: display.newActivity,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(newActivity: v)),
          child: Text(translate.newActivity),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.stopWatch),
          value: display.newTimer,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(newTimer: v)),
          child: Text(translate.newTimer),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.day),
          value: true,
          child: Text(translate.calendarView),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.week),
          value: display.week,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(week: v)),
          child: Text(translate.weekCalendar),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.month),
          value: display.month,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(display.copyWith(month: v)),
          child: Text(translate.monthCalendar),
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
            '${translate.menu}${display.allMenuItemsDisabled ? ' (${translate.menuItemsDisabled})' : ''}',
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
    final translate = Lt.of(context);
    return BlocBuilder<FunctionSettingsCubit, FunctionsSettings>(
      builder: (context, functions) {
        void onChange(v) => context
            .read<FunctionSettingsCubit>()
            .changeFunctionSettings(functions.copyWith(startView: v));
        return _SettingsTab(
          hint: translate.homeScreenSettingsHint,
          children: [
            RadioField(
              leading: const Icon(AbiliaIcons.day),
              text: Text(translate.calendarView),
              value: StartView.dayCalendar,
              groupValue: functions.startView,
              onChanged: onChange,
            ),
            if (functions.display.week)
              RadioField(
                leading: const Icon(AbiliaIcons.week),
                text: Text(translate.weekCalendar),
                value: StartView.weekCalendar,
                groupValue: functions.startView,
                onChanged: onChange,
              ),
            if (functions.display.month)
              RadioField(
                leading: const Icon(AbiliaIcons.month),
                text: Text(translate.monthCalendar),
                value: StartView.monthCalendar,
                groupValue: functions.startView,
                onChanged: onChange,
              ),
            if (functions.display.menuValue)
              RadioField(
                leading: const Icon(AbiliaIcons.appMenu),
                text: Text(translate.menu),
                value: StartView.menu,
                groupValue: functions.startView,
                onChanged: onChange,
              ),
            RadioField(
              leading: const Icon(AbiliaIcons.photoCalendar),
              text: Text(translate.photoCalendar.singleLine),
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
    final translate = Lt.of(context);
    final timeoutSettings = context.select(
      (FunctionSettingsCubit value) => value.state.timeout,
    );

    return _SettingsTab(
      hint: translate.timeoutSettingsHint,
      children: [
        ...TimeoutSettings.timeoutOptions.map((d) => d.minutes()).map(
              (d) => RadioField<Duration>(
                text: Text(
                  d == Duration.zero
                      ? translate.noTimeout
                      : d.toDurationString(translate, shortMin: false),
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
          child: Text(translate.activateScreensaver),
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
            child: Text(translate.onlyActivateScreensaverDuringNight),
          ),
        ),
      ],
    );
  }
}
