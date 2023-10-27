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
    'logOut': [],
    'signIn': [],
    'sync': [],
    'userNameOrEmail': [],
    'password': [],
    'welcomeToHandi': [],
    'verifyCredentials': [],
    'unsupportedUserType': [],
    'noHandiLicence': [],
    'lincenseExpired': [],
    'somethingWentWrong': [],
    'connectToInternet': [],
    'tooManyAttempts': []
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

  /// `Log out`
  String get logOut {
    return Intl.message(
      'Log out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get signIn {
    return Intl.message(
      'Log in',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Sync`
  String get sync {
    return Intl.message(
      'Sync',
      name: 'sync',
      desc: '',
      args: [],
    );
  }

  /// `Username or email address`
  String get userNameOrEmail {
    return Intl.message(
      'Username or email address',
      name: 'userNameOrEmail',
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

  /// `Welcome to Handi!`
  String get welcomeToHandi {
    return Intl.message(
      'Welcome to Handi!',
      name: 'welcomeToHandi',
      desc: '',
      args: [],
    );
  }

  /// `Username or password doesn’t match. Verify your credentials and try again.`
  String get verifyCredentials {
    return Intl.message(
      'Username or password doesn’t match. Verify your credentials and try again.',
      name: 'verifyCredentials',
      desc: '',
      args: [],
    );
  }

  /// `You need to have myAbilia account with type “User” to be able use Handi calendar app.`
  String get unsupportedUserType {
    return Intl.message(
      'You need to have myAbilia account with type “User” to be able use Handi calendar app.',
      name: 'unsupportedUserType',
      desc: '',
      args: [],
    );
  }

  /// `You need to have Handi Calendar licence to be able to use app.`
  String get noHandiLicence {
    return Intl.message(
      'You need to have Handi Calendar licence to be able to use app.',
      name: 'noHandiLicence',
      desc: '',
      args: [],
    );
  }

  /// `Your license expired, please connect support to extend license.`
  String get lincenseExpired {
    return Intl.message(
      'Your license expired, please connect support to extend license.',
      name: 'lincenseExpired',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong on our side. Please try again later.`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong on our side. Please try again later.',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Connect to the internet to continue.`
  String get connectToInternet {
    return Intl.message(
      'Connect to the internet to continue.',
      name: 'connectToInternet',
      desc: '',
      args: [],
    );
  }

  /// `Please, wait a moment before you can try again.`
  String get tooManyAttempts {
    return Intl.message(
      'Please, wait a moment before you can try again.',
      name: 'tooManyAttempts',
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
