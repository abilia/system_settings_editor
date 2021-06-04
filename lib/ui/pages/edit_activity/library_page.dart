// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

typedef LibraryItemGenerator<T extends SortableData> = Widget Function(
    Sortable<T>);

class LibraryPage<T extends SortableData> extends StatelessWidget {
  const LibraryPage({
    Key key,
    @required this.selectedItemGenerator,
    @required this.libraryItemGenerator,
    @required this.emptyLibraryMessage,
    @required this.onOk,
    this.libraryFolderGenerator,
    this.onCancel,
    this.appBar,
    this.rootHeading,
  }) : super(key: key);
  final PreferredSizeWidget appBar;
  final Function(Sortable<T>) onOk;
  final VoidCallback onCancel;
  final LibraryItemGenerator<T> selectedItemGenerator;
  final LibraryItemGenerator<T> libraryItemGenerator;
  final LibraryItemGenerator<T> libraryFolderGenerator;
  final String emptyLibraryMessage, rootHeading;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SortableArchiveBloc<T>>(
      create: (_) => SortableArchiveBloc<T>(
        sortableBloc: BlocProvider.of<SortableBloc>(context),
      ),
      child: BlocBuilder<SortableArchiveBloc<T>, SortableArchiveState<T>>(
        builder: (context, state) => Scaffold(
          appBar: appBar ??
              AbiliaAppBar(
                iconData: AbiliaIcons.documents,
                title: Translator.of(context).translate.selectFromLibrary,
              ),
          body: Column(
            children: [
              if (!state.isAtRootAndNoSelection || rootHeading != null)
                LibraryHeading<T>(
                  sortableArchiveState: state,
                  rootHeading: rootHeading,
                ),
              Expanded(
                child: state.isSelected
                    ? selectedItemGenerator(state.selected)
                    : SortableLibrary<T>(
                        libraryItemGenerator,
                        emptyLibraryMessage,
                        libraryFolderGenerator: libraryFolderGenerator,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(onPressed: onCancel),
            forwardNavigationWidget: state.isSelected
                ? OkButton(
                    onPressed: () => onOk(state.selected),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class LibraryHeading<T extends SortableData> extends StatelessWidget {
  LibraryHeading({
    Key key,
    @required this.sortableArchiveState,
    String rootHeading,
  })  : heading = _getLibraryHeading(sortableArchiveState, rootHeading),
        super(key: key);
  final SortableArchiveState<T> sortableArchiveState;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return Tts(
      data: heading,
      child: Padding(
        padding: EdgeInsets.only(right: 12.s),
        child: Separated(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.s, 12.s, 0.0, 4.s),
            child: Row(
              children: [
                ActionButtonDark(
                  onPressed: () => back(context, sortableArchiveState),
                  child: Icon(AbiliaIcons.navigation_previous),
                ),
                SizedBox(width: 12.0.s),
                Expanded(
                  child: Text(
                    heading,
                    style: abiliaTheme.textTheme.headline6,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _getLibraryHeading(
      SortableArchiveState state, String rootHeading) {
    if (state.isAtRootAndNoSelection) {
      return rootHeading;
    }
    if (state.isSelected) {
      return state.selected.data.title() ?? '';
    }
    return state.allById[state.currentFolderId]?.data?.title();
  }

  Future back(BuildContext context, SortableArchiveState<T> state) async {
    if (state.isSelected) {
      BlocProvider.of<SortableArchiveBloc<T>>(context)
          .add(SortableSelected(null));
    } else if (!state.isAtRoot) {
      BlocProvider.of<SortableArchiveBloc<T>>(context).add(NavigateUp());
    } else {
      await Navigator.of(context).maybePop();
    }
  }
}

class SortableLibrary<T extends SortableData> extends StatefulWidget {
  final LibraryItemGenerator<T> libraryItemGenerator;
  final LibraryItemGenerator<T> libraryFolderGenerator;
  final String emptyLibraryMessage;

  SortableLibrary(
    this.libraryItemGenerator,
    this.emptyLibraryMessage, {
    this.libraryFolderGenerator,
  });

  @override
  _SortableLibraryState<T> createState() => _SortableLibraryState<T>();
}

class _SortableLibraryState<T extends SortableData>
    extends State<SortableLibrary<T>> {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveBloc<T>, SortableArchiveState<T>>(
      builder: (context, archiveState) {
        final List<Sortable<T>> currentFolderContent =
            archiveState.allByFolder[archiveState.currentFolderId] ?? [];
        currentFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        if (currentFolderContent.isEmpty) {
          return EmptyLibraryMessage(
            emptyLibraryMessage: widget.emptyLibraryMessage,
            rootFolder: archiveState.isAtRoot,
          );
        }
        return VerticalScrollArrows(
          controller: _controller,
          child: GridView.count(
            controller: _controller,
            padding: EdgeInsets.only(
              top: verticalPadding,
              left: leftPadding,
              right: rightPadding,
            ),
            mainAxisSpacing: 8.0.s,
            crossAxisSpacing: 8.0.s,
            crossAxisCount: 3,
            childAspectRatio: 0.92,
            children: currentFolderContent
                .map(
                  (sortable) => sortable.isGroup
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: borderRadius,
                            onTap: () {
                              BlocProvider.of<SortableArchiveBloc<T>>(context)
                                  .add(FolderChanged(sortable.id));
                            },
                            child: widget.libraryFolderGenerator == null
                                ? LibraryFolder(
                                    title: sortable.data.title(),
                                    fileId: sortable.data.folderFileId(),
                                    filePath: sortable.data.folderFilePath(),
                                  )
                                : widget.libraryFolderGenerator(sortable),
                          ),
                        )
                      : Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () =>
                                BlocProvider.of<SortableArchiveBloc<T>>(context)
                                    .add(SortableSelected(sortable)),
                            borderRadius: borderRadius,
                            child: widget.libraryItemGenerator(sortable),
                          ),
                        ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class EmptyLibraryMessage extends StatelessWidget {
  const EmptyLibraryMessage({
    Key key,
    @required this.emptyLibraryMessage,
    @required this.rootFolder,
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
                .copyWith(color: AbiliaColors.black75),
          ),
        ),
      ),
    );
  }
}

class LibraryFolder extends StatelessWidget {
  final String title, fileId, filePath;
  final Color color;

  const LibraryFolder({
    Key key,
    @required this.title,
    this.fileId,
    this.filePath,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              style: abiliaTextTheme.caption,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.s),
            Stack(
              children: [
                Icon(
                  AbiliaIcons.folder,
                  size: 86.s,
                  color: color ?? AbiliaColors.orange,
                ),
                Positioned(
                  bottom: 16.s,
                  left: 10.s,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.s),
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 42 / 66,
                      child: FadeInAbiliaImage(
                        imageFileId: fileId,
                        imageFilePath: filePath,
                        width: 66.s,
                        height: 66.s,
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
