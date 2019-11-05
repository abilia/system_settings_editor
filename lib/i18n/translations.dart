import 'dart:ui';

Map<Locale, Translated> dictionaries = {
  Locale('en'): English(),
  Locale('sv'): Swedish()
};

abstract class Translated {
  String get userName;
  String get password;
  String get infoText1;
  String get infoText2;
  String get login;
  String get wrongCredentials;
  String get now;
}

class English extends Translated {
  String userName = 'Username / Email',
      password = 'Password',
      infoText1 = 'Use your ',
      infoText2 = ' account to login',
      login = 'Log in',
      wrongCredentials =
          'Your username/email or password is not correct. Please, try another one.',
      now = 'now';
}

class Swedish extends Translated {
  String userName = 'Användarnamn',
      password = 'Lösenord',
      infoText1 = 'Använd ditt ',
      infoText2 = '-konto för att logga in',
      login = 'Logga in',
      wrongCredentials = 'Fel användarnamn eller lösenord',
      now = 'nu';
}
