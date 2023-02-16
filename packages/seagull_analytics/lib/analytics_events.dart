class AnalyticsEvents {
  static const navigation = "Navigation";
  static const timerDeleted = "Timer Deleted";
  static const timerStarted = "Timer Started";
  static const activityCreated = "Activity created"; // keep sentence cased
}

class AnalyticsProperties {
  // super properties - keep camel cased
  static const flavor = "flavor";
  static const release = "release";
  static const clientId = "clientId";
  static const environment = 'environment';
  static const locale = 'locale';
  static const language = 'language';

  // navigation
  static const page = "Page";
  static const action = "Action";
}
