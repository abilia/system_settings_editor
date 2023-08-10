import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/generics.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:rxdart/rxdart.dart';

class DayCalendarViewCubit extends Cubit<DayCalendarViewSettings> {
  final DayCalendarViewDb dayCalendarViewDb;

  DayCalendarViewCubit(this.dayCalendarViewDb, GenericCubit genericCubit)
      : super(dayCalendarViewDb.viewOptions) {
    if (dayCalendarViewDb.isNotSet) {
      genericCubit.stream.whereType<GenericsLoaded>().take(1).listen(
        (event) async {
          await setDayCalendarViewOptionsSettings(
            DayCalendarViewSettings.fromSettingsMap(
              event.generics.filterMemoplannerSettingsData(),
            ),
          );
        },
      );
    }
  }

  Future setDayCalendarViewOptionsSettings(
    DayCalendarViewSettings dayCalendarViewOptionsSettings,
  ) async {
    await dayCalendarViewDb
        .setDayCalendarViewOptionsSettings(dayCalendarViewOptionsSettings);
    if (isClosed) return;
    emit(dayCalendarViewOptionsSettings);
  }
}
