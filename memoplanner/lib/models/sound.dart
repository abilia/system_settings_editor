// ignore_for_file: constant_identifier_names

import 'package:memoplanner/l10n/generated/l10n.dart';

enum Sound {
  NoSound,
  Default,
  AfloatSynth,
  AlarmClock,
  BreathlessPiano,
  DoorBell,
  GibsonGuitar,
  Harpe,
  Hello,
  LatinAcousticGuitar,
  Notification,
  OrientalStrings,
  Trumpet,
}

extension SoundExtension on Sound {
  static const defaultName = 'Default';
  String displayName(Lt translate) {
    switch (this) {
      case Sound.Default:
        return defaultName;
      case Sound.NoSound:
        return translate.noSound;
      case Sound.AfloatSynth:
        return 'Afloat Synth';
      case Sound.AlarmClock:
        return 'Alarm Clock';
      case Sound.BreathlessPiano:
        return 'Breathless Piano';
      case Sound.DoorBell:
        return 'Door Bell';
      case Sound.GibsonGuitar:
        return 'Gibson Guitar';
      case Sound.Harpe:
        return 'Harpe';
      case Sound.Hello:
        return 'Hello';
      case Sound.LatinAcousticGuitar:
        return 'Latin Acoustic Guitar';
      case Sound.Notification:
        return 'Notification';
      case Sound.OrientalStrings:
        return 'Oriental Strings';
      case Sound.Trumpet:
        return 'Trumpet';
      default:
        throw Exception();
    }
  }

  String fileName() {
    switch (this) {
      case Sound.Default:
        return '';
      case Sound.NoSound:
        return 'silent';
      case Sound.AfloatSynth:
        return 'afloat_synth';
      case Sound.AlarmClock:
        return 'alarm_clock';
      case Sound.BreathlessPiano:
        return 'breathless_piano';
      case Sound.DoorBell:
        return 'door_bell';
      case Sound.GibsonGuitar:
        return 'gibson_guitar';
      case Sound.Harpe:
        return 'harpe';
      case Sound.Hello:
        return 'hello';
      case Sound.LatinAcousticGuitar:
        return 'latin_acoustic_guitar';
      case Sound.Notification:
        return 'notification';
      case Sound.OrientalStrings:
        return 'oriental_strings';
      case Sound.Trumpet:
        return 'trumpet';
      default:
        throw Exception();
    }
  }
}

extension SoundStringExtension on String? {
  Sound toSound() {
    return this == null
        ? Sound.Default
        : Sound.values.firstWhere((e) => e.toString() == 'Sound.$this',
            orElse: () => Sound.Default);
  }
}
