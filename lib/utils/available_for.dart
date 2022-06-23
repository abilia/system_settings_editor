import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

extension AvailableForHelper on AvailableForType {
  IconData get icon {
    switch (this) {
      case AvailableForType.onlyMe:
        return AbiliaIcons.lock;
      case AvailableForType.allSupportPersons:
        return AbiliaIcons.unlock;
      case AvailableForType.selectedSupportPersons:
        return AbiliaIcons.selectedSupport;
    }
  }

  String text(Translated translator) {
    switch (this) {
      case AvailableForType.onlyMe:
        return translator.onlyMe;
      case AvailableForType.allSupportPersons:
        return translator.allSupportPersons;
      case AvailableForType.selectedSupportPersons:
        return translator.selectedSupportPersons;
    }
  }
}