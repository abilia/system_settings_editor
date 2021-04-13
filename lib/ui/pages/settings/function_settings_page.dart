import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FunctionSettingsPage extends StatelessWidget {
  const FunctionSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<FunctionSettingsCubit>(
      create: (context) => FunctionSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.functions,
            iconData: AbiliaIcons.menu_setup,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                Icon(AbiliaIcons.shortcut_menu),
                Icon(AbiliaIcons.browser_home),
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
                onPressed: () {
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
    Key key,
    @required this.hint,
    this.children = const [],
  }) : super(key: key);
  final List<Widget> children;
  final String hint;
  @override
  Widget build(BuildContext context) {
    final widgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 8.s),
        child: Tts(child: Text(hint)),
      ),
      ...children,
    ]
        .map(
          (w) => w is Divider
              ? Padding(
                  padding: EdgeInsets.only(top: 16.s, bottom: 16.s),
                  child: w,
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(12.s, 8.s, 16.s, 0),
                  child: w,
                ),
        )
        .toList();
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 20.s),
      children: widgets,
    );
  }
}

class ToolbarSettingsTab extends StatelessWidget {
  const ToolbarSettingsTab({Key key}) : super(key: key);
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
              text: Text(t.createActivity),
              value: state.displayNewActivity,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(
                      state.copyWith(displayNewActivity: v)),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.day),
              text: Text(t.calendarView),
              value: true,
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.week),
              text: Text(t.weekCalendar),
              value: state.displayWeek,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayWeek: v)),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.month),
              text: Text(t.monthCalendar),
              value: state.displayMonth,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayMonth: v)),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.app_menu),
              text: Text(t.menu),
              value: state.displayMenu,
              onChanged: (v) => context
                  .read<FunctionSettingsCubit>()
                  .changeFunctionSettings(state.copyWith(displayMenu: v)),
            ),
          ],
        );
      },
    );
  }
}

class HomeScreenSettingsTab extends StatelessWidget {
  const HomeScreenSettingsTab({Key key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<FunctionSettingsCubit, FunctionSettingsState>(
      builder: (context, state) {
        final onChange = (v) => context
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
                leading: Icon(AbiliaIcons.app_menu),
                text: Text(t.menu),
                value: StartView.menu,
                groupValue: state.startView,
                onChanged: onChange,
              ),
            RadioField(
              leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
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
  const TimeoutSettingsTab({Key key}) : super(key: key);
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
                  (d) => RadioField(
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
              leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
              text: Text(t.activateScreensaver),
              value: state.shouldUseScreenSaver,
              onChanged: state.hasTimeOut
                  ? (v) => context
                      .read<FunctionSettingsCubit>()
                      .changeFunctionSettings(state.copyWith(useScreensaver: v))
                  : null,
            ),
          ],
        );
      },
    );
  }
}