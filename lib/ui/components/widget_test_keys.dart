import 'package:flutter/foundation.dart';

class TestKey {
  TestKey._();
  static const Key userNameInput = Key('userName'),
      passwordInput = Key('password'),
      hidePasswordToggle = Key('hidePassword'),
      loggInButton = Key('loggIn'),
      loginError = Key('loginError'),
      goToNowButton = Key('goToNow'),
      onScreenAlarm = Key('onScreenAlarm'),
      changeView = (Key('changeView')),
      timePillarButton = Key('timePillarButton');
}
