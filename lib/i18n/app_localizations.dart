import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seagull/i18n/translations.dart';

class Translator {
  static List<Locale> get supportedLocals => dictionaries.keys.toList();
  final Locale locale;

  Translator(this.locale);

  static Translator of(BuildContext context) =>
      Localizations.of<Translator>(context, Translator);

  Translated get translate => dictionaries[locale]; 

  static const LocalizationsDelegate<Translator> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<Translator> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      dictionaries.keys.map((l) => l.languageCode).contains(locale.languageCode);

  @override
  Future<Translator> load(Locale locale) async => Translator(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
