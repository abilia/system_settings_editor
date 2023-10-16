// GENERATED CODE
//
// After the template files .arb have been changed,
// generate this class by the command in the terminal:
// flutter pub run lokalise_flutter_sdk:gen-lok-l10n
//
// Please see https://pub.dev/packages/lokalise_flutter_sdk

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'intl/messages_all.dart';

class Lt {
  Lt._internal();

  static const LocalizationsDelegate<Lt> delegate = _AppLocalizationDelegate();

  static const List<Locale> supportedLocales = [
    Locale.fromSubtags(languageCode: 'en'),
    Locale.fromSubtags(languageCode: 'sv')
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static final Map<String, List<String>> _metadata = {
    'about': [],
    'afternoon': [],
    'app_version': [],
    'back': [],
    'check_for_updates': [],
    'close': [],
    'connect_to_myabilia': [],
    'early_morning': [],
    'evening': [],
    'hide': [],
    'internet': [],
    'last_sync': [],
    'license_expired': [],
    'log_in': [],
    'log_out': [],
    'login_hint': [],
    'mid_morning': [],
    'night': [],
    'no_license': [],
    'ok': [],
    'password': [],
    'play': [],
    'producer': [],
    'settings': [],
    'show': [],
    'stop': [],
    'today': [],
    'username_email': [],
    'wrong_username_or_password': []
  };

  static Future<Lt> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    Lokalise.instance.metadata = _metadata;

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = Lt._internal();
      return instance;
    });
  }

  static Lt of(BuildContext context) {
    final instance = Localizations.of<Lt>(context, Lt);
    assert(instance != null,
        'No instance of Lt present in the widget tree. Did you add Lt.delegate in localizationsDelegates?');
    return instance!;
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get afternoon {
    return Intl.message(
      'Afternoon',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `App version`
  String get app_version {
    return Intl.message(
      'App version',
      name: 'app_version',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get check_for_updates {
    return Intl.message(
      'Check for updates',
      name: 'check_for_updates',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Connect to myAbilia`
  String get connect_to_myabilia {
    return Intl.message(
      'Connect to myAbilia',
      name: 'connect_to_myabilia',
      desc: '',
      args: [],
    );
  }

  /// `Early morning`
  String get early_morning {
    return Intl.message(
      'Early morning',
      name: 'early_morning',
      desc: '',
      args: [],
    );
  }

  /// `Evening`
  String get evening {
    return Intl.message(
      'Evening',
      name: 'evening',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get hide {
    return Intl.message(
      'Hide',
      name: 'hide',
      desc: '',
      args: [],
    );
  }

  /// `Internet`
  String get internet {
    return Intl.message(
      'Internet',
      name: 'internet',
      desc: '',
      args: [],
    );
  }

  /// `Last sync:`
  String get last_sync {
    return Intl.message(
      'Last sync:',
      name: 'last_sync',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get license_expired {
    return Intl.message(
      '',
      name: 'license_expired',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get log_in {
    return Intl.message(
      'Log in',
      name: 'log_in',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get log_out {
    return Intl.message(
      'Log out',
      name: 'log_out',
      desc: '',
      args: [],
    );
  }

  /// `Make sure that CARY Base is connected to myAbilia. Log in here with the same account.`
  String get login_hint {
    return Intl.message(
      'Make sure that CARY Base is connected to myAbilia. Log in here with the same account.',
      name: 'login_hint',
      desc: '',
      args: [],
    );
  }

  /// `Mid-morning`
  String get mid_morning {
    return Intl.message(
      'Mid-morning',
      name: 'mid_morning',
      desc: '',
      args: [],
    );
  }

  /// `Night`
  String get night {
    return Intl.message(
      'Night',
      name: 'night',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get no_license {
    return Intl.message(
      '',
      name: 'no_license',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message(
      'Play',
      name: 'play',
      desc: '',
      args: [],
    );
  }

  /// `Producer`
  String get producer {
    return Intl.message(
      'Producer',
      name: 'producer',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message(
      'Show',
      name: 'show',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get stop {
    return Intl.message(
      'Stop',
      name: 'stop',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Username / Email`
  String get username_email {
    return Intl.message(
      'Username / Email',
      name: 'username_email',
      desc: '',
      args: [],
    );
  }

  /// `Wrong username or password`
  String get wrong_username_or_password {
    return Intl.message(
      'Wrong username or password',
      name: 'wrong_username_or_password',
      desc: '',
      args: [],
    );
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<Lt> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => Lt.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode);

  @override
  Future<Lt> load(Locale locale) => Lt.load(locale);

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
