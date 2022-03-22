import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

typedef LibraryItemGenerator<T extends SortableData> = Widget Function(
    Sortable<T>);

class LibraryPage<T extends SortableData> extends StatelessWidget {
  const LibraryPage.nonSelectable({
    Key? key,
    required this.libraryItemGenerator,
    required this.emptyLibraryMessage,
    this.onCancel,
    this.appBar,
    this.rootHeading,
    this.showBottomNavigationBar = true,
    this.gridCrossAxisCount,
    this.gridChildAspectRatio,
  })  : selectableItems = false,
        selectedItemGenerator = null,
        onOk = null,
        super(key: key);

  const LibraryPage.selectable({
    Key? key,
    required this.selectedItemGenerator,
    required this.libraryItemGenerator,
    required this.emptyLibraryMessage,
    required this.onOk,
    this.onCancel,
    this.appBar,
    this.rootHeading,
    this.showBottomNavigationBar = true,
    this.gridCrossAxisCount,
    this.gridChildAspectRatio,
  })  : selectableItems = true,
        assert(
            onOk != null, 'onOk should not be null in LibraryPage.selectable'),
        assert(selectedItemGenerator != null,
            'selectedItemGenerator should not be null in LibraryPage.selectable'),
        super(key: key);
  final bool selectableItems, showBottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final Function(Sortable<T>)? onOk;
  final VoidCallback? onCancel;
  final LibraryItemGenerator<T>? selectedItemGenerator;
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;
  final String? rootHeading;
  final int? gridCrossAxisCount;
  final double? gridChildAspectRatio;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (context, state) {
        final selected = selectableItems ? state.selected : null;
        final selectedGenerator = selectedItemGenerator;
        return Scaffold(
          appBar: appBar,
          body: Column(
            children: [
              if (!state.isAtRootAndNoSelection || rootHeading != null)
                LibraryHeading<T>(
                  sortableArchiveState: state,
                  rootHeading: rootHeading ?? '',
                ),
              Expanded(
                child: selected != null && selectedGenerator != null
                    ? selectedGenerator(selected)
                    : SortableLibrary<T>(
                        libraryItemGenerator,
                        emptyLibraryMessage,
                        selectableItems: selectableItems,
                        crossAxisCount: gridCrossAxisCount,
                        childAspectRatio: gridChildAspectRatio,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: showBottomNavigationBar
              ? BottomNavigation(
                  backNavigationWidget: CancelButton(onPressed: onCancel),
                  forwardNavigationWidget: selected != null
                      ? OkButton(
                          onPressed: () => onOk?.call(selected),
                        )
                      : null,
                )
              : null,
        );
      },
    );
  }
}

class LibraryHeading<T extends SortableData> extends StatelessWidget {
  const LibraryHeading({
    Key? key,
    required this.sortableArchiveState,
    required this.rootHeading,
  }) : super(key: key);
  final SortableArchiveState<T> sortableArchiveState;
  final String rootHeading;

  @override
  Widget build(BuildContext context) {
    final heading = sortableArchiveState.isAtRootAndNoSelection
        ? rootHeading
        : sortableArchiveState.title(
            Translator.of(context).translate,
          );
    return Tts.data(
      data: heading,
      child: Column(
        children: [
          Padding(
            padding: layout.libraryPage.headerPadding,
            child: Row(
              children: [
                IconActionButtonDark(
                  onPressed: () => back(context, sortableArchiveState),
                  child: const Icon(AbiliaIcons.navigationPrevious),
                ),
                SizedBox(width: 12.0.s),
                Expanded(
                  child: Text(
                    heading,
                    style: layout.libraryPage.headerStyle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future back(BuildContext context, SortableArchiveState<T> state) async {
    if (state.isSelected) {
      BlocProvider.of<SortableArchiveCubit<T>>(context)
          .folderChanged(state.currentFolderId);
    } else if (!state.isAtRoot) {
      BlocProvider.of<SortableArchiveCubit<T>>(context).navigateUp();
    } else {
      await Navigator.of(context).maybePop();
    }
  }
}

class SortableLibrary<T extends SortableData> extends StatefulWidget {
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;
  final bool selectableItems;
  final int? crossAxisCount;
  final double? childAspectRatio;

  const SortableLibrary(
    this.libraryItemGenerator,
    this.emptyLibraryMessage, {
    this.selectableItems = true,
    this.crossAxisCount,
    this.childAspectRatio,
    Key? key,
  }) : super(key: key);

  @override
  _SortableLibraryState<T> createState() => _SortableLibraryState<T>();
}

class _SortableLibraryState<T extends SortableData>
    extends State<SortableLibrary<T>> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (context, archiveState) {
        List<Sortable<T>> content =
            (archiveState.allByFolder[archiveState.currentFolderId] ?? [])
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        if (content.isEmpty) {
          return EmptyLibraryMessage(
            emptyLibraryMessage: widget.emptyLibraryMessage,
            rootFolder: archiveState.isAtRoot,
          );
        }
        return ScrollArrows.vertical(
          controller: _controller,
          child: GridView.count(
            controller: _controller,
            padding: EdgeInsets.only(
              top: verticalPadding,
              left: leftPadding,
              right: rightPadding,
            ),
            mainAxisSpacing: layout.libraryPage.mainAxisSpacing,
            crossAxisSpacing: layout.libraryPage.crossAxisSpacing,
            crossAxisCount:
                widget.crossAxisCount ?? layout.libraryPage.crossAxisCount,
            childAspectRatio:
                widget.childAspectRatio ?? layout.libraryPage.childAspectRatio,
            children: content
                .map((sortable) => sortable.isGroup
                    ? Folder(sortable: sortable)
                    : widget.selectableItems
                        ? SelectableItem(
                            sortable: sortable,
                            libraryItemGenerator: widget.libraryItemGenerator,
                          )
                        : widget.libraryItemGenerator(sortable))
                .toList(),
          ),
        );
      },
    );
  }
}

class ListLibrary<T extends SortableData> extends StatelessWidget {
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;

  const ListLibrary(
    this.libraryItemGenerator,
    this.emptyLibraryMessage, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = ScrollController();
    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (context, archiveState) {
        List<Sortable<T>> content =
            (archiveState.allByFolder[archiveState.currentFolderId] ?? [])
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        if (content.isEmpty) {
          return EmptyLibraryMessage(
            emptyLibraryMessage: emptyLibraryMessage,
            rootFolder: archiveState.isAtRoot,
          );
        }
        return ScrollArrows.vertical(
          controller: _controller,
          child: ListView.separated(
            controller: _controller,
            padding: EdgeInsets.only(
              top: verticalPadding,
              left: leftPadding,
              right: rightPadding,
            ),
            itemCount: content.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: layout.libraryPage.listSeperation),
            itemBuilder: (BuildContext context, int index) =>
                libraryItemGenerator(content[index]),
          ),
        );
      },
    );
  }
}

class Folder<T extends SortableData> extends StatelessWidget {
  const Folder({Key? key, required this.sortable}) : super(key: key);

  final Sortable<T> sortable;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => BlocProvider.of<SortableArchiveCubit<T>>(context)
            .folderChanged(sortable.id),
        child: LibraryFolder(sortableData: sortable.data),
      ),
    );
  }
}

class SelectableItem<T extends SortableData> extends StatelessWidget {
  const SelectableItem({
    Key? key,
    required this.sortable,
    required this.libraryItemGenerator,
  }) : super(key: key);

  final Sortable<T> sortable;
  final LibraryItemGenerator<T> libraryItemGenerator;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => BlocProvider.of<SortableArchiveCubit<T>>(context)
            .sortableSelected(sortable),
        borderRadius: borderRadius,
        child: libraryItemGenerator(sortable),
      ),
    );
  }
}

