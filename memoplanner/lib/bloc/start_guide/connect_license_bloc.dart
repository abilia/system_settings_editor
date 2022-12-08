import 'dart:async';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

import 'package:memoplanner/repository/all.dart';

class ConnectLicenseBloc extends Bloc<String, ConnectLicenseState> {
  ConnectLicenseBloc({required this.deviceRepository})
      : super(ConnectLicenseState()) {
    on<String>(connectWithLicense, transformer: droppable());
  }

  final DeviceRepository deviceRepository;

  Future<void> connectWithLicense(
    String license,
    Emitter<ConnectLicenseState> emit,
  ) async {
    if (state is SuccessfullyConnectedLicense) return;
    if (license.length < licenseLength) {
      return emit(ConnectLicenseState());
    }
    try {
      emit(ConnectingLicense());
      final connectedLicense =
          await deviceRepository.connectWithLicense(license);
      if (isClosed) return;
      return emit(
        SuccessfullyConnectedLicense(
          license: license,
          endTime: connectedLicense.endTime ??
              DateTime.fromMicrosecondsSinceEpoch(0),
        ),
      );
    } on ConnectedLicenseException catch (e) {
      emit(ConnectingLicenseFailed(e.reason, e));
    } on SocketException {
      emit(ConnectingLicenseFailed(ConnectingLicenseFailedReason.noConnection));
    } catch (e) {
      emit(ConnectingLicenseFailed(ConnectingLicenseFailedReason.unknown, e));
    }
  }
}

class ConnectLicenseState extends Equatable {
  @override
  List<Object?> get props => [];
  @override
  bool get stringify => true;
}

class ConnectingLicense extends ConnectLicenseState {
  @override
  List<Object?> get props => [];
}

class ConnectingLicenseFailed extends ConnectLicenseState {
  final ConnectingLicenseFailedReason reason;
  final Object? exception;
  ConnectingLicenseFailed(this.reason, [this.exception]);

  @override
  List<Object?> get props => [reason, exception];
}

class SuccessfullyConnectedLicense extends ConnectLicenseState {
  final String license;
  final DateTime endTime;
  bool get hasEndTime => endTime != DateTime.fromMillisecondsSinceEpoch(0);

  SuccessfullyConnectedLicense({
    required this.license,
    required this.endTime,
  });
  @override
  List<Object?> get props => [license, endTime];
}
