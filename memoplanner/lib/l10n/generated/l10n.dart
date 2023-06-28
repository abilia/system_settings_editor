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
    Locale.fromSubtags(languageCode: 'da'),
    Locale.fromSubtags(languageCode: 'de'),
    Locale.fromSubtags(languageCode: 'fi'),
    Locale.fromSubtags(languageCode: 'nb'),
    Locale.fromSubtags(languageCode: 'nl'),
    Locale.fromSubtags(languageCode: 'sv'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

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

  static final Map<String, List<String>> _metadata = {
    'welcome': [],
    'welcomeText': [],
    'step': [],
    'finish': [],
    'setupYourInternetConnection': [],
    'wifiNoInternet': [],
    'connectInternetToContinue': [],
    'notSelected': [],
    'enterYourLicense': [],
    'enterYourLicenseHint': [],
    'licenseErrorAlreadyInUse': [],
    'licenseErrorNotFound': [],
    'downloadVoiceText': [],
    'username': [],
    'password': [],
    'loginHintMP': [],
    'loginHintMPGO': [],
    'login': [],
    'logout': [],
    'wrongCredentials': [],
    'noConnection': [],
    'enterUsername': [],
    'enterPassword': [],
    'userTypeNotSupported': [],
    'loggedOutMessage': [],
    'unauthorizedHeader': [],
    'unauthorizedMessage': [],
    'tooManyAttempts': [],
    'createAccountHint': [],
    'createAccount': [],
    'createAccountHeading': [],
    'createAccountSubheading': [],
    'usernameHint': [],
    'passwordHint': [],
    'confirmPassword': [],
    'passwordToShort': [],
    'passwordMismatch': [],
    'confirmTermsOfUse': [],
    'confirmPrivacyPolicy': [],
    'usernameTaken': [],
    'unknownError': [],
    'accountCreatedHeading': [],
    'accountCreatedBody': [],
    'browser': [],
    'backToLogin': [],
    'noLicense': [],
    'licenseExpired': [],
    'licenseExpiredMessage': [],
    'toLogin': [],
    'memoplannerLicenseExpired': [],
    'needLicenseToSaveData': [],
    'contactProviderToExtendLicense': [],
    'allDataSaved': [],
    'goOnlineBeforeLogout': [],
    'doNotLoseYourContent': [],
    'syncing': [],
    'canLogOutSafely': [],
    'lastSyncWas': [],
    'connectToWifiToLogOut': [],
    'connectToInternetToLogOut': [],
    'ifYouLogoutYouWillLose': [],
    'activityTemplateSingular': [],
    'activityTemplatePlural': [],
    'timerTemplateSingular': [],
    'timerTemplatePlural': [],
    'photoSingular': [],
    'photoPlural': [],
    'settingsData': [],
    'fullDay': [],
    'earlyMorning': [],
    'midMorning': [],
    'lunch': [],
    'afternoon': [],
    'evening': [],
    'night': [],
    'today': [],
    'days': [],
    'day': [],
    'hours': [],
    'hour': [],
    'h': [],
    'minutes': [],
    'minute': [],
    'seconds': [],
    'second': [],
    'min': [],
    'am': [],
    'pm': [],
    'dayInessive': [],
    'hourInessive': [],
    'minuteInessive': [],
    'now': [],
    'week': [],
    'month': [],
    'clockTheTimeIsTts': [],
    'clockFiveMinutesPastTts': [],
    'clockFiveMinutesHalfPastTts': [],
    'clockFiveMinutesToTts': [],
    'clockFiveMinutesToHalfPastTts': [],
    'clockHalfPastTts': [],
    'clockQuarterPastTts': [],
    'clockQuarterToTts': [],
    'clockTenMinutesPastTts': [],
    'clockTenMinutesToTts': [],
    'clockTwentyMinutesPastTts': [],
    'clockTwentyMinutesToTts': [],
    'nbOneAClock': [],
    'timeMorningTts': [],
    'timeForeNoonTts': [],
    'timeAfternoonTts': [],
    'timeEveningTts': [],
    'timeNightTts': [],
    'timerInvalidDuration': [],
    'timerDelete': [],
    'timerPause': [],
    'timerResume': [],
    'timerPaused': [],
    'pause': [],
    'continue_': [],
    'activity': [],
    'activities': [],
    'reminders': [],
    'reminder': [],
    'alarm': [],
    'endsNow': [],
    'startsNow': [],
    'noActivities': [],
    'left': [],
    'right': [],
    'check': [],
    'undo': [],
    'deleteActivityQuestion': [],
    'editRecurringActivity': [],
    'deleteRecurringActivity': [],
    'onlyThisDay': [],
    'allDays': [],
    'allDay': [],
    'thisDayAndForward': [],
    'notCompleted': [],
    'completed': [],
    'completedQuestion': [],
    'unCheckActivityQuestion': [],
    'inTimePre': [],
    'timeAgoPre': [],
    'timeAgoPost': [],
    'checklistDoneInfo': [],
    'templates': [],
    'timeTo': [],
    'addTimer': [],
    'start': [],
    'newTimer': [],
    'selectDuration': [],
    'startTimer': [],
    'enterNameForTimer': [],
    'selectTemplateTimer': [],
    'timer': [],
    'timeIsUp': [],
    'timers': [],
    'editTimer': [],
    'newTimerTemplate': [],
    'editTimerTemplate': [],
    'menu': [],
    'cancel': [],
    'yes': [],
    'no': [],
    'close': [],
    'previous': [],
    'next': [],
    'ok': [],
    'record': [],
    'newText': [],
    'fromTemplate': [],
    'newActivity': [],
    'editActivity': [],
    'newActivityTemplate': [],
    'editActivityTemplate': [],
    'category': [],
    'checkable': [],
    'notCheckable': [],
    'deleteAfter': [],
    'dontDeleteAfter': [],
    'name': [],
    'picture': [],
    'date': [],
    'startTime': [],
    'endTime': [],
    'emptyFolder': [],
    'noTemplates': [],
    'noChecklists': [],
    'noNotes': [],
    'noImages': [],
    'setTime': [],
    'time': [],
    'save': [],
    'endBeforeStartError': [],
    'speech': [],
    'speechOnStart': [],
    'speechOnEnd': [],
    'duration': [],
    'stop': [],
    'play': [],
    'enterNameForActivity': [],
    'error': [],
    'warning': [],
    'missingTitleOrImageAndStartTime': [],
    'missingTitleOrImage': [],
    'missingStartTime': [],
    'startTimeBeforeNowError': [],
    'startTimeBeforeNowWarning': [],
    'conflictWarning': [],
    'noTemplateActivityError1': [],
    'noTemplateActivityError2': [],
    'missingRequiredActivitySetting': [],
    'availableFor': [],
    'activityAvailableFor': [],
    'allSupportPersons': [],
    'onlyMe': [],
    'selectedSupportPersons': [],
    'supportPersons': [],
    'selectAlarmType': [],
    'alarmAndVibration': [],
    'vibrationIfAvailable': [],
    'noAlarm': [],
    'silentAlarm': [],
    'alarmOnlyAtStartTime': [],
    'alertAlarmsDisabled': [],
    'disableAlarms': [],
    'selectImage': [],
    'removeImage': [],
    'imageArchive': [],
    'devicesLocalImages': [],
    'myPhotos': [],
    'mobilePictures': [],
    'takeNewPhoto': [],
    'search': [],
    'searchImage': [],
    'noMatchingImage': [],
    'recurrence': [],
    'weekly': [],
    'monthly': [],
    'yearly': [],
    'noEndDate': [],
    'endDate': [],
    'everyOtherWeek': [],
    'recurringDataEmptyErrorMessage': [],
    'endDateNotSpecifiedErrorMessage': [],
    'selectAll': [],
    'deselectAll': [],
    'mo': [],
    'tu': [],
    'we': [],
    'th': [],
    'fr': [],
    'sa': [],
    'su': [],
    'extra': [],
    'infoType': [],
    'selectInfoType': [],
    'infoTypeNone': [],
    'addChecklist': [],
    'addNote': [],
    'typeSomething': [],
    'enterText': [],
    'clear': [],
    'selectFromLibrary': [],
    'addNew': [],
    'task': [],
    'enterTask': [],
    'screenBrightness': [],
    'battery': [],
    'clickSound': [],
    'volumeAlarm': [],
    'volumeMedia': [],
    'wifi': [],
    'notConnected': [],
    'connected': [],
    'connectedNoInternet': [],
    'screenTimeout': [],
    'alwaysOn': [],
    'keepScreenAwakeWhileCharging': [],
    'settings': [],
    'calendarView': [],
    'oneTimePillarView': [],
    'twoTimePillarsView': [],
    'listView': [],
    'timepillarSettings': [],
    'activityDuration': [],
    'dots': [],
    'edge': [],
    'monthCalendarGrid': [],
    'monthCalendarPreview': [],
    'textToSpeech': [],
    'longpressToSpeak': [],
    'longPressInfoText': [],
    'display': [],
    'viewMode': [],
    'dayInterval': [],
    'interval': [],
    'intervals': [],
    'categories': [],
    'viewDay': [],
    'dayAndNight': [],
    'timelineZoom': [],
    'small': [],
    'medium': [],
    'large': [],
    'system': [],
    'calendar': [],
    'functions': [],
    'imagePicker': [],
    'general': [],
    'dayCalendar': [],
    'weekCalendar': [],
    'monthCalendar': [],
    'activityView': [],
    'addActivity': [],
    'alarmSettings': [],
    'nonCheckableActivities': [],
    'checkableActivities': [],
    'alarmTime': [],
    'alert': [],
    'defaultSound': [],
    'noSound': [],
    'showDisableAlarms': [],
    'showWeekNumber': [],
    'showYear': [],
    'showMonthAndYear': [],
    'everyDay': [],
    'view': [],
    'viewSettings': [],
    'typeOfDisplay': [],
    'timelineLength': [],
    'weekdays': [],
    'captions': [],
    'columns': [],
    'headings': [],
    'allowPassedStartTime': [],
    'addRecurringActivity': [],
    'showEndTime': [],
    'showAlarm': [],
    'showVibrationAlarm': [],
    'showSilentAlarm': [],
    'showNoAlarm': [],
    'showAlarmOnlyAtStartTime': [],
    'showSpeechAtAlarm': [],
    'showReminders': [],
    'showSelectEndDate': [],
    'recurring': [],
    'throughEditView': [],
    'androidSettings': [],
    'stepByStep': [],
    'showTemplates': [],
    'selectName': [],
    'selectDate': [],
    'selectType': [],
    'selectAllDay': [],
    'selectCategory': [],
    'selectCheckable': [],
    'selectAvailableFor': [],
    'selectAlarm': [],
    'iOSAlarmTimeWarning': [],
    'selectChecklist': [],
    'selectNote': [],
    'selectReminder': [],
    'add': [],
    'defaults': [],
    'onlyAppliesToGo': [],
    'showOngoingActivityInFullScreen': [],
    'toolbar': [],
    'toolbarSettingsHint': [],
    'homeScreen': [],
    'homeScreenSettingsHint': [],
    'timeout': [],
    'timeoutSettingsHint': [],
    'noTimeout': [],
    'activateScreensaver': [],
    'onlyActivateScreensaverDuringNight': [],
    'menuRemovalWarning': [],
    'menuItemsDisabled': [],
    'selectADayToViewDetails': [],
    'topField': [],
    'showBrowseButtons': [],
    'showWeekday': [],
    'showDayPeriod': [],
    'showDate': [],
    'showClock': [],
    'delete': [],
    'edit': [],
    'showQuarterHourWatchBar': [],
    'timeOnQuarterHourBar': [],
    'clock': [],
    'analogueDigital': [],
    'analogue': [],
    'digital': [],
    'timeline': [],
    'earyMorning': [],
    'twelveHourFormat': [],
    'oneDot': [],
    'columnOfDots': [],
    'lineAcrossCurrentTime': [],
    'linesForEachHour': [],
    'saturdayAndSunday': [],
    'dayColours': [],
    'noDayColours': [],
    'showCagetories': [],
    'showColours': [],
    'editCategory': [],
    'speakEveryWord': [],
    'speechRate': [],
    'voice': [],
    'noVoicesInstalled': [],
    'installing': [],
    'testOfSpeechRate': [],
    'voices': [],
    'codeProtect': [],
    'code': [],
    'codeProtectSettings': [],
    'codeProtectThisView': [],
    'codeProtectAndroidSettings': [],
    'enterCode': [],
    'enterYourCodeToAccess': [],
    'enterNewCode': [],
    'confirmCode': [],
    'incorrectCode': [],
    'permissions': [],
    'notifications': [],
    'accessToPhotos': [],
    'accessToCamera': [],
    'allowNotifications': [],
    'allowNotificationsDescription1': [],
    'settingsLink': [],
    'turnOffNotifications': [],
    'turnOffNotificationsBody': [],
    'notificationsWarningHintText': [],
    'notificationsWarningText': [],
    'fullScreenAlarm': [],
    'redirectToAndroidSettings': [],
    'fullScreenAlarmInfo': [],
    'allow': [],
    'previewActivityTitle': [],
    'allowAccessPhotosBody': [],
    'allowAccessCameraBody': [],
    'allowAccessBody2': [],
    'accessToMicrophone': [],
    'allowAccessMicrophoneBody': [],
    'ignoreBatteryOptimizations': [],
    'about': [],
    'aboutMemoplanner': [],
    'licenseNumber': [],
    'licenseValidDate': [],
    'loggedInUser': [],
    'aboutDevice': [],
    'supportId': [],
    'deviceName': [],
    'serialNumber': [],
    'version': [],
    'androidVersion': [],
    'iosVersion': [],
    'producer': [],
    'searchForUpdate': [],
    'camera': [],
    'photoCalendar': [],
    'countdown': [],
    'quickSettingsMenu': [],
    'allPhotos': [],
    'addToPhotoCalendarQuestion': [],
    'removeFromPhotoCalendarQuestion': [],
    'remove': [],
    'doYouWantToDeleteThisPhoto': [],
    'installStarterSet': [],
    'doYouWantToImportADefaultSet': [],
    'welcomeTo': [],
    'getStarted': [],
    'readAndAgree1': [],
    'readAndAgree2': [],
    'acceptTerms': [],
    'termsOfUse': [],
    'termsOfUseUrl': [],
    'privacyPolicy': [],
    'privacyPolicyUrl': [],
    'confirmDiscard': [],
    'keepEditing': [],
    'discard': [],
    'resetDeviceQuestion': [],
    'factoryReset': [],
    'factoryResetDescription': [],
    'clearData': [],
    'clearDataDescription': [],
    'confirmFactoryReset': [],
    'confirmFactoryResetDescription': [],
    'factoryResetFailed': [],
    'back': [],
    'selectTemplate': [],
    'noRecurrence': [],
    'daily': [],
    'once': []
  };

  /// `Welcome!`
  String get welcome {
    return Intl.message(
      'Welcome!',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `This guide will help you get started with MEMOplanner.`
  String get welcomeText {
    return Intl.message(
      'This guide will help you get started with MEMOplanner.',
      name: 'welcomeText',
      desc: '',
      args: [],
    );
  }

  /// `Step`
  String get step {
    return Intl.message(
      'Step',
      name: 'step',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get finish {
    return Intl.message(
      'Finish',
      name: 'finish',
      desc: '',
      args: [],
    );
  }

  /// `Setup your internet connection`
  String get setupYourInternetConnection {
    return Intl.message(
      'Setup your internet connection',
      name: 'setupYourInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Your current Wi-Fi has failed to connect to the internet, try another network or contact your internet provider for help.`
  String get wifiNoInternet {
    return Intl.message(
      'Your current Wi-Fi has failed to connect to the internet, try another network or contact your internet provider for help.',
      name: 'wifiNoInternet',
      desc: '',
      args: [],
    );
  }

  /// `Connect to the internet to continue`
  String get connectInternetToContinue {
    return Intl.message(
      'Connect to the internet to continue',
      name: 'connectInternetToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Not selected`
  String get notSelected {
    return Intl.message(
      'Not selected',
      name: 'notSelected',
      desc: '',
      args: [],
    );
  }

  /// `Enter your license key`
  String get enterYourLicense {
    return Intl.message(
      'Enter your license key',
      name: 'enterYourLicense',
      desc: '',
      args: [],
    );
  }

  /// `License key should contain 12 digits`
  String get enterYourLicenseHint {
    return Intl.message(
      'License key should contain 12 digits',
      name: 'enterYourLicenseHint',
      desc: '',
      args: [],
    );
  }

  /// `License is already in use`
  String get licenseErrorAlreadyInUse {
    return Intl.message(
      'License is already in use',
      name: 'licenseErrorAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `We didn't find a valid license.\nPlease check the license key and try again`
  String get licenseErrorNotFound {
    return Intl.message(
      'We didn\'t find a valid license.\nPlease check the license key and try again',
      name: 'licenseErrorNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Download voice for speech support`
  String get downloadVoiceText {
    return Intl.message(
      'Download voice for speech support',
      name: 'downloadVoiceText',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
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

  /// `Use your myAbilia account to Log in`
  String get loginHintMP {
    return Intl.message(
      'Use your myAbilia account to Log in',
      name: 'loginHintMP',
      desc: '',
      args: [],
    );
  }

  /// `Login with the same username and password as on your MEMOplanner`
  String get loginHintMPGO {
    return Intl.message(
      'Login with the same username and password as on your MEMOplanner',
      name: 'loginHintMPGO',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get login {
    return Intl.message(
      'Log in',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message(
      'Log out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Username or password doesn't match.\nVerify your credentials and try again.`
  String get wrongCredentials {
    return Intl.message(
      'Username or password doesn\'t match.\nVerify your credentials and try again.',
      name: 'wrongCredentials',
      desc: '',
      args: [],
    );
  }

  /// `No contact with myAbilia. Check your Internet connection.`
  String get noConnection {
    return Intl.message(
      'No contact with myAbilia. Check your Internet connection.',
      name: 'noConnection',
      desc: '',
      args: [],
    );
  }

  /// `Enter username`
  String get enterUsername {
    return Intl.message(
      'Enter username',
      name: 'enterUsername',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get enterPassword {
    return Intl.message(
      'Enter password',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Users of type Support person or Admin can't log in to MEMOplanner. Please use myAbilia.`
  String get userTypeNotSupported {
    return Intl.message(
      'Users of type Support person or Admin can\'t log in to MEMOplanner. Please use myAbilia.',
      name: 'userTypeNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `You have been logged out. Please log in again.`
  String get loggedOutMessage {
    return Intl.message(
      'You have been logged out. Please log in again.',
      name: 'loggedOutMessage',
      desc: '',
      args: [],
    );
  }

  /// `You have been logged out`
  String get unauthorizedHeader {
    return Intl.message(
      'You have been logged out',
      name: 'unauthorizedHeader',
      desc: '',
      args: [],
    );
  }

  /// `This is most likely due to a password change, please try logging in again.`
  String get unauthorizedMessage {
    return Intl.message(
      'This is most likely due to a password change, please try logging in again.',
      name: 'unauthorizedMessage',
      desc: '',
      args: [],
    );
  }

  /// `You have made too many attempts to log in. Please wait a few seconds until trying again`
  String get tooManyAttempts {
    return Intl.message(
      'You have made too many attempts to log in. Please wait a few seconds until trying again',
      name: 'tooManyAttempts',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have a myAbilia account yet?`
  String get createAccountHint {
    return Intl.message(
      'Don’t have a myAbilia account yet?',
      name: 'createAccountHint',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create your account in myAbilia`
  String get createAccountHeading {
    return Intl.message(
      'Create your account in myAbilia',
      name: 'createAccountHeading',
      desc: '',
      args: [],
    );
  }

  /// `You need a myAbilia account to use MEMOplanner`
  String get createAccountSubheading {
    return Intl.message(
      'You need a myAbilia account to use MEMOplanner',
      name: 'createAccountSubheading',
      desc: '',
      args: [],
    );
  }

  /// `Username (phone number or email)`
  String get usernameHint {
    return Intl.message(
      'Username (phone number or email)',
      name: 'usernameHint',
      desc: '',
      args: [],
    );
  }

  /// `Password (minimum 12 characters)`
  String get passwordHint {
    return Intl.message(
      'Password (minimum 12 characters)',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `The password must consist of at least 12 characters`
  String get passwordToShort {
    return Intl.message(
      'The password must consist of at least 12 characters',
      name: 'passwordToShort',
      desc: '',
      args: [],
    );
  }

  /// `Both passwords must be the same`
  String get passwordMismatch {
    return Intl.message(
      'Both passwords must be the same',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Confirm terms of use`
  String get confirmTermsOfUse {
    return Intl.message(
      'Confirm terms of use',
      name: 'confirmTermsOfUse',
      desc: '',
      args: [],
    );
  }

  /// `Confirm privacy policy`
  String get confirmPrivacyPolicy {
    return Intl.message(
      'Confirm privacy policy',
      name: 'confirmPrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Username/email address is already in use`
  String get usernameTaken {
    return Intl.message(
      'Username/email address is already in use',
      name: 'usernameTaken',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error`
  String get unknownError {
    return Intl.message(
      'Unknown error',
      name: 'unknownError',
      desc: '',
      args: [],
    );
  }

  /// `Account created`
  String get accountCreatedHeading {
    return Intl.message(
      'Account created',
      name: 'accountCreatedHeading',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been created.\nYou can login using your username and password`
  String get accountCreatedBody {
    return Intl.message(
      'Your account has been created.\nYou can login using your username and password',
      name: 'accountCreatedBody',
      desc: '',
      args: [],
    );
  }

  /// `Browser`
  String get browser {
    return Intl.message(
      'Browser',
      name: 'browser',
      desc: '',
      args: [],
    );
  }

  /// `Back to Login`
  String get backToLogin {
    return Intl.message(
      'Back to Login',
      name: 'backToLogin',
      desc: '',
      args: [],
    );
  }

  /// `This account has no valid license.`
  String get noLicense {
    return Intl.message(
      'This account has no valid license.',
      name: 'noLicense',
      desc: '',
      args: [],
    );
  }

  /// `License is expired`
  String get licenseExpired {
    return Intl.message(
      'License is expired',
      name: 'licenseExpired',
      desc: '',
      args: [],
    );
  }

  /// `Your license has expired and MEMOplanner will no longer synchronize with myAbilia`
  String get licenseExpiredMessage {
    return Intl.message(
      'Your license has expired and MEMOplanner will no longer synchronize with myAbilia',
      name: 'licenseExpiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `to Log in`
  String get toLogin {
    return Intl.message(
      'to Log in',
      name: 'toLogin',
      desc: '',
      args: [],
    );
  }

  /// `MEMOplanner license expired`
  String get memoplannerLicenseExpired {
    return Intl.message(
      'MEMOplanner license expired',
      name: 'memoplannerLicenseExpired',
      desc: '',
      args: [],
    );
  }

  /// `You need an active license to save your data to myAbilia.`
  String get needLicenseToSaveData {
    return Intl.message(
      'You need an active license to save your data to myAbilia.',
      name: 'needLicenseToSaveData',
      desc: '',
      args: [],
    );
  }

  /// `Contact your MEMOplanner provider in order to extend your license.`
  String get contactProviderToExtendLicense {
    return Intl.message(
      'Contact your MEMOplanner provider in order to extend your license.',
      name: 'contactProviderToExtendLicense',
      desc: '',
      args: [],
    );
  }

  /// `All data saved!`
  String get allDataSaved {
    return Intl.message(
      'All data saved!',
      name: 'allDataSaved',
      desc: '',
      args: [],
    );
  }

  /// `Go online before you log out!`
  String get goOnlineBeforeLogout {
    return Intl.message(
      'Go online before you log out!',
      name: 'goOnlineBeforeLogout',
      desc: '',
      args: [],
    );
  }

  /// `Don't lose your content!`
  String get doNotLoseYourContent {
    return Intl.message(
      'Don\'t lose your content!',
      name: 'doNotLoseYourContent',
      desc: '',
      args: [],
    );
  }

  /// `Syncing...`
  String get syncing {
    return Intl.message(
      'Syncing...',
      name: 'syncing',
      desc: '',
      args: [],
    );
  }

  /// `Now you can log out safely`
  String get canLogOutSafely {
    return Intl.message(
      'Now you can log out safely',
      name: 'canLogOutSafely',
      desc: '',
      args: [],
    );
  }

  /// `Last sync was`
  String get lastSyncWas {
    return Intl.message(
      'Last sync was',
      name: 'lastSyncWas',
      desc: '',
      args: [],
    );
  }

  /// `Connect to Wi-Fi to log out safely`
  String get connectToWifiToLogOut {
    return Intl.message(
      'Connect to Wi-Fi to log out safely',
      name: 'connectToWifiToLogOut',
      desc: '',
      args: [],
    );
  }

  /// `Connect to internet to log out safely`
  String get connectToInternetToLogOut {
    return Intl.message(
      'Connect to internet to log out safely',
      name: 'connectToInternetToLogOut',
      desc: '',
      args: [],
    );
  }

  /// `If you log out now you will lose:`
  String get ifYouLogoutYouWillLose {
    return Intl.message(
      'If you log out now you will lose:',
      name: 'ifYouLogoutYouWillLose',
      desc: '',
      args: [],
    );
  }

  /// `activity template`
  String get activityTemplateSingular {
    return Intl.message(
      'activity template',
      name: 'activityTemplateSingular',
      desc: '',
      args: [],
    );
  }

  /// `activity templates`
  String get activityTemplatePlural {
    return Intl.message(
      'activity templates',
      name: 'activityTemplatePlural',
      desc: '',
      args: [],
    );
  }

  /// `timer template`
  String get timerTemplateSingular {
    return Intl.message(
      'timer template',
      name: 'timerTemplateSingular',
      desc: '',
      args: [],
    );
  }

  /// `timer templates`
  String get timerTemplatePlural {
    return Intl.message(
      'timer templates',
      name: 'timerTemplatePlural',
      desc: '',
      args: [],
    );
  }

  /// `photo`
  String get photoSingular {
    return Intl.message(
      'photo',
      name: 'photoSingular',
      desc: '',
      args: [],
    );
  }

  /// `photos`
  String get photoPlural {
    return Intl.message(
      'photos',
      name: 'photoPlural',
      desc: '',
      args: [],
    );
  }

  /// `Settings data`
  String get settingsData {
    return Intl.message(
      'Settings data',
      name: 'settingsData',
      desc: '',
      args: [],
    );
  }

  /// `All day`
  String get fullDay {
    return Intl.message(
      'All day',
      name: 'fullDay',
      desc: '',
      args: [],
    );
  }

  /// `early morning`
  String get earlyMorning {
    return Intl.message(
      'early morning',
      name: 'earlyMorning',
      desc: '',
      args: [],
    );
  }

  /// `mid-morning`
  String get midMorning {
    return Intl.message(
      'mid-morning',
      name: 'midMorning',
      desc: '',
      args: [],
    );
  }

  /// `Lunch`
  String get lunch {
    return Intl.message(
      'Lunch',
      name: 'lunch',
      desc: '',
      args: [],
    );
  }

  /// `afternoon`
  String get afternoon {
    return Intl.message(
      'afternoon',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `evening`
  String get evening {
    return Intl.message(
      'evening',
      name: 'evening',
      desc: '',
      args: [],
    );
  }

  /// `night`
  String get night {
    return Intl.message(
      'night',
      name: 'night',
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

  /// `days`
  String get days {
    return Intl.message(
      'days',
      name: 'days',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get day {
    return Intl.message(
      'day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `hours`
  String get hours {
    return Intl.message(
      'hours',
      name: 'hours',
      desc: '',
      args: [],
    );
  }

  /// `hour`
  String get hour {
    return Intl.message(
      'hour',
      name: 'hour',
      desc: '',
      args: [],
    );
  }

  /// `h`
  String get h {
    return Intl.message(
      'h',
      name: 'h',
      desc: '',
      args: [],
    );
  }

  /// `minutes`
  String get minutes {
    return Intl.message(
      'minutes',
      name: 'minutes',
      desc: '',
      args: [],
    );
  }

  /// `minute`
  String get minute {
    return Intl.message(
      'minute',
      name: 'minute',
      desc: '',
      args: [],
    );
  }

  /// `seconds`
  String get seconds {
    return Intl.message(
      'seconds',
      name: 'seconds',
      desc: '',
      args: [],
    );
  }

  /// `second`
  String get second {
    return Intl.message(
      'second',
      name: 'second',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get min {
    return Intl.message(
      'min',
      name: 'min',
      desc: '',
      args: [],
    );
  }

  /// `AM`
  String get am {
    return Intl.message(
      'AM',
      name: 'am',
      desc: '',
      args: [],
    );
  }

  /// `PM`
  String get pm {
    return Intl.message(
      'PM',
      name: 'pm',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get dayInessive {
    return Intl.message(
      '',
      name: 'dayInessive',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get hourInessive {
    return Intl.message(
      '',
      name: 'hourInessive',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get minuteInessive {
    return Intl.message(
      '',
      name: 'minuteInessive',
      desc: '',
      args: [],
    );
  }

  /// `Now`
  String get now {
    return Intl.message(
      'Now',
      name: 'now',
      desc: '',
      args: [],
    );
  }

  /// `week`
  String get week {
    return Intl.message(
      'week',
      name: 'week',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `the time is %s`
  String get clockTheTimeIsTts {
    return Intl.message(
      'the time is %s',
      name: 'clockTheTimeIsTts',
      desc: '',
      args: [],
    );
  }

  /// `five past %s`
  String get clockFiveMinutesPastTts {
    return Intl.message(
      'five past %s',
      name: 'clockFiveMinutesPastTts',
      desc: '',
      args: [],
    );
  }

  /// `twenty five to %s`
  String get clockFiveMinutesHalfPastTts {
    return Intl.message(
      'twenty five to %s',
      name: 'clockFiveMinutesHalfPastTts',
      desc: '',
      args: [],
    );
  }

  /// `five to %s`
  String get clockFiveMinutesToTts {
    return Intl.message(
      'five to %s',
      name: 'clockFiveMinutesToTts',
      desc: '',
      args: [],
    );
  }

  /// `twenty five past %s`
  String get clockFiveMinutesToHalfPastTts {
    return Intl.message(
      'twenty five past %s',
      name: 'clockFiveMinutesToHalfPastTts',
      desc: '',
      args: [],
    );
  }

  /// `Half past %s`
  String get clockHalfPastTts {
    return Intl.message(
      'Half past %s',
      name: 'clockHalfPastTts',
      desc: '',
      args: [],
    );
  }

  /// `quarter past %s`
  String get clockQuarterPastTts {
    return Intl.message(
      'quarter past %s',
      name: 'clockQuarterPastTts',
      desc: '',
      args: [],
    );
  }

  /// `Quarter to %s`
  String get clockQuarterToTts {
    return Intl.message(
      'Quarter to %s',
      name: 'clockQuarterToTts',
      desc: '',
      args: [],
    );
  }

  /// `ten past %s`
  String get clockTenMinutesPastTts {
    return Intl.message(
      'ten past %s',
      name: 'clockTenMinutesPastTts',
      desc: '',
      args: [],
    );
  }

  /// `ten to %s`
  String get clockTenMinutesToTts {
    return Intl.message(
      'ten to %s',
      name: 'clockTenMinutesToTts',
      desc: '',
      args: [],
    );
  }

  /// `twenty past %s`
  String get clockTwentyMinutesPastTts {
    return Intl.message(
      'twenty past %s',
      name: 'clockTwentyMinutesPastTts',
      desc: '',
      args: [],
    );
  }

  /// `twenty to %s`
  String get clockTwentyMinutesToTts {
    return Intl.message(
      'twenty to %s',
      name: 'clockTwentyMinutesToTts',
      desc: '',
      args: [],
    );
  }

  /// `one o clock`
  String get nbOneAClock {
    return Intl.message(
      'one o clock',
      name: 'nbOneAClock',
      desc: '',
      args: [],
    );
  }

  /// `%s in the early morning`
  String get timeMorningTts {
    return Intl.message(
      '%s in the early morning',
      name: 'timeMorningTts',
      desc: '',
      args: [],
    );
  }

  /// `%s in the mid-morning`
  String get timeForeNoonTts {
    return Intl.message(
      '%s in the mid-morning',
      name: 'timeForeNoonTts',
      desc: '',
      args: [],
    );
  }

  /// `%s in the afternoon`
  String get timeAfternoonTts {
    return Intl.message(
      '%s in the afternoon',
      name: 'timeAfternoonTts',
      desc: '',
      args: [],
    );
  }

  /// `%s in the evening`
  String get timeEveningTts {
    return Intl.message(
      '%s in the evening',
      name: 'timeEveningTts',
      desc: '',
      args: [],
    );
  }

  /// `%s at night`
  String get timeNightTts {
    return Intl.message(
      '%s at night',
      name: 'timeNightTts',
      desc: '',
      args: [],
    );
  }

  /// `Duration cannot be zero.`
  String get timerInvalidDuration {
    return Intl.message(
      'Duration cannot be zero.',
      name: 'timerInvalidDuration',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete the timer?`
  String get timerDelete {
    return Intl.message(
      'Do you want to delete the timer?',
      name: 'timerDelete',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to pause the timer?`
  String get timerPause {
    return Intl.message(
      'Do you want to pause the timer?',
      name: 'timerPause',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to continue the timer?`
  String get timerResume {
    return Intl.message(
      'Do you want to continue the timer?',
      name: 'timerResume',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get timerPaused {
    return Intl.message(
      'Paused',
      name: 'timerPaused',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message(
      'Pause',
      name: 'pause',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continue_ {
    return Intl.message(
      'Continue',
      name: 'continue_',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get activity {
    return Intl.message(
      'Activity',
      name: 'activity',
      desc: '',
      args: [],
    );
  }

  /// `Activities`
  String get activities {
    return Intl.message(
      'Activities',
      name: 'activities',
      desc: '',
      args: [],
    );
  }

  /// `Reminders`
  String get reminders {
    return Intl.message(
      'Reminders',
      name: 'reminders',
      desc: '',
      args: [],
    );
  }

  /// `Reminder`
  String get reminder {
    return Intl.message(
      'Reminder',
      name: 'reminder',
      desc: '',
      args: [],
    );
  }

  /// `Alarm`
  String get alarm {
    return Intl.message(
      'Alarm',
      name: 'alarm',
      desc: '',
      args: [],
    );
  }

  /// `Ends now`
  String get endsNow {
    return Intl.message(
      'Ends now',
      name: 'endsNow',
      desc: '',
      args: [],
    );
  }

  /// `Starts now`
  String get startsNow {
    return Intl.message(
      'Starts now',
      name: 'startsNow',
      desc: '',
      args: [],
    );
  }

  /// `No activities today`
  String get noActivities {
    return Intl.message(
      'No activities today',
      name: 'noActivities',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get left {
    return Intl.message(
      'Left',
      name: 'left',
      desc: '',
      args: [],
    );
  }

  /// `Right`
  String get right {
    return Intl.message(
      'Right',
      name: 'right',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get check {
    return Intl.message(
      'Check',
      name: 'check',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get undo {
    return Intl.message(
      'Undo',
      name: 'undo',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete this activity?`
  String get deleteActivityQuestion {
    return Intl.message(
      'Do you want to delete this activity?',
      name: 'deleteActivityQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Edit recurring activity`
  String get editRecurringActivity {
    return Intl.message(
      'Edit recurring activity',
      name: 'editRecurringActivity',
      desc: '',
      args: [],
    );
  }

  /// `Delete recurring activity`
  String get deleteRecurringActivity {
    return Intl.message(
      'Delete recurring activity',
      name: 'deleteRecurringActivity',
      desc: '',
      args: [],
    );
  }

  /// `Only this day`
  String get onlyThisDay {
    return Intl.message(
      'Only this day',
      name: 'onlyThisDay',
      desc: '',
      args: [],
    );
  }

  /// `All days`
  String get allDays {
    return Intl.message(
      'All days',
      name: 'allDays',
      desc: '',
      args: [],
    );
  }

  /// `All day`
  String get allDay {
    return Intl.message(
      'All day',
      name: 'allDay',
      desc: '',
      args: [],
    );
  }

  /// `This day and forward`
  String get thisDayAndForward {
    return Intl.message(
      'This day and forward',
      name: 'thisDayAndForward',
      desc: '',
      args: [],
    );
  }

  /// `not completed`
  String get notCompleted {
    return Intl.message(
      'not completed',
      name: 'notCompleted',
      desc: '',
      args: [],
    );
  }

  /// `completed`
  String get completed {
    return Intl.message(
      'completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Completed?`
  String get completedQuestion {
    return Intl.message(
      'Completed?',
      name: 'completedQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to uncheck the activity?`
  String get unCheckActivityQuestion {
    return Intl.message(
      'Do you want to uncheck the activity?',
      name: 'unCheckActivityQuestion',
      desc: '',
      args: [],
    );
  }

  /// `in`
  String get inTimePre {
    return Intl.message(
      'in',
      name: 'inTimePre',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get timeAgoPre {
    return Intl.message(
      '',
      name: 'timeAgoPre',
      desc: '',
      args: [],
    );
  }

  /// `ago`
  String get timeAgoPost {
    return Intl.message(
      'ago',
      name: 'timeAgoPost',
      desc: '',
      args: [],
    );
  }

  /// `All checklist tasks in your activity are completed. Do you want to complete the activity?`
  String get checklistDoneInfo {
    return Intl.message(
      'All checklist tasks in your activity are completed. Do you want to complete the activity?',
      name: 'checklistDoneInfo',
      desc: '',
      args: [],
    );
  }

  /// `Templates`
  String get templates {
    return Intl.message(
      'Templates',
      name: 'templates',
      desc: '',
      args: [],
    );
  }

  /// `to`
  String get timeTo {
    return Intl.message(
      'to',
      name: 'timeTo',
      desc: '',
      args: [],
    );
  }

  /// `Add Timer`
  String get addTimer {
    return Intl.message(
      'Add Timer',
      name: 'addTimer',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `New timer`
  String get newTimer {
    return Intl.message(
      'New timer',
      name: 'newTimer',
      desc: '',
      args: [],
    );
  }

  /// `Select duration`
  String get selectDuration {
    return Intl.message(
      'Select duration',
      name: 'selectDuration',
      desc: '',
      args: [],
    );
  }

  /// `Start timer`
  String get startTimer {
    return Intl.message(
      'Start timer',
      name: 'startTimer',
      desc: '',
      args: [],
    );
  }

  /// `Enter name for timer`
  String get enterNameForTimer {
    return Intl.message(
      'Enter name for timer',
      name: 'enterNameForTimer',
      desc: '',
      args: [],
    );
  }

  /// `Select timer`
  String get selectTemplateTimer {
    return Intl.message(
      'Select timer',
      name: 'selectTemplateTimer',
      desc: '',
      args: [],
    );
  }

  /// `Timer`
  String get timer {
    return Intl.message(
      'Timer',
      name: 'timer',
      desc: '',
      args: [],
    );
  }

  /// `Time is up`
  String get timeIsUp {
    return Intl.message(
      'Time is up',
      name: 'timeIsUp',
      desc: '',
      args: [],
    );
  }

  /// `Timers`
  String get timers {
    return Intl.message(
      'Timers',
      name: 'timers',
      desc: '',
      args: [],
    );
  }

  /// `Edit timer`
  String get editTimer {
    return Intl.message(
      'Edit timer',
      name: 'editTimer',
      desc: '',
      args: [],
    );
  }

  /// `New timer template`
  String get newTimerTemplate {
    return Intl.message(
      'New timer template',
      name: 'newTimerTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Edit timer template`
  String get editTimerTemplate {
    return Intl.message(
      'Edit timer template',
      name: 'editTimerTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message(
      'Menu',
      name: 'menu',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
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

  /// `Previous`
  String get previous {
    return Intl.message(
      'Previous',
      name: 'previous',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Record`
  String get record {
    return Intl.message(
      'Record',
      name: 'record',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get newText {
    return Intl.message(
      'New',
      name: 'newText',
      desc: '',
      args: [],
    );
  }

  /// `From template`
  String get fromTemplate {
    return Intl.message(
      'From template',
      name: 'fromTemplate',
      desc: '',
      args: [],
    );
  }

  /// `New activity`
  String get newActivity {
    return Intl.message(
      'New activity',
      name: 'newActivity',
      desc: '',
      args: [],
    );
  }

  /// `Edit activity`
  String get editActivity {
    return Intl.message(
      'Edit activity',
      name: 'editActivity',
      desc: '',
      args: [],
    );
  }

  /// `New activity template`
  String get newActivityTemplate {
    return Intl.message(
      'New activity template',
      name: 'newActivityTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Edit activity template`
  String get editActivityTemplate {
    return Intl.message(
      'Edit activity template',
      name: 'editActivityTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Checkable`
  String get checkable {
    return Intl.message(
      'Checkable',
      name: 'checkable',
      desc: '',
      args: [],
    );
  }

  /// `Not checkable`
  String get notCheckable {
    return Intl.message(
      'Not checkable',
      name: 'notCheckable',
      desc: '',
      args: [],
    );
  }

  /// `Delete at the end of the day`
  String get deleteAfter {
    return Intl.message(
      'Delete at the end of the day',
      name: 'deleteAfter',
      desc: '',
      args: [],
    );
  }

  /// `Don't remove at the end of the day`
  String get dontDeleteAfter {
    return Intl.message(
      'Don\'t remove at the end of the day',
      name: 'dontDeleteAfter',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get picture {
    return Intl.message(
      'Image',
      name: 'picture',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Start time`
  String get startTime {
    return Intl.message(
      'Start time',
      name: 'startTime',
      desc: '',
      args: [],
    );
  }

  /// `End time`
  String get endTime {
    return Intl.message(
      'End time',
      name: 'endTime',
      desc: '',
      args: [],
    );
  }

  /// `The folder is empty`
  String get emptyFolder {
    return Intl.message(
      'The folder is empty',
      name: 'emptyFolder',
      desc: '',
      args: [],
    );
  }

  /// `You have no templates`
  String get noTemplates {
    return Intl.message(
      'You have no templates',
      name: 'noTemplates',
      desc: '',
      args: [],
    );
  }

  /// `You have no checklists`
  String get noChecklists {
    return Intl.message(
      'You have no checklists',
      name: 'noChecklists',
      desc: '',
      args: [],
    );
  }

  /// `You have no notes`
  String get noNotes {
    return Intl.message(
      'You have no notes',
      name: 'noNotes',
      desc: '',
      args: [],
    );
  }

  /// `You have no images`
  String get noImages {
    return Intl.message(
      'You have no images',
      name: 'noImages',
      desc: '',
      args: [],
    );
  }

  /// `Set time`
  String get setTime {
    return Intl.message(
      'Set time',
      name: 'setTime',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `End date can't be before start date`
  String get endBeforeStartError {
    return Intl.message(
      'End date can\'t be before start date',
      name: 'endBeforeStartError',
      desc: '',
      args: [],
    );
  }

  /// `Speech`
  String get speech {
    return Intl.message(
      'Speech',
      name: 'speech',
      desc: '',
      args: [],
    );
  }

  /// `Speech at Start time`
  String get speechOnStart {
    return Intl.message(
      'Speech at Start time',
      name: 'speechOnStart',
      desc: '',
      args: [],
    );
  }

  /// `Speech at End time`
  String get speechOnEnd {
    return Intl.message(
      'Speech at End time',
      name: 'speechOnEnd',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message(
      'Duration',
      name: 'duration',
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

  /// `Play`
  String get play {
    return Intl.message(
      'Play',
      name: 'play',
      desc: '',
      args: [],
    );
  }

  /// `Enter name for activity`
  String get enterNameForActivity {
    return Intl.message(
      'Enter name for activity',
      name: 'enterNameForActivity',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Your activity should contain an image or name and start time.`
  String get missingTitleOrImageAndStartTime {
    return Intl.message(
      'Your activity should contain an image or name and start time.',
      name: 'missingTitleOrImageAndStartTime',
      desc: '',
      args: [],
    );
  }

  /// `An activity needs an image or a name.`
  String get missingTitleOrImage {
    return Intl.message(
      'An activity needs an image or a name.',
      name: 'missingTitleOrImage',
      desc: '',
      args: [],
    );
  }

  /// `You must enter a start time.`
  String get missingStartTime {
    return Intl.message(
      'You must enter a start time.',
      name: 'missingStartTime',
      desc: '',
      args: [],
    );
  }

  /// `You have selected a start time which has already passed. This is not allowed.`
  String get startTimeBeforeNowError {
    return Intl.message(
      'You have selected a start time which has already passed. This is not allowed.',
      name: 'startTimeBeforeNowError',
      desc: '',
      args: [],
    );
  }

  /// `You have selected a start time which has already passed. Press OK to continue.`
  String get startTimeBeforeNowWarning {
    return Intl.message(
      'You have selected a start time which has already passed. Press OK to continue.',
      name: 'startTimeBeforeNowWarning',
      desc: '',
      args: [],
    );
  }

  /// `There are activities conflicting with this activity. Press OK to continue.`
  String get conflictWarning {
    return Intl.message(
      'There are activities conflicting with this activity. Press OK to continue.',
      name: 'conflictWarning',
      desc: '',
      args: [],
    );
  }

  /// `There are no templates and you have not selected name or image in adding an activity step-by-step.`
  String get noTemplateActivityError1 {
    return Intl.message(
      'There are no templates and you have not selected name or image in adding an activity step-by-step.',
      name: 'noTemplateActivityError1',
      desc: '',
      args: [],
    );
  }

  /// `To fix this, either create templates or select either name or image for step-by-step.`
  String get noTemplateActivityError2 {
    return Intl.message(
      'To fix this, either create templates or select either name or image for step-by-step.',
      name: 'noTemplateActivityError2',
      desc: '',
      args: [],
    );
  }

  /// `You need either “Show templates”, “Select name” or “Select image” selected.`
  String get missingRequiredActivitySetting {
    return Intl.message(
      'You need either “Show templates”, “Select name” or “Select image” selected.',
      name: 'missingRequiredActivitySetting',
      desc: '',
      args: [],
    );
  }

  /// `Available for`
  String get availableFor {
    return Intl.message(
      'Available for',
      name: 'availableFor',
      desc: '',
      args: [],
    );
  }

  /// `Available for`
  String get activityAvailableFor {
    return Intl.message(
      'Available for',
      name: 'activityAvailableFor',
      desc: '',
      args: [],
    );
  }

  /// `All my support persons`
  String get allSupportPersons {
    return Intl.message(
      'All my support persons',
      name: 'allSupportPersons',
      desc: '',
      args: [],
    );
  }

  /// `Only me`
  String get onlyMe {
    return Intl.message(
      'Only me',
      name: 'onlyMe',
      desc: '',
      args: [],
    );
  }

  /// `Selected support persons`
  String get selectedSupportPersons {
    return Intl.message(
      'Selected support persons',
      name: 'selectedSupportPersons',
      desc: '',
      args: [],
    );
  }

  /// `Support persons`
  String get supportPersons {
    return Intl.message(
      'Support persons',
      name: 'supportPersons',
      desc: '',
      args: [],
    );
  }

  /// `Select alarm`
  String get selectAlarmType {
    return Intl.message(
      'Select alarm',
      name: 'selectAlarmType',
      desc: '',
      args: [],
    );
  }

  /// `Alarm + vibration`
  String get alarmAndVibration {
    return Intl.message(
      'Alarm + vibration',
      name: 'alarmAndVibration',
      desc: '',
      args: [],
    );
  }

  /// `Vibration (if available)`
  String get vibrationIfAvailable {
    return Intl.message(
      'Vibration (if available)',
      name: 'vibrationIfAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No alarm`
  String get noAlarm {
    return Intl.message(
      'No alarm',
      name: 'noAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Silent alarm`
  String get silentAlarm {
    return Intl.message(
      'Silent alarm',
      name: 'silentAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Alarm only at Start time`
  String get alarmOnlyAtStartTime {
    return Intl.message(
      'Alarm only at Start time',
      name: 'alarmOnlyAtStartTime',
      desc: '',
      args: [],
    );
  }

  /// `All alarms will be disabled until midnight on this device`
  String get alertAlarmsDisabled {
    return Intl.message(
      'All alarms will be disabled until midnight on this device',
      name: 'alertAlarmsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Disable alarms`
  String get disableAlarms {
    return Intl.message(
      'Disable alarms',
      name: 'disableAlarms',
      desc: '',
      args: [],
    );
  }

  /// `Select image`
  String get selectImage {
    return Intl.message(
      'Select image',
      name: 'selectImage',
      desc: '',
      args: [],
    );
  }

  /// `Remove image`
  String get removeImage {
    return Intl.message(
      'Remove image',
      name: 'removeImage',
      desc: '',
      args: [],
    );
  }

  /// `Image Archive`
  String get imageArchive {
    return Intl.message(
      'Image Archive',
      name: 'imageArchive',
      desc: '',
      args: [],
    );
  }

  /// `Device’s local images`
  String get devicesLocalImages {
    return Intl.message(
      'Device’s local images',
      name: 'devicesLocalImages',
      desc: '',
      args: [],
    );
  }

  /// `My photos`
  String get myPhotos {
    return Intl.message(
      'My photos',
      name: 'myPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Mobile pictures`
  String get mobilePictures {
    return Intl.message(
      'Mobile pictures',
      name: 'mobilePictures',
      desc: '',
      args: [],
    );
  }

  /// `Take new photo`
  String get takeNewPhoto {
    return Intl.message(
      'Take new photo',
      name: 'takeNewPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Search image`
  String get searchImage {
    return Intl.message(
      'Search image',
      name: 'searchImage',
      desc: '',
      args: [],
    );
  }

  /// `No matching image name`
  String get noMatchingImage {
    return Intl.message(
      'No matching image name',
      name: 'noMatchingImage',
      desc: '',
      args: [],
    );
  }

  /// `Recurrence`
  String get recurrence {
    return Intl.message(
      'Recurrence',
      name: 'recurrence',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get weekly {
    return Intl.message(
      'Weekly',
      name: 'weekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `Yearly`
  String get yearly {
    return Intl.message(
      'Yearly',
      name: 'yearly',
      desc: '',
      args: [],
    );
  }

  /// `No end date`
  String get noEndDate {
    return Intl.message(
      'No end date',
      name: 'noEndDate',
      desc: '',
      args: [],
    );
  }

  /// `End date`
  String get endDate {
    return Intl.message(
      'End date',
      name: 'endDate',
      desc: '',
      args: [],
    );
  }

  /// `Every other week`
  String get everyOtherWeek {
    return Intl.message(
      'Every other week',
      name: 'everyOtherWeek',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one day.`
  String get recurringDataEmptyErrorMessage {
    return Intl.message(
      'Select at least one day.',
      name: 'recurringDataEmptyErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `You must enter an end date.`
  String get endDateNotSpecifiedErrorMessage {
    return Intl.message(
      'You must enter an end date.',
      name: 'endDateNotSpecifiedErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get selectAll {
    return Intl.message(
      'Select all',
      name: 'selectAll',
      desc: '',
      args: [],
    );
  }

  /// `Deselect all`
  String get deselectAll {
    return Intl.message(
      'Deselect all',
      name: 'deselectAll',
      desc: '',
      args: [],
    );
  }

  /// `Mon`
  String get mo {
    return Intl.message(
      'Mon',
      name: 'mo',
      desc: '',
      args: [],
    );
  }

  /// `Tue`
  String get tu {
    return Intl.message(
      'Tue',
      name: 'tu',
      desc: '',
      args: [],
    );
  }

  /// `Wed`
  String get we {
    return Intl.message(
      'Wed',
      name: 'we',
      desc: '',
      args: [],
    );
  }

  /// `Thu`
  String get th {
    return Intl.message(
      'Thu',
      name: 'th',
      desc: '',
      args: [],
    );
  }

  /// `Fri`
  String get fr {
    return Intl.message(
      'Fri',
      name: 'fr',
      desc: '',
      args: [],
    );
  }

  /// `Sat`
  String get sa {
    return Intl.message(
      'Sat',
      name: 'sa',
      desc: '',
      args: [],
    );
  }

  /// `Sun`
  String get su {
    return Intl.message(
      'Sun',
      name: 'su',
      desc: '',
      args: [],
    );
  }

  /// `Extra`
  String get extra {
    return Intl.message(
      'Extra',
      name: 'extra',
      desc: '',
      args: [],
    );
  }

  /// `Select extra function`
  String get infoType {
    return Intl.message(
      'Select extra function',
      name: 'infoType',
      desc: '',
      args: [],
    );
  }

  /// `Select extra function`
  String get selectInfoType {
    return Intl.message(
      'Select extra function',
      name: 'selectInfoType',
      desc: '',
      args: [],
    );
  }

  /// `No extra function selected`
  String get infoTypeNone {
    return Intl.message(
      'No extra function selected',
      name: 'infoTypeNone',
      desc: '',
      args: [],
    );
  }

  /// `Add checklist`
  String get addChecklist {
    return Intl.message(
      'Add checklist',
      name: 'addChecklist',
      desc: '',
      args: [],
    );
  }

  /// `Add note`
  String get addNote {
    return Intl.message(
      'Add note',
      name: 'addNote',
      desc: '',
      args: [],
    );
  }

  /// `Type something…`
  String get typeSomething {
    return Intl.message(
      'Type something…',
      name: 'typeSomething',
      desc: '',
      args: [],
    );
  }

  /// `Enter text`
  String get enterText {
    return Intl.message(
      'Enter text',
      name: 'enterText',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `Select from library`
  String get selectFromLibrary {
    return Intl.message(
      'Select from library',
      name: 'selectFromLibrary',
      desc: '',
      args: [],
    );
  }

  /// `Add new`
  String get addNew {
    return Intl.message(
      'Add new',
      name: 'addNew',
      desc: '',
      args: [],
    );
  }

  /// `Task`
  String get task {
    return Intl.message(
      'Task',
      name: 'task',
      desc: '',
      args: [],
    );
  }

  /// `Enter task`
  String get enterTask {
    return Intl.message(
      'Enter task',
      name: 'enterTask',
      desc: '',
      args: [],
    );
  }

  /// `Screen brightness`
  String get screenBrightness {
    return Intl.message(
      'Screen brightness',
      name: 'screenBrightness',
      desc: '',
      args: [],
    );
  }

  /// `Battery`
  String get battery {
    return Intl.message(
      'Battery',
      name: 'battery',
      desc: '',
      args: [],
    );
  }

  /// `Click Sound`
  String get clickSound {
    return Intl.message(
      'Click Sound',
      name: 'clickSound',
      desc: '',
      args: [],
    );
  }

  /// `Volume for alarm`
  String get volumeAlarm {
    return Intl.message(
      'Volume for alarm',
      name: 'volumeAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Volume for media`
  String get volumeMedia {
    return Intl.message(
      'Volume for media',
      name: 'volumeMedia',
      desc: '',
      args: [],
    );
  }

  /// `Wi-Fi`
  String get wifi {
    return Intl.message(
      'Wi-Fi',
      name: 'wifi',
      desc: '',
      args: [],
    );
  }

  /// `Not connected`
  String get notConnected {
    return Intl.message(
      'Not connected',
      name: 'notConnected',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get connected {
    return Intl.message(
      'Connected',
      name: 'connected',
      desc: '',
      args: [],
    );
  }

  /// `Connected, no internet`
  String get connectedNoInternet {
    return Intl.message(
      'Connected, no internet',
      name: 'connectedNoInternet',
      desc: '',
      args: [],
    );
  }

  /// `Screen timeout`
  String get screenTimeout {
    return Intl.message(
      'Screen timeout',
      name: 'screenTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Always on`
  String get alwaysOn {
    return Intl.message(
      'Always on',
      name: 'alwaysOn',
      desc: '',
      args: [],
    );
  }

  /// `Keep screen awake when charging`
  String get keepScreenAwakeWhileCharging {
    return Intl.message(
      'Keep screen awake when charging',
      name: 'keepScreenAwakeWhileCharging',
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

  /// `Day Calendar`
  String get calendarView {
    return Intl.message(
      'Day Calendar',
      name: 'calendarView',
      desc: '',
      args: [],
    );
  }

  /// `1 time pillar`
  String get oneTimePillarView {
    return Intl.message(
      '1 time pillar',
      name: 'oneTimePillarView',
      desc: '',
      args: [],
    );
  }

  /// `2 time pillars`
  String get twoTimePillarsView {
    return Intl.message(
      '2 time pillars',
      name: 'twoTimePillarsView',
      desc: '',
      args: [],
    );
  }

  /// `List`
  String get listView {
    return Intl.message(
      'List',
      name: 'listView',
      desc: '',
      args: [],
    );
  }

  /// `Time pillar settings`
  String get timepillarSettings {
    return Intl.message(
      'Time pillar settings',
      name: 'timepillarSettings',
      desc: '',
      args: [],
    );
  }

  /// `Activity duration`
  String get activityDuration {
    return Intl.message(
      'Activity duration',
      name: 'activityDuration',
      desc: '',
      args: [],
    );
  }

  /// `Dots`
  String get dots {
    return Intl.message(
      'Dots',
      name: 'dots',
      desc: '',
      args: [],
    );
  }

  /// `Edge`
  String get edge {
    return Intl.message(
      'Edge',
      name: 'edge',
      desc: '',
      args: [],
    );
  }

  /// `Simple`
  String get monthCalendarGrid {
    return Intl.message(
      'Simple',
      name: 'monthCalendarGrid',
      desc: '',
      args: [],
    );
  }

  /// `Detailed`
  String get monthCalendarPreview {
    return Intl.message(
      'Detailed',
      name: 'monthCalendarPreview',
      desc: '',
      args: [],
    );
  }

  /// `Speech support`
  String get textToSpeech {
    return Intl.message(
      'Speech support',
      name: 'textToSpeech',
      desc: '',
      args: [],
    );
  }

  /// `Tap and hold for speech support`
  String get longpressToSpeak {
    return Intl.message(
      'Tap and hold for speech support',
      name: 'longpressToSpeak',
      desc: '',
      args: [],
    );
  }

  /// `Tap and hold about 1 second on any function to get it read to by speech synthesis`
  String get longPressInfoText {
    return Intl.message(
      'Tap and hold about 1 second on any function to get it read to by speech synthesis',
      name: 'longPressInfoText',
      desc: '',
      args: [],
    );
  }

  /// `Display`
  String get display {
    return Intl.message(
      'Display',
      name: 'display',
      desc: '',
      args: [],
    );
  }

  /// `View mode`
  String get viewMode {
    return Intl.message(
      'View mode',
      name: 'viewMode',
      desc: '',
      args: [],
    );
  }

  /// `Day interval`
  String get dayInterval {
    return Intl.message(
      'Day interval',
      name: 'dayInterval',
      desc: '',
      args: [],
    );
  }

  /// `Interval`
  String get interval {
    return Intl.message(
      'Interval',
      name: 'interval',
      desc: '',
      args: [],
    );
  }

  /// `Intervals`
  String get intervals {
    return Intl.message(
      'Intervals',
      name: 'intervals',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get viewDay {
    return Intl.message(
      'Day',
      name: 'viewDay',
      desc: '',
      args: [],
    );
  }

  /// `Day and night`
  String get dayAndNight {
    return Intl.message(
      'Day and night',
      name: 'dayAndNight',
      desc: '',
      args: [],
    );
  }

  /// `Timeline zoom`
  String get timelineZoom {
    return Intl.message(
      'Timeline zoom',
      name: 'timelineZoom',
      desc: '',
      args: [],
    );
  }

  /// `Small`
  String get small {
    return Intl.message(
      'Small',
      name: 'small',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get medium {
    return Intl.message(
      'Medium',
      name: 'medium',
      desc: '',
      args: [],
    );
  }

  /// `Large`
  String get large {
    return Intl.message(
      'Large',
      name: 'large',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message(
      'Calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `Functions`
  String get functions {
    return Intl.message(
      'Functions',
      name: 'functions',
      desc: '',
      args: [],
    );
  }

  /// `Image picker`
  String get imagePicker {
    return Intl.message(
      'Image picker',
      name: 'imagePicker',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Day Calendar`
  String get dayCalendar {
    return Intl.message(
      'Day Calendar',
      name: 'dayCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Week Calendar`
  String get weekCalendar {
    return Intl.message(
      'Week Calendar',
      name: 'weekCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Month Calendar`
  String get monthCalendar {
    return Intl.message(
      'Month Calendar',
      name: 'monthCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Activity View`
  String get activityView {
    return Intl.message(
      'Activity View',
      name: 'activityView',
      desc: '',
      args: [],
    );
  }

  /// `Add activity`
  String get addActivity {
    return Intl.message(
      'Add activity',
      name: 'addActivity',
      desc: '',
      args: [],
    );
  }

  /// `Alarm settings`
  String get alarmSettings {
    return Intl.message(
      'Alarm settings',
      name: 'alarmSettings',
      desc: '',
      args: [],
    );
  }

  /// `Non checkable activities`
  String get nonCheckableActivities {
    return Intl.message(
      'Non checkable activities',
      name: 'nonCheckableActivities',
      desc: '',
      args: [],
    );
  }

  /// `Checkable activities`
  String get checkableActivities {
    return Intl.message(
      'Checkable activities',
      name: 'checkableActivities',
      desc: '',
      args: [],
    );
  }

  /// `Alarm time`
  String get alarmTime {
    return Intl.message(
      'Alarm time',
      name: 'alarmTime',
      desc: '',
      args: [],
    );
  }

  /// `Alert`
  String get alert {
    return Intl.message(
      'Alert',
      name: 'alert',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get defaultSound {
    return Intl.message(
      'Default',
      name: 'defaultSound',
      desc: '',
      args: [],
    );
  }

  /// `- No sound -`
  String get noSound {
    return Intl.message(
      '- No sound -',
      name: 'noSound',
      desc: '',
      args: [],
    );
  }

  /// `Show Disable alarms`
  String get showDisableAlarms {
    return Intl.message(
      'Show Disable alarms',
      name: 'showDisableAlarms',
      desc: '',
      args: [],
    );
  }

  /// `Show week number`
  String get showWeekNumber {
    return Intl.message(
      'Show week number',
      name: 'showWeekNumber',
      desc: '',
      args: [],
    );
  }

  /// `Show year`
  String get showYear {
    return Intl.message(
      'Show year',
      name: 'showYear',
      desc: '',
      args: [],
    );
  }

  /// `Show month and year`
  String get showMonthAndYear {
    return Intl.message(
      'Show month and year',
      name: 'showMonthAndYear',
      desc: '',
      args: [],
    );
  }

  /// `Every day (7)`
  String get everyDay {
    return Intl.message(
      'Every day (7)',
      name: 'everyDay',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }

  /// `View settings`
  String get viewSettings {
    return Intl.message(
      'View settings',
      name: 'viewSettings',
      desc: '',
      args: [],
    );
  }

  /// `Type of display`
  String get typeOfDisplay {
    return Intl.message(
      'Type of display',
      name: 'typeOfDisplay',
      desc: '',
      args: [],
    );
  }

  /// `Timeline length`
  String get timelineLength {
    return Intl.message(
      'Timeline length',
      name: 'timelineLength',
      desc: '',
      args: [],
    );
  }

  /// `Weekdays (5)`
  String get weekdays {
    return Intl.message(
      'Weekdays (5)',
      name: 'weekdays',
      desc: '',
      args: [],
    );
  }

  /// `Captions`
  String get captions {
    return Intl.message(
      'Captions',
      name: 'captions',
      desc: '',
      args: [],
    );
  }

  /// `Columns`
  String get columns {
    return Intl.message(
      'Columns',
      name: 'columns',
      desc: '',
      args: [],
    );
  }

  /// `Headings`
  String get headings {
    return Intl.message(
      'Headings',
      name: 'headings',
      desc: '',
      args: [],
    );
  }

  /// `Allow passed start time`
  String get allowPassedStartTime {
    return Intl.message(
      'Allow passed start time',
      name: 'allowPassedStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Add recurring activity`
  String get addRecurringActivity {
    return Intl.message(
      'Add recurring activity',
      name: 'addRecurringActivity',
      desc: '',
      args: [],
    );
  }

  /// `Show end time`
  String get showEndTime {
    return Intl.message(
      'Show end time',
      name: 'showEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Show alarm`
  String get showAlarm {
    return Intl.message(
      'Show alarm',
      name: 'showAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Show vibration`
  String get showVibrationAlarm {
    return Intl.message(
      'Show vibration',
      name: 'showVibrationAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Show silent alarm`
  String get showSilentAlarm {
    return Intl.message(
      'Show silent alarm',
      name: 'showSilentAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Show no alarm`
  String get showNoAlarm {
    return Intl.message(
      'Show no alarm',
      name: 'showNoAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Show alarm only at start time`
  String get showAlarmOnlyAtStartTime {
    return Intl.message(
      'Show alarm only at start time',
      name: 'showAlarmOnlyAtStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Show speech at alarm`
  String get showSpeechAtAlarm {
    return Intl.message(
      'Show speech at alarm',
      name: 'showSpeechAtAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Show reminders`
  String get showReminders {
    return Intl.message(
      'Show reminders',
      name: 'showReminders',
      desc: '',
      args: [],
    );
  }

  /// `Show select end date`
  String get showSelectEndDate {
    return Intl.message(
      'Show select end date',
      name: 'showSelectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Recurring`
  String get recurring {
    return Intl.message(
      'Recurring',
      name: 'recurring',
      desc: '',
      args: [],
    );
  }

  /// `Through Edit View`
  String get throughEditView {
    return Intl.message(
      'Through Edit View',
      name: 'throughEditView',
      desc: '',
      args: [],
    );
  }

  /// `Android Settings`
  String get androidSettings {
    return Intl.message(
      'Android Settings',
      name: 'androidSettings',
      desc: '',
      args: [],
    );
  }

  /// `Step-by-step`
  String get stepByStep {
    return Intl.message(
      'Step-by-step',
      name: 'stepByStep',
      desc: '',
      args: [],
    );
  }

  /// `Show templates`
  String get showTemplates {
    return Intl.message(
      'Show templates',
      name: 'showTemplates',
      desc: '',
      args: [],
    );
  }

  /// `Select name`
  String get selectName {
    return Intl.message(
      'Select name',
      name: 'selectName',
      desc: '',
      args: [],
    );
  }

  /// `Select date`
  String get selectDate {
    return Intl.message(
      'Select date',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  /// `Select type`
  String get selectType {
    return Intl.message(
      'Select type',
      name: 'selectType',
      desc: '',
      args: [],
    );
  }

  /// `Select all day`
  String get selectAllDay {
    return Intl.message(
      'Select all day',
      name: 'selectAllDay',
      desc: '',
      args: [],
    );
  }

  /// `Select category`
  String get selectCategory {
    return Intl.message(
      'Select category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select checkable`
  String get selectCheckable {
    return Intl.message(
      'Select checkable',
      name: 'selectCheckable',
      desc: '',
      args: [],
    );
  }

  /// `Select available for`
  String get selectAvailableFor {
    return Intl.message(
      'Select available for',
      name: 'selectAvailableFor',
      desc: '',
      args: [],
    );
  }

  /// `Select alarm`
  String get selectAlarm {
    return Intl.message(
      'Select alarm',
      name: 'selectAlarm',
      desc: '',
      args: [],
    );
  }

  /// `On an iPhone, alarm sounds can only be played for maximum 30 seconds`
  String get iOSAlarmTimeWarning {
    return Intl.message(
      'On an iPhone, alarm sounds can only be played for maximum 30 seconds',
      name: 'iOSAlarmTimeWarning',
      desc: '',
      args: [],
    );
  }

  /// `Select checklist`
  String get selectChecklist {
    return Intl.message(
      'Select checklist',
      name: 'selectChecklist',
      desc: '',
      args: [],
    );
  }

  /// `Select note`
  String get selectNote {
    return Intl.message(
      'Select note',
      name: 'selectNote',
      desc: '',
      args: [],
    );
  }

  /// `Select reminder`
  String get selectReminder {
    return Intl.message(
      'Select reminder',
      name: 'selectReminder',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Defaults`
  String get defaults {
    return Intl.message(
      'Defaults',
      name: 'defaults',
      desc: '',
      args: [],
    );
  }

  /// `Only applies to MEMOplanner Go`
  String get onlyAppliesToGo {
    return Intl.message(
      'Only applies to MEMOplanner Go',
      name: 'onlyAppliesToGo',
      desc: '',
      args: [],
    );
  }

  /// `Show ongoing activity in full screen`
  String get showOngoingActivityInFullScreen {
    return Intl.message(
      'Show ongoing activity in full screen',
      name: 'showOngoingActivityInFullScreen',
      desc: '',
      args: [],
    );
  }

  /// `Toolbar`
  String get toolbar {
    return Intl.message(
      'Toolbar',
      name: 'toolbar',
      desc: '',
      args: [],
    );
  }

  /// `Functions displayed in bottom of page`
  String get toolbarSettingsHint {
    return Intl.message(
      'Functions displayed in bottom of page',
      name: 'toolbarSettingsHint',
      desc: '',
      args: [],
    );
  }

  /// `Home screen`
  String get homeScreen {
    return Intl.message(
      'Home screen',
      name: 'homeScreen',
      desc: '',
      args: [],
    );
  }

  /// `View displayed when the home button is pressed`
  String get homeScreenSettingsHint {
    return Intl.message(
      'View displayed when the home button is pressed',
      name: 'homeScreenSettingsHint',
      desc: '',
      args: [],
    );
  }

  /// `Timeout`
  String get timeout {
    return Intl.message(
      'Timeout',
      name: 'timeout',
      desc: '',
      args: [],
    );
  }

  /// `Returns to the home screen after a period of inactivity`
  String get timeoutSettingsHint {
    return Intl.message(
      'Returns to the home screen after a period of inactivity',
      name: 'timeoutSettingsHint',
      desc: '',
      args: [],
    );
  }

  /// `No timeout`
  String get noTimeout {
    return Intl.message(
      'No timeout',
      name: 'noTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Activate Screensaver`
  String get activateScreensaver {
    return Intl.message(
      'Activate Screensaver',
      name: 'activateScreensaver',
      desc: '',
      args: [],
    );
  }

  /// `Only activate screensaver during night`
  String get onlyActivateScreensaverDuringNight {
    return Intl.message(
      'Only activate screensaver during night',
      name: 'onlyActivateScreensaverDuringNight',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to remove the Settings from the Menu? If you do, it will still be possible to access settings by clicking directly under the category symbols in the day calendar; left – right – left. This works even if they are hidden.`
  String get menuRemovalWarning {
    return Intl.message(
      'Do you really want to remove the Settings from the Menu? If you do, it will still be possible to access settings by clicking directly under the category symbols in the day calendar; left – right – left. This works even if they are hidden.',
      name: 'menuRemovalWarning',
      desc: '',
      args: [],
    );
  }

  /// `all menu items are disabled`
  String get menuItemsDisabled {
    return Intl.message(
      'all menu items are disabled',
      name: 'menuItemsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Select a day to view more details`
  String get selectADayToViewDetails {
    return Intl.message(
      'Select a day to view more details',
      name: 'selectADayToViewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Top Field`
  String get topField {
    return Intl.message(
      'Top Field',
      name: 'topField',
      desc: '',
      args: [],
    );
  }

  /// `Show browse buttons`
  String get showBrowseButtons {
    return Intl.message(
      'Show browse buttons',
      name: 'showBrowseButtons',
      desc: '',
      args: [],
    );
  }

  /// `Show weekday`
  String get showWeekday {
    return Intl.message(
      'Show weekday',
      name: 'showWeekday',
      desc: '',
      args: [],
    );
  }

  /// `Show time for day and night`
  String get showDayPeriod {
    return Intl.message(
      'Show time for day and night',
      name: 'showDayPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Show date`
  String get showDate {
    return Intl.message(
      'Show date',
      name: 'showDate',
      desc: '',
      args: [],
    );
  }

  /// `Show clock`
  String get showClock {
    return Intl.message(
      'Show clock',
      name: 'showClock',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Show Quarter Hour Watch bar`
  String get showQuarterHourWatchBar {
    return Intl.message(
      'Show Quarter Hour Watch bar',
      name: 'showQuarterHourWatchBar',
      desc: '',
      args: [],
    );
  }

  /// `Time on Quarter Hour bar`
  String get timeOnQuarterHourBar {
    return Intl.message(
      'Time on Quarter Hour bar',
      name: 'timeOnQuarterHourBar',
      desc: '',
      args: [],
    );
  }

  /// `Clock`
  String get clock {
    return Intl.message(
      'Clock',
      name: 'clock',
      desc: '',
      args: [],
    );
  }

  /// `Analogue + digital`
  String get analogueDigital {
    return Intl.message(
      'Analogue + digital',
      name: 'analogueDigital',
      desc: '',
      args: [],
    );
  }

  /// `Analogue`
  String get analogue {
    return Intl.message(
      'Analogue',
      name: 'analogue',
      desc: '',
      args: [],
    );
  }

  /// `Digital`
  String get digital {
    return Intl.message(
      'Digital',
      name: 'digital',
      desc: '',
      args: [],
    );
  }

  /// `Timeline`
  String get timeline {
    return Intl.message(
      'Timeline',
      name: 'timeline',
      desc: '',
      args: [],
    );
  }

  /// `early morning`
  String get earyMorning {
    return Intl.message(
      'early morning',
      name: 'earyMorning',
      desc: '',
      args: [],
    );
  }

  /// `12 hours format`
  String get twelveHourFormat {
    return Intl.message(
      '12 hours format',
      name: 'twelveHourFormat',
      desc: '',
      args: [],
    );
  }

  /// `One dot`
  String get oneDot {
    return Intl.message(
      'One dot',
      name: 'oneDot',
      desc: '',
      args: [],
    );
  }

  /// `Column of dots`
  String get columnOfDots {
    return Intl.message(
      'Column of dots',
      name: 'columnOfDots',
      desc: '',
      args: [],
    );
  }

  /// `Line across current time`
  String get lineAcrossCurrentTime {
    return Intl.message(
      'Line across current time',
      name: 'lineAcrossCurrentTime',
      desc: '',
      args: [],
    );
  }

  /// `Lines for each hour`
  String get linesForEachHour {
    return Intl.message(
      'Lines for each hour',
      name: 'linesForEachHour',
      desc: '',
      args: [],
    );
  }

  /// `Saturday and Sunday`
  String get saturdayAndSunday {
    return Intl.message(
      'Saturday and Sunday',
      name: 'saturdayAndSunday',
      desc: '',
      args: [],
    );
  }

  /// `Day colours`
  String get dayColours {
    return Intl.message(
      'Day colours',
      name: 'dayColours',
      desc: '',
      args: [],
    );
  }

  /// `No day colours`
  String get noDayColours {
    return Intl.message(
      'No day colours',
      name: 'noDayColours',
      desc: '',
      args: [],
    );
  }

  /// `Show categories`
  String get showCagetories {
    return Intl.message(
      'Show categories',
      name: 'showCagetories',
      desc: '',
      args: [],
    );
  }

  /// `Show colours`
  String get showColours {
    return Intl.message(
      'Show colours',
      name: 'showColours',
      desc: '',
      args: [],
    );
  }

  /// `Edit category`
  String get editCategory {
    return Intl.message(
      'Edit category',
      name: 'editCategory',
      desc: '',
      args: [],
    );
  }

  /// `Read out word when space bar is pressed`
  String get speakEveryWord {
    return Intl.message(
      'Read out word when space bar is pressed',
      name: 'speakEveryWord',
      desc: '',
      args: [],
    );
  }

  /// `Speech rate`
  String get speechRate {
    return Intl.message(
      'Speech rate',
      name: 'speechRate',
      desc: '',
      args: [],
    );
  }

  /// `Voice`
  String get voice {
    return Intl.message(
      'Voice',
      name: 'voice',
      desc: '',
      args: [],
    );
  }

  /// `No voices installed`
  String get noVoicesInstalled {
    return Intl.message(
      'No voices installed',
      name: 'noVoicesInstalled',
      desc: '',
      args: [],
    );
  }

  /// `Installing`
  String get installing {
    return Intl.message(
      'Installing',
      name: 'installing',
      desc: '',
      args: [],
    );
  }

  /// `Test of speech rate`
  String get testOfSpeechRate {
    return Intl.message(
      'Test of speech rate',
      name: 'testOfSpeechRate',
      desc: '',
      args: [],
    );
  }

  /// `Voices`
  String get voices {
    return Intl.message(
      'Voices',
      name: 'voices',
      desc: '',
      args: [],
    );
  }

  /// `Code protect`
  String get codeProtect {
    return Intl.message(
      'Code protect',
      name: 'codeProtect',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message(
      'Code',
      name: 'code',
      desc: '',
      args: [],
    );
  }

  /// `Code protect settings`
  String get codeProtectSettings {
    return Intl.message(
      'Code protect settings',
      name: 'codeProtectSettings',
      desc: '',
      args: [],
    );
  }

  /// `Code protect this view`
  String get codeProtectThisView {
    return Intl.message(
      'Code protect this view',
      name: 'codeProtectThisView',
      desc: '',
      args: [],
    );
  }

  /// `Code protect Android Settings`
  String get codeProtectAndroidSettings {
    return Intl.message(
      'Code protect Android Settings',
      name: 'codeProtectAndroidSettings',
      desc: '',
      args: [],
    );
  }

  /// `Enter code`
  String get enterCode {
    return Intl.message(
      'Enter code',
      name: 'enterCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter your code to access`
  String get enterYourCodeToAccess {
    return Intl.message(
      'Enter your code to access',
      name: 'enterYourCodeToAccess',
      desc: '',
      args: [],
    );
  }

  /// `Enter new code`
  String get enterNewCode {
    return Intl.message(
      'Enter new code',
      name: 'enterNewCode',
      desc: '',
      args: [],
    );
  }

  /// `Confirm code`
  String get confirmCode {
    return Intl.message(
      'Confirm code',
      name: 'confirmCode',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect code`
  String get incorrectCode {
    return Intl.message(
      'Incorrect code',
      name: 'incorrectCode',
      desc: '',
      args: [],
    );
  }

  /// `Permissions`
  String get permissions {
    return Intl.message(
      'Permissions',
      name: 'permissions',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Access to Photos`
  String get accessToPhotos {
    return Intl.message(
      'Access to Photos',
      name: 'accessToPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Access to Camera`
  String get accessToCamera {
    return Intl.message(
      'Access to Camera',
      name: 'accessToCamera',
      desc: '',
      args: [],
    );
  }

  /// `Allow notifications`
  String get allowNotifications {
    return Intl.message(
      'Allow notifications',
      name: 'allowNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Allow notifications to be able to get alarms and reminders from activities. You can do that from the`
  String get allowNotificationsDescription1 {
    return Intl.message(
      'Allow notifications to be able to get alarms and reminders from activities. You can do that from the',
      name: 'allowNotificationsDescription1',
      desc: '',
      args: [],
    );
  }

  /// `settings`
  String get settingsLink {
    return Intl.message(
      'settings',
      name: 'settingsLink',
      desc: '',
      args: [],
    );
  }

  /// `Turn off notifications?`
  String get turnOffNotifications {
    return Intl.message(
      'Turn off notifications?',
      name: 'turnOffNotifications',
      desc: '',
      args: [],
    );
  }

  /// `You will no longer be able to get alarms and reminders from activities.`
  String get turnOffNotificationsBody {
    return Intl.message(
      'You will no longer be able to get alarms and reminders from activities.',
      name: 'turnOffNotificationsBody',
      desc: '',
      args: [],
    );
  }

  /// `Allow notifications to be able to get alarms and reminders from activities.`
  String get notificationsWarningHintText {
    return Intl.message(
      'Allow notifications to be able to get alarms and reminders from activities.',
      name: 'notificationsWarningHintText',
      desc: '',
      args: [],
    );
  }

  /// `Allow notifications from the settings to be able to receive alarms and reminders.`
  String get notificationsWarningText {
    return Intl.message(
      'Allow notifications from the settings to be able to receive alarms and reminders.',
      name: 'notificationsWarningText',
      desc: '',
      args: [],
    );
  }

  /// `Full screen alarm`
  String get fullScreenAlarm {
    return Intl.message(
      'Full screen alarm',
      name: 'fullScreenAlarm',
      desc: '',
      args: [],
    );
  }

  /// `You will be redirect to the Android settings.`
  String get redirectToAndroidSettings {
    return Intl.message(
      'You will be redirect to the Android settings.',
      name: 'redirectToAndroidSettings',
      desc: '',
      args: [],
    );
  }

  /// `Allow this permission to be able to get full screen alarm of activities`
  String get fullScreenAlarmInfo {
    return Intl.message(
      'Allow this permission to be able to get full screen alarm of activities',
      name: 'fullScreenAlarmInfo',
      desc: '',
      args: [],
    );
  }

  /// `Allow`
  String get allow {
    return Intl.message(
      'Allow',
      name: 'allow',
      desc: '',
      args: [],
    );
  }

  /// `Erik's birthday party`
  String get previewActivityTitle {
    return Intl.message(
      'Erik\'s birthday party',
      name: 'previewActivityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Allow access to photos to be able to use photos from the device.`
  String get allowAccessPhotosBody {
    return Intl.message(
      'Allow access to photos to be able to use photos from the device.',
      name: 'allowAccessPhotosBody',
      desc: '',
      args: [],
    );
  }

  /// `Allow access to camera to be able to take a photo from the device.`
  String get allowAccessCameraBody {
    return Intl.message(
      'Allow access to camera to be able to take a photo from the device.',
      name: 'allowAccessCameraBody',
      desc: '',
      args: [],
    );
  }

  /// `You can always do that later from the`
  String get allowAccessBody2 {
    return Intl.message(
      'You can always do that later from the',
      name: 'allowAccessBody2',
      desc: '',
      args: [],
    );
  }

  /// `Access to Microphone`
  String get accessToMicrophone {
    return Intl.message(
      'Access to Microphone',
      name: 'accessToMicrophone',
      desc: '',
      args: [],
    );
  }

  /// `Allow access to microphone to be able to record speech from the device`
  String get allowAccessMicrophoneBody {
    return Intl.message(
      'Allow access to microphone to be able to record speech from the device',
      name: 'allowAccessMicrophoneBody',
      desc: '',
      args: [],
    );
  }

  /// `Ignore battery optimizations`
  String get ignoreBatteryOptimizations {
    return Intl.message(
      'Ignore battery optimizations',
      name: 'ignoreBatteryOptimizations',
      desc: '',
      args: [],
    );
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

  /// `About`
  String get aboutMemoplanner {
    return Intl.message(
      'About',
      name: 'aboutMemoplanner',
      desc: '',
      args: [],
    );
  }

  /// `License number`
  String get licenseNumber {
    return Intl.message(
      'License number',
      name: 'licenseNumber',
      desc: '',
      args: [],
    );
  }

  /// `License valid date`
  String get licenseValidDate {
    return Intl.message(
      'License valid date',
      name: 'licenseValidDate',
      desc: '',
      args: [],
    );
  }

  /// `Logged in user account`
  String get loggedInUser {
    return Intl.message(
      'Logged in user account',
      name: 'loggedInUser',
      desc: '',
      args: [],
    );
  }

  /// `About the device`
  String get aboutDevice {
    return Intl.message(
      'About the device',
      name: 'aboutDevice',
      desc: '',
      args: [],
    );
  }

  /// `Support id`
  String get supportId {
    return Intl.message(
      'Support id',
      name: 'supportId',
      desc: '',
      args: [],
    );
  }

  /// `Device name`
  String get deviceName {
    return Intl.message(
      'Device name',
      name: 'deviceName',
      desc: '',
      args: [],
    );
  }

  /// `Serial number`
  String get serialNumber {
    return Intl.message(
      'Serial number',
      name: 'serialNumber',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Android version`
  String get androidVersion {
    return Intl.message(
      'Android version',
      name: 'androidVersion',
      desc: '',
      args: [],
    );
  }

  /// `iOS version`
  String get iosVersion {
    return Intl.message(
      'iOS version',
      name: 'iosVersion',
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

  /// `Search for update`
  String get searchForUpdate {
    return Intl.message(
      'Search for update',
      name: 'searchForUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Photo calendar`
  String get photoCalendar {
    return Intl.message(
      'Photo calendar',
      name: 'photoCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Countdown`
  String get countdown {
    return Intl.message(
      'Countdown',
      name: 'countdown',
      desc: '',
      args: [],
    );
  }

  /// `Quick settings`
  String get quickSettingsMenu {
    return Intl.message(
      'Quick settings',
      name: 'quickSettingsMenu',
      desc: '',
      args: [],
    );
  }

  /// `All photos`
  String get allPhotos {
    return Intl.message(
      'All photos',
      name: 'allPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to add this photo to Photo-calendar?`
  String get addToPhotoCalendarQuestion {
    return Intl.message(
      'Do you want to add this photo to Photo-calendar?',
      name: 'addToPhotoCalendarQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to remove this photo from Photo-calendar?`
  String get removeFromPhotoCalendarQuestion {
    return Intl.message(
      'Do you want to remove this photo from Photo-calendar?',
      name: 'removeFromPhotoCalendarQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this photo?`
  String get doYouWantToDeleteThisPhoto {
    return Intl.message(
      'Are you sure you want to delete this photo?',
      name: 'doYouWantToDeleteThisPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Install starter set?`
  String get installStarterSet {
    return Intl.message(
      'Install starter set?',
      name: 'installStarterSet',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to import a default set of data with activities, timers, checklists and image archive?`
  String get doYouWantToImportADefaultSet {
    return Intl.message(
      'Do you want to import a default set of data with activities, timers, checklists and image archive?',
      name: 'doYouWantToImportADefaultSet',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to`
  String get welcomeTo {
    return Intl.message(
      'Welcome to',
      name: 'welcomeTo',
      desc: '',
      args: [],
    );
  }

  /// `Get started`
  String get getStarted {
    return Intl.message(
      'Get started',
      name: 'getStarted',
      desc: '',
      args: [],
    );
  }

  /// `To use`
  String get readAndAgree1 {
    return Intl.message(
      'To use',
      name: 'readAndAgree1',
      desc: '',
      args: [],
    );
  }

  /// `, please read and agree to the terms of use and privacy policy.`
  String get readAndAgree2 {
    return Intl.message(
      ', please read and agree to the terms of use and privacy policy.',
      name: 'readAndAgree2',
      desc: '',
      args: [],
    );
  }

  /// `I have read and agree to the`
  String get acceptTerms {
    return Intl.message(
      'I have read and agree to the',
      name: 'acceptTerms',
      desc: '',
      args: [],
    );
  }

  /// `terms of use`
  String get termsOfUse {
    return Intl.message(
      'terms of use',
      name: 'termsOfUse',
      desc: '',
      args: [],
    );
  }

  /// `intl/terms-of-use`
  String get termsOfUseUrl {
    return Intl.message(
      'intl/terms-of-use',
      name: 'termsOfUseUrl',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `intl/policy-for-the-processing-of-personal-data`
  String get privacyPolicyUrl {
    return Intl.message(
      'intl/policy-for-the-processing-of-personal-data',
      name: 'privacyPolicyUrl',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to discard your changes?`
  String get confirmDiscard {
    return Intl.message(
      'Are you sure you want to discard your changes?',
      name: 'confirmDiscard',
      desc: '',
      args: [],
    );
  }

  /// `Keep editing`
  String get keepEditing {
    return Intl.message(
      'Keep editing',
      name: 'keepEditing',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get discard {
    return Intl.message(
      'Discard',
      name: 'discard',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to reset the device?`
  String get resetDeviceQuestion {
    return Intl.message(
      'Do you want to reset the device?',
      name: 'resetDeviceQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Factory reset`
  String get factoryReset {
    return Intl.message(
      'Factory reset',
      name: 'factoryReset',
      desc: '',
      args: [],
    );
  }

  /// `Factory reset and reinstall MEMOplanner software (instructions required).`
  String get factoryResetDescription {
    return Intl.message(
      'Factory reset and reinstall MEMOplanner software (instructions required).',
      name: 'factoryResetDescription',
      desc: '',
      args: [],
    );
  }

  /// `Clear MEMOplanner data`
  String get clearData {
    return Intl.message(
      'Clear MEMOplanner data',
      name: 'clearData',
      desc: '',
      args: [],
    );
  }

  /// `Clear app data and go to startup guide.`
  String get clearDataDescription {
    return Intl.message(
      'Clear app data and go to startup guide.',
      name: 'clearDataDescription',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to start factory reset?`
  String get confirmFactoryReset {
    return Intl.message(
      'Do you want to start factory reset?',
      name: 'confirmFactoryReset',
      desc: '',
      args: [],
    );
  }

  /// `After factory reset is finished you will need to reinstall MEMOplanner software. Follow the reconditioning instructions to do that.`
  String get confirmFactoryResetDescription {
    return Intl.message(
      'After factory reset is finished you will need to reinstall MEMOplanner software. Follow the reconditioning instructions to do that.',
      name: 'confirmFactoryResetDescription',
      desc: '',
      args: [],
    );
  }

  /// `Factory reset failed, please try again later.`
  String get factoryResetFailed {
    return Intl.message(
      'Factory reset failed, please try again later.',
      name: 'factoryResetFailed',
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

  /// `Select template`
  String get selectTemplate {
    return Intl.message(
      'Select template',
      name: 'selectTemplate',
      desc: '',
      args: [],
    );
  }

  /// `No recurrence`
  String get noRecurrence {
    return Intl.message(
      'No recurrence',
      name: 'noRecurrence',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `Once`
  String get once {
    return Intl.message(
      'Once',
      name: 'once',
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
