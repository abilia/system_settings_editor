import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class ProductionGuideCubit extends Cubit<ProductionGuideState> {
  ProductionGuideCubit({
    required this.deviceRepository,
    required bool runProductionGuide,
  }) : super(runProductionGuide
            ? ProductionGuideInitial()
            : ProductionGuideDone());

  final DeviceRepository deviceRepository;

  void verifySerialId(String serialId) async {
    try {
      final clientId = await deviceRepository.getClientId();
      final verifiedOk =
          await deviceRepository.verifyDevice(serialId, clientId);
      if (verifiedOk) {
        await deviceRepository.setSerialId(serialId);
        emit(ProductionGuideDone());
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
    emit(ProductionGuideDone());
  }
}

abstract class ProductionGuideState {}

class ProductionGuideDone extends ProductionGuideState {}

class ProductionGuideInitial extends ProductionGuideState {}

class VerifySerialIdFailed extends ProductionGuideState {
  final String message;

  VerifySerialIdFailed(this.message);
}
