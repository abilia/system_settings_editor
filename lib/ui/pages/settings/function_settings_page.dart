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
        genericBloc: context.read<GenericBloc>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.functions,
            iconData: AbiliaIcons.menuSetup,
            bottom: AbiliaTabBar(
              tabs: const <Widget>[
                Icon(AbiliaIcons.shortcutMenu),
                Icon(AbiliaIcons.browserHome),
                Icon(AbiliaIcons.restore),
              ],
            ),
          ),
          body: TabBarView(children: const [
            ToolbarSettingsTab(),
            HomeScreenSettingsTab(),
            TimeoutSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () async {
                  if (context
                      .read<FunctionSettingsCubit>()
                      .state
                      .displayMenuChangedToDisabled) {
                    final answer = await showViewDialog<bool>(
                      context: context,
                      builder: (context) => YesNoDialog(
                        heading: t.functions,
                        text: t.menuRemovalWarning,
                      ),
                    );
                    if (answer != true) return;
                  }
                  context.read<FunctionSettingsCubit>().save();
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

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    Key? key,
    required this.hint,
    this.children = const [],
  }) : super(key: key);
  final List<Widget> children;
  final String hint;
  @override
  Widget build(BuildContext context) => SettingsTab(children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.s),
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
              leading: Icon(AbiliaIcons.plus),
              value: state.displayNewActivity,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(
                      state.copyWith(displayNewActivity: v)),
              child: Text(t.createActivity),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.day),
              value: true,
              child: Text(t.calendarView),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.week),
              value: state.displayWeek,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayWeek: v)),
              child: Text(t.weekCalendar),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.month),
              value: state.displayMonth,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayMonth: v)),
              child: Text(t.monthCalendar),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.appMenu),
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
        onChange(v) => context
            .read<FunctionSettingsCubit>()
            .changeFunctionSettings(state.copyWith(startView: v));
        return _SettingsTab(
          hint: t.homeScreenSettingsHint,
          children: [
            RadioField(
              leading: Icon(AbiliaIcons.day),
              text: Text(t.calendarView),
              value: StartView.dayCalendar,
              groupValue: state.startView,
              onChanged: onChange,
            ),
            if (state.displayWeek)
              RadioField(
                leading: Icon(AbiliaIcons.week),
                text: Text(t.weekCalendar),
                value: StartView.weekCalendar,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            if (state.displayMonth)
              RadioField(
                leading: Icon(AbiliaIcons.month),
                text: Text(t.monthCalendar),
                value: StartView.monthCalendar,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            if (state.displayMenu)
              RadioField(
                leading: Icon(AbiliaIcons.appMenu),
                text: Text(t.menu),
                value: StartView.menu,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            RadioField(
              leading: Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
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
              leading: Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
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
