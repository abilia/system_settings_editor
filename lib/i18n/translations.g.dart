// GENERATED CODE - DO NOT MODIFY BY HAND

// instead, modify lib/i18n/translations.tsv and run
// > flutter packages pub run build_runner build

import 'dart:ui';

class Locales {
  static final language = <Locale, Translated>{
    Locale('en'): EN(),
    Locale('sv'): SV(),
    Locale('da'): DA(),
    Locale('nl'): NL(),
    Locale('fi'): FI(),
    Locale('de'): DE(),
    Locale('nb'): NB()
  };
}

abstract class Translated {
  final String userName = 'Username or email';

  final String password = 'Password';

  final String loginHint =
      'Login with the same username and password as on your MEMOplanner';

  final String login = 'Log in';

  final String logout = 'Log out';

  final String wrongCredentials =
      "Username or password doesn\'t match.\n\nVerify your credentials and try again.";

  final String noConnection =
      'No contact with myAbilia. Check your Internet connection.';

  final String noLicense = 'This account has no valid license.';

  final String licenseExpired = 'License is expired';

  final String licenseExpiredMessage =
      'Your license has expired and MEMOplanner Go can no longer be used. Contact your supplier to extend the license.';

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

  final String noActivities = 'No activities today';

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

  final String category = 'Category';

  final String checkable = 'Checkable';

  final String deleteAfter = 'Delete after';

  final String name = 'Name';

  final String picture = 'Image';

  final String date = 'Date';

  final String startTime = 'Start time';

  final String endTime = 'End time';

  final String noEndTime = 'No end time';

  final String emptyFolder = 'The folder is empty';

  final String noBasicActivities = 'You have no basic activities';

  final String noChecklists = 'You have no checklists';

  final String noNotes = 'You have no notes';

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

  final String recurringDataEmptyErrorMessage = 'Select at least one day.';

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

  final String longpressToSpeak = 'Tap and hold for speech support';

  final String longPressInfoText =
      'Tap and hold about 1½ seconds on any function to get it read to by speech synthesis';

  final String permissions = 'Permissions';

  final String notifications = 'Notifications';

  final String accessToPhotos = 'Access to Photos';

  final String accessToCamera = 'Access to Camera';

  final String allowNotifications = 'Allow notifications';

  final String allowNotificationsDescription1 =
      'Allow notifications to be able to get alarms and reminders from activities. You can do that from the';

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

  final String allowAccessBody2 = 'You can always do that later from the';
}

class EN extends Translated {}

class SV extends Translated {
  @override
  final String userName = 'Användarnamn eller e-post';

  @override
  final String password = 'Lösenord';

  @override
  final String loginHint =
      'Logga in med samma användarnamn och lösenord som på din MEMOplanner';

  @override
  final String login = 'Logga in';

  @override
  final String logout = 'Logga ut';

  @override
  final String wrongCredentials =
      'Användarnamn eller lösenord stämmer inte.\n\nKontrollera att du har skrivit rätt och försök igen.';

  @override
  final String noConnection =
      'Ingen kontakt med myAbilia. Kontrollera din internetanslutning.';

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
  final String newActivity = 'Helt ny';

  @override
  final String editActivity = 'Ändra aktivitet';

  @override
  final String category = 'Kategori';

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
  final String emptyFolder = 'Mappen är tom';

  @override
  final String noBasicActivities = 'Du har inga basaktiviteter';

  @override
  final String noChecklists = 'Du har inga checklistor';

  @override
  final String noNotes = 'Du har inga anteckningar';

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
  final String activityAvailableFor = 'Tillgänglig för';

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
  final String longpressToSpeak = 'Tryck och håll ned för talstöd';

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
      'Tillåt notiser för att få larm och påminnelser från aktiviteter. Du kan göra det ifrån';

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
  final String allowAccessBody2 = 'Du kan alltid göra det senare från';
}

class DA extends Translated {
  @override
  final String userName = 'Brugernavn eller e-mail';

  @override
  final String password = 'Adgangskode';

  @override
  final String loginHint =
      'Log ind med samme brugernavn og adgangskode som på din MEMOplanner';

  @override
  final String login = 'Log ind';

  @override
  final String logout = 'Log ud';

  @override
  final String wrongCredentials =
      'Brugernavn eller adgangskode er ikke korrekt.\n\nKontroller at du har skrevet det rigtigt og forsøg igen.';

  @override
  final String noConnection =
      'Enheden er ikke tilsluttet myAbilia. Kontroller din internetforbindelse.';

  @override
  final String noLicense =
      'Problemer med at logge ind!\n\nDu har ikke en gyldig licens.';

  @override
  final String licenseExpired = 'Licensen er udløbet';

  @override
  final String licenseExpiredMessage =
      'Licensen er udløbet, og MEMOplanner Go kan ikke længere bruges. Kontakt din bevilgende kontaktperson, hvis du ønsker at forlænge licensen.';

