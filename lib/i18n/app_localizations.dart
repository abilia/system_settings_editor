import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:seagull/i18n/all.dart';

class Translator {
  static List<Locale> get supportedLocals => Locales.language.keys.toList();
  final Locale locale;

  Translator(this.locale);

  static Translator of(BuildContext context) =>
      Localizations.of<Translator>(context, Translator);

  Translated get translate => Locales.language[locale];

  static const LocalizationsDelegate<Translator> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<Translator> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => Locales.language.containsKey(locale);

  @override
  Future<Translator> load(Locale locale) async => Translator(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
