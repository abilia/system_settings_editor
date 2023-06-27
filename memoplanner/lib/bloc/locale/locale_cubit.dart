import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/db/all.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsDb settingsDb;
  final SeagullAnalytics seagullAnalytics;

  LocaleCubit({
    required this.settingsDb,
    required this.seagullAnalytics,
  }) : super(Locale(settingsDb.language));

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    seagullAnalytics.setLocale(locale);
    await settingsDb.setLanguage(locale.languageCode);
  }
}