  @override
  final String fullDay = 'Hele dagen';

  @override
  final String morning = 'morgen';

  @override
  final String forenoon = 'formiddag';

  @override
  final String afternoon = 'eftermiddag';

  @override
  final String evening = 'aften';

  @override
  final String night = 'nat';

  @override
  final String today = 'I dag';

  @override
  final String days = 'dage';

  @override
  final String day = 'dag';

  @override
  final String hours = 'timer';

  @override
  final String hour = 'time';

  @override
  final String minutes = 'minutter';

  @override
  final String minute = 'minut';

  @override
  final String reminders = 'Påmindelser';

  @override
  final String alarm = 'Alarm';

  @override
  final String noActivities = 'Ingen aktiviteter i dag';

  @override
  final String left = 'Venstre';

  @override
  final String right = 'Højre';

  @override
  final String check = 'Kvittere';

  @override
  final String uncheck = 'Fortryd';

  @override
  final String fromBasicActivity = 'Fra standardaktivitet';

  @override
  final String createActivity = 'Ny aktivitet';

  @override
  final String basicActivities = 'Vælg standardaktivitet';

  @override
  final String deleteActivity =
      'Er du sikker på, at du vil slette aktiviteten?';

  @override
  final String appyTo = 'Ændre gentagende aktivitet';

  @override
  final String onlyThisDay = 'Kun denne dag';

  @override
  final String allDays = 'Alle dage';

  @override
  final String thisDayAndForward = 'Denne dag og frem';

  @override
  final String checkActivityQuestion = 'Færdig?';

  @override
  final String unCheckActivityQuestion =
      'Vil du fjerne markeringen af aktiviteten?';

  @override
  final String menu = 'Menu';

  @override
  final String cancel = 'Annuller';

  @override
  final String newActivity = 'Helt ny';

  @override
  final String editActivity = 'Ændre aktivitet';

  @override
  final String category = 'Kategori';

  @override
  final String checkable = 'Kvitterbar';

  @override
  final String deleteAfter = 'Slet bagefter';

  @override
  final String name = 'Navn';

  @override
  final String picture = 'Billede';

  @override
  final String date = 'Dato';

  @override
  final String startTime = 'Starttid';

  @override
  final String endTime = 'Sluttid';

  @override
  final String noEndTime = 'Ingen sluttid';

  @override
  final String emptyFolder = 'Mappen er tom';

  @override
  final String noBasicActivities = 'Du har ingen standardaktiviteter';

  @override
  final String noChecklists = 'Du har ingen tjeklister';

  @override
  final String noNotes = 'Du har ingen noter';

  @override
  final String missingTitleOrImage =
      'En aktivitet skal have enten et billede eller et navn.';

  @override
  final String missingStartTime = 'Du skal angive en starttid.';

  @override
  final String startTimeBeforeNow =
      'Starttiden er allerede passeret. Det er ikke tilladt.';

  @override
  final String availableFor = 'Fås til';

  @override
  final String activityAvailableFor = 'Fås til';

  @override
  final String meAndSupportPersons = 'Mig og støttepersoner';

  @override
  final String onlyMe = 'Bare mig';

  @override
  final String selectAlarmType = 'Vælg alarm';

  @override
  final String alarmAndVibration = 'Alarm + vibration';

  @override
  final String vibration = 'Vibration';

  @override
  final String noAlarm = 'Ingen alarm';

  @override
  final String silentAlarm = 'Stille alarm';

  @override
  final String alarmOnlyAtStartTime = 'Kun alarm ved starttidspunkt';

  @override
  final String selectPicture = 'Vælg billede';

  @override
  final String removePicture = 'Fjern billede';

  @override
  final String imageArchive = 'Billedarkiv';

  @override
  final String myPhotos = 'Mine fotos';

  @override
  final String takeNewPhoto = 'Tag et nyt billede';

  @override
  final String recurrence = 'Gentagelse';

  @override
  final String once = 'En gang';

  @override
  final String weekly = 'Ugentlig';

  @override
  final String monthly = 'Månedlig';

  @override
  final String yearly = 'Årlig';

  @override
  final String noEndDate = 'Ingen slutdato';

  @override
  final String endDate = 'Slutdato';

  @override
  final String everyOtherWeek = 'Hver anden uge';

  @override
  final String recurringDataEmptyErrorMessage = 'Vælg mindst en dag';

  @override
  final String mo = 'man';

  @override
  final String tu = 'tir';

  @override
  final String we = 'ons';

  @override
  final String th = 'tor';

  @override
  final String fr = 'fre';

  @override
  final String sa = 'lør';

  @override
  final String su = 'søn';

  @override
  final String infoType = 'Vælg ekstra funktion';

  @override
  final String selectInfoType = 'Vælg ekstra funktion';

  @override
  final String infoTypeNone = 'Ingen yderligere funktion er valgt';

