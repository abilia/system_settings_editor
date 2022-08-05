import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FunctionSettingsPage extends StatelessWidget {
  const FunctionSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<FunctionSettingsCubit>(
      create: (context) => FunctionSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
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
                  if (functionSettingsCubit
                      .state.displayMenuChangedToDisabled) {
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
    return BlocBuilder<FunctionSettingsCubit, FunctionSettingsState>(
      builder: (context, state) {
        return _SettingsTab(
          hint: t.toolbarSettingsHint,
          children: [
            SwitchField(
              leading: const Icon(AbiliaIcons.plus),
              value: state.displayNewActivity,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(
                      state.copyWith(displayNewActivity: v)),
              child: Text(t.newActivity),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.stopWatch),
              value: state.displayNewTimer,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayNewTimer: v)),
              child: Text(t.newTimer),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.day),
              value: true,
              child: Text(t.calendarView),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.week),
              value: state.displayWeek,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayWeek: v)),
              child: Text(t.weekCalendar),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.month),
              value: state.displayMonth,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayMonth: v)),
              child: Text(t.monthCalendar),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.appMenu),
              value: state.displayMenu,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayMenu: v)),
              child: Text(t.menu),
            ),
          ],
        );
      },
    );
  }
}

class HomeScreenSettingsTab extends StatelessWidget {
  const HomeScreenSettingsTab({Key? key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<FunctionSettingsCubit, FunctionSettingsState>(
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
            if (state.displayWeek)
              RadioField(
                leading: const Icon(AbiliaIcons.week),
                text: Text(t.weekCalendar),
                value: StartView.weekCalendar,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            if (state.displayMonth)
              RadioField(
                leading: const Icon(AbiliaIcons.month),
                text: Text(t.monthCalendar),
                value: StartView.monthCalendar,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            if (state.displayMenu)
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
    return BlocBuilder<FunctionSettingsCubit, FunctionSettingsState>(
      builder: (context, state) {
        return _SettingsTab(
          hint: t.timeoutSettingsHint,
          children: [
            ...[0, 10, 5, 1].map((d) => d.minutes()).map(
                  (d) => RadioField<int>(
                    text: Text(
                      d.inMilliseconds == 0
                          ? t.noTimeout
                          : d.toDurationString(t, shortMin: false),
                    ),
                    value: d.inMilliseconds,
                    groupValue: state.timeout,
                    onChanged: (v) => context
                        .read<FunctionSettingsCubit>()
                        .changeFunctionSettings(state.copyWith(timeout: v)),
                  ),
                ),
            const Divider(),
            SwitchField(
              leading: const Icon(AbiliaIcons.screenSaverNight),
              value: state.shouldUseScreenSaver,
              onChanged: state.hasTimeOut
                  ? (v) => context
                      .read<FunctionSettingsCubit>()
                      .changeFunctionSettings(state.copyWith(useScreensaver: v))
                  : null,
              child: Text(t.activateScreensaver),
            ),
          ],
        );
      },
    );
  }
}
