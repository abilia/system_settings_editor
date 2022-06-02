import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class ProductionGuideCubit extends Cubit<ProductionGuideState> {
  ProductionGuideCubit({
    required this.deviceRepository,
  }) : super(Config.isMP && deviceRepository.serialId.isEmpty
            ? ProductionGuideInitial()
            : Config.isMP
                ? StartupGuideInitial()
                : InitializationDone());

  final DeviceRepository deviceRepository;

  void verifySerialId(String serialId) async {
    try {
      final clientId = await deviceRepository.getClientId();
      final verifiedOk =
          await deviceRepository.verifyDevice(serialId, clientId);
      if (verifiedOk) {
        await deviceRepository.setSerialId(serialId);
        emit(StartupGuideInitial());
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
    emit(StartupGuideInitial());
  }
}

abstract class ProductionGuideState {}

class InitializationDone extends ProductionGuideState {}

class StartupGuideInitial extends ProductionGuideState {}

class ProductionGuideInitial extends ProductionGuideState {}

class VerifySerialIdFailed extends ProductionGuideState {
  final String message;

  VerifySerialIdFailed(this.message);
}
