import 'package:battery_plus/battery_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class QuickSettingsPage extends StatelessWidget {
  const QuickSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final translate = Lt.of(context);
    final hasBattery = GetIt.I<Device>().hasBattery;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.quickSettingsMenu.singleLine,
        iconData: AbiliaIcons.settings,
      ),
      body: ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            if (hasBattery)
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
              create: (_) => AlarmSoundBloc(
                spamProtectionDelay: GetIt.I<Delays>().spamProtectionDelay,
              ),
              child: BlocBuilder<AlarmSoundBloc, Sound?>(
                builder: (context, state) => QuickSettingsGroup(children: [
                  SubHeading(translate.volumeAlarm),
                  AlarmVolumeSlider(
                    onVolumeSet: () async => context
                        .read<AlarmSoundBloc>()
                        .add(const PlayAlarmSound(Sound.Default)),
                  ),
                  SizedBox(height: layout.formPadding.groupBottomDistance),
                  SubHeading(translate.volumeMedia),
                  MediaVolumeSlider(
                    onVolumeSet: () async => context
                        .read<AlarmSoundBloc>()
                        .add(const PlayAlarmSoundAsMedia(Sound.Harpe)),
                  ),
                ]),
              ),
            ),
            const QuickSettingsGroup(children: [
              BrightnessSlider(),
            ]),
            if (hasBattery)
              QuickSettingsGroup(
                children: [
                  SubHeading(translate.screenTimeout),
                  const ScreenTimeoutPickField(),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  const KeepOnWhileChargingSwitch(),
                ],
              ),
            SizedBox(
                height: layout.templates.m1.bottom -
                    layout.formPadding.groupBottomDistance)
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
