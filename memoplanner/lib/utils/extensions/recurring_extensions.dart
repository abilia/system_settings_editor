import 'package:flutter/widgets.dart';
import 'package:memoplanner/l10n/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/components/all.dart';

extension RecursExtensions on RecurrentType {
  IconData iconData() {
    switch (this) {
      case RecurrentType.none:
        return AbiliaIcons.cancel;
      case RecurrentType.daily:
        return AbiliaIcons.day;
      case RecurrentType.weekly:
        return AbiliaIcons.week;
      case RecurrentType.monthly:
        return AbiliaIcons.month;
      case RecurrentType.yearly:
        return AbiliaIcons.basicActivity;
    }
  }

  String text(Lt translate) {
    switch (this) {
      case RecurrentType.none:
        return translate.noRecurrence;
      case RecurrentType.daily:
        return translate.daily;
      case RecurrentType.weekly:
        return translate.weekly;
      case RecurrentType.monthly:
        return translate.monthly;
      case RecurrentType.yearly:
        return translate.yearly;
    }
  }
}
