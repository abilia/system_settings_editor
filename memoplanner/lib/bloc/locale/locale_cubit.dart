import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/i18n/translations.g.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsDb settingsDb;
  LocaleCubit(
    this.settingsDb,
  ) : super(Locale(settingsDb.language));

  void _changeLocale(Locale locale) {
    emit(locale);
    settingsDb.setLanguage(locale.languageCode);
  }

  static LocalizationsDelegate<LocaleCubit> delegate(LocaleCubit cubit) =>
      _LocaleCubitsDelegate(cubit);
}

class _LocaleCubitsDelegate extends LocalizationsDelegate<LocaleCubit> {
  const _LocaleCubitsDelegate(this.cubit);
  final LocaleCubit cubit;

  @override
  bool isSupported(Locale locale) => Locales.language.containsKey(locale);

  @override
  Future<LocaleCubit> load(Locale locale) async => cubit.._changeLocale(locale);

  @override
  bool shouldReload(_LocaleCubitsDelegate old) => false;
}