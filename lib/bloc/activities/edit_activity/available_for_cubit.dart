import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/models/support_person.dart';
import 'package:seagull/repository/data_repository/support_persons_repository.dart';

class AvailableForCubit extends Cubit<AvailableForState> {
  AvailableForCubit({
    required this.supportPersonsRepository,
    AvailableForType? availableFor,
    Iterable<int>? selectedSupportPersons,
  }) : super(
          AvailableForState(
            availableFor: availableFor ?? AvailableForType.allSupportPersons,
            selectedSupportPersons: selectedSupportPersons ?? const <int>[],
            allSupportPersons: const [],
          ),
        ) {
    initialize();
  }

  void initialize() async {
    emit(
      state.copyWith(
        allSupportPersons: await supportPersonsRepository.load(),
      ),
    );
  }

  final SupportPersonsRepository supportPersonsRepository;

  void setAvailableFor(AvailableForType availableFor) => emit(
        state.copyWith(
          availableFor: availableFor,
          selectedSupportPersons: const [],
        ),
      );

  void selectSupportPerson(int id) {
    final _supportPersons = Set<int>.from(state.selectedSupportPersons);
    if (!_supportPersons.remove(id)) {
      _supportPersons.add(id);
    }
    emit(state.copyWith(selectedSupportPersons: _supportPersons));
  }
}

class AvailableForState extends Equatable {
  const AvailableForState({
    required this.allSupportPersons,
    required this.availableFor,
    required this.selectedSupportPersons,
  });

  final AvailableForType availableFor;
  final Iterable<int> selectedSupportPersons;
  final Iterable<SupportPerson> allSupportPersons;

  AvailableForState copyWith({
    AvailableForType? availableFor,
    Iterable<int>? selectedSupportPersons,
    Iterable<SupportPerson>? allSupportPersons,
  }) =>
      AvailableForState(
        availableFor: availableFor ?? this.availableFor,
        selectedSupportPersons:
            selectedSupportPersons ?? this.selectedSupportPersons,
        allSupportPersons: allSupportPersons ?? this.allSupportPersons,
      );

  @override
  List<Object?> get props => [
        availableFor,
        selectedSupportPersons,
        allSupportPersons,
      ];
}
