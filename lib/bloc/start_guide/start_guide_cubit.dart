import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:uuid/uuid.dart';

class StartGuideCubit extends Cubit<StartGuideState> {
  StartGuideCubit({
    required this.deviceRepository,
    required StartGuideState initialState,
  }) : super(initialState);

  final DeviceRepository deviceRepository;

  void verifySerialId(String serialId) async {
    try {
      final clientId = const Uuid().v4();
      final verifiedOk =
          await deviceRepository.verifyDevice(serialId, clientId);
      if (verifiedOk) {
        await deviceRepository.setSerialId(serialId);
        await deviceRepository.setClientId(clientId);
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
    deviceRepository.setClientId(const Uuid().v4());
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
