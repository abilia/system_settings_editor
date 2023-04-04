import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

typedef ItemSelected<T extends SortableData> = void Function(
    BuildContext t, Sortable<T>);

class ListLibrary<T extends SortableData> extends StatelessWidget {
  final BasicTemplateItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;
  final ItemSelected<T>? onTapEdit;
  final bool selectableItems;

  const ListLibrary({
    required this.emptyLibraryMessage,
    required this.libraryItemGenerator,
    this.onTapEdit,
    this.selectableItems = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (context, archiveState) {
        final onTapEdit = this.onTapEdit;
        final content = archiveState.currentFolderSorted;
        return Column(
          children: [
            if (!archiveState.isAtRoot)
              LibraryHeading<T>(
                sortableArchiveState: archiveState,
                rootHeading: '',
                showOnlyFolders: true,
              ),
            Expanded(
              child: content.isEmpty
                  ? EmptyLibraryMessage(
                      emptyLibraryMessage: emptyLibraryMessage,
                      rootFolder: archiveState.isAtRoot,
                    )
                  : ScrollArrows.vertical(
                      controller: controller,
                      child: ListView.separated(
                        controller: controller,
                        padding: layout.templates.m1,
                        itemCount: content.length,
                        separatorBuilder: (context, index) => SizedBox(
                          height: layout.formPadding.smallVerticalItemDistance,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final Sortable<T> sortable = content[index];
                          final bool selected =
                              archiveState.selected?.id == sortable.id;
                          return libraryItemGenerator(
                            sortable,
                            () => sortable.isGroup
                                ? context
                                    .read<SortableArchiveCubit<T>>()
                                    .folderChanged(sortable.id)
                                : selectableItems
                                    ? context
                                        .read<SortableArchiveCubit<T>>()
                                        .sortableSelected(
                                            selected ? null : sortable)
                                    : {},
                            SortableToolbar(
                              disableUp: index == 0,
                              disableDown: index == content.length - 1,
                              onTapEdit: onTapEdit != null
                                  ? () => onTapEdit(context, sortable)
                                  : null,
                              onTapDelete: () async =>
                                  _onDeleteItem(context, sortable),
                              onTapReorder: (direction) => context
                                  .read<SortableArchiveCubit<T>>()
                                  .reorder(direction),
                            ),
                            selected,
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDeleteItem(
    BuildContext context,
    Sortable sortable,
  ) async {
    final sortableArchiveCubit = context.read<SortableArchiveCubit<T>>();

    final result = await showViewDialog<bool>(
      context: context,
      builder: (_) => sortable.data is BasicTimerData
          ? const ConfirmDeleteTimerTemplateDialog()
          : const ConfirmDeleteActivityTemplateDialog(),
      routeSettings: (sortable.data is BasicTimerData
              ? ConfirmDeleteTimerTemplateDialog
              : ConfirmDeleteActivityTemplateDialog)
          .routeSetting(),
    );

    if (result == true) {
      sortableArchiveCubit.delete();
    }
  }
}

class ConfirmDeleteTimerTemplateDialog extends StatelessWidget {
  const ConfirmDeleteTimerTemplateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      ConfirmDeleteDialog(text: Translator.of(context).translate.timerDelete);
}

class ConfirmDeleteActivityTemplateDialog extends StatelessWidget {
  const ConfirmDeleteActivityTemplateDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => ConfirmDeleteDialog(
      text: Translator.of(context).translate.deleteActivityQuestion);
}

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => YesNoDialog(
        heading: Translator.of(context).translate.delete,
        headingIcon: AbiliaIcons.deleteAllClear,
        text: text,
      );
}
