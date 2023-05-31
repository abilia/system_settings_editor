import 'package:meta/meta.dart';
import 'package:sortables/models/sortable/sortable.dart';

///
/// Sort order algorithm copied from myAbilia frontend code with adjustments to dart.
///

const String _sortOrderCharacters =
    '!"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}';
const startChar = '!', endChar = '}', startSortOrder = 'O';

@visibleForTesting
String calculateNextSortOrder(String sortOrder, int step) {
  if (sortOrder.isEmpty) return startSortOrder;
  final i = sortOrder.length - 1;
  var arr = sortOrder.split('').toList();
  final next = sortOrder.codeUnitAt(i) + step;
  final nextSort = String.fromCharCode(next);

  if (nextSort.compareTo(startChar) <= 0) {
    if (i == 0 || sortOrder[i - 1] == startChar) {
      arr[i] = startChar;
      arr.add(endChar);
    } else {
      arr[i] = '';
      arr = calculateNextSortOrder(arr.join(''), 0).split('');
    }
  } else if (nextSort.compareTo(endChar) > 0) {
    if (i > 0 && arr.join('')[i - 1] == startChar) {
      arr[i - 1] =
          _sortOrderCharacters[(_sortOrderCharacters.indexOf(startChar) + 1)];
      arr[i] = '';
    } else {
      arr.add(String.fromCharCode(startChar.codeUnitAt(0) + 1));
    }
  } else {
    arr[i] = nextSort;
  }

  return arr.join('');
}

extension SortExtension on Iterable<Sortable> {
  String firstSortOrderForFolder({String folderId = ''}) =>
      where((s) => s.groupId == folderId).firstSortOrder();

  String firstSortOrder() {
    if (isEmpty) return startSortOrder;
    final sorted = toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return calculateNextSortOrder(sorted.first.sortOrder, -1);
  }
}
