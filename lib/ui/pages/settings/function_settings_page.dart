import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FunctionSettingsPage extends StatelessWidget {
  const FunctionSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final initialState =
        context.read<MemoplannerSettingBloc>().state.settings.functions;
    return BlocProvider<FunctionSettingsCubit>(
      create: (context) => FunctionSettingsCubit(
        functionSettings: initialState,
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
                          initialState.display.menuValue;
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

    final state = context
        .select<FunctionSettingsCubit, DisplaySettings>((s) => s.state.display);

    return _SettingsTab(
      hint: t.toolbarSettingsHint,
      children: [
        SwitchField(
          leading: const Icon(AbiliaIcons.plus),
          value: state.newActivity,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(state.copyWith(newActivity: v)),
          child: Text(t.newActivity),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.stopWatch),
          value: state.newTimer,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(state.copyWith(newTimer: v)),
          child: Text(t.newTimer),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.day),
          value: true,
          child: Text(t.calendarView),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.week),
          value: state.week,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(state.copyWith(week: v)),
          child: Text(t.weekCalendar),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.month),
          value: state.month,
          onChanged: (v) => context
              .read<FunctionSettingsCubit>()
              .changeDisplaySettings(state.copyWith(month: v)),
          child: Text(t.monthCalendar),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.appMenu),
          value: state.menuValue,
          onChanged: state.allMenuItemsDisabled
              ? null
              : (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeDisplaySettings(state.copyWith(menuValue: v)),
          child: Text(
            '${t.menu}${state.allMenuItemsDisabled ? ' (${t.menuItemsDisabled})' : ''}',
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
    return BlocBuilder<FunctionSettingsCubit, FunctionSettings>(
      builder: (context, state) {
        void onChange(v) => context
            .read<FunctionSettingsCubit>()
            .changeFunctionSettings(state.copyWith(startView: v));
        return _SettingsTab(
          hint: t.homeScreenSettingsHint,
          children: [
            RadioField(
              leading: const Icon(AbiliaIcons.day),
              text: Text(t.calendarView),
              value: StartView.dayCalendar,
              groupValue: state.startView,
              onChanged: onChange,
            ),
            if (state.display.week)
              RadioField(
                leading: const Icon(AbiliaIcons.week),
                text: Text(t.weekCalendar),
                value: StartView.weekCalendar,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            if (state.display.month)
              RadioField(
                leading: const Icon(AbiliaIcons.month),
                text: Text(t.monthCalendar),
                value: StartView.monthCalendar,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            if (state.display.menuValue)
              RadioField(
                leading: const Icon(AbiliaIcons.appMenu),
                text: Text(t.menu),
                value: StartView.menu,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            RadioField(
              leading: const Icon(AbiliaIcons.photoCalendar),
              text: Text(t.photoCalendar.singleLine),
              value: StartView.photoAlbum,
              groupValue: state.startView,
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
    final state = context.select<FunctionSettingsCubit, ScreensaverSettings>(
      (value) => value.state.screensaver,
    );

    return _SettingsTab(
      hint: t.timeoutSettingsHint,
      children: [
        ...[0, 10, 5, 1].map((d) => d.minutes()).map(
              (d) => RadioField<Duration>(
                text: Text(
                  d == Duration.zero
                      ? t.noTimeout
                      : d.toDurationString(t, shortMin: false),
                ),
                value: d,
                groupValue: state.timeout,
                onChanged: (v) => context
                    .read<FunctionSettingsCubit>()
                    .changeScreensaverSettings(state.copyWith(timeout: v)),
              ),
            ),
        const Divider(),
        SwitchField(
          leading: const Icon(AbiliaIcons.screenSaverNight),
          value: state.shouldUseScreenSaver,
          onChanged: state.hasTimeOut
              ? (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeScreensaverSettings(state.copyWith(use: v))
              : null,
          child: Text(t.activateScreensaver),
        ),
        CollapsableWidget(
          child: SwitchField(
            leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
            value: state.onlyDuringNight,
            onChanged: state.hasTimeOut
                ? (v) => context
                    .read<FunctionSettingsCubit>()
                    .changeScreensaverSettings(
                        state.copyWith(onlyDuringNight: v))
                : null,
            child: Text(t.onlyActivateScreenSaverDuringNight),
          ),
          collapsed: !state.shouldUseScreenSaver,
        ),
      ],
    );
  }
}
