import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:seagull/bloc/all.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

void registerFallbackValues() {
  registerFallbackValue(const MemoplannerSettingsNotLoaded());
  registerFallbackValue(const UpdateMemoplannerSettings(MapView({})));
  registerFallbackValue(TimepillarState(
      TimepillarInterval(
          start: DateTime(1910, 01, 01), end: DateTime(1987, 05, 23)),
      1.0));
  registerFallbackValue(File(''));
  registerFallbackValue(TZDateTime.utc(2021));
  registerFallbackValue(const NotificationDetails());
  registerFallbackValue(PushReady());
  registerFallbackValue(const ActivitySaved());
  registerFallbackValue('');
  registerFallbackValue(ActivitiesNotLoaded());
  registerFallbackValue(LoadActivities());
  registerFallbackValue(const UserFilesNotLoaded());
  registerFallbackValue(Duration.zero);
  registerFallbackValue(Curves.ease);
  registerFallbackValue(GenericsNotLoaded());
  registerFallbackValue(LoadGenerics());
  registerFallbackValue(const ImageThumb(id: ''));
  registerFallbackValue(Uri());
  registerFallbackValue(Uint8List(1));
  registerFallbackValue(const EventsLoading());
  registerFallbackValue(SortablesNotLoaded());
  registerFallbackValue(const LoadSortables());
  registerFallbackValue(TimerState(timers: const []));
  registerFallbackValue(
    AbiliaTimer(
      id: '',
      title: '',
      startTime: DateTime(2),
      duration: Duration.zero,
    ),
  );
}
