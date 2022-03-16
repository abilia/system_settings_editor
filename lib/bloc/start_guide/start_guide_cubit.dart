import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class StartGuideCubit extends Cubit<StartGuideState> {
  StartGuideCubit({
    required this.deviceRepository,
    required bool runStartGuide,
  }) : super(runStartGuide ? StartGuideInitial() : StartGuideDone());

  final DeviceRepository deviceRepository;

  void verifySerialId(String serialId) async {
    try {
      final clientId = await deviceRepository.getClientId();
      final verifiedOk =
          await deviceRepository.verifyDevice(serialId, clientId);
      if (verifiedOk) {
        await deviceRepository.setSerialId(serialId);
        emit(StartGuideDone());
      } else {
        emit(VerifySerialIdFailed('Serial id $serialId not found in myAbilia'));
      }
    } on VerifyDeviceException catch (e) {
      emit(VerifySerialIdFailed(
          'Error when trying to verify serial id $serialId. ${e.badRequest.message}'));
    }
  }

  void skipStartGuide() {
    deviceRepository.setSerialId('debugSerialId');
    emit(StartGuideDone());
  }
}

abstract class StartGuideState {}

class StartGuideDone extends StartGuideState {}

class StartGuideInitial extends StartGuideState {}

class VerifySerialIdFailed extends StartGuideState {
  final String message;

  VerifySerialIdFailed(this.message);
}