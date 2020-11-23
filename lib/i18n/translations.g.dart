// GENERATED CODE - DO NOT MODIFY BY HAND

// instead, modify lib/i18n/translations.tsv and run
// > flutter packages pub run build_runner build

import 'dart:ui';

class Locales {
  static final language = <Locale, Translated>{
    Locale('en'): EN(),
    Locale('sv'): SV()
  };
}

abstract class Translated {
  final String userName = 'Username or email';

  final String password = 'Password';

  final String loginHint =
      'Use your MEMOplanner username and password to login';

  final String login = 'Log in';

  final String logout = 'Log out';

  final String wrongCredentials =
      "Username or password doesn\'t match.\n\nVerify your credentials and try again.";

  final String noConnection =
      'The device is not connected to the Internet. Check your Internet connection.';

  final String noLicense = 'This account has no valid license.';

  final String licenseExpired = 'License expired';

  final String licenseExpiredMessage =
      'Your license has expired and Memoplanner can no longer be used. Contact your supplier to extend the license.';

  final String fullDay = 'All day';

  final String morning = 'morning';

  final String forenoon = 'forenoon';

  final String lunch = 'Lunch';

  final String afternoon = 'afternoon';

  final String evening = 'evening';

  final String night = 'night';

  final String today = 'Today';

  final String days = 'days';

  final String day = 'day';

  final String hours = 'hours';

  final String hour = 'hour';

  final String h = 'h';

  final String minutes = 'minutes';

  final String minute = 'minute';

  final String min = 'min';

  final String am = 'AM';

  final String pm = 'PM';

  final String reminders = 'Reminders';

  final String alarm = 'Alarm';

  final String endsNow = 'Ends now';

  final String startsNow = 'Starts now';

  final String noActivities = 'No activities for today';

  final String left = 'Left';

  final String right = 'Right';

  final String check = 'Check';

  final String uncheck = 'Undo';

  final String fromBasicActivity = 'From Basic Activity';

  final String createActivity = 'New activity';

  final String basicActivities = 'Select Basic Activity';

  final String deleteActivity = 'Do you want to delete this activity?';

  final String appyTo = 'Edit recurring activity';

  final String onlyThisDay = 'Only this day';

  final String allDays = 'All days';

  final String thisDayAndForward = 'This day and forward';

  final String checkActivityQuestion = 'Completed?';

  final String unCheckActivityQuestion =
      'Do you want to uncheck the activity? ';

  final String inTimePre = 'in';

  final String timeAgoPre = '';

  final String timeAgoPost = 'ago';

  final String checklistDoneInfo =
      'All checklist tasks in your activity are completed. Do you want to complete the activity?';

  final String menu = 'Menu';

  final String cancel = 'Cancel';

  final String newActivity = 'New';

  final String editActivity = 'Edit activity';

  final String category = 'Category (left or right)';

  final String checkable = 'Checkable';

  final String deleteAfter = 'Delete after';

  final String name = 'Name';

  final String picture = 'Image';

  final String date = 'Date';

  final String startTime = 'Start time';

  final String endTime = 'End time';

  final String noEndTime = 'No end time';

  final String missingTitleOrImageAndStartTime =
      'Your activity should contain an image or name and start time.';

  final String missingTitleOrImage = 'An activity needs an image or a name.';

  final String missingStartTime = 'You must enter a start time.';

  final String startTimeBeforeNow =
      'You have selected a start time which has already passed. This is not allowed.';

  final String availableFor = 'Available for';

  final String activityAvailableFor = 'Available for';

  final String meAndSupportPersons = 'Me and support persons';

  final String onlyMe = 'Only me';

  final String selectAlarmType = 'Select alarm';

  final String alarmAndVibration = 'Alarm + vibration';

  final String vibration = 'Vibration';

  final String noAlarm = 'No alarm';

  final String silentAlarm = 'Silent alarm';

  final String alarmOnlyAtStartTime = 'Alarm only at Start time';

  final String selectPicture = 'Select image';

  final String removePicture = 'Remove image';

  final String imageArchive = 'Image Archive';

  final String myPhotos = 'My photos';

