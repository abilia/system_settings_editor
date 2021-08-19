part of 'calendar_view_bloc.dart';

class ToggleCategory extends Equatable {
  final int category;
  const ToggleCategory(this.category);
  @override
  List<Object> get props => [category];
}
