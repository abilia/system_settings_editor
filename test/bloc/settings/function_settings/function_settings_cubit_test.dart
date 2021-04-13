import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../../mocks.dart';
import '../../../utils/types.dart';

void main() {
  test('initial state', () {
    final settingsState = MemoplannerSettingsNotLoaded();
    final functionSettingsCubit = FunctionSettingsCubit(
      settingsState: settingsState,
      genericBloc: MockGenericBloc(),
    );

    expect(
      functionSettingsCubit.state.displayWeek,
      settingsState.displayWeekCalendar,
    );
    expect(
      functionSettingsCubit.state.displayMonth,
      settingsState.displayMonthCalendar,
    );
    expect(
      functionSettingsCubit.state.displayNewActivity,
      settingsState.displayNewActivity,
    );
    expect(
      functionSettingsCubit.state.displayMenu,
      settingsState.displayMenu,
    );
    expect(
      functionSettingsCubit.state.timeout,
      settingsState.activityTimeout,
    );
    expect(
      functionSettingsCubit.state.useScreensaver,
      settingsState.useScreensaver,
    );
    expect(
      functionSettingsCubit.state.startView,
      settingsState.startView,
    );
  });

  test('state after all change', () {
    final functionSettingsCubit = FunctionSettingsCubit(
      settingsState: MemoplannerSettingsNotLoaded(),
      genericBloc: MockGenericBloc(),
    );

    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        displayWeek: false,
        displayMonth: false,
        displayNewActivity: false,
        displayMenu: false,
        timeout: 60000,
        useScreensaver: true,
        startView: StartView.photoAlbum,
      ),
    );

    expect(functionSettingsCubit.state.displayWeek, false);
    expect(
      functionSettingsCubit.state.displayMonth,
      false,
    );
    expect(
      functionSettingsCubit.state.displayNewActivity,
      false,
    );
    expect(
      functionSettingsCubit.state.displayMenu,
      false,
    );
    expect(
      functionSettingsCubit.state.timeout,
      60000,
    );
    expect(
      functionSettingsCubit.state.useScreensaver,
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
      settingsState: MemoplannerSettingsNotLoaded(),
      genericBloc: MockGenericBloc(),
    );

    // Act -- Change to week calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        startView: StartView.weekCalendar,
      ),
    );

    // Assert
    expect(
      functionSettingsCubit.state.displayWeek,
      true,
    );

    expect(
      functionSettingsCubit.state.startView,
      StartView.weekCalendar,
    );

    // Act -- Disable week calendar
    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        displayWeek: false,
      ),
    );

    // Assert -- start view fallback to day calendar
    expect(
      functionSettingsCubit.state.displayWeek,
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
        displayMonth: false,
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
        displayMenu: false,
      ),
    );

    // Assert -- fallback to day month
    expect(
      functionSettingsCubit.state.startView,
      StartView.dayCalendar,
    );
  });

  test('saving', () {
    final genericBloc = MockGenericBloc();
    final functionSettingsCubit = FunctionSettingsCubit(
      settingsState: MemoplannerSettingsNotLoaded(),
      genericBloc: genericBloc,
    );

    functionSettingsCubit.changeFunctionSettings(
      functionSettingsCubit.state.copyWith(
        displayWeek: false,
        displayMonth: false,
        displayNewActivity: false,
        displayMenu: false,
        timeout: 0,
        useScreensaver: true,
        startView: StartView.photoAlbum,
      ),
    );

    final expectedSettingsData = [
      MemoplannerSettingData.fromData(
        data: false,
        identifier: MemoplannerSettings.functionMenuDisplayWeekKey,
      ),
      MemoplannerSettingData.fromData(
        data: false,
        identifier: MemoplannerSettings.functionMenuDisplayMonthKey,
      ),
      MemoplannerSettingData.fromData(
        data: false,
        identifier: MemoplannerSettings.functionMenuDisplayNewActivityKey,
      ),
      MemoplannerSettingData.fromData(
          data: false,
          identifier: MemoplannerSettings.functionMenuDisplayMenuKey),
      MemoplannerSettingData.fromData(
        data: 0,
        identifier: MemoplannerSettings.activityTimeoutKey,
      ),
      MemoplannerSettingData.fromData(
        data: false, // if timeout is 0 screensaver should be false
        identifier: MemoplannerSettings.useScreensaverKey,
      ),
      MemoplannerSettingData.fromData(
        data: StartView.photoAlbum.index,
        identifier: MemoplannerSettings.functionMenuStartViewKey,
      ),
    ];

    expect(
      functionSettingsCubit.state.memoplannerSettingData,
      expectedSettingsData,
    );

    // Act -- save
    functionSettingsCubit.save();

    // Assert -- calls genericBloc
    final captured = verify(genericBloc.add(captureAny)).captured;
    expect(captured, hasLength(1));
    expect(captured.single.runtimeType, typeOf<GenericUpdated>());
    expect(
      (captured.single as GenericUpdated).genericData,
      expectedSettingsData,
    );
  });
}