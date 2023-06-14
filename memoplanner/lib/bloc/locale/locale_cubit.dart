import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/l10n/all.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsDb settingsDb;
  LocaleCubit(
    this.settingsDb,
  ) : super(Locale(settingsDb.language));

  Future<void> _changeLocale(Locale locale) async {
    emit(locale);
    await settingsDb.setLanguage(locale.languageCode);
  }

  static LocalizationsDelegate<LocaleCubit> delegate(LocaleCubit cubit) =>
      _LocaleCubitsDelegate(cubit);
}

class _LocaleCubitsDelegate extends LocalizationsDelegate<LocaleCubit> {
  const _LocaleCubitsDelegate(this.cubit);
  final LocaleCubit cubit;

  @override
  bool isSupported(Locale locale) => Lt.supportedLocales.contains(locale);

  @override
  Future<LocaleCubit> load(Locale locale) async {
    await cubit._changeLocale(locale);
    return cubit;
  }

  @override
  bool shouldReload(_LocaleCubitsDelegate old) => false;
}
