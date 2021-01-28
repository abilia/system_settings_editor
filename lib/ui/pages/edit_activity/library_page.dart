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
    this.onCancel,
    this.appBar,
    this.rootHeading,
  }) : super(key: key);
  final PreferredSizeWidget appBar;
  final Function(Sortable<T>) onOk;
  final VoidCallback onCancel;
  final LibraryItemGenerator<T> selectedItemGenerator;
  final LibraryItemGenerator<T> libraryItemGenerator;
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
              NewAbiliaAppBar(
                iconData: AbiliaIcons.documents,
                title: Translator.of(context).translate.selectFromLibrary,
              ),
          body: Column(
            children: [
              if (!state.isAtRoot || rootHeading != null)
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
                      ),
              ),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigation(
            showForward: state.isSelected,
            backNavigationWidget: CancelButton(onPressed: onCancel),
            forwardNavigationWidget: OkButton(
              onPressed: () => onOk(state.selected),
            ),
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
        padding: const EdgeInsets.only(right: 12.0),
        child: Separated(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 0.0, 4.0),
            child: Row(
              children: [
                ActionButton(
                  onPressed: () => back(context, sortableArchiveState),
                  themeData: darkButtonTheme,
                  child: Icon(AbiliaIcons.navigation_previous),
                ),
                const SizedBox(width: 12.0),
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
    if (state.isAtRoot) {
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

class SortableLibrary<T extends SortableData> extends StatelessWidget {
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;

  const SortableLibrary(this.libraryItemGenerator, this.emptyLibraryMessage);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveBloc<T>, SortableArchiveState<T>>(
      builder: (context, archiveState) {
        final List<Sortable<T>> currentFolderContent =
            archiveState.allByFolder[archiveState.currentFolderId] ?? [];
        currentFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        if (currentFolderContent.isEmpty) {
          return EmptyLibraryMessage(
            emptyLibraryMessage: emptyLibraryMessage,
            rootFolder: archiveState.isAtRoot,
          );
        }
        return GridView.count(
          padding: const EdgeInsets.only(
            top: ViewDialog.verticalPadding,
            left: ViewDialog.leftPadding,
            right: ViewDialog.rightPadding,
          ),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: currentFolderContent
              .map(
                (sortable) => sortable.isGroup
                    ? LibraryFolder(
                        title: sortable.data.title(),
                        fileId: sortable.data.folderFileId(),
                        filePath: sortable.data.folderFilePath(),
                        onTap: () {
                          BlocProvider.of<SortableArchiveBloc<T>>(context)
                              .add(FolderChanged(sortable.id));
                        },
                      )
                    : Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () =>
                              BlocProvider.of<SortableArchiveBloc<T>>(context)
                                  .add(SortableSelected(sortable)),
                          borderRadius: borderRadius,
                          child: libraryItemGenerator(sortable),
                        ),
                      ),
              )
              .toList(),
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
      padding: const EdgeInsets.only(top: 60.0),
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
  final GestureTapCallback onTap;
  final String title, fileId, filePath;

  const LibraryFolder({
    Key key,
    @required this.onTap,
    @required this.title,
    @required this.fileId,
    @required this.filePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      SemanticsProperties(
        label: title,
        button: true,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  style: abiliaTextTheme.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Stack(
                  children: [
                    const Icon(
                      AbiliaIcons.folder,
                      size: 86,
                      color: AbiliaColors.orange,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: 42 / 66,
                          child: FadeInAbiliaImage(
                            imageFileId: fileId,
                            imageFilePath: filePath,
                            width: 66,
                            height: 66,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
