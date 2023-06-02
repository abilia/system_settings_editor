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
          final mpSettings = event.generics.filterMemoplannerSettingsData();
          await setDayCalendarViewOptionsSettings(
            state.copyWith(
              display: state.display.copyWith(
                calendarType: mpSettings[GenericData.uniqueId(
                  GenericType.memoPlannerSettings,
                  DayCalendarViewOptionsDisplaySettings.displayCalendarTypeKey,
                )]
                    ?.data,
                intervalType: mpSettings[GenericData.uniqueId(
                  GenericType.memoPlannerSettings,
                  DayCalendarViewOptionsDisplaySettings
                      .displayIntervalTypeIntervalKey,
                )]
                    ?.data,
                timepillarZoom: mpSettings[GenericData.uniqueId(
                  GenericType.memoPlannerSettings,
                  DayCalendarViewOptionsDisplaySettings
                      .displayTimepillarZoomKey,
                )]
                    ?.data,
                duration: mpSettings[GenericData.uniqueId(
                  GenericType.memoPlannerSettings,
                  DayCalendarViewOptionsDisplaySettings.displayDurationKey,
                )]
                    ?.data,
              ),
              dots: mpSettings[GenericData.uniqueId(
                GenericType.memoPlannerSettings,
                DayCalendarViewSettings.viewOptionsDotsKey,
              )]
                  ?.data,
              calendarType: mpSettings[GenericData.uniqueId(
                GenericType.memoPlannerSettings,
                DayCalendarViewSettings.viewOptionsCalendarTypeKey,
              )]
                  ?.data,
              intervalType: mpSettings[GenericData.uniqueId(
                GenericType.memoPlannerSettings,
                DayCalendarViewSettings.viewOptionsTimeIntervalKey,
              )]
                  ?.data,
              timepillarZoom: mpSettings[GenericData.uniqueId(
                GenericType.memoPlannerSettings,
                DayCalendarViewSettings.viewOptionsTimepillarZoomKey,
              )]
                  ?.data,
            ),
          );
        },
      );
    }
  }

  Future setDayCalendarViewOptionsSettings(
      DayCalendarViewSettings dayCalendarViewOptionsSettings) async {
    await dayCalendarViewDb
        .setDayCalendarViewOptionsSettings(dayCalendarViewOptionsSettings);
    emit(dayCalendarViewOptionsSettings);
  }
}
