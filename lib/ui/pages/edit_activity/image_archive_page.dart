import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImageArchivePage extends StatefulWidget {
  final String previousImage;

  const ImageArchivePage({Key key, this.previousImage}) : super(key: key);
  @override
  _ImageArchivePageState createState() => _ImageArchivePageState();
}

class _ImageArchivePageState extends State<ImageArchivePage> {
  Function onOk(SortableArchiveState<ImageArchiveData> state) =>
      state.isSelected
          ? () => Navigator.of(context).maybePop(
                SelectedImage(
                  id: state.selected.data.fileId,
                  path: state.selected.data.file,
                ),
              )
          : null;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveBloc<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      builder: (innerContext, imageArchiveState) => ViewDialog(
        verticalPadding: 0.0,
        backButton: ActionButton(
          onPressed: () async {
            if (imageArchiveState.currentFolderId == null) {
              await Navigator.of(context).maybePop();
            } else {
              BlocProvider.of<SortableArchiveBloc<ImageArchiveData>>(
                      innerContext)
                  .add(NavigateUp());
            }
          },
          themeData: darkButtonTheme,
          child: Icon(
            AbiliaIcons.navigation_previous,
            size: defaultIconSize,
          ),
        ),
        heading: getImageArchiveHeading(imageArchiveState),
        onOk: () => onOk(imageArchiveState),
        child: ImageArchive(),
      ),
    );
  }

  Text getImageArchiveHeading(SortableArchiveState state) {
    final folderName = state.allById[state.currentFolderId]?.data?.title() ??
        Translator.of(context).translate.imageArchive;
    return Text(folderName, style: abiliaTheme.textTheme.headline6);
  }
}
