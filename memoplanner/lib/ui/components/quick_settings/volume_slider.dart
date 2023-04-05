import 'dart:async';

import 'package:flutter/services.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:system_settings_editor/volume_settings.dart';

class AlarmVolumeSlider extends _VolumeSlider {
  const AlarmVolumeSlider({Key? key, VoidCallback? onVolumeSet})
      : super(key: key, onVolumeSet: onVolumeSet);

  @override
  State createState() => _AlarmVolumeSliderState();
}

class MediaVolumeSlider extends _VolumeSlider {
  const MediaVolumeSlider({Key? key, VoidCallback? onVolumeSet})
      : super(key: key, onVolumeSet: onVolumeSet);

  @override
  State createState() => _MediaVolumeSliderState();
}

abstract class _VolumeSlider extends StatefulWidget {
  final VoidCallback? onVolumeSet;

  const _VolumeSlider({Key? key, this.onVolumeSet}) : super(key: key);
}

class _AlarmVolumeSliderState extends _VolumeSliderState {
  _AlarmVolumeSliderState()
      : super(
          key: TestKey.alarmVolumeSlider,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(AbiliaIcons.volumeNormal),
              Positioned(
                top: layout.icon.doubleIconTop,
                left: layout.icon.doubleIconLeft,
                child: Icon(
                  AbiliaIcons.handiAlarmVibration,
                  size: layout.icon.tiny,
                ),
              )
            ],
          ),
        );

  @override
  Future<double?> getVolume() {
    return VolumeSettings.alarmVolume;
  }

  @override
  Future<double> getMinVolume() async {
    final maxVolumeIndex = await VolumeSettings.alarmMaxVolume;
    if (maxVolumeIndex != null) {
      final minVolume = 1 / maxVolumeIndex;
      return minVolume;
    }
    return 0;
  }

  @override
  Future<void> setVolume(double volume) {
    return VolumeSettings.setAlarmVolume(volume);
  }
}

class _MediaVolumeSliderState extends _VolumeSliderState {
  _MediaVolumeSliderState() : super(key: TestKey.mediaVolumeSlider);

  @override
  Future<double?> getVolume() {
    return VolumeSettings.mediaVolume;
  }

  @override
  Future<double> getMinVolume() {
    return Future.value(0);
  }

  @override
  Future<void> setVolume(double volume) {
    return VolumeSettings.setMediaVolume(volume);
  }
}

abstract class _VolumeSliderState extends State<_VolumeSlider>
    with WidgetsBindingObserver {
  final _log = Logger((_VolumeSliderState).toString());
  final Key key;
  final Widget? leading;
  double _volume = 1.0, _minVolume = 0;

  _VolumeSliderState({required this.key, this.leading});

  Widget get volumeIcon {
    if (_volume <= _minVolume) {
      return const Icon(AbiliaIcons.noVolume);
    }
    return const Icon(AbiliaIcons.volumeNormal);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initVolume();
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _initVolume();
    }
  }

  Future<void> _initVolume() async {
    try {
      final volume = await getVolume();
      final minVolume = await getMinVolume();
      setState(() {
        _volume = volume ?? 0;
        _minVolume = minVolume;
      });
    } on PlatformException catch (e) {
      _log.warning('Could not get volume', e);
    }
  }

  Future<double?> getVolume();

  Future<double> getMinVolume();

  Future<void> setVolume(double volume);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AbiliaSlider(
          key: key,
          leading: leading ?? volumeIcon,
          value: _volume,
          min: _minVolume,
          onChanged: (double b) async {
            await setVolume(b);
            setState(() {
              _volume = b;
            });
          },
          onChangeEnd: (double b) async {
            await setVolume(b);
            widget.onVolumeSet?.call();
            setState(() {
              _volume = b;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
