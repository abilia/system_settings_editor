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
  registerFallbackValue(MemoplannerSettingsNotLoaded());
  registerFallbackValue(UpdateMemoplannerSettings(MapView({})));
  registerFallbackValue(TimepillarState(
      TimepillarInterval(
          start: DateTime(1910, 01, 01), end: DateTime(1987, 05, 23)),
      1.0));
  registerFallbackValue(TimepillarConditionsChangedEvent());
  registerFallbackValue(File(''));
  registerFallbackValue(TZDateTime.utc(2021));
  registerFallbackValue(NotificationDetails());
  registerFallbackValue(PushEvent(''));
  registerFallbackValue(PushReady());
  registerFallbackValue(ActivitySaved());
  registerFallbackValue(SyncInitial());
  registerFallbackValue(ActivitiesNotLoaded());
  registerFallbackValue(LoadActivities());
  registerFallbackValue(UserFilesNotLoaded());
  registerFallbackValue(LoadUserFiles());
  registerFallbackValue(Duration.zero);
  registerFallbackValue(Curves.ease);
  registerFallbackValue(GenericsNotLoaded());
  registerFallbackValue(LoadGenerics());
  registerFallbackValue(ImageThumb(id: ''));
  registerFallbackValue(Uri());
  registerFallbackValue(Uint8List(1));
  registerFallbackValue(ActivitiesOccasionLoading());
  registerFallbackValue(NowChanged(DateTime(1337)));
  registerFallbackValue(SortablesNotLoaded());
  registerFallbackValue(LoadSortables());
}
