import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

class ResetDeviceCubit extends Cubit<ResetDeviceState> {
  final FactoryResetRepository factoryResetRepository;

  ResetDeviceCubit({required this.factoryResetRepository})
      : super(const ResetDeviceState(input: '', resetType: null));

  bool get isResetting => state is FactoryResetInProgress;

  Future<void> factoryResetDevice() async {
    emit(FactoryResetInProgress(
      input: state.input,
      resetType: state.resetType,
    ));
    final result = await factoryResetRepository.factoryResetDevice();
    if (!result) {
      emit(FactoryResetFailed(input: state.input, resetType: state.resetType));
    }
  }

  void setInput(String input) {
    emit(ResetDeviceState(input: input, resetType: state.resetType));
  }

  void setResetType(ResetType? resetType) {
    emit(ResetDeviceState(input: state.input, resetType: resetType));
  }

  void reset() {
    emit(const ResetDeviceState(input: '', resetType: null));
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
  const FactoryResetInProgress({
    required String input,
    required ResetType? resetType,
  }) : super(input: input, resetType: resetType);
}

class FactoryResetFailed extends ResetDeviceState {
  const FactoryResetFailed({
    required String input,
    required ResetType? resetType,
  }) : super(input: input, resetType: resetType);
}
