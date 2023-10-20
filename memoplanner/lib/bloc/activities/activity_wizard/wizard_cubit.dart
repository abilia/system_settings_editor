import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/models/all.dart';

part 'wizard_state.dart';

abstract class WizardCubit extends Cubit<WizardState> {
  WizardCubit(super.initialState);
  void next({
    bool warningConfirmed = false,
    SaveRecurring? saveRecurring,
  });

  void previous() =>
      emit(state.copyWith(newStep: (state.step - 1), saveErrors: {}));

  void removeCorrectedErrors();
}

class SaveRecurring {
  final ApplyTo applyTo;
  final DateTime day;

  const SaveRecurring(this.applyTo, this.day);
}
