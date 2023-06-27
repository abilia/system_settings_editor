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

  String text(Lt translate) {
    switch (this) {
      case AvailableForType.onlyMe:
        return translate.onlyMe;
      case AvailableForType.allSupportPersons:
        return translate.allSupportPersons;
      case AvailableForType.selectedSupportPersons:
        return translate.selectedSupportPersons;
    }
  }
}
