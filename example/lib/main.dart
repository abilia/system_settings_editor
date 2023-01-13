import 'dart:math';

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
  bool _canWrite = false;
  double? _alarmVolume;
  double? _mediaVolume;
  Duration? _timeout;
  double? _sliderTimeout;
  bool? _hasBattery;

  static const _maxTimeOutSec = 600;

  @override
  void initState() {
    super.initState();
    getCanWriteSettings();
    getBrightness();
    getSoundEffectsEnabled();
    getAlarmVolume();
    getMediaVolume();
    getScreenOffTimeout();
    getHasBattery();
  }

  Future<void> getCanWriteSettings() async {
    bool canWrite = await SystemSettingsEditor.canWriteSettings;
    if (!mounted) return;
    setState(() {
      _canWrite = canWrite;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getBrightness() async {
    double? brightness;
    try {
      brightness = await SystemSettingsEditor.brightness;
    } on PlatformException {
      brightness = null;
    }
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

  Future<void> getScreenOffTimeout() async {
    Duration? timeout;
    try {
      timeout = await SystemSettingsEditor.screenOffTimeout;
    } on PlatformException {
      timeout = null;
    }
    if (!mounted) return;

    setState(() {
      _timeout = timeout;
      final timeoutSec = timeout?.inSeconds.toDouble();
      if (timeoutSec != null) {
        _sliderTimeout = min(timeoutSec, _maxTimeOutSec.toDouble());
      }
    });
  }

  Future<void> getHasBattery() async {
    bool? hasBattery;
    try {
      hasBattery = await SystemSettingsEditor.hasBattery;
    } on PlatformException {
      hasBattery = null;
    }

    if (!mounted) return;

    setState(() {
      _hasBattery = hasBattery;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _brightness;
    final alarmVolume = _alarmVolume;
    final mediaVolume = _mediaVolume;
    final timeout = _timeout;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('System settings example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _hasBattery == false
                    ? 'No battery detected'
                    : 'Battery detected',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: getCanWriteSettings,
              child: Text(
                  'Check write settings access (${_canWrite ? 'granted' : 'not granted'})'),
            ),
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
            ),
            const SizedBox(height: 20),
            const Text('Screen off timeout'),
            Center(
              child: timeout != null
                  ? Text('${timeout.inSeconds}')
                  : const Text('timeout unknown'),
            ),
            ElevatedButton(
              onPressed: getScreenOffTimeout,
              child: const Text('Get timeout'),
            ),
            Slider(
              max: _maxTimeOutSec.toDouble(),
              divisions: _maxTimeOutSec,
              onChanged: timeout != null
                  ? (b) {
                      SystemSettingsEditor.setScreenOffTimeout(
                          Duration(seconds: b.toInt()));
                      setState(() => _sliderTimeout = b);
                    }
                  : null,
              value: _sliderTimeout ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}
