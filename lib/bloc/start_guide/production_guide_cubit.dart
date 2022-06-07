import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class ProductionGuideCubit extends Cubit<StartupState> {
  ProductionGuideCubit({
    required this.deviceRepository,
  }) : super(Config.isMP && deviceRepository.serialId.isEmpty
            ? ProductionGuide()
            : Config.isMP && !deviceRepository.isStartGuideCompleted
                ? StartupGuide()
                : StartupDone());

  final DeviceRepository deviceRepository;

  void verifySerialId(String serialId) async {
    try {
      final clientId = await deviceRepository.getClientId();
      final verifiedOk =
          await deviceRepository.verifyDevice(serialId, clientId);
      if (verifiedOk) {
        await deviceRepository.setSerialId(serialId);
        emit(StartupGuide());
      } else {
        emit(VerifySerialIdFailed('Serial id $serialId not found in myAbilia'));
      }
    } on VerifyDeviceException catch (e) {
      emit(VerifySerialIdFailed(
          'Error when trying to verify serial id $serialId. ${e.badRequest.message}'));
    }
  }

  void skipProductionGuide() {
    deviceRepository.setSerialId('debugSerialId');
    emit(StartupGuide());
  }

  void startGuideDone() async {
    await deviceRepository.setStartGuideCompleted();
    emit(StartupDone());
  }
}

abstract class StartupState {}

class StartupDone extends StartupState {}

class StartupGuide extends StartupState {}

class ProductionGuide extends StartupState {}

class VerifySerialIdFailed extends StartupState {
  final String message;

  VerifySerialIdFailed(this.message);
}
