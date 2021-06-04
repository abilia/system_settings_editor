import 'package:seagull/models/all.dart';

///
/// Sort order algorithm copied from myAbilia frontend code with adjustments to dart.
///

const String SORT_ORDER_CHARACTERS =
    '!"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}';
const START_CHAR = '!';
const END_CHAR = '}';

String getStartSortOrder() =>
    SORT_ORDER_CHARACTERS[((SORT_ORDER_CHARACTERS.length / 2).floor())];

String calculateNextSortOrder(String sortOrder, int step) {
  final i = sortOrder.length - 1;
  var arr = sortOrder.split('').toList();
  final next = sortOrder.codeUnitAt(i) + step;
  final nextSort = String.fromCharCode(next);

  if (nextSort.compareTo(START_CHAR) <= 0) {
    if (i == 0 || sortOrder[i - 1] == START_CHAR) {
      arr[i] = START_CHAR;
      arr.add(END_CHAR);
    } else {
      arr[i] = '';
      arr = calculateNextSortOrder(arr.join(''), 0).split('');
    }
  } else if (nextSort.compareTo(END_CHAR) > 0) {
    if (i > 0 && arr.join('')[i - 1] == START_CHAR) {
      arr[i - 1] = SORT_ORDER_CHARACTERS[
          (SORT_ORDER_CHARACTERS.indexOf(START_CHAR) + 1)];
      arr[i] = '';
    } else {
      arr.add(String.fromCharCode(START_CHAR.codeUnitAt(0) + 1));
    }
  } else {
    arr[i] = nextSort;
  }

  return arr.join('');
}

extension SortExtension on Iterable<Sortable> {
  String firstSortOrderInFolder(String folderId) {
    final root = where((s) => s.groupId == folderId).toList();
    root.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return root.isEmpty
        ? getStartSortOrder()
        : calculateNextSortOrder(root.first.sortOrder, -1);
  }
}
