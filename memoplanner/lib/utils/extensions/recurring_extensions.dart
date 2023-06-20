import 'package:flutter/widgets.dart';
import 'package:memoplanner/i18n/all.dart';
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

  String text(Translated translator) {
    switch (this) {
      case RecurrentType.none:
        return translator.noRecurrence;
      case RecurrentType.daily:
        return translator.daily;
      case RecurrentType.weekly:
        return translator.weekly;
      case RecurrentType.monthly:
        return translator.monthly;
      case RecurrentType.yearly:
        return translator.yearly;
    }
  }
}