  final String takeNewPhoto = 'Take new photo';

  final String recurrence = 'Recurrence';

  final String once = 'Once';

  final String weekly = 'Weekly';

  final String monthly = 'Monthly';

  final String yearly = 'Yearly';

  final String noEndDate = 'No end date';

  final String endDate = 'End date';

  final String everyOtherWeek = 'Every other week';

  final String recurringDataEmptyErrorMessage = 'Select at least on day.';

  final String mo = 'Mon';

  final String tu = 'Tue';

  final String we = 'Wed';

  final String th = 'Thu';

  final String fr = 'Fri';

  final String sa = 'Sat';

  final String su = 'Sun';

  final String infoType = 'Select extra function';

  final String selectInfoType = 'Select extra function';

  final String infoTypeNone = 'No extra function selected';

  final String infoTypeChecklist = 'Add checklist';

  final String infoTypeNote = 'Add note';

  final String typeSomething = 'Type something…';

  final String clear = 'Clear';

  final String selectFromLibrary = 'Select from library';

  final String addNew = 'Add new';

  final String task = 'Enter task';

  final String remove = 'Delete';

  final String calendarView = 'Day Calendar';

  final String timePillarView = '1 timepillar';

  final String listView = 'List';

  final String timepillarSettings = 'Timepillar settings';

  final String activityDuration = 'Activity duration';

  final String dots = 'Dots';

  final String edge = 'Edge';

  final String preview = 'Preview';

  final String textToSpeech = 'Speech support';

  final String longpressToSpeak = 'Long press to speak';

  final String longPressInfoText =
      'Make a long press on any text or object with text to speak it loudly';

  final String permissions = 'Permissions';

  final String notifications = 'Notifications';

  final String accessToPhotos = 'Access to Photos';

  final String accessToCamera = 'Access to Camera';

  final String allowNotifications = 'Allow notifications';

  final String allowNotificationsDescription1 =
      'Allow notifications to be able to get alarms and reminders from activities. You can do that from the ';

  final String settingsLink = 'settings';

  final String turnOffNotifications = 'Turn off notifications?';

  final String turnOffNotificationsBody =
      'You will no longer be able to get alarms and reminders from activities.';

  final String notificationsWarningHintText =
      'Allow notifications to be able to get alarms and reminders from activities.';

  final String notificationsWarningText =
      'Allow notifications from the settings to be able to receive alarms and reminders.';

  final String fullScreenAlarm = 'Full screen alarm';

  final String redirectToAndroidSettings =
      'You will be redirect to the Android settings.';

  final String fullScreenAlarmInfo =
      'Allow this permission to be able to get full screen alarm of activities';

  final String allow = 'Allow';

  final String previewActivityTitle = "Erik's birthday party";

  final String allowAccessPhotosBody =
      'Allow access to photos to be able to use photos from the device.';

  final String allowAccessCameraBody =
      'Allow access to camera to be able to take a photo from the device.';

  final String allowAccessBody2 = ' You can always do that later from the ';
}

class EN extends Translated {}

class SV extends Translated {
  @override
  final String userName = 'Användarnamn';

  @override
  final String password = 'Lösenord';

  @override
  final String loginHint =
      'Logga in med samma användarnamn och lösenord som till din MEMOplanner';

  @override
  final String login = 'Logga in';

  @override
  final String logout = 'Logga ut';

  @override
  final String wrongCredentials =
      'Användarnamn eller lösenord stämmer inte.\n\nKontrollera att du har skrivit rätt och försök igen.';

  @override
  final String noConnection =
      'Enheten är inte ansluten till internet. Kontrollera din internetanslutning.';

  @override
  final String noLicense =
      'Det här kontot saknar giltig licens. Du kan därför inte logga in.';

  @override
  final String licenseExpired = 'Licensen har gått ut';

  @override
  final String licenseExpiredMessage =
      'Licensen har gått ut och Memoplanner kan därför inte längre användas. Kontakta din förskrivare om du vill förlänga licensen.';

  @override
  final String fullDay = 'Heldag';

  @override
  final String morning = 'morgon';

