import 'package:flutter/widgets.dart';
import 'package:memoplanner/l10n/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/components/all.dart';

extension RecursExtensions on RecurrentType {
  IconData iconData() {
    switch (this) {
      case RecurrentType.weekly:
        return AbiliaIcons.week;
      case RecurrentType.monthly:
        return AbiliaIcons.month;
      case RecurrentType.yearly:
        return AbiliaIcons.basicActivity;
      default:
        return AbiliaIcons.day;
    }
  }

  String text(Lt translator) {
    switch (this) {
      case RecurrentType.weekly:
        return translator.weekly;
      case RecurrentType.monthly:
        return translator.monthly;
      case RecurrentType.yearly:
        return translator.yearly;
      default:
        return translator.once;
    }
  }
}
