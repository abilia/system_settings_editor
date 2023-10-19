import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:permissions/permission_cubit.dart';
import 'package:text_to_speech/text_to_speech.dart';

part 'production_guide_state.dart';

class ProductionGuideCubit extends Cubit<ProductionGuideState> {
  final SpeechSettingsCubit speechSettingsCubit;
  final PermissionCubit permissionCubit;

  ProductionGuideCubit({
    required this.speechSettingsCubit,
    required this.permissionCubit,
  }) : super(
          getState(speechSettingsCubit.state, permissionCubit.state.status),
        ) {
    speechSettingsCubit.stream.listen((speechState) =>
        emit(getState(speechState, permissionCubit.state.status)));
    permissionCubit.stream.listen((permissionState) =>
        emit(getState(speechSettingsCubit.state, permissionState.status)));
  }

  static ProductionGuideState getState(
    SpeechSettingsState speechSettingsState,
    Map<Permission, PermissionStatus> permissionStatus,
  ) {
    if (speechSettingsState.voice.isNotEmpty &&
        permissionStatus[Permission.ignoreBatteryOptimizations] ==
            PermissionStatus.granted) {
      return ProductionGuideDone();
    }
    return ProductionGuideNotDone();
  }
}