  @override
  final String forenoon = 'förmiddag';

  @override
  final String lunch = 'Lunch';

  @override
  final String afternoon = 'eftermiddag';

  @override
  final String evening = 'kväll';

  @override
  final String night = 'natt';

  @override
  final String today = 'Idag';

  @override
  final String days = 'dagar';

  @override
  final String day = 'dag';

  @override
  final String hours = 'timmar';

  @override
  final String hour = 'timme';

  @override
  final String h = 't';

  @override
  final String minutes = 'minuter';

  @override
  final String minute = 'minut';

  @override
  final String min = 'min';

  @override
  final String am = 'fm';

  @override
  final String pm = 'em';

  @override
  final String reminders = 'Påminnelser';

  @override
  final String alarm = 'Larm';

  @override
  final String endsNow = 'Slutar nu';

  @override
  final String startsNow = 'Börjar nu';

  @override
  final String noActivities = 'Inga aktiviteter idag';

  @override
  final String left = 'Vänster';

  @override
  final String right = 'Höger';

  @override
  final String check = 'Kvittera';

  @override
  final String uncheck = 'Ångra';

  @override
  final String fromBasicActivity = 'Från basaktivitet';

  @override
  final String createActivity = 'Ny aktivitet';

  @override
  final String basicActivities = 'Välj basaktivitet';

  @override
  final String deleteActivity =
      'Är du säker på att du vill ta bort aktiviteten?';

  @override
  final String appyTo = 'Ändra återkommande aktivitet';

  @override
  final String onlyThisDay = 'Endast denna dag';

  @override
  final String allDays = 'Alla dagar';

  @override
  final String thisDayAndForward = 'Denna dag och framåt';

  @override
  final String checkActivityQuestion = 'Klar?';

  @override
  final String unCheckActivityQuestion =
      'Vill du ångra kvitteringen av aktiviteten?';

  @override
  final String inTimePre = 'om';

  @override
  final String timeAgoPre = 'för';

  @override
  final String timeAgoPost = 'sen';

  @override
  final String checklistDoneInfo =
      'Alla uppgifter är avklarade. Vill du klarmarkera aktiviteten?';

  @override
  final String menu = 'Meny';

  @override
  final String cancel = 'Avbryt';

  @override
  final String newActivity = 'Ny';

  @override
  final String editActivity = 'Ändra aktivitet';

  @override
  final String category = 'Kategori (vänster eller höger)';

  @override
  final String checkable = 'Kvitterbar';

  @override
  final String deleteAfter = 'Ta bort efteråt';

  @override
  final String name = 'Namn';

  @override
  final String picture = 'Bild';

  @override
  final String date = 'Datum';

  @override
  final String startTime = 'Starttid';

  @override
  final String endTime = 'Sluttid';

  @override
  final String noEndTime = 'Ingen sluttid';

  @override
  final String missingTitleOrImageAndStartTime =
      'Aktiviteten måste ha ett namn eller en bild och en starttid.';

  @override
  final String missingTitleOrImage =
      'En aktivitet måste ha antingen en bild eller ett namn.';

  @override
  final String missingStartTime = 'Du måste ange en starttid.';

  @override
  final String startTimeBeforeNow =
      'Du har valt en starttid som är före aktuell tid. Det är inte tillåtet.';

  @override
  final String availableFor = 'Tillgänglig för';

  @override
  final String activityAvailableFor = 'Aktivitet tillgänglig för';

  @override
  final String meAndSupportPersons = 'Mig och stödpersoner';

  @override
  final String onlyMe = 'Bara mig';

  @override
  final String selectAlarmType = 'Ange larm';

  @override
  final String alarmAndVibration = 'Larm + vibration';

  @override
  final String vibration = 'Vibration';

  @override
  final String noAlarm = 'Inget larm';

  @override
  final String silentAlarm = 'Tyst larm';

  @override
  final String alarmOnlyAtStartTime = 'Larm endast vid starttid';

  @override
  final String selectPicture = 'Välj bild';

  @override
  final String removePicture = 'Ta bort bild';

  @override
  final String imageArchive = 'Bildarkiv';

