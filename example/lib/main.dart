import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

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

  @override
  void initState() {
    super.initState();
    getBrightness();
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

  @override
  Widget build(BuildContext context) {
    final brightness = _brightness;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('System settings example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: brightness != null
                  ? Text('${brightness * 100}% brightness')
                  : const Text('brightness unknown'),
            ),
            ElevatedButton(
              onPressed: getBrightness,
              child: const Text('Get brigthness'),
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
