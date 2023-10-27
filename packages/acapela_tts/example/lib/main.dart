import 'dart:async';
import 'dart:math';

import 'package:acapela_tts/acapela_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double? _speechRate = 100;
  List<String>? _voices;
  String? _selectedVoice;
  final AcapelaTts _acapelaTts = AcapelaTts();

  @override
  void initState() {
    super.initState();

    initialize();
    getSpeechRate();
    getVoices();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Acapela TTS example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              value: _selectedVoice,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _voices?.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _acapelaTts.setVoice({'voice': newValue});
                }
                setState(() {
                  _selectedVoice = newValue;
                });
              },
            ),
            const Text('Click for tts'),
            ElevatedButton(
              onPressed: () => _acapelaTts.speak('Text till tal exempel'),
              child: const Text('Test TTS'),
            ),
            const SizedBox(height: 20),
            Text('Speechrate $_speechRate'),
            Slider(
              min: 0,
              max: 1000,
              onChanged: _speechRate != null
                  ? (b) {
                      _acapelaTts.setSpeechRate(b);
                      setState(() => _speechRate = b);
                    }
                  : null,
              value: _speechRate ?? 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _acapelaTts.stop(),
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: () => _acapelaTts.pause(),
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: () => _acapelaTts.resume(),
                  child: const Text('Resume'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initialize() async {
    // TODO: insert license here
    await _acapelaTts.initialize(
      userId: 0,
      password: 0,
      license: '',
      voicesPath: (await getApplicationSupportDirectory()).path,
    );
  }

  Future<void> getSpeechRate() async {
    double? speechRate;

    try {
      speechRate = await _acapelaTts.speechRate;
    } on PlatformException {
      speechRate = null;
    }
    if (speechRate != null) {
      speechRate = max(0, speechRate);
      speechRate = min(100, speechRate);
    }

    if (!mounted) return;

    setState(() {
      _speechRate = speechRate;
    });
  }

  Future<void> getVoices() async {
    List<Object?>? voices;
    try {
      voices = await _acapelaTts.availableVoices;
      if (voices.isNotEmpty) {
        _acapelaTts.setVoice({'voice': voices.first.toString()});
      }
    } on PlatformException {
      voices = null;
    }

    if (!mounted) return;

    setState(() {
      _voices?.clear();
      if (voices != null) {
        _voices = (voices.map((e) => e.toString())).toList();
      }
    });
  }
}
