import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key key}) : super(key: key);
  final widgets = const <Widget>[
    TextToSpeechSwitch(),
    PermissionPickField(),
    AboutPickField(),
    LogoutPickField(),
    if (Config.alpha) FakeTicker(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.menu,
        iconData: AbiliaIcons.app_menu,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12.0, 20.0, 16.0, 20.0),
        itemBuilder: (context, i) => widgets[i],
        itemCount: widgets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CloseButton(),
      ),
    );
  }
}

class LogoutPickField extends StatelessWidget {
  const LogoutPickField({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickField(
      leading: Icon(AbiliaIcons.power_off_on),
      text: Text(Translator.of(context).translate.logout),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: LogoutPage(),
          ),
          settings: RouteSettings(name: 'LogoutPage'),
        ),
      ),
    );
  }
}

class AboutPickField extends StatelessWidget {
  const AboutPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.information),
        text: Text(Translator.of(context).translate.about),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: AboutPage(),
            ),
            settings: RouteSettings(name: 'AboutPage'),
          ),
        ),
      );
}

class TextToSpeechSwitch extends StatelessWidget {
  const TextToSpeechSwitch({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) => Row(children: [
        Expanded(
          child: SwitchField(
            value: settingsState.textToSpeech,
            leading: Icon(AbiliaIcons.speak_text),
            text: Text(Translator.of(context).translate.textToSpeech),
            onChanged: (v) =>
                context.read<SettingsBloc>().add(TextToSpeechUpdated(v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 4.0, 0),
          child: InfoButton(
            onTap: () => showViewDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => LongPressInfoDialog(),
            ),
          ),
        ),
      ]),
    );
  }
}

class LongPressInfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = darkButtonTheme;
    return Theme(
      data: theme,
      child: SmallDialog(
        bodyPadding: EdgeInsets.symmetric(horizontal: 20),
        expanded: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 128,
            ),
            Stack(children: [
              buildPreviewActivityCard(translate),
              Align(
                alignment: Alignment.bottomCenter,
                child: Icon(
                  AbiliaIcons.speak_on_entry,
                  size: hugeIconSize,
                ),
              ),
            ]),
            Spacer(
              flex: 80,
            ),
            Tts(
              child: Text(
                translate.longpressToSpeak,
                textAlign: TextAlign.center,
                style: abiliaTextTheme.headline6,
              ),
            ),
            Tts(
              child: Text(
                translate.longPressInfoText,
                textAlign: TextAlign.center,
                style: abiliaTextTheme.bodyText2.copyWith(
                  color: AbiliaColors.black75,
                ),
              ),
            ),
            Spacer(
              flex: 111,
            ),
          ],
        ),
        backNavigationWidget: CloseButton(
          onPressed: () => Navigator.of(context).maybePop(false),
        ),
      ),
    );
  }

  Widget buildPreviewActivityCard(Translated translate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ActivityCard(
        activityOccasion: ActivityOccasion(
          Activity.createNew(
            title: translate.lunch,
            startTime: DateTime.now().withTime(TimeOfDay(hour: 12, minute: 0)),
          ),
          DateTime.now(),
          Occasion.future,
        ),
        preview: true,
      ),
    );
  }
}

class PermissionPickField extends StatelessWidget {
  const PermissionPickField({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) => Stack(
          children: [
            PickField(
              leading: Icon(AbiliaIcons.menu_setup),
              text: Text(Translator.of(context).translate.permissions),
              onTap: () async {
                context.read<PermissionBloc>().checkAll();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: PermissionsPage(),
                    ),
                    settings: RouteSettings(name: 'PermissionPage'),
                  ),
                );
              },
            ),
            if (state.importantPermissionMissing)
              Positioned(
                top: 8.0,
                right: 8.0,
                child: OrangeDot(),
              ),
          ],
        ),
      );
}

class FakeTicker extends StatefulWidget {
  const FakeTicker({Key key}) : super(key: key);

  @override
  _FakeTickerState createState() => _FakeTickerState();
}

class _FakeTickerState extends State<FakeTicker> {
  double minPerMin;
  bool get useMockTime => minPerMin != null;
  @override
  void initState() {
    minPerMin = context.read<ClockBloc>().minPerMin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        children: [
          SwitchField(
            value: useMockTime,
            text: Text('Fake time'),
            onChanged: (v) {
              setState(() => minPerMin = v ? 1 : null);
              final cb = context.read<ClockBloc>();
              if (!v) {
                cb.resetTicker(GetIt.I<Ticker>());
              }
            },
          ),
          CollapsableWidget(
            collapsed: !useMockTime,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  BlocBuilder<ClockBloc, DateTime>(
                    builder: (context, state) {
                      final time = TimeOfDay.fromDateTime(state);
                      return TimePicker(
                        '${minPerMin?.toInt() ?? 1} min/min',
                        TimeInput(time, null),
                        onTap: () async {
                          final newTime = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (newTime != null) {
                            context.read<ClockBloc>().setFakeTicker(
                                  initTime: state.withTime(newTime),
                                );
                          }
                        },
                      );
                    },
                  ),
                  Slider(
                    value: minPerMin ?? 1,
                    divisions: 599,
                    onChanged: (v) {
                      setState(() => minPerMin = v);
                      context.read<ClockBloc>().setFakeTicker(ticksPerMin: v);
                    },
                    max: 600,
                    min: 1,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
