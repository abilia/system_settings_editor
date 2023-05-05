import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

typedef LibraryItemGenerator<T extends SortableData> = Widget Function(
    Sortable<T>);

typedef BasicTemplateItemGenerator<T extends SortableData> = Widget Function(
  Sortable<T>,
  GestureTapCallback,
  SortableToolbar,
  bool,
);

class LibraryPage<T extends SortableData> extends StatelessWidget {
  const LibraryPage.nonSelectable({
    required this.libraryItemGenerator,
    required this.emptyLibraryMessage,
    this.onCancel,
    this.appBar,
    this.rootHeading,
    this.showBottomNavigationBar = true,
    this.gridCrossAxisCount,
    this.gridChildAspectRatio,
    Key? key,
  })  : selectableItems = false,
        selectedItemGenerator = null,
        onOk = null,
        showSearch = false,
        super(key: key);

  const LibraryPage.selectable({
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
    this.showSearch = false,
    Key? key,
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
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    final sortableArchiveCubit = context.watch<SortableArchiveCubit<T>>();
    final sortableState = sortableArchiveCubit.state;
    final selected = selectableItems ? sortableState.selected : null;
    final selectedGenerator = selectedItemGenerator;
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          if (selected != null)
            LibraryHeading<T>(
              sortableArchiveState: sortableState,
              rootHeading: rootHeading ?? '',
            )
          else if (showSearch)
            const _SearchHeading()
          else if (!sortableState.isAtRootAndNoSelection || rootHeading != null)
            LibraryHeading<T>(
              sortableArchiveState: sortableState,
              rootHeading: rootHeading ?? '',
              showSearchButton: true,
            ),
          Expanded(
            child: selected != null && selectedGenerator != null
                ? selectedGenerator(selected)
                : SortableLibrary<T>(
                    libraryItemGenerator,
                    emptyLibraryMessage,
                    showSearch: showSearch,
                    selectableItems: selectableItems,
                    crossAxisCount: gridCrossAxisCount,
                    childAspectRatio: gridChildAspectRatio,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: showBottomNavigationBar
          ? Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: BottomNavigation(
                backNavigationWidget: CancelButton(
                  onPressed: showSearch && sortableState.isSelected
                      ? () => context.read<SortableArchiveCubit<T>>().unselect()
                      : onCancel,
                ),
                forwardNavigationWidget: selected != null
                    ? OkButton(
                        onPressed: () => onOk?.call(selected),
                      )
                    : null,
              ),
            )
          : null,
    );
  }
}

class LibraryHeading<T extends SortableData> extends StatelessWidget {
  const LibraryHeading({
    required this.sortableArchiveState,
    required this.rootHeading,
    this.showOnlyFolders = false,
    this.showSearchButton = false,
    this.onCancel,
    Key? key,
  }) : super(key: key);
  final SortableArchiveState<T> sortableArchiveState;
  final String rootHeading;
  final bool showOnlyFolders;
  final bool showSearchButton;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final heading = sortableArchiveState.isAtRootAndNoSelection
        ? rootHeading
        : sortableArchiveState.title(
            onlyFolders: showOnlyFolders);
    return Tts.data(
      data: heading,
      child: Column(
        children: [
          Padding(
            padding: layout.libraryPage.headerPadding,
            child: Row(
              children: [
                IconActionButton(
                  style: actionButtonStyleDark.withSize(
                    layout.libraryPage.backButtonSize,
                    iconSize: layout.libraryPage.backButtonIconSize,
                  ),
                  onPressed: () async => back(context, sortableArchiveState),
                  child: const Icon(AbiliaIcons.navigationPrevious),
                ),
                SizedBox(width: layout.formPadding.largeHorizontalItemDistance),
                Expanded(
                  child: Text(
                    heading,
                    style: layout.libraryPage.headerStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (showSearchButton)
                  IconAndTextButton(
                    style: actionButtonStyleDark
                        .withSize(
                          layout.libraryPage.searchButtonSize,
                        )
                        .copyWith(
                          textStyle: MaterialStateProperty.all(
                            abiliaTextTheme.bodyLarge,
                          ),
                        ),
                    text: translate.search,
                    icon: AbiliaIcons.find,
                    onPressed: () async {
                      final authProviders = copiedAuthProviders(context);
                      final sortableArchiveCubit = context
                          .read<SortableArchiveCubit<ImageArchiveData>>()
                        ..searchValueChanged('');
                      final selectedImageData =
                          await Navigator.of(context).push<SelectedImageData>(
                        PersistentMaterialPageRoute(
                          settings: (ImageArchivePage).routeSetting(
                            properties: {
                              'type': 'Search',
                            },
                          ),
                          builder: (_) => MultiBlocProvider(
                            providers: authProviders,
                            child: BlocProvider<
                                SortableArchiveCubit<ImageArchiveData>>.value(
                              value: sortableArchiveCubit,
                              child: ImageArchivePage(
                                onCancel: onCancel,
                                showSearch: true,
                              ),
                            ),
                          ),
                        ),
                      );
                      if (selectedImageData != null && context.mounted) {
                        Navigator.of(context).pop(selectedImageData);
                      }
                    },
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
      return context.read<SortableArchiveCubit<T>>().unselect();
    }
    if (!state.isAtRoot) {
      return context.read<SortableArchiveCubit<T>>().navigateUp();
    }
    return Navigator.of(context).maybePop();
  }
}

class _SearchHeading extends StatefulWidget {
  const _SearchHeading({Key? key}) : super(key: key);

  @override
  State<_SearchHeading> createState() => _SearchHeadingState();
}

class _SearchHeadingState extends State<_SearchHeading> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller
      ..text = context
          .read<SortableArchiveCubit<ImageArchiveData>>()
          .state
          .searchValue
      ..addListener(() => context
          .read<SortableArchiveCubit<ImageArchiveData>>()
          .searchValueChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveCubit<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      builder: (BuildContext context, state) {
        return Column(
          children: [
            Padding(
              padding: layout.libraryPage.searchPadding,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                      ),
                    ),
                  ),
                  TtsPlayButton(
                    controller: _controller,
                    padding: EdgeInsets.only(
                      left: layout
                          .defaultTextInputPage.textFieldActionButtonSpacing,
                    ),
                  ),
                ],
              ),
            ),
            if (_controller.text.isNotEmpty) const Divider(),
          ],
        );
      },
    );
  }
}

class SortableLibrary<T extends SortableData> extends StatefulWidget {
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;
  final bool selectableItems;
  final bool showSearch;
  final int? crossAxisCount;
  final double? childAspectRatio;

