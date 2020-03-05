import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sortable/image_archive/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/sortable/image_archive.dart';
import 'package:seagull/ui/theme.dart';

class SelectPictureDialog extends StatefulWidget {
  final BuildContext outerContext;
  final ValueChanged<String> onChanged;

  const SelectPictureDialog({
    Key key,
    @required this.outerContext,
    @required this.onChanged,
  }) : super(key: key);

  @override
  _SelectPictureDialogState createState() => _SelectPictureDialogState();
}

class _SelectPictureDialogState extends State<SelectPictureDialog> {
  bool imageArchiveView = false;
  String imageSelected;

  @override
  Widget build(BuildContext context) {
    final sortableBloc = BlocProvider.of<SortableBloc>(widget.outerContext);
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    final imageArchiveBloc = ImageArchiveBloc(
      sortableBloc: sortableBloc,
    );
    return BlocProvider<ImageArchiveBloc>(
      create: (context) => imageArchiveBloc,
      child: BlocBuilder<ImageArchiveBloc, ImageArchiveState>(
        builder: (innerContext, imageArchiveState) {
          return ViewDialog(
            expanded: imageArchiveView,
            backButton: imageArchiveView
                ? ActionButton(
                    onPressed: () {
                      if (imageArchiveState.currentFolderId == null) {
                        setState(() {
                          imageArchiveView = false;
                        });
                      } else {
                        BlocProvider.of<ImageArchiveBloc>(innerContext)
                            .add(NavigateUp());
                      }
                    },
                    themeData: darkButtonTheme,
                    child: Icon(
                      AbiliaIcons.navigation_previous,
                      size: 32,
                    ),
                  )
                : null,
            heading: imageArchiveView
                ? getImageArchiveHeading(imageArchiveState)
                : Text(translate.selectPicture, style: theme.textTheme.title),
            onOk: imageSelected != null
                ? () {
                    widget.onChanged(imageSelected);
                    Navigator.of(context).maybePop();
                  }
                : null,
            child: imageArchiveView
                ? ImageArchive(
                    onChanged: (imageId) {
                      setState(() {
                        imageSelected = imageId;
                      });
                    },
                  )
                : buildSelectPictureSource(translate),
          );
        },
      ),
    );
  }

  Column buildSelectPictureSource(Translated translate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PickField(
          leading: Icon(AbiliaIcons.folder),
          label: Text(
            translate.imageArchive,
            style: abiliaTheme.textTheme.body2,
          ),
          onTap: () async {
            setState(() {
              imageArchiveView = !imageArchiveView;
            });
          },
        ),
        SizedBox(height: 8.0),
        PickField(
          leading: Icon(AbiliaIcons.my_photos),
          label: Text(
            translate.myPhotos,
            style: abiliaTheme.textTheme.body2,
          ),
          onTap: () async {
            var image =
                await ImagePicker.pickImage(source: ImageSource.gallery);
            print(image);
          },
        ),
        SizedBox(height: 8.0),
        PickField(
          leading: Icon(AbiliaIcons.camera_photo),
          label: Text(
            translate.takeNewPhoto,
            style: abiliaTheme.textTheme.body2,
          ),
          onTap: () async {
            var image = await ImagePicker.pickImage(source: ImageSource.camera);
            print(image);
          },
        ),
      ],
    );
  }

  Text getImageArchiveHeading(ImageArchiveState state) {
    final translate = Translator.of(context).translate;
    if (state.currentFolderId == null) {
      return Text(translate.imageArchive, style: abiliaTheme.textTheme.title);
    }
    final sortable = state.allById[state.currentFolderId];
    final sortableData = json.decode(sortable.data);
    final folderName = sortableData['name'];
    return Text(folderName, style: abiliaTheme.textTheme.title);
  }
}

class ImageArchiveHeader extends StatelessWidget {
  const ImageArchiveHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hwej'),
    );
  }
}
