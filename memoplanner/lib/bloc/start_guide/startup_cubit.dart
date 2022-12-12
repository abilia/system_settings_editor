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
                ? LoadingLicense()
                : StartupDone()) {
    if (state is LoadingLicense) checkConnectedLicense();
  }

  final DeviceRepository deviceRepository;

  Future<void> verifySerialId(String serialId, String licenseKey) async {
    emit(Verifying());
    try {
      final clientId = await deviceRepository.getClientId();
      final verifiedOk = await deviceRepository.verifyDevice(
        serialId,
        clientId,
        licenseKey.replaceAll(RegExp(r'\D'), ''),
      );
      if (verifiedOk) {
        await deviceRepository.setSerialId(serialId);
        await checkConnectedLicense();
      } else {
        emit(VerifySerialIdFailed('Serial id $serialId not found in myAbilia'));
      }
    } on VerifyDeviceException catch (e) {
      emit(
        VerifySerialIdFailed(
          'Error when trying to verify serial id '
          '$serialId. ${e.badRequest.message}',
        ),
      );
    } catch (e) {
      emit(VerifySerialIdFailed('Error when trying to verify serial id'));
    }
  }

  Future<void> checkConnectedLicense() async {
    try {
      emit(LoadingLicense());
      final connectedLicense = await deviceRepository.checkLicense();
      if (isClosed) return;
      final product = connectedLicense.product;
      if (product == null) return emit(NoConnectedLicense('Product is null'));
      if (product != memoplannerLicenseName) {
        return emit(NoConnectedLicense('Wrong product name: $product'));
      }

      return emit(
        LicenseConnected(
          serialNumber: connectedLicense.serialNumber,
          product: product,
          endTime: connectedLicense.endTime ??
              DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    } on VerifyDeviceException catch (e) {
      emit(LoadingLicenseFailed(e.badRequest.message));
    } catch (e) {
      emit(LoadingLicenseFailed(e));
    }
  }

  Future<void> skipProductionGuide() async {
    deviceRepository.setSerialId('debugSerialId');
    await startGuideDone();
  }

  Future<void> startGuideDone() async {
    await deviceRepository.setStartGuideCompleted();
    emit(StartupDone());
  }

  Future<void> resetStartGuideDone() async {
    await deviceRepository.setStartGuideCompleted(false);
    await checkConnectedLicense();
  }
}

abstract class StartupState {}

class StartupDone extends StartupState {}

class ProductionGuide extends StartupState {}

class Verifying extends StartupState {}

class VerifySerialIdFailed extends StartupState {
  final String message;

  VerifySerialIdFailed(this.message);
}

abstract class WelcomeGuide extends StartupState {}

class LoadingLicense extends WelcomeGuide {}

class LoadingLicenseFailed extends WelcomeGuide {
  final Object? exception;
  LoadingLicenseFailed([this.exception]);

  @override
  String toString() => 'LoadingLicenseFailed $exception';
}

abstract class LicenseLoaded extends WelcomeGuide {}

class NoConnectedLicense extends LicenseLoaded {
  final String reason;

  NoConnectedLicense(this.reason);
  @override
  String toString() => 'NoConnectedLicense $reason';
}

class LicenseConnected extends LicenseLoaded {
  final String serialNumber, product;
  final DateTime endTime;
  bool get hasEndTime => endTime != DateTime.fromMillisecondsSinceEpoch(0);

  LicenseConnected({
    required this.serialNumber,
    required this.product,
    required this.endTime,
  });
  @override
  String toString() => 'LicenseConnected [$serialNumber, $product, $endTime]';
}
