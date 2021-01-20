import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImageArchivePage extends StatefulWidget {
  const ImageArchivePage({Key key}) : super(key: key);
  @override
  _ImageArchivePageState createState() => _ImageArchivePageState();
}

class _ImageArchivePageState extends State<ImageArchivePage> {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveBloc<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      builder: (context, state) {
        return Scaffold(
          appBar: NewAbiliaAppBar(
            iconData: AbiliaIcons.past_picture_from_windows_clipboard,
            title: translate.selectPicture,
          ),
          body: Column(
            children: [
              LibraryHeading(sortableArchiveState: state),
              Expanded(
                child: state.isSelected
                    ? FullScreenImageArchive(sortableArchiveState: state)
                    : const ImageArchive(),
              ),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigation(
            showForward: state.isSelected,
            backNavigationWidget: GreyButton(
              icon: AbiliaIcons.close_program,
              text: translate.cancel,
              onPressed: () => Navigator.of(context).popUntil((route) =>
                  route.settings.name?.startsWith('$EditActivityPage') ??
                  false),
            ),
            forwardNavigationWidget: GreenButton(
              text: translate.ok,
              icon: AbiliaIcons.ok,
              onPressed: () => Navigator.of(context).pop<SelectedImage>(
                SelectedImage(
                  id: state.selected?.data?.fileId,
                  path: state.selected?.data?.file,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FullScreenImageArchive extends StatelessWidget {
  const FullScreenImageArchive({
    Key key,
    @required this.sortableArchiveState,
  }) : super(key: key);
  final SortableArchiveState<ImageArchiveData> sortableArchiveState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: FullScreenImage(
          backgroundDecoration: whiteNoBorderBoxDecoration,
          fileId: sortableArchiveState.selected.data.fileId,
          filePath: sortableArchiveState.selected.data.icon,
        ),
      ),
    );
  }
}

class LibraryHeading extends StatelessWidget {
  const LibraryHeading({
    Key key,
    @required this.sortableArchiveState,
  }) : super(key: key);
  final SortableArchiveState<ImageArchiveData> sortableArchiveState;

  @override
  Widget build(BuildContext context) {
    final heading = getImageArchiveHeading(sortableArchiveState) ??
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
                  onPressed: () => onBack(context, sortableArchiveState),
                  themeData: darkButtonTheme,
                  child: Icon(AbiliaIcons.navigation_previous),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    heading,
                    style: abiliaTheme.textTheme.headline6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getImageArchiveHeading(SortableArchiveState state) {
    if (state.isSelected) {
      return state.selected.data.title() ?? '';
    }
    return state.allById[state.currentFolderId]?.data?.title();
  }

  Future onBack(BuildContext context,
      SortableArchiveState<ImageArchiveData> state) async {
    if (state.isSelected) {
      BlocProvider.of<SortableArchiveBloc<ImageArchiveData>>(context)
          .add(SortableSelected<ImageArchiveData>(null));
    } else if (state.currentFolderId != null) {
      BlocProvider.of<SortableArchiveBloc<ImageArchiveData>>(context)
          .add(NavigateUp());
    } else {
      await Navigator.of(context).maybePop();
    }
  }
}
