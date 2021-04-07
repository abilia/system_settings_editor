import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FunctionSettingsPage extends StatelessWidget {
  const FunctionSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final tabs = const [
      ToolbarSettingsTab(),
      HomeScreenSettingsTab(),
      TimeoutSettingsTab(),
    ];
    return DefaultTabController(
      length: tabs.length,
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
        body: TabBarView(children: tabs),
        bottomNavigationBar: const BottomNavigation(
          backNavigationWidget: CancelButton(),
          forwardNavigationWidget: OkButton(),
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
    return _SettingsTab(
      hint: t.toolbarSettingsHint,
      children: [
        SwitchField(
          leading: Icon(AbiliaIcons.plus),
          text: Text(t.createActivity),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.day),
          text: Text(t.calendarView),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.week),
          text: Text(t.weekCalendar),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.month),
          text: Text(t.monthCalendar),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.app_menu),
          text: Text(t.menu),
        ),
      ],
    );
  }
}

class HomeScreenSettingsTab extends StatelessWidget {
  const HomeScreenSettingsTab({Key key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return _SettingsTab(
      hint: t.homeScreenSettingsHint,
      children: [
        RadioField(
          leading: Icon(AbiliaIcons.day),
          text: Text(t.calendarView),
          value: 1,
          groupValue: 2,
          onChanged: (_) {},
        ),
        RadioField(
          leading: Icon(AbiliaIcons.week),
          text: Text(t.weekCalendar),
          value: 1,
          groupValue: 2,
          onChanged: (_) {},
        ),
        RadioField(
          leading: Icon(AbiliaIcons.month),
          text: Text(t.monthCalendar),
          value: 1,
          groupValue: 2,
          onChanged: (_) {},
        ),
        RadioField(
          leading: Icon(AbiliaIcons.app_menu),
          text: Text(t.menu),
          value: 1,
          groupValue: 2,
          onChanged: (_) {},
        ),
        RadioField(
          leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
          text: Text(t.photoCalendar.singleLine),
          value: 1,
          groupValue: 2,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class TimeoutSettingsTab extends StatelessWidget {
  const TimeoutSettingsTab({Key key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return _SettingsTab(
      hint: t.timeoutSettingsHint,
      children: [
        ...[-1, 10, 5, 1]
            .map((d) => Duration(minutes: d))
            .map((d) => d.isNegative
                ? t.noTimeout
                : d.toDurationString(t, shortMin: false))
            .map(
              (text) => RadioField(
                text: Text(text),
                value: 1,
                groupValue: 2,
                onChanged: (_) {},
              ),
            ),
        Divider(),
        SwitchField(
          leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
          text: Text(t.activateScreensaver),
        ),
      ],
    );
  }
}
