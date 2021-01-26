import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class LibraryPage<T extends SortableData> extends StatelessWidget {
  const LibraryPage({
    Key key,
    @required this.appBar,
    @required this.onOk,
    @required this.onCancel,
    @required this.libraryfullPageGenerator,
    @required this.libraryItemGenerator,
    @required this.emptyLibraryMessage,
  }) : super(key: key);
  final PreferredSizeWidget appBar;
  final Function(Sortable<T>) onOk;
  final VoidCallback onCancel;
  final LibraryItemGenerator<T> libraryfullPageGenerator;
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocProvider<SortableArchiveBloc<T>>(
      create: (_) => SortableArchiveBloc<T>(
        sortableBloc: BlocProvider.of<SortableBloc>(context),
      ),
      child: BlocBuilder<SortableArchiveBloc<T>, SortableArchiveState<T>>(
        builder: (context, state) => Scaffold(
          appBar: appBar,
          body: Column(
            children: [
              LibraryHeading(
                key: TestKey.libraryHeading,
                sortableArchiveState: state,
              ),
              Expanded(
                child: state.isSelected
                    ? libraryfullPageGenerator(state.selected)
                    : SortableLibrary<T>(
                        libraryItemGenerator,
                        emptyLibraryMessage,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigation(
            showForward: state.isSelected,
            backNavigationWidget: GreyButton(
              icon: AbiliaIcons.close_program,
              text: translate.cancel,
              onPressed: onCancel,
            ),
            forwardNavigationWidget: GreenButton(
              text: translate.ok,
              icon: AbiliaIcons.ok,
              onPressed: () => onOk(state.selected),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryHeading<T extends SortableData> extends StatelessWidget {
  const LibraryHeading({
    Key key,
    @required this.sortableArchiveState,
  }) : super(key: key);
  final SortableArchiveState<T> sortableArchiveState;

  @override
  Widget build(BuildContext context) {
    final heading = getLibraryHeading(sortableArchiveState) ??
        Translator.of(context).translate.imageArchive;
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

  String getLibraryHeading(SortableArchiveState state) {
    if (state.isSelected) {
      return state.selected.data.title() ?? '';
    }
    return state.allById[state.currentFolderId]?.data?.title();
  }

  Future back(BuildContext context, SortableArchiveState<T> state) async {
    if (state.isSelected) {
      BlocProvider.of<SortableArchiveBloc<T>>(context)
          .add(SortableSelected(null));
    } else if (state.currentFolderId != null) {
      BlocProvider.of<SortableArchiveBloc<T>>(context).add(NavigateUp());
    } else {
      await Navigator.of(context).maybePop();
    }
  }
}

class SortableLibraryPage<T extends SortableData> extends StatelessWidget {
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;

  const SortableLibraryPage({
    Key key,
    @required this.libraryItemGenerator,
    @required this.emptyLibraryMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SortableArchiveBloc<T>>(
          create: (_) => SortableArchiveBloc<T>(
            sortableBloc: BlocProvider.of<SortableBloc>(context),
          ),
        ),
        BlocProvider<UserFileBloc>.value(
          value: BlocProvider.of<UserFileBloc>(context),
        ),
      ],
      child: BlocBuilder<SortableArchiveBloc<T>, SortableArchiveState<T>>(
        builder: (innerContext, sortableArchiveState) => ViewDialog(
          verticalPadding: 0.0,
          backButton: sortableArchiveState.currentFolderId == null
              ? null
              : SortableLibraryBackButton<T>(),
          heading: _getArchiveHeading(sortableArchiveState, context),
          child: SortableLibrary<T>(
            libraryItemGenerator,
            emptyLibraryMessage,
          ),
        ),
      ),
    );
  }

  Text _getArchiveHeading(SortableArchiveState state, BuildContext context) {
    final folderName = state.allById[state.currentFolderId]?.data?.title() ??
        Translator.of(context).translate.selectFromLibrary;
    return Text(folderName, style: abiliaTheme.textTheme.headline6);
  }
}

class SortableLibraryBackButton<T extends SortableData>
    extends StatelessWidget {
  const SortableLibraryBackButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onPressed: () {
        BlocProvider.of<SortableArchiveBloc<T>>(context).add(NavigateUp());
      },
      themeData: darkButtonTheme,
      child: Icon(
        AbiliaIcons.navigation_previous,
        size: defaultIconSize,
      ),
    );
  }
}

typedef LibraryItemGenerator<T extends SortableData> = Widget Function(
    Sortable<T>);

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
          return Align(
            alignment: Alignment.topCenter,
            child: Tts(
              child: Text(
                archiveState.currentFolderId == null
                    ? emptyLibraryMessage
                    : Translator.of(context).translate.emptyFolder,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
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
