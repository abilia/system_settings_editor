import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

void main() {
  late Database db;
  late SortableDb sortableDb;

  setUp(() async {
    db = await DatabaseRepository.createInMemoryFfiDb();
    sortableDb = SortableDb(db);
  });
  testWidgets('sortable db ...', (tester) async {});

  test('Test add sortable', () async {
    final all = await sortableDb.getAll();
    expect(all.length, 0);
    final s = Sortable.createNew<BasicActivityDataItem>(
      data: BasicActivityDataItem.createNew(title: 'title'),
    ).wrapWithDbModel();
    final ss = s as DbModel<Sortable<SortableData>>;
    await sortableDb.insert([ss]);

    final all2 = await sortableDb.getAll();
    expect(all2.length, 1);
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });
}