  @override
  final String infoTypeChecklist = 'Tilføj tjekliste';

  @override
  final String infoTypeNote = 'Tilføj note';

  @override
  final String typeSomething = 'Skriv noget…';

  @override
  final String selectFromLibrary = 'Vælg fra bibliotek';

  @override
  final String addNew = 'Tilføj';

  @override
  final String task = 'Indsæt opgave';

  @override
  final String remove = 'Slet';

  @override
  final String calendarView = 'Dagkalender';

  @override
  final String timePillarView = '1 tidslinje';

  @override
  final String listView = 'Liste';

  @override
  final String textToSpeech = 'Talestøtte';

  @override
  final String longpressToSpeak = 'Tryk og hold nede for talestøtte';

  @override
  final String longPressInfoText =
      'Tryk og hold ca. 1½ sekund på enhver funktion for at få den læst til ved talesyntese';
}

class NL extends Translated {
  @override
  final String userName = 'Gebruikersnaam of e-mail';

  @override
  final String password = 'Wachtwoord';

  @override
  final String loginHint =
      'Log in met dezelfde gebruikersnaam en hetzelfde wachtwoord als op uw MEMOplanner';

  @override
  final String login = 'Inloggen';

  @override
  final String logout = 'Uitloggen';

  @override
  final String wrongCredentials =
      'Gebruikersnaam of wachtwoord komt niet overeen.\n\nControleer uw gegevens en probeer opnieuw.';

  @override
  final String noConnection =
      'Het apparaat is niet aangesloten op het myAbilia. Controleer uw internetverbinding.';

  @override
  final String noLicense = 'Dit account heeft geen geldige licentie.';

  @override
  final String licenseExpired = 'Licentie verlopen';

  @override
  final String licenseExpiredMessage =
      'De licentie is verlopen en MEMOplanner Go kan niet langer worden gebruikt. Neem contact op met uw aanbieder om de licentie te verlengen.';

  @override
  final String fullDay = 'Hele dag';

  @override
  final String morning = 'ochtend';

  @override
  final String forenoon = 'midden-ochtend';

  @override
  final String afternoon = 'middag';

  @override
  final String evening = 'avond';

  @override
  final String night = 'nacht';

  @override
  final String today = 'Vandaag';

  @override
  final String days = 'dagen';

  @override
  final String day = 'dag';

  @override
  final String hours = 'uur';

  @override
  final String hour = 'uur';

  @override
  final String minutes = 'minuten';

  @override
  final String minute = 'minuut';

  @override
  final String reminders = 'Herinneringen';

  @override
  final String alarm = 'Alarm';

  @override
  final String noActivities = 'Geen activiteiten vandaag';

  @override
  final String left = 'Links';

  @override
  final String right = 'Rechts';

  @override
  final String check = 'Afvinken';

  @override
  final String uncheck = 'Ongedaan maken';

  @override
  final String fromBasicActivity = 'Uit standaardactiviteit';

  @override
  final String createActivity = 'Nieuwe activiteit';

  @override
  final String basicActivities = 'Standaardactiviteit selecteren';

  @override
  final String deleteActivity = 'Wilt u deze activiteit verwijderen?';

  @override
  final String appyTo = 'Terugkerende activiteit bewerken';

  @override
  final String onlyThisDay = 'Alleen deze dag';

  @override
  final String allDays = 'Alle dagen';

  @override
  final String thisDayAndForward = 'Deze dag en verder';

  @override
  final String checkActivityQuestion = 'Afgerond?';

  @override
  final String unCheckActivityQuestion = 'Wilt u de activiteit uitvinken?';

  @override
  final String menu = 'Menu';

  @override
  final String cancel = 'Annuleren';

  @override
  final String newActivity = 'Nieuw';

  @override
  final String editActivity = 'Activiteit bewerken';

  @override
  final String category = 'Categorie';

  @override
  final String checkable = 'Afvinkbaar';

  @override
  final String deleteAfter = 'Verwijderen na';

  @override
  final String name = 'Naam';

  @override
  final String picture = 'Afbeelding';

  @override
  final String date = 'Datum';

  @override
  final String startTime = 'Starttijd';

  @override
  final String endTime = 'Eindtijd';

  @override
  final String noEndTime = 'Geen eindtijd';

  @override
  final String emptyFolder = 'De map is leeg';

  @override
  final String noBasicActivities = 'Je hebt geen standaardactiviteiten';

  @override
  final String noChecklists = 'Je hebt geen checklists';

  @override
  final String noNotes = 'Je hebt geen aantekeningen';

  @override
  final String missingTitleOrImage =
      'Deze activiteit heeft een afbeelding of een naam nodig.';

  @override
  final String missingStartTime = 'U moet een starttijd instellen.';

  @override
  final String startTimeBeforeNow =
      'U heeft een starttijd geselecteerd die al voorbij is. Dit is niet toegestaan.';

