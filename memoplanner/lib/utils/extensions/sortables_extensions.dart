import 'package:memoplanner/models/all.dart';
import 'package:collection/collection.dart';

extension SortableExtension on Iterable<Sortable> {
  Sortable<ImageArchiveData>? getUploadFolder() {
    return whereType<Sortable<ImageArchiveData>>()
        .firstWhereOrNull((s) => s.data.upload);
  }

  Sortable<ImageArchiveData>? getMyPhotosFolder() =>
      whereType<Sortable<ImageArchiveData>>()
          .firstWhereOrNull((s) => s.data.myPhotos);
}
