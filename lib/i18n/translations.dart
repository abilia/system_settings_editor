import 'dart:ui';

abstract class Translated {
  static Map<Locale, Translated> dictionaries = {
    Locale('en'): English(),
    Locale('sv'): Swedish()
  };
  String get userName;
  String get password;
  String get infoText1;
  String get infoText2;
  String get login;
  String get logout;
  String get wrongCredentials;
  String get now;
  String get fullDay;
  String get week;
  String get reminder;
  String inMinutes(int minutes);
  String get ok => 'OK';
  String get alarm => 'Alarm';
  String get startsNow;
  String get endsNow;
  String get noActivities;
}

class English extends Translated {
  String userName = 'Username / Email',
      password = 'Password',
      infoText1 = 'Use your ',
      infoText2 = ' account to Log in',
      login = 'Log in',
      logout = 'Log out',
      wrongCredentials =
          'Your username/email or password is not correct. Please, try another one.',
      now = 'now',
      fullDay = 'All day',
      week = 'week',
      reminder = 'Reminder',
      endsNow = 'Ends now',
      startsNow = 'Starts now',
      noActivities = 'No activities for today';
  String inMinutes(int minutes) => 'in $minutes minutes';
}

class Swedish extends Translated {
  String userName = 'Användarnamn',
      password = 'Lösenord',
      infoText1 = 'Använd ditt ',
      infoText2 = '-konto för att logga in',
      login = 'Logga in',
      logout = 'Logga ut',
      wrongCredentials = 'Fel användarnamn eller lösenord',
      now = 'nu',
      fullDay = 'Heldag',
      week = 'vecka',
      reminder = 'Påminnelse',
      endsNow = 'Slutar nu',
      startsNow = 'Börjar nu',
      noActivities = 'Inga aktiviteter idag';
  String inMinutes(int minutes) => 'om $minutes minuter';
}