  @override
  final String availableFor = 'Beschikbaar voor';

  @override
  final String activityAvailableFor = 'Beschikbaar voor';

  @override
  final String meAndSupportPersons = 'Mij en ondersteuningspersonen';

  @override
  final String onlyMe = 'Mij alleen';

  @override
  final String selectAlarmType = 'Alarm selecteren';

  @override
  final String alarmAndVibration = 'Alarm + trilfunctie';

  @override
  final String vibration = 'Trilfunctie';

  @override
  final String noAlarm = 'Geen alarm';

  @override
  final String silentAlarm = 'Stil alarm';

  @override
  final String alarmOnlyAtStartTime = 'Alarm alleen op begintijd';

  @override
  final String selectPicture = 'Afbeelding selecteren';

  @override
  final String removePicture = 'Afbeelding verwijderen';

  @override
  final String imageArchive = 'Afbeeldingenarchief';

  @override
  final String myPhotos = "Mijn foto\'s";

  @override
  final String takeNewPhoto = 'Nieuwe foto nemen';

  @override
  final String recurrence = 'Terugkerend';

  @override
  final String once = 'Eén keer';

  @override
  final String weekly = 'Wekelijks';

  @override
  final String monthly = 'Maandelijks';

  @override
  final String yearly = 'Jaarlijks';

  @override
  final String noEndDate = 'Geen einddatum';

  @override
  final String endDate = 'Einddatum';

  @override
  final String everyOtherWeek = 'Om de week';

  @override
  final String recurringDataEmptyErrorMessage = 'Selecteer ten minste één dag.';

  @override
  final String mo = 'Ma';

  @override
  final String tu = 'Di';

  @override
  final String we = 'Wo';

  @override
  final String th = 'Do';

  @override
  final String fr = 'Vr';

  @override
  final String sa = 'Za';

  @override
  final String su = 'Zo';

  @override
  final String infoType = 'Extra functie selecteren';

  @override
  final String selectInfoType = 'Extra functie selecteren';

  @override
  final String infoTypeNone = 'Geen extra functie geselecteerd';

  @override
  final String infoTypeChecklist = 'Checklist toevoegen';

  @override
  final String infoTypeNote = 'Notitie toevoegen';

  @override
  final String typeSomething = 'Typ iets';

  @override
  final String selectFromLibrary = 'Selecteren uit bibliotheek';

  @override
  final String addNew = 'Toevoegen';

  @override
  final String task = 'Taak invoeren';

  @override
  final String remove = 'Verwijderen';

  @override
  final String calendarView = 'Dagkalender';

  @override
  final String timePillarView = '1 tijdlijn';

  @override
  final String listView = 'Lijst';

  @override
  final String textToSpeech = 'Spraakondersteuning';

  @override
  final String longpressToSpeak = 'Tik en houd vast voor spraakondersteuning';

  @override
  final String longPressInfoText =
      'Tik en houd ongeveer 1½ seconde vast op een functie om deze te laten voorlezen door spraaksynthese';
}

class FI extends Translated {
  @override
  final String userName = 'Käyttäjätunnus tai sähköpostiosoite';

  @override
  final String password = 'Salasana';

  @override
  final String loginHint =
      'Kirjaudu sisään samalla käyttäjänimellä ja salasanalla kuin MEMOplannerilla';

  @override
  final String login = 'Kirjaudu sisään';

  @override
  final String logout = 'Kirjaudu ulos';

  @override
  final String wrongCredentials =
      'Käyttäjätunnus tai salasana ei täsmää.\n\nVahvista tunnistetiedot ja yritä uudelleen.';

  @override
  final String noConnection =
      'Laitetta ei ole yhdistetty myAbilia. Tarkista Internet-yhteys.';

  @override
  final String noLicense = 'Tällä tilillä ei ole kelvollista lisenssiä.';

  @override
  final String licenseExpired = 'Lisenssi on vanhentunut';

  @override
  final String licenseExpiredMessage =
      'Lisenssisi on vanhentunut, eikä Memoplanneria voi enää käyttää. Jatka lisenssiä ottamalla yhteyttä jälleenmyyjään.';

  @override
  final String fullDay = 'Koko päivä';

  @override
  final String morning = 'aamu';

  @override
  final String forenoon = 'aamupäivän puolivälissä';

  @override
  final String afternoon = 'iltapäivä';

  @override
  final String evening = 'ilta';

  @override
  final String night = 'yö';

  @override
  final String today = 'Tänään';

  @override
  final String days = 'päivää';

  @override
  final String day = 'päivä';

  @override
  final String hours = 'tunnit';

  @override
  final String hour = 'tunti';

  @override
  final String minutes = 'minuuttia';

  @override
  final String minute = 'minuutti';

  @override
  final String reminders = 'Muistutukset';

  @override
  final String alarm = 'Hälytys';

