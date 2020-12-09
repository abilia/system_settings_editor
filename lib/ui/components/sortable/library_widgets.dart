import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SortableLibraryDialog<T extends SortableData> extends StatelessWidget {
  final LibraryItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;

  const SortableLibraryDialog({
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
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
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
          padding: EdgeInsets.symmetric(vertical: ViewDialog.verticalPadding),
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: currentFolderContent
              .map((sortable) => sortable.isGroup
                  ? LibraryFolder(
                      title: sortable.data.title(),
                      fileId: sortable.data.folderFileId(),
                      filePath: sortable.data.folderFilePath(),
                      onTap: () {
                        BlocProvider.of<SortableArchiveBloc<T>>(context)
                            .add(FolderChanged(sortable.id));
                      },
                    )
                  : libraryItemGenerator(sortable))
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
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 4),
                Text(
                  title,
                  style: abiliaTextTheme.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(
                        AbiliaIcons.folder,
                        size: 86,
                        color: AbiliaColors.orange,
                      ),
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
