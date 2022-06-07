import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/models/support_person.dart';
import 'package:seagull/repository/data_repository/support_persons_repository.dart';

class AvailableForCubit extends Cubit<AvailableForState> {
  AvailableForCubit({
    required this.supportPersonsRepository,
    AvailableForType? availableFor,
    List<int>? selectedSupportPersons,
  }) : super(
          AvailableForState(
            availableFor: availableFor ?? AvailableForType.allSupportPersons,
            selectedSupportPersons: selectedSupportPersons ?? const [],
            allSupportPersons: const [],
          ),
        ) {
    initialize();
  }

  void initialize() async {
    emit(
      state.copyWith(
        allSupportPersons:
            await supportPersonsRepository.fetchAllAndInsertIntoDb(),
      ),
    );
  }

  final SupportPersonsRepository supportPersonsRepository;

  void setAvailableFor(AvailableForType availableFor) => emit(state.copyWith(
      availableFor: availableFor,
      selectedSupportPersons:
          availableFor != AvailableForType.selectedSupportPersons ? [] : null));

  void selectSupportPerson(int id, bool selected) {
    if (selected && !state.selectedSupportPersons.contains(id)) {
      emit(state.copyWith(
          selectedSupportPersons: List.from(state.selectedSupportPersons)
            ..add(id)));
    } else if (!selected && state.selectedSupportPersons.contains(id)) {
      emit(state.copyWith(
          selectedSupportPersons: List.from(state.selectedSupportPersons)
            ..remove(id)));
    }
  }
}

class AvailableForState extends Equatable {
  const AvailableForState({
    required this.allSupportPersons,
    required this.availableFor,
    required this.selectedSupportPersons,
  });

  final AvailableForType availableFor;
  final List<int> selectedSupportPersons;
  final Iterable<SupportPerson> allSupportPersons;

  AvailableForState copyWith(
          {AvailableForType? availableFor,
          List<int>? selectedSupportPersons,
          Iterable<SupportPerson>? allSupportPersons}) =>
      AvailableForState(
          availableFor: availableFor ?? this.availableFor,
          selectedSupportPersons:
              selectedSupportPersons ?? this.selectedSupportPersons,
          allSupportPersons: allSupportPersons ?? this.allSupportPersons);

  @override
  List<Object?> get props => [
        availableFor,
        selectedSupportPersons,
        allSupportPersons,
      ];
}
