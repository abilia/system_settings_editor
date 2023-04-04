import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/activity/activity.dart';
import 'package:memoplanner/models/support_person.dart';

class AvailableForCubit extends Cubit<AvailableForState> {
  late StreamSubscription _supportPersonsSubscription;

  AvailableForCubit({
    required SupportPersonsCubit supportPersonsCubit,
    required AvailableForType availableFor,
    required Set<int> selectedSupportPersons,
  }) : super(
          AvailableForState(
            availableFor: availableFor,
            selectedSupportPersons: UnmodifiableSetView(selectedSupportPersons),
            allSupportPersons: UnmodifiableSetView(
              supportPersonsCubit.state.supportPersons,
            ),
          ),
        ) {
    _supportPersonsSubscription = supportPersonsCubit.stream.listen(
      (supportPersonsState) => emit(
        state.copyWith(
          allSupportPersons: supportPersonsState.supportPersons,
        ),
      ),
    );
    unawaited(supportPersonsCubit.loadSupportPersons());
  }

  @override
  Future<void> close() {
    _supportPersonsSubscription.cancel();
    return super.close();
  }

  void setAvailableFor(AvailableForType availableFor) => emit(
        state.copyWith(
          availableFor: availableFor,
          selectedSupportPersons: const {},
        ),
      );

  void toggleSupportPerson(int id) {
    final supportPersons = Set<int>.from(state.selectedSupportPersons);
    if (!supportPersons.remove(id)) {
      supportPersons.add(id);
    }
    emit(state.copyWith(selectedSupportPersons: supportPersons));
  }
}

class AvailableForState extends Equatable {
  const AvailableForState({
    required this.allSupportPersons,
    required this.availableFor,
    required this.selectedSupportPersons,
  });

  final AvailableForType availableFor;
  final UnmodifiableSetView<int> selectedSupportPersons;
  final UnmodifiableSetView<SupportPerson> allSupportPersons;

  AvailableForState copyWith({
    AvailableForType? availableFor,
    Set<int>? selectedSupportPersons,
    Set<SupportPerson>? allSupportPersons,
  }) =>
      AvailableForState(
        availableFor: availableFor ?? this.availableFor,
        selectedSupportPersons: selectedSupportPersons != null
            ? UnmodifiableSetView(selectedSupportPersons)
            : this.selectedSupportPersons,
        allSupportPersons: allSupportPersons != null
            ? UnmodifiableSetView(allSupportPersons)
            : this.allSupportPersons,
      );

  @override
  List<Object?> get props => [
        availableFor,
        selectedSupportPersons,
        allSupportPersons,
      ];
}
