import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:mocktail/mocktail.dart';

void registerFallbackValues() {
  registerFallbackValue(File(''));
  registerFallbackValue(TZDateTime.utc(2021));
  registerFallbackValue(const NotificationDetails());
  registerFallbackValue('');
  registerFallbackValue(Activity.createNew(startTime: DateTime(1)));
  registerFallbackValue(ApplyTo.onlyThisDay);
  registerFallbackValue(
      ActivityDay(Activity.createNew(startTime: DateTime(1)), DateTime(1)));
  registerFallbackValue(const LoginInfo(token: '', endDate: 1, renewToken: ''));
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
  registerFallbackValue(const LoadSortables());
  registerFallbackValue(Request('GET', ''.toUri()));
  registerFallbackValue(const ScheduleNotifications(''));
  registerFallbackValue(const StopSound());
  registerFallbackValue(FileStorage(''));
  registerFallbackValue(UrlSource(''));
}