  @override
  final String noActivities = 'Ei toimintaa tänään';

  @override
  final String left = 'Vasen';

  @override
  final String right = 'Oikea';

  @override
  final String check = 'Tarkista';

  @override
  final String uncheck = 'Peruuta';

  @override
  final String fromBasicActivity = 'Perusaktiviteetista';

  @override
  final String createActivity = 'Uusi aktiviteetti';

  @override
  final String basicActivities = 'Valitse perusaktiviteetti';

  @override
  final String deleteActivity = 'Haluatko poistaa tämän aktiviteetin?';

  @override
  final String appyTo = 'Muokkaa toistuvaa aktiviteettia';

  @override
  final String onlyThisDay = 'Vain tänä päivänä';

  @override
  final String allDays = 'Kaikki päivät';

  @override
  final String thisDayAndForward = 'Tästä päivästä lähtien';

  @override
  final String checkActivityQuestion = 'Valmis?';

  @override
  final String unCheckActivityQuestion =
      'Haluatko poistaa valinnan aktiviteetista?';

  @override
  final String menu = 'Valikko';

  @override
  final String cancel = 'Peruuta';

  @override
  final String newActivity = 'Uusi';

  @override
  final String editActivity = 'Muokkaa aktiviteettia';

  @override
  final String category = 'Kategoria';

  @override
  final String checkable = 'Tarkistettava';

  @override
  final String deleteAfter = 'Poista, kun on kulunut';

  @override
  final String name = 'Nimi';

  @override
  final String picture = 'Kuva';

  @override
  final String date = 'Päivämäärä';

  @override
  final String startTime = 'Aloitusaika';

  @override
  final String endTime = 'Päättymisaika';

  @override
  final String noEndTime = 'Ei loppuaikaa';

  @override
  final String emptyFolder = 'Kansio on tyhjä';

  @override
  final String noBasicActivities = 'Sinulla ei ole perusaktiviteettit';

  @override
  final String noChecklists = 'Sinulla ei ole tarkistuslistoja';

  @override
  final String noNotes = 'Sinulla ei ole muistiinpanoja';

  @override
  final String missingTitleOrImage =
      'Tämä aktiviteetti tarvitsee kuvan tai nimen.';

  @override
  final String missingStartTime = 'Anna aloitusaika.';

  @override
  final String startTimeBeforeNow =
      'Valitsit aloitusajan, joka on jo mennyt. Tätä ei sallita.';

  @override
  final String availableFor = 'Käytettävissä';

  @override
  final String activityAvailableFor = 'Käytettävissä';

  @override
  final String meAndSupportPersons = 'Minä ja tukihenkilöt';

  @override
  final String onlyMe = 'Vain minä';

  @override
  final String selectAlarmType = 'Valitse hälytys';

  @override
  final String alarmAndVibration = 'Hälytys + värinä';

  @override
  final String vibration = 'Värinä';

  @override
  final String noAlarm = 'Ei hälytystä';

  @override
  final String silentAlarm = 'Äänetön hälytys';

  @override
  final String alarmOnlyAtStartTime = 'Vain hälytys alkamisaikaan';

  @override
  final String selectPicture = 'Valitse kuva';

  @override
  final String removePicture = 'Poista kuva';

  @override
  final String imageArchive = 'Kuva-arkisto';

  @override
  final String myPhotos = 'Omat valokuvat';

  @override
  final String takeNewPhoto = 'Ota uusi kuva';

  @override
  final String recurrence = 'Toistuminen';

  @override
  final String once = 'Kerran';

  @override
  final String weekly = 'Viikoittain';

  @override
  final String monthly = 'Kuukausittain';

  @override
  final String yearly = 'Vuosittain';

  @override
  final String noEndDate = 'Ei päättymispäivää';

  @override
  final String endDate = 'Päättymispäivä';

  @override
  final String everyOtherWeek = 'Kahden viikon välein';

  @override
  final String recurringDataEmptyErrorMessage = 'Valitse vähintään yksi päivä.';

  @override
  final String mo = 'Ma';

  @override
  final String tu = 'Ti';

  @override
  final String we = 'Ke';

  @override
  final String th = 'To';

  @override
  final String fr = 'Pe';

  @override
  final String sa = 'La';

  @override
  final String su = 'Su';

  @override
  final String infoType = 'Valitse lisätoiminto';

  @override
  final String selectInfoType = 'Valitse lisätoiminto';

  @override
  final String infoTypeNone = 'Lisätoimintoa ei ole valittu';

  @override
  final String infoTypeChecklist = 'Lisää tarkistusluettelo';

  @override
  final String infoTypeNote = 'Lisää muistiinpano';

  @override
  final String typeSomething = 'Kirjoita jotain';

  @override
  final String selectFromLibrary = 'Valitse kirjastosa';

  @override
  final String addNew = 'Lisää';

