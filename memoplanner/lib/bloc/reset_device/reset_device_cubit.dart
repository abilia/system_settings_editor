import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

class ResetDeviceCubit extends Cubit<ResetDeviceState> {
  final FactoryResetRepository factoryResetRepository;

  ResetDeviceCubit({required this.factoryResetRepository})
      : super(const ResetDeviceState(resetType: null));

  bool get isResetting => state is FactoryResetInProgress;

  Future<void> factoryResetDevice() async {
    emit(const FactoryResetInProgress());
    final success = await factoryResetRepository.factoryResetDevice();
    if (!success) {
      emit(const FactoryResetFailed());
    }
  }

  void setResetType(ResetType? resetType) {
    emit(ResetDeviceState(resetType: resetType));
  }
}

enum ResetType {
  factoryReset,
  clearData,
}

class ResetDeviceState extends Equatable {
  final ResetType? resetType;

  const ResetDeviceState({
    required this.resetType,
  });

  @override
  List<Object?> get props => [resetType];
}

class FactoryResetInProgress extends ResetDeviceState {
  const FactoryResetInProgress() : super(resetType: ResetType.factoryReset);
}

class FactoryResetFailed extends ResetDeviceState {
  const FactoryResetFailed() : super(resetType: ResetType.factoryReset);
}
