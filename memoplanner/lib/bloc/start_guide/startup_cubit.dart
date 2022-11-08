import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

class StartupCubit extends Cubit<StartupState> {
  StartupCubit({
    required this.deviceRepository,
  }) : super(Config.isMP && deviceRepository.serialId.isEmpty
            ? ProductionGuide()
            : Config.isMP && !deviceRepository.isStartGuideCompleted
                ? WelcomeGuide()
                : StartupDone());

  final DeviceRepository deviceRepository;

  Future<void> verifySerialId(String serialId, String licenseKey) async {
    try {
      final clientId = await deviceRepository.getClientId();
      final verifiedOk = await deviceRepository.verifyDevice(
        serialId,
        clientId,
        licenseKey.replaceAll(RegExp('-| '), ''),
      );
      if (verifiedOk) {
        await deviceRepository.setSerialId(serialId);
        emit(WelcomeGuide());
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
    emit(WelcomeGuide());
  }

  Future<void> startGuideDone() async {
    await deviceRepository.setStartGuideCompleted();
    emit(StartupDone());
  }

  Future<void> resetStartGuideDone() async {
    await deviceRepository.setStartGuideCompleted(false);
    emit(WelcomeGuide());
  }
}

abstract class StartupState {}

class StartupDone extends StartupState {}

class WelcomeGuide extends StartupState {}

class ProductionGuide extends StartupState {}

class VerifySerialIdFailed extends StartupState {
  final String message;

  VerifySerialIdFailed(this.message);
}
