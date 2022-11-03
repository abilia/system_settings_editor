import 'package:battery_plus/battery_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/sound.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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
            if (!layout.large)
              Padding(
                padding: layout.templates.m1
                    .copyWith(bottom: layout.formPadding.groupBottomDistance),
                child: BatteryLevel(battery: GetIt.I<Battery>()),
              ),
            QuickSettingsGroup(children: [
              const WiFiPickField(),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              const SoundEffectsSwitch(),
            ]),
            BlocProvider<AlarmSoundBloc>(
              create: (_) => AlarmSoundBloc(),
              child: BlocBuilder<AlarmSoundBloc, Sound?>(
                builder: (context, state) => QuickSettingsGroup(children: [
                  SubHeading(t.volumeAlarm),
                  AlarmVolumeSlider(
                    onVolumeSet: () async {
                      final alarmBloc = context.read<AlarmSoundBloc>();
                      alarmBloc.add(const PlaySoundAlarm(Sound.Default));
                    },
                  ),
                  SizedBox(height: layout.formPadding.groupBottomDistance),
                  SubHeading(t.volumeMedia),
                  MediaVolumeSlider(
                    onVolumeSet: () async {
                      final alarmBloc = context.read<AlarmSoundBloc>();
                      alarmBloc.add(const RestartSoundAlarm(Sound.Harpe));
                    },
                  ),
                ]),
              ),
            ),
            const QuickSettingsGroup(children: [
              BrightnessSlider(),
            ]),
            if (!layout.large)
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
          const BottomNavigation(backNavigationWidget: CloseButton()),
    );
  }
}

class QuickSettingsGroup extends StatelessWidget {
  const QuickSettingsGroup({
    required this.children,
    Key? key,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: layout.templates.m1.copyWith(
            bottom: layout.formPadding.groupBottomDistance,
          ),
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
