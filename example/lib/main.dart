import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:system_settings_editor/system_settings_editor.dart';
import 'package:system_settings_editor/volume_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double? _brightness;
  double? _sliderBrightness;
  bool? _soundEffectsEnabled;
  double? _alarmVolume;
  double? _mediaVolume;

  @override
  void initState() {
    super.initState();
    getBrightness();
    getSoundEffectsEnabled();
    getAlarmVolume();
    getMediaVolume();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getBrightness() async {
    double? brightness;

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      brightness = await SystemSettingsEditor.brightness;
    } on PlatformException {
      brightness = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _brightness = _sliderBrightness = brightness;
    });
  }

  Future<void> getSoundEffectsEnabled() async {
    bool? enabled;

    try {
      enabled = await SystemSettingsEditor.soundEffectsEnabled;
    } on PlatformException {
      enabled = false;
    }
    if (!mounted) return;
    setState(() {
      _soundEffectsEnabled = enabled;
    });
  }

  Future<void> getAlarmVolume() async {
    double? volume;

    try {
      volume = await VolumeSettings.alarmVolume;
    } on PlatformException {
      volume = null;
    }

    if (!mounted) return;

    setState(() {
      _alarmVolume = volume;
    });
  }

  Future<void> getMediaVolume() async {
    double? volume;

    try {
      volume = await VolumeSettings.mediaVolume;
    } on PlatformException {
      volume = null;
    }

    if (!mounted) return;

    setState(() {
      _mediaVolume = volume;
    });
  }

  void toggleSoundEffects() {
    SystemSettingsEditor.setSoundEffectsEnabled(
        _soundEffectsEnabled != null && _soundEffectsEnabled == false);
    getSoundEffectsEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _brightness;
    final alarmVolume = _alarmVolume;
    final mediaVolume = _mediaVolume;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('System settings example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Click sounds'),
            ElevatedButton(
              onPressed: toggleSoundEffects,
              child: const Text('Toggle Click Sounds'),
            ),
            Text('Sound is $_soundEffectsEnabled'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Tap me!'),
            ),
            const SizedBox(height: 20),
            const Text('Volume for alarm'),
            Slider(
              divisions: 8,
              onChanged: alarmVolume != null
                  ? (b) {
                      VolumeSettings.setAlarmVolume(b);
                      setState(() => _alarmVolume = b);
                    }
                  : null,
              value: _alarmVolume ?? 0,
            ),
            const SizedBox(height: 20),
            const Text('Volume for media'),
            Slider(
              onChanged: mediaVolume != null
                  ? (b) {
                      VolumeSettings.setMediaVolume(b);
                      setState(() => _mediaVolume = b);
                    }
                  : null,
              value: _mediaVolume ?? 0,
            ),
            const SizedBox(height: 20),
            const Text('Brightness'),
            Center(
              child: brightness != null
                  ? Text('${brightness * 100}% brightness')
                  : const Text('brightness unknown'),
            ),
            ElevatedButton(
              onPressed: getBrightness,
              child: const Text('Get brightness'),
            ),
            Slider(
              onChanged: brightness != null
                  ? (b) {
                      SystemSettingsEditor.setBrightness(b);
                      setState(() => _sliderBrightness = b);
                    }
                  : null,
              value: _sliderBrightness ?? 0,
            )
          ],
        ),
      ),
    );
  }
}
