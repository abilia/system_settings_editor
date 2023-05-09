import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sortables/all.dart';

class MockSortableRepository extends Mock implements SortableRepository {}

class MockSortableBloc extends MockBloc<SortableEvent, SortableState>
    implements SortableBloc {}
