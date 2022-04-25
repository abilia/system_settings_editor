part of 'edit_checklist_cubit.dart';

class EditChecklistState extends Equatable {
  final Checklist checklist;
  final int? index;
  Question? get selected => index != null ? checklist.questions[index!] : null;
  bool get disableUp => index == 0;
  bool get disableDown => index == checklist.questions.length - 1;

  EditChecklistState(InfoItem checklist, [this.index])
      : checklist = checklist is Checklist ? checklist : Checklist();

  EditChecklistState select(int? index) => EditChecklistState(checklist, index);
  EditChecklistState changeChecklist(Checklist checklist, int? index) =>
      EditChecklistState(checklist, index);

  @override
  List<Object?> get props => [checklist, index];
}
