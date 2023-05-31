import 'package:mocktail/mocktail.dart';
import 'package:sortables/bloc/sortable_bloc.dart';

void registerFallbackValues() {
  registerFallbackValue(Uri());
  registerFallbackValue(const LoadSortables());
}
