import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

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

  String text(Lt translator) {
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
