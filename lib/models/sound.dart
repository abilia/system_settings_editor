import 'package:seagull/i18n/all.dart';

enum Sound {
  Default,
  Trip,
  Drum,
}

extension SoundExtension on Sound {
  String displayName(Translated t) {
    switch (this) {
      case Sound.Trip:
        return 'Trip';
      case Sound.Drum:
        return 'Drum';
      case Sound.Default:
        return 'Default';
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
