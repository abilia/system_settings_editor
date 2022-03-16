import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

void registerFallbackValues() {
  registerFallbackValue(File(''));
  registerFallbackValue(TZDateTime.utc(2021));
  registerFallbackValue(const NotificationDetails());
  registerFallbackValue('');
  registerFallbackValue(const LoginInfo(token: '', endDate: 1, renewToken: ''));
  registerFallbackValue(LoadActivities());
  registerFallbackValue(Duration.zero);
  registerFallbackValue(Curves.ease);
  registerFallbackValue(const ImageThumb(id: ''));
  registerFallbackValue(Uri());
  registerFallbackValue(Uint8List(1));
  registerFallbackValue(
    AbiliaTimer(
      id: '',
      title: '',
      startTime: DateTime(2),
      duration: Duration.zero,
    ),
  );
}