  @override
  final String task = 'Anna tehtävä';

  @override
  final String remove = 'Poista';

  @override
  final String calendarView = 'Päiväkalenteri';

  @override
  final String timePillarView = '1 aikajana';

  @override
  final String listView = 'Luettelo';

  @override
  final String textToSpeech = 'Puhetuki';

  @override
  final String longpressToSpeak = 'Napauta ja pidä painettuna puhetukea varten';

  @override
  final String longPressInfoText =
      'Napauta ja pidä painettuna noin 1,5 sekuntia mitä tahansa toimintoa saadaksesi sen lukemaan puheen synteesin avulla';
}

class DE extends Translated {
  @override
  final String userName = 'Benutzername oder E-Mail';

  @override
  final String password = 'Passwort';

  @override
  final String loginHint =
      'Melden Sie sich mit demselben Benutzernamen und Passwort wie auf Ihrem MEMOplanner an';

  @override
  final String login = 'Anmelden';

  @override
  final String logout = 'Abmelden';

  @override
  final String wrongCredentials =
      'Benutzername oder Passwort unkorrekt.\n\nBitte Anmeldedaten prüfen und nochmals versuchen.';

  @override
  final String noConnection =
      'Das Gerät ist nicht mit dem myAbilia verbunden. Überprüfen Sie Ihre Internetverbindung.';

  @override
  final String noLicense = 'Für dieses Konto gibt es keine gültige Lizenz.';

  @override
  final String licenseExpired = 'Lizenz abgelaufen';

  @override
  final String licenseExpiredMessage =
      'Ihre Lizenz ist abgelaufen und MEMOplanner Go kann nicht mehr genutzt werden. Wenden Sie sich an Ihre Bezugsquelle, um die Lizenz zu verlängern.';

  @override
  final String fullDay = 'Ganztägig';

  @override
  final String morning = 'frühmorgens';

  @override
  final String forenoon = 'Vormittag';

  @override
  final String afternoon = 'Nachmittag';

  @override
  final String evening = 'Abend';

  @override
  final String night = 'Nacht';

  @override
  final String today = 'Heute';

  @override
  final String days = 'Tage';

  @override
  final String day = 'Tag';

  @override
  final String hours = 'Stunden';

  @override
  final String hour = 'Stunde';

  @override
  final String minutes = 'Minuten';

  @override
  final String minute = 'Minute';

  @override
  final String reminders = 'Erinnerungen';

  @override
  final String alarm = 'Alarm';

  @override
  final String noActivities = 'Keine Aktivitäten heute';

  @override
  final String left = 'Links';

  @override
  final String right = 'Rechts';

  @override
  final String check = 'Kontrollieren';

  @override
  final String uncheck = 'Rückgängig';

  @override
  final String fromBasicActivity = 'Von Standardaktivität';

  @override
  final String createActivity = 'Neue Aktivität';

  @override
  final String basicActivities = 'Standardaktivität auswählen';

  @override
  final String deleteActivity = 'Möchten Sie diese Aktivität löschen?';

  @override
  final String appyTo = 'Wiederkehrende Aktivität bearbeiten';

  @override
  final String onlyThisDay = 'Nur an diesem Tag';

  @override
  final String allDays = 'Alle Tage';

  @override
  final String thisDayAndForward = 'Von diesem Tag an';

  @override
  final String checkActivityQuestion = 'Bist Du fertig?';

  @override
  final String unCheckActivityQuestion =
      'Möchten Sie die Auswahl rückgängig machen?';

  @override
  final String menu = 'Menü';

  @override
  final String cancel = 'Abbrechen';

  @override
  final String newActivity = 'Neu';

  @override
  final String editActivity = 'Aktivität bearbeiten';

  @override
  final String category = 'Kategorie';

  @override
  final String checkable = 'Kontrollabfrage';

  @override
  final String deleteAfter = 'am Endes des Tages löschen';

  @override
  final String name = 'Name';

  @override
  final String picture = 'Bild';

  @override
  final String date = 'Datum';

  @override
  final String startTime = 'Startzeit';

  @override
  final String endTime = 'Endezeit';

  @override
  final String noEndTime = 'Keine Endezeit';

  @override
  final String emptyFolder = 'Der Ordner leer ist';

  @override
  final String noBasicActivities = 'Sie haben keine Standardaktivitäten';

  @override
  final String noChecklists = 'Sie haben keine Checklisten';

  @override
  final String noNotes = 'Sie haben keine Notizen';

  @override
  final String missingTitleOrImage =
      'Diese Aktivität braucht ein Bild oder einen Namen.';

  @override
  final String missingStartTime = 'Sie müssen eine Startzeit eingeben:';

  @override
  final String startTimeBeforeNow =
      'Die gewählte Startzeit liegt in der Vergangenheit. Dies ist nicht zulässig.';

  @override
  final String availableFor = 'Verfügbar für';

