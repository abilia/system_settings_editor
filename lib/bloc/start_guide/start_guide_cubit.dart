import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class StartGuideCubit extends Cubit<StartGuideState> {
  StartGuideCubit({
    required this.serialIdRepository,
    required StartGuideState initialState,
  }) : super(initialState);

  final SerialIdRepository serialIdRepository;

  void verifySerialId(String serialId) async {
    try {
      final ok = await serialIdRepository.verifyDevice(serialId);
      if (ok) {
        serialIdRepository.setSerialId(serialId);
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
    serialIdRepository.setSerialId('debugSerialId');
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
