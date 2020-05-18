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
  String get menu;
  String get close;
  String get wrongCredentials;
  String get now;
  String get fullDay;
  String get week;
  String get reminder;
  String inMinutes(int minutes);
  String get alarm;
  String get startsNow;
  String get endsNow;
  String get noActivities;
  String get timePillarView;
  String get listView;
  String get left;
  String get right;
  String get check;
  String get uncheck;
  String get newActivity;
  String get editActivity;
  String get category;
  String get noColor;
  String get selectAlarmType;
  String get alarmAndVibration;
  String get vibration;
  String get noAlarm;
  String get alarmOnlyAtStartTime;
  String get checkable;
  String get deleteAfter;
  String get availableFor;
  String get meAndSupportPersons;
  String get onlyMe;
  String get name;
  String get picture;
  String get date;
  String get today;
  String get startTime;
  String get endTime;
  String get noEndTime;
  String get calendarView;
  String get selectPicture;
  String get imageArchive;
  String get myPhotos;
  String get takeNewPhoto;
  String get days;
  String get day;
  String get hours;
  String get hour;
  String get h;
  String get min;
  String get am;
  String get pm;
  String get remove;
  String get deleteActivity;
  String get removePicture;
  String get appyTo;
  String get onlyThisDay;
  String get allDays;
  String get thisDayAndForward;
}

class English extends Translated {
  @override
  String userName = 'Username / Email',
      password = 'Password',
      infoText1 = 'Use your ',
      infoText2 = ' account to Log in',
      login = 'Log in',
      logout = 'Log out',
      menu = 'Menu',
      close = 'Close',
      wrongCredentials =
          'Your username/email or password is not correct. Please, try another one.',
      now = 'now',
      fullDay = 'All day',
      week = 'week',
      reminder = 'Reminder',
      alarm = 'Alarm',
      endsNow = 'Ends now',
      startsNow = 'Starts now',
      noActivities = 'No activities for today',
      timePillarView = 'Timepillar view',
      listView = 'List view',
      left = 'Left',
      right = 'Right',
      check = 'Check',
      uncheck = 'Uncheck',
      newActivity = 'New activity',
      editActivity = 'Edit activity',
      category = 'Category',
      noColor = 'No color',
      selectAlarmType = 'Select alarm type',
      alarmAndVibration = 'Alarm + vibration',
      vibration = 'Vibration',
      noAlarm = 'No alarm',
      alarmOnlyAtStartTime = 'Alarm only at Start time',
      checkable = 'Checkable',
      deleteAfter = 'Delete after',
      availableFor = 'Available for',
      meAndSupportPersons = 'Me and support persons',
      onlyMe = 'Only me',
      name = 'Name',
      picture = 'Picture',
      date = 'Date',
      today = 'Today',
      startTime = 'Start time',
      endTime = 'End time',
      noEndTime = 'No end time',
      calendarView = 'Calendar view',
      selectPicture = 'Select picture',
      imageArchive = 'Image archive',
      myPhotos = 'My photos',
      takeNewPhoto = 'Take new photo',
      days = 'days',
      day = 'day',
      hours = 'hours',
      hour = 'hour',
      h = 'h',
      min = 'min',
      am = 'AM',
      pm = 'PM',
      remove = 'Remove',
      deleteActivity = 'Delete activity?',
      removePicture = 'Remove picture',
      appyTo = 'Apply to',
      onlyThisDay = 'Only this day',
      allDays = 'All days',
      thisDayAndForward = 'This day and forward';

  @override
  String inMinutes(int minutes) => 'in $minutes minutes';
}

class Swedish extends Translated {
  @override
  String userName = 'Användarnamn',
      password = 'Lösenord',
      infoText1 = 'Använd ditt ',
      infoText2 = '-konto för att logga in',
      login = 'Logga in',
      logout = 'Logga ut',
      menu = 'Meny',
      close = 'Stäng',
      wrongCredentials = 'Fel användarnamn eller lösenord',
      now = 'nu',
      fullDay = 'Heldag',
      week = 'vecka',
      reminder = 'Påminnelse',
      alarm = 'Larm',
      endsNow = 'Slutar nu',
      startsNow = 'Börjar nu',
      noActivities = 'Inga aktiviteter idag',
      timePillarView = 'Tidspelare',
      listView = 'Listvy',
      left = 'Vänster',
      right = 'Höger',
      check = 'Kvittera',
      uncheck = 'Ångra',
      newActivity = 'Ny aktivitet',
      editActivity = 'Ändra aktivitet',
      category = 'Kategori',
      noColor = 'Ingen färg',
      selectAlarmType = 'Välj typ av larm',
      alarmAndVibration = 'Larm + vibration',
      vibration = 'Vibration',
      noAlarm = 'Inget larm',
      alarmOnlyAtStartTime = 'Larm endast vid starttid',
      checkable = 'Kvittera',
      deleteAfter = 'Ta bort efteråt',
      availableFor = 'Tillgänglig för',
      meAndSupportPersons = 'Mig och stödpersoner',
      onlyMe = 'Bara mig',
      name = 'Namn',
      picture = 'Bild',
      date = 'Datum',
      today = 'Idag',
      startTime = 'Starttid',
      endTime = 'Sluttid',
      noEndTime = 'Ingen sluttid',
      calendarView = 'Kalendervy',
      selectPicture = 'Välj bild',
      imageArchive = 'Bildarkiv',
      myPhotos = 'Mina bilder',
      takeNewPhoto = 'Ta bild',
      days = 'dagar',
      day = 'dag',
      hours = 'timmar',
      hour = 'timme',
      h = 't',
      min = 'min',
      am = 'fm',
      pm = 'em',
      remove = 'Ta bort',
      deleteActivity = 'Ta bort aktivitet?',
      removePicture = 'Ta bort bild',
      appyTo = 'Ändra på',
      onlyThisDay = 'Endast denna dag',
      allDays = 'Alla dagar',
      thisDayAndForward = 'Denna dag och framåt';

  @override
  String inMinutes(int minutes) => 'om $minutes minuter';
}
