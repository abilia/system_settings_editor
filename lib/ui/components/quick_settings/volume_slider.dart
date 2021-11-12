import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:system_settings_editor/volume_settings.dart';

class AlarmVolumeSlider extends _VolumeSlider {
  const AlarmVolumeSlider({Key? key}) : super(key: key);

  @override
  State<_VolumeSlider> createState() => _AlarmVolumeSliderState();
}

class MediaVolumeSlider extends _VolumeSlider {
  const MediaVolumeSlider({Key? key}) : super(key: key);

  @override
  State<_VolumeSlider> createState() => _MediaVolumeSliderState();
}

abstract class _VolumeSlider extends StatefulWidget {
  const _VolumeSlider({Key? key}) : super(key: key);
}

class _AlarmVolumeSliderState extends _VolumeSliderState {
  _AlarmVolumeSliderState()
      : super(
          leading: Stack(clipBehavior: Clip.none, children: const [
            Icon(AbiliaIcons.volumeNormal),
            Positioned(
              top: 14.0,
              left: 25.0,
              child: Icon(AbiliaIcons.handiAlarmVibration, size: 20),
            )
          ]),
        );

  @override
  Future<double?> getVolume() {
    return VolumeSettings.alarmVolume;
  }

  @override
  Future<void> setVolume(double volume) {
    return VolumeSettings.setAlarmVolume(volume);
  }
}

class _MediaVolumeSliderState extends _VolumeSliderState {
  _MediaVolumeSliderState()
      : super(leading: const Icon(AbiliaIcons.volumeNormal));

  @override
  Future<double?> getVolume() {
    return VolumeSettings.mediaVolume;
  }

  @override
  Future<void> setVolume(double volume) {
    return VolumeSettings.setMediaVolume(volume);
  }
}

abstract class _VolumeSliderState extends State<_VolumeSlider>
    with WidgetsBindingObserver {
  final _log = Logger((_VolumeSliderState).toString());
  final Widget leading;
  double _volume = 1.0;

  _VolumeSliderState({required this.leading});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initVolume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initVolume();
    }
  }

  void _initVolume() async {
    try {
      final b = await getVolume();
      setState(() {
        _volume = b ?? 0;
      });
    } on PlatformException catch (e) {
      _log.warning('Could not get volume', e);
    }
  }

  Future<double?> getVolume();

  Future<void> setVolume(double volume);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AbiliaSlider(
            leading: leading,
            value: _volume,
            onChanged: (double b) {
              setState(() {
                _volume = b;
                setVolume(_volume);
              });
            }),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
