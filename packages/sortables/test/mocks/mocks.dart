import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sortables/sortables.dart';

class MockSortableRepository extends Mock implements SortableRepository {}

class MockSortableBloc extends MockBloc<SortableEvent, SortableState>
    implements SortableBloc {}
