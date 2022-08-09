import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../../fakes/fakes_blocs.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  test('initial state', () {
    const settingsState = FunctionSettings();
    final functionSettingsCubit = FunctionSettingsCubit(
      functionSettings: settingsState,
      genericCubit: FakeGenericCubit(),
    );

    expect(
      functionSettingsCubit.state.display.week,
      settingsState.display.week,
    );
    expect(
      functionSettingsCubit.state.display.month,
      settingsState.display.week,
    );
    expect(
      functionSettingsCubit.state.display.newActivity,
      settingsState.display.newActivity,
    );
    expect(
      functionSettingsCubit.state.display.menuValue,
      settingsState.display.menuValue,
    );
    expect(
      functionSettingsCubit.state.screensaver.timeout,
      settingsState.screensaver.timeout,
    );
    expect(
      functionSettingsCubit.state.screensaver.use,
      settingsState.screensaver.use,
    );
    expect(
      functionSettingsCubit.state.screensaver.onlyDuringNight,
      settingsState.screensaver.onlyDuringNight,
    );
    expect(
      functionSettingsCubit.state.startView,
      settingsState.startView,
    );
  });

  test('state after all change', () {
    final functionSettingsCubit = FunctionSettingsCubit(
      functionSettings: const FunctionSettings(),
      genericCubit: FakeGenericCubit(),
    );

    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        display: const DisplaySettings(
          week: false,
          month: false,
          newActivity: false,
          menuValue: false,
        ),
        screensaver: const ScreensaverSettings(
          timeout: Duration(minutes: 1),
          use: true,
          onlyDuringNight: true,
        ),
        startView: StartView.photoAlbum,
      ),
    );

    expect(functionSettingsCubit.state.display.week, false);
    expect(
      functionSettingsCubit.state.display.month,
      false,
    );
    expect(
      functionSettingsCubit.state.display.newActivity,
      false,
    );
    expect(
      functionSettingsCubit.state.display.menuValue,
      false,
    );
    expect(
      functionSettingsCubit.state.screensaver.timeout,
      const Duration(minutes: 1),
    );
    expect(
      functionSettingsCubit.state.screensaver.use,
      true,
    );
    expect(
      functionSettingsCubit.state.screensaver.use,
      true,
    );
    expect(
      functionSettingsCubit.state.startView,
      StartView.photoAlbum,
    );
  });

  test('Removing a display state changes start view', () {
    // Arrange
    final functionSettingsCubit = FunctionSettingsCubit(
      functionSettings: const FunctionSettings(),
      genericCubit: FakeGenericCubit(),
    );

    // Act -- Change to week calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        startView: StartView.weekCalendar,
      ),
    );

    // Assert
    expect(
      functionSettingsCubit.state.display.week,
      true,
    );

    expect(
      functionSettingsCubit.state.startView,
      StartView.weekCalendar,
    );

    // Act -- Disable week calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        display: functionSettingsCubit.state.display.copyWith(week: false),
      ),
    );

    // Assert -- start view fallback to day calendar
    expect(
      functionSettingsCubit.state.display.week,
      false,
    );
    expect(
      functionSettingsCubit.state.startView,
      StartView.dayCalendar,
    );

    // Act -- try change to week calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        startView: StartView.weekCalendar,
      ),
    );

    // Assert -- does not change
    expect(
      functionSettingsCubit.state.startView,
      StartView.dayCalendar,
    );

    // Act -- change to month calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        startView: StartView.monthCalendar,
      ),
    );

    // Assert -- now month
    expect(
      functionSettingsCubit.state.startView,
      StartView.monthCalendar,
    );

    // Act -- disable month calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        display: functionSettingsCubit.state.display.copyWith(month: false),
      ),
    );

    // Assert -- fallback to day month
    expect(
      functionSettingsCubit.state.startView,
      StartView.dayCalendar,
    );

    // Act -- change to menu
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        startView: StartView.menu,
      ),
    );

    // Assert -- now menu
    expect(
      functionSettingsCubit.state.startView,
      StartView.menu,
    );

    // Act -- disable month calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        display: functionSettingsCubit.state.display.copyWith(menuValue: false),
      ),
    );

    // Assert -- fallback to day month
    expect(
      functionSettingsCubit.state.startView,
      StartView.dayCalendar,
    );
  });

  test('saving', () async {
    final genericCubit = MockGenericCubit();
    final functionSettingsCubit = FunctionSettingsCubit(
      functionSettings: const FunctionSettings(),
      genericCubit: genericCubit,
    );

    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        display: const DisplaySettings(
          week: false,
          month: false,
          newActivity: false,
          newTimer: false,
          menuValue: false,
        ),
        screensaver: const ScreensaverSettings(
          timeout: Duration.zero,
          use: true,
          onlyDuringNight: true,
        ),
        startView: StartView.photoAlbum,
      ),
    );

    final expectedSettingsData = [
      MemoplannerSettingData<dynamic>.fromData(
        data: false,
        identifier: DisplaySettings.functionMenuDisplayWeekKey,
      ),
      MemoplannerSettingData<dynamic>.fromData(
        data: false,
        identifier: DisplaySettings.functionMenuDisplayMonthKey,
      ),
      MemoplannerSettingData<dynamic>.fromData(
        data: false,
        identifier: DisplaySettings.functionMenuDisplayNewActivityKey,
      ),
      MemoplannerSettingData<dynamic>.fromData(
        data: false,
        identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
      ),
      MemoplannerSettingData<dynamic>.fromData(
          data: false, identifier: DisplaySettings.functionMenuDisplayMenuKey),
      MemoplannerSettingData<dynamic>.fromData(
        data: 0,
        identifier: ScreensaverSettings.activityTimeoutKey,
      ),
      MemoplannerSettingData<dynamic>.fromData(
        data: false, // if timeout is 0 screensaver should be false
        identifier: ScreensaverSettings.useScreensaverKey,
      ),
      MemoplannerSettingData<dynamic>.fromData(
        data: true,
        identifier: ScreensaverSettings.screenSaverOnlyDuringNightKey,
      ),
      MemoplannerSettingData<dynamic>.fromData(
        data: StartView.photoAlbum.index,
        identifier: FunctionSettings.functionMenuStartViewKey,
      ),
    ];

    expect(
      functionSettingsCubit.state.memoplannerSettingData,
      expectedSettingsData,
    );

    // Act -- save
    functionSettingsCubit.save();

    // Assert -- calls genericCubit

    final captured =
        verify(() => genericCubit.genericUpdated(captureAny())).captured;
    expect(captured, hasLength(1));

    expect(captured.single.runtimeType, List<MemoplannerSettingData<dynamic>>);
    expect(
      (captured.single as List<MemoplannerSettingData<dynamic>>),
      expectedSettingsData,
    );
  });
}
