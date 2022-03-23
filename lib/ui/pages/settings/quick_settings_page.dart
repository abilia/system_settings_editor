import 'package:battery_plus/battery_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/strings.dart';

class QuickSettingsPage extends StatelessWidget {
  const QuickSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: t.quickSettingsMenu.singleLine,
        iconData: AbiliaIcons.settings,
      ),
      body: ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(12.s, 20.s, 16.s, 20.s),
              child: BatteryLevel(battery: GetIt.I<Battery>()),
            ),
            QuickSettingsGroup(children: [
              const WiFiPickField(),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              const SoundEffectsSwitch(),
            ]),
            QuickSettingsGroup(children: [
              SubHeading(t.volumeAlarm),
              const AlarmVolumeSlider(),
              SizedBox(height: 20.s),
              SubHeading(t.volumeMedia),
              const MediaVolumeSlider(),
            ]),
            const QuickSettingsGroup(children: [
              BrightnessSlider(),
            ]),
            QuickSettingsGroup(children: [
              SubHeading(t.screenTimeout),
              const ScreenTimeoutPickField(),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              const KeepOnWhileChargingSwitch(),
            ]),
          ],
        ),
      ),
      bottomNavigationBar:
          const BottomNavigation(backNavigationWidget: PreviousButton()),
    );
  }
}

class QuickSettingsGroup extends StatelessWidget {
  const QuickSettingsGroup({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: EdgeInsets.fromLTRB(12.s, 24.s, 16.s, 20.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...children,
            ],
          ),
        )
      ],
    );
  }
}