  @override
  final String activityAvailableFor = 'Verfügbar für';

  @override
  final String meAndSupportPersons = 'Mich und Hilfspersonen';

  @override
  final String onlyMe = 'Nur für mich';

  @override
  final String selectAlarmType = 'Alarm auswählen';

  @override
  final String alarmAndVibration = 'Alarm + Vibration';

  @override
  final String vibration = 'Vibration';

  @override
  final String noAlarm = 'Kein Alarm';

  @override
  final String silentAlarm = 'Stiller Alarm';

  @override
  final String alarmOnlyAtStartTime = 'Alarm nur zur Startzeit';

  @override
  final String selectPicture = 'Bild auswählen';

  @override
  final String removePicture = 'Entferne Bild';

  @override
  final String imageArchive = 'Bildarchiv';

  @override
  final String myPhotos = 'Meine Fotos';

  @override
  final String takeNewPhoto = 'Neues Foto machen';

  @override
  final String recurrence = 'Intervall';

  @override
  final String once = 'Einmal';

  @override
  final String weekly = 'Wöchentlich';

  @override
  final String monthly = 'Monatlich';

  @override
  final String yearly = 'Jährlich';

  @override
  final String noEndDate = 'Kein Enddatum';

  @override
  final String endDate = 'Enddatum';

  @override
  final String everyOtherWeek = 'Vierzehntägig';

  @override
  final String recurringDataEmptyErrorMessage =
      'Mindestens einen Tag auswählen.';

  @override
  final String mo = 'Mo';

  @override
  final String tu = 'Di';

  @override
  final String we = 'Mi';

  @override
  final String th = 'Do';

  @override
  final String fr = 'Fr';

  @override
  final String sa = 'Sa';

  @override
  final String su = 'So';

  @override
  final String infoType = 'Extrafunktion auswählen';

  @override
  final String selectInfoType = 'Extrafunktion auswählen';

  @override
  final String infoTypeNone = 'Keine Extrafunktion ausgewählt';

  @override
  final String infoTypeChecklist = 'Checkliste hinzufügen';

  @override
  final String infoTypeNote = 'Hinweis hinzufügen';

  @override
  final String typeSomething = 'Geben Sie etwas ein…';

  @override
  final String selectFromLibrary = 'Aus Bibliothek wählen';

  @override
  final String addNew = 'Hinzufügen';

  @override
  final String task = 'Aufgabe eingeben';

  @override
  final String remove = 'Löschen';

  @override
  final String calendarView = 'Tageskalender';

  @override
  final String timePillarView = '1 Zeitstrahl';

  @override
  final String listView = 'Liste';

  @override
  final String textToSpeech = 'Sprachausgabe';

  @override
  final String longpressToSpeak =
      'Tippen und halten Sie für die Sprachunterstützung';

  @override
  final String longPressInfoText =
      'Tippen und halten Sie etwa 1½ Sekunden lang auf eine Funktion, um sie durch Sprachsynthese lesen zu lassen';
}

class NB extends Translated {
  @override
  final String userName = 'Brukernavn eller e-post';

  @override
  final String password = 'Passord';

  @override
  final String loginHint =
      'Logg inn med samme brukernavn og passord som på MEMOplanner';

  @override
  final String login = 'Logg inn';

  @override
  final String logout = 'Logg ut';

  @override
  final String wrongCredentials =
      'Brukernavn eller passord er ikke riktig.\n\nKontroller at du har skrevet riktig og prøv igjen.';

  @override
  final String noConnection =
      'Enheten er ikke koblet til myAbilia. Sjekk din Internettforbindelse.';

  @override
  final String noLicense =
      'Problemer med å logge inn!\n\nDu har ikke en gyldig lisens.';

  @override
  final String licenseExpired = 'Lisensen har utløpt';

  @override
  final String licenseExpiredMessage =
      'Lisensen er utløpt og MEMOplanner Go kan ikke lenger brukes. Kontakt din forskriver hvis du ønsker å forlenge lisensen.';

  @override
  final String fullDay = 'Hele dagen';

  @override
  final String morning = 'morgen';

  @override
  final String forenoon = 'formiddag';

  @override
  final String afternoon = 'ettermiddag';

  @override
  final String evening = 'kveld';

  @override
  final String night = 'natt';

  @override
  final String today = 'I dag';

  @override
  final String days = 'dager';

  @override
  final String day = 'dag';

  @override
  final String hours = 'timer';

  @override
  final String hour = 'time';

  @override
  final String minutes = 'minutter';

  @override
  final String minute = 'minutt';

  @override
  final String reminders = 'Påminnelser';

  @override
  final String alarm = 'Alarm';

  @override
  final String noActivities = 'Ingen aktiviteter i dag';

  @override
  final String left = 'Venstre';

  @override
  final String right = 'Høyre';

  @override
  final String check = 'Kvittere';

  @override
  final String uncheck = 'Angre';