class EmptyLibraryMessage extends StatelessWidget {
  const EmptyLibraryMessage({
    Key? key,
    required this.emptyLibraryMessage,
    required this.rootFolder,
  }) : super(key: key);

  final String emptyLibraryMessage;
  final bool rootFolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 60.0.s),
      child: Align(
        alignment: Alignment.topCenter,
        child: Tts(
          child: Text(
            rootFolder
                ? emptyLibraryMessage
                : Translator.of(context).translate.emptyFolder,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: AbiliaColors.black75),
          ),
        ),
      ),
    );
  }
}

class LibraryFolder extends StatelessWidget {
  final SortableData sortableData;

  const LibraryFolder({
    Key? key,
    required this.sortableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = sortableData.title(Translator.of(context).translate);
    return Tts.fromSemantics(
      SemanticsProperties(
        label: title,
        button: true,
      ),
      child: Padding(
        padding: EdgeInsets.all(4.0.s),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: abiliaTextTheme.caption?.copyWith(height: 1),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.s),
            Stack(
              children: [
                Icon(
                  AbiliaIcons.folder,
                  size: layout.libraryPage.folderIconSize,
                  color: AbiliaColors.orange,
                ),
                SizedBox(
                  height: layout.libraryPage.folderIconSize,
                  width: layout.libraryPage.folderIconSize,
                  child: Padding(
                    padding: layout.libraryPage.folderImagePadding,
                    child: Center(
                      child: FadeInAbiliaImage(
                        imageFileId: sortableData.dataFileId(),
                        imageFilePath: sortableData.dataFilePath(),
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.circular(4.s),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