  @override
  final String myPhotos = 'Mina foton';

  @override
  final String takeNewPhoto = 'Ta ny bild';

  @override
  final String recurrence = 'Upprepning';

  @override
  final String once = 'Enstaka';

  @override
  final String weekly = 'Veckovis';

  @override
  final String monthly = 'Månadsvis';

  @override
  final String yearly = 'Årsvis';

  @override
  final String noEndDate = 'Inget slutdatum';

  @override
  final String endDate = 'Slutdatum';

  @override
  final String everyOtherWeek = 'Varannan vecka';

  @override
  final String recurringDataEmptyErrorMessage = 'Välj minst en dag.';

  @override
  final String mo = 'mån';

  @override
  final String tu = 'tis';

  @override
  final String we = 'ons';

  @override
  final String th = 'tor';

  @override
  final String fr = 'fre';

  @override
  final String sa = 'lör';

  @override
  final String su = 'sön';

  @override
  final String infoType = 'Välj extra funktion';

  @override
  final String selectInfoType = 'Välj extra funktion';

  @override
  final String infoTypeNone = 'Ingen extra funktion vald';

  @override
  final String infoTypeChecklist = 'Lägg till checklista';

  @override
  final String infoTypeNote = 'Lägg till anteckning';

  @override
  final String typeSomething = 'Skriv något…';

  @override
  final String clear = 'Rensa';

  @override
  final String selectFromLibrary = 'Välj från bibliotek';

  @override
  final String addNew = 'Lägg till ny';

  @override
  final String task = 'Skriv in uppgift';

  @override
  final String remove = 'Ta bort';

  @override
  final String calendarView = 'Dagkalender';

  @override
  final String timePillarView = '1 tidpelare';

  @override
  final String listView = 'Lista';

  @override
  final String timepillarSettings = 'Inställningar för tidpelare';

  @override
  final String activityDuration = 'Visa tid som';

  @override
  final String dots = 'Prickar';

  @override
  final String edge = 'Flärp';

  @override
  final String preview = 'Förhandsgranskning';

  @override
  final String textToSpeech = 'Talstöd';

  @override
  final String longpressToSpeak = 'Tryck länge för tal';

  @override
  final String longPressInfoText =
      'Tryck länge på någon text för att få den uppläst';

  @override
  final String permissions = 'Behörigheter';

  @override
  final String notifications = 'Notiser';

  @override
  final String accessToPhotos = 'Tillgång till bilder';

  @override
  final String accessToCamera = 'Tillgång till kameran';

  @override
  final String allowNotifications = 'Tillåt notiser';

  @override
  final String allowNotificationsDescription1 =
      'Tillåt notiser för att få larm och påminnelser från aktiviteter. Du kan göra det ifrån ';

  @override
  final String settingsLink = 'inställningar';

  @override
  final String turnOffNotifications = 'Stäng av notiser?';

  @override
  final String turnOffNotificationsBody =
      'Du kommer inte längre kunna få alarm och notiser för aktiviteter.';

  @override
  final String notificationsWarningHintText =
      'Tillåt notiser för att få larm och påminnelser för aktiviteter.';

  @override
  final String notificationsWarningText =
      'Tillåt notiser från inställningar för att få larm och påminnelser.';

  @override
  final String fullScreenAlarm = 'Helskärmslarm';

  @override
  final String redirectToAndroidSettings =
      'Du kommer att omdirigeras till Android-inställningarna.';

  @override
  final String fullScreenAlarmInfo =
      'Tillåt denna behörighet för att kunna få helskärmslarm om aktiviteter';

  @override
  final String allow = 'Tillåt';

  @override
  final String previewActivityTitle = 'Eriks födelsedagskalas';

  @override
  final String allowAccessPhotosBody =
      'Tillåt behörighet till bilder för att ha möjlighet att använda bilder från enheten.';

  @override
  final String allowAccessCameraBody =
      'Tillåt behörighet till kameran för att ha möjlighet att ta bilder från enheten.';

  @override
  final String allowAccessBody2 = ' Du kan alltid göra det senare från ';
}