  @override
  final String fromBasicActivity = 'Fra standardaktivitet';

  @override
  final String createActivity = 'Ny aktivitet';

  @override
  final String basicActivities = 'Velg standardaktivitet';

  @override
  final String deleteActivity = 'Er du sikker på at du vil slette aktiviteten?';

  @override
  final String appyTo = 'Endre gjentakende aktivitet';

  @override
  final String onlyThisDay = 'Bare denne dagen';

  @override
  final String allDays = 'Alle dager';

  @override
  final String thisDayAndForward = 'Denne dagen og fremover';

  @override
  final String checkActivityQuestion = 'Ferdig?';

  @override
  final String unCheckActivityQuestion =
      'Vil du fjerne merket for aktiviteten?';

  @override
  final String menu = 'Meny';

  @override
  final String cancel = 'Avbryt';

  @override
  final String newActivity = 'Helt ny';

  @override
  final String editActivity = 'Endre aktivitet';

  @override
  final String category = 'Kategori';

  @override
  final String checkable = 'Kvitterbar';

  @override
  final String deleteAfter = 'Slett etterpå';

  @override
  final String name = 'Navn';

  @override
  final String picture = 'Bilde';

  @override
  final String date = 'Dato';

  @override
  final String startTime = 'Starttid';

  @override
  final String endTime = 'Sluttid';

  @override
  final String noEndTime = 'Ingen sluttid';

  @override
  final String emptyFolder = 'Mappen er tom';

  @override
  final String noBasicActivities = 'Du har ingen standardaktiviteter';

  @override
  final String noChecklists = 'Du har ingen sjekklister';

  @override
  final String noNotes = 'Du har ingen notater';

  @override
  final String missingTitleOrImage =
      'En aktivitet må ha enten et bilde eller et navn.';

  @override
  final String missingStartTime = 'En aktivitet må ha en starttid.';

  @override
  final String startTimeBeforeNow =
      'Starttiden er allerede passert. Det er ikke tillatt.';

  @override
  final String availableFor = 'Tilgjengelig for';

  @override
  final String activityAvailableFor = 'Tilgjengelig for';

  @override
  final String meAndSupportPersons = 'Meg og støttepersoner';

  @override
  final String onlyMe = 'Bare meg';

  @override
  final String selectAlarmType = 'Angi alarm';

  @override
  final String alarmAndVibration = 'Alarm + Vibrasjon';

  @override
  final String vibration = 'Vibrasjon';

  @override
  final String noAlarm = 'Ingen alarm';

  @override
  final String silentAlarm = 'Stille alarm';

  @override
  final String alarmOnlyAtStartTime = 'Alarm kun på starttid';

  @override
  final String selectPicture = 'Velg bilde';

  @override
  final String removePicture = 'Fjern bildet';

  @override
  final String imageArchive = 'Bildearkiv';

  @override
  final String myPhotos = 'Mine foto';

  @override
  final String takeNewPhoto = 'Ta nytt bilde';

  @override
  final String recurrence = 'Gjentakelse';

  @override
  final String once = 'En gang';

  @override
  final String weekly = 'Ukentlig';

  @override
  final String monthly = 'Månedlig';

  @override
  final String yearly = 'Årlig';

  @override
  final String noEndDate = 'Uten sluttdato';

  @override
  final String endDate = 'Sluttdato';

  @override
  final String everyOtherWeek = 'Annenhver uke';

  @override
  final String recurringDataEmptyErrorMessage = 'Velg minst en dag.';

  @override
  final String mo = 'man';

  @override
  final String tu = 'tir';

  @override
  final String we = 'ons';

  @override
  final String th = 'tor';

  @override
  final String fr = 'fre';

  @override
  final String sa = 'lør';

  @override
  final String su = 'søn';

  @override
  final String infoType = 'Velg ekstra funksjon';

  @override
  final String selectInfoType = 'Velg ekstra funksjon';

  @override
  final String infoTypeNone = 'Ingen ekstra funksjon valgt';

  @override
  final String infoTypeChecklist = 'Legg til sjekkliste';

  @override
  final String infoTypeNote = 'Legg til notat';

  @override
  final String typeSomething = 'Skriv noe…';

  @override
  final String selectFromLibrary = 'Velg fra bibliotek';

  @override
  final String addNew = 'Legg til';

  @override
  final String task = 'Skriv inn oppgave';

  @override
  final String remove = 'Slett';

  @override
  final String calendarView = 'Dagkalender';

  @override
  final String timePillarView = '1 tidslinje';

  @override
  final String listView = 'Liste';

  @override
  final String textToSpeech = 'Talesyntese';

  @override
  final String longpressToSpeak = 'Trykk og hold for talestøtte';

  @override
  final String longPressInfoText =
      'Trykk og hold i ca. 1½ sekund på en funksjon for å få den lest opp ved talesyntese';
}
