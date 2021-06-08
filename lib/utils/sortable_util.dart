import 'package:seagull/models/all.dart';
import 'package:collection/collection.dart';

extension SortableExtension on Iterable<Sortable> {
  Sortable getUploadFolder() {
    return whereType<Sortable<ImageArchiveData>>()
        .firstWhere((s) => s.data.upload);
  }

  Sortable<ImageArchiveData>? getMyPhotosFolder() =>
      whereType<Sortable<ImageArchiveData>>()
          .firstWhereOrNull((s) => s.data.myPhotos);
}
