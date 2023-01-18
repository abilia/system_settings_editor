import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:collection/collection.dart';

class PhotoPage extends StatelessWidget {
  const PhotoPage({
    required this.sortable,
    Key? key,
  }) : super(key: key);

  final Sortable<ImageArchiveData> sortable;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return BlocBuilder<SortableBloc, SortableState>(
      builder: (context, state) {
        final updatedSortable = (state is SortablesLoaded
                ? state.sortables
                    .whereType<Sortable<ImageArchiveData>>()
                    .firstWhereOrNull((element) => element.id == sortable.id)
                : null) ??
            sortable;

        final bool isInPhotoCalendar = updatedSortable.data.isInPhotoCalendar();

        return Scaffold(
          appBar: AbiliaAppBar(
            title: updatedSortable.data.name,
            label: translate.myPhotos,
            iconData: AbiliaIcons.myPhotos,
          ),
          body: Padding(
            padding: layout.myPhotos.fullScreenImagePadding,
            child: Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      layout.myPhotos.fullScreenImageBorderRadius,
                    ),
                    child: FullScreenImage(
                      backgroundDecoration: const BoxDecoration(),
                      fileId: updatedSortable.data.fileId,
                      filePath: updatedSortable.data.file,
                      tightMode: true,
                    ),
                  ),
                  if (isInPhotoCalendar)
                    const Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: PhotoCalendarSticker(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: SizedBox(
              height: layout.toolbar.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextAndOrIconActionButtonLight(
                    isInPhotoCalendar ? translate.remove : translate.add,
                    isInPhotoCalendar
                        ? AbiliaIcons.noPhotoCalendar
                        : AbiliaIcons.photoCalendar,
                    onPressed: () {
                      _addOrRemovePhotoFromPhotoCalendar(
                        context,
                        remove: isInPhotoCalendar,
                        sortable: updatedSortable,
                      );
                    },
                  ),
                  if (!isInPhotoCalendar)
                    TextAndOrIconActionButtonLight(
                      translate.delete,
                      AbiliaIcons.deleteAllClear,
                      onPressed: () => _deletePhoto(context, sortable),
                    ),
                  TextAndOrIconActionButtonLight(
                    translate.close,
                    AbiliaIcons.navigationPrevious,
                    onPressed: Navigator.of(context).maybePop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future _addOrRemovePhotoFromPhotoCalendar(
    BuildContext context, {
    required bool remove,
    required Sortable<ImageArchiveData> sortable,
  }) async {
    final sortableBloc = context.read<SortableBloc>();

    final result = await showViewDialog<bool>(
      context: context,
      builder: (_) => remove
          ? const RemoveFromPhotoCalendarDialog()
          : const AddToPhotoCalendarDialog(),
      routeSettings:
          (remove ? RemoveFromPhotoCalendarDialog : AddToPhotoCalendarDialog)
              .routeSetting(),
    );

    if (result == true) {
      final tags = sortable.data.tags.toSet();
      if (tags.add(ImageArchiveData.photoCalendarTag) ||
          tags.remove(ImageArchiveData.photoCalendarTag)) {
        sortableBloc.add(
          SortableUpdated(
            sortable.copyWith(
              data: sortable.data.copyWith(tags: tags),
            ),
          ),
        );
      }
    }
  }
}

class RemoveFromPhotoCalendarDialog extends StatelessWidget {
  const RemoveFromPhotoCalendarDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return _AddOrRemoveFromPhotoCalendarDialog(
      bodyText: translate.removeFromPhotoCalendarQuestion,
      buttonText: translate.remove,
    );
  }
}

class AddToPhotoCalendarDialog extends StatelessWidget {
  const AddToPhotoCalendarDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return _AddOrRemoveFromPhotoCalendarDialog(
      bodyText: translate.addToPhotoCalendarQuestion,
      buttonText: translate.add,
    );
  }
}

class _AddOrRemoveFromPhotoCalendarDialog extends StatelessWidget {
  const _AddOrRemoveFromPhotoCalendarDialog({
    required this.bodyText,
    required this.buttonText,
    Key? key,
  }) : super(key: key);

  final String bodyText, buttonText;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      heading: AppBarHeading(
        text: translate.photoCalendar,
        iconData: AbiliaIcons.photoCalendar,
      ),
      body: Tts(
        child: Text(bodyText),
      ),
      backNavigationWidget: const CancelButton(),
      forwardNavigationWidget: GreenButton(
        text: buttonText,
        icon: AbiliaIcons.ok,
        onPressed: () => Navigator.of(context).maybePop(true),
      ),
    );
  }
}

Future _deletePhoto(
  BuildContext context,
  Sortable<ImageArchiveData> sortable,
) async {
  final sortableBloc = context.read<SortableBloc>();
  final navigator = Navigator.of(context);
  final result = await showViewDialog<bool>(
      context: context,
      builder: (_) => const DeletePhotoDialog(),
      routeSettings: (DeletePhotoDialog).routeSetting());

  if (result == true) {
    sortableBloc.add(SortableUpdated(sortable.copyWith(deleted: true)));
    await navigator.maybePop();
  }
}

class DeletePhotoDialog extends StatelessWidget {
  const DeletePhotoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return YesNoDialog(
      heading: translate.delete,
      headingIcon: AbiliaIcons.deleteAllClear,
      text: translate.doYouWantToDeleteThisPhoto,
    );
  }
}
