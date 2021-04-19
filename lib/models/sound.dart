import 'package:seagull/i18n/all.dart';

enum Sound {
  NoSound,
  Default,
  Trip,
  Drum,
  Springboard,
}

extension SoundExtension on Sound {
  String displayName(Translated t) {
    switch (this) {
      case Sound.Trip:
        return 'Trip';
      case Sound.Drum:
        return 'Drum';
      case Sound.Springboard:
        return 'Springboard';
      case Sound.Default:
        return 'Default';
      case Sound.NoSound:
        return '- No sound -';
      default:
        throw Exception();
    }
  }

  String name() {
    return toString().split('.').last;
  }

  String fileName() {
    switch (this) {
      case Sound.Trip:
        return 'trip';
      case Sound.Drum:
        return 'drum';
      case Sound.Springboard:
        return 'springboard';
      case Sound.Default:
        return '';
      case Sound.NoSound:
        return 'silent';
      default:
        throw Exception();
    }
  }
}

extension SoundStringExtension on String {
  Sound toSound() {
    return Sound.values.firstWhere((e) => e.toString() == 'Sound.' + this,
        orElse: () => Sound.Default);
  }
}
