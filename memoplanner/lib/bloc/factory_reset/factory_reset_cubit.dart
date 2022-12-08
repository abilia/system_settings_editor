import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

class FactoryResetCubit extends Cubit<FactoryResetState?> {
  final FactoryResetRepository factoryResetRepository;

  FactoryResetCubit({required this.factoryResetRepository}) : super(null);

  bool get isResetting => state is FactoryResetInProgress;

  Future<void> factoryResetDevice() async {
    emit(const FactoryResetInProgress());
    final result = await factoryResetRepository.factoryResetDevice();
    if (!result) {
      emit(const FactoryResetFailed());
    }
  }
}

abstract class FactoryResetState extends Equatable {
  const FactoryResetState();

  @override
  List<Object?> get props => [];
}

class FactoryResetInProgress extends FactoryResetState {
  const FactoryResetInProgress();
}

class FactoryResetFailed extends FactoryResetState {
  const FactoryResetFailed();
}
