import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

class ResetDeviceCubit extends Cubit<ResetDeviceState> {
  final FactoryResetRepository factoryResetRepository;

  ResetDeviceCubit({required this.factoryResetRepository})
      : super(const ResetDeviceState(input: '', resetType: null));

  bool get isResetting => state is FactoryResetInProgress;

  Future<void> factoryResetDevice() async {
    emit(FactoryResetInProgress(state));
    final success = await factoryResetRepository.factoryResetDevice();
    if (!success) {
      emit(FactoryResetFailed(state));
    }
  }

  void setInput(String input) {
    emit(ResetDeviceState(input: input, resetType: state.resetType));
  }

  void setResetType(ResetType? resetType) {
    emit(ResetDeviceState(input: state.input, resetType: resetType));
  }
}

enum ResetType {
  factoryReset,
  clearData,
}

class ResetDeviceState extends Equatable {
  static const String _factoryResetCode = 'FactoryresetMP4';
  final String input;
  final ResetType? resetType;

  bool get correctInputOrEmpty => correctInput || input.isEmpty;

  bool get correctInput => input == _factoryResetCode;

  const ResetDeviceState({
    required this.input,
    required this.resetType,
  });

  @override
  List<Object?> get props => [input, resetType];
}

class FactoryResetInProgress extends ResetDeviceState {
  FactoryResetInProgress(ResetDeviceState previousState)
      : super(input: previousState.input, resetType: previousState.resetType);
}

class FactoryResetFailed extends ResetDeviceState {
  FactoryResetFailed(ResetDeviceState previousState)
      : super(input: previousState.input, resetType: previousState.resetType);
}