  const SortableLibrary(
    this.libraryItemGenerator,
    this.emptyLibraryMessage, {
    required this.showSearch,
    required this.selectableItems,
    required this.crossAxisCount,
    required this.childAspectRatio,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _SortableLibraryState<T>();
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
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (context, archiveState) {
        final content = widget.showSearch
            ? archiveState.allFilteredAndSorted()
            : archiveState.currentFolderSorted;
        if (content.isEmpty) {
          if (!widget.showSearch) {
            return EmptyLibraryMessage(
              emptyLibraryMessage: widget.emptyLibraryMessage,
              rootFolder: archiveState.isAtRoot,
            );
          }
          if (widget.showSearch && archiveState.searchValue.isNotEmpty) {
            return EmptyLibraryMessage(
              emptyLibraryMessage: translate.noMatchingImage,
              rootFolder: true,
            );
          }
        }
        return ScrollArrows.vertical(
          controller: _controller,
          child: GridView.count(
            controller: _controller,
            padding: layout.templates.m1,
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

class Folder<T extends SortableData> extends StatelessWidget {
  const Folder({
    required this.sortable,
    Key? key,
  }) : super(key: key);

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
    required this.sortable,
    required this.libraryItemGenerator,
    Key? key,
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
    required this.emptyLibraryMessage,
    required this.rootFolder,
    Key? key,
  }) : super(key: key);

  final String emptyLibraryMessage;
  final bool rootFolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: layout.libraryPage.emptyMessageTopPadding),
      child: Align(
        alignment: Alignment.topCenter,
        child: Tts(
          child: Text(
            rootFolder
                ? emptyLibraryMessage
                : Translator.of(context).translate.emptyFolder,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
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
    required this.sortableData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    String title = '';
    if (sortableData is ImageArchiveData) {
      title = (sortableData as ImageArchiveData).isUpload()
          ? translate.mobilePictures
          : (sortableData as ImageArchiveData).isMyPhotos()
              ? translate.myPhotos
              : sortableData.title();
    }

    return Tts.fromSemantics(
      SemanticsProperties(
        label: title,
        button: true,
      ),
      child: Padding(
        padding: layout.libraryPage.contentPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: abiliaTextTheme.bodySmall?.copyWith(height: 1),
              overflow: TextOverflow.ellipsis,
            ),
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
                        borderRadius: BorderRadius.circular(
                          layout.libraryPage.folderImageRadius,
                        ),
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
