import 'dart:io';

import 'package:flutter/material.dart' hide CloseButton;
import 'package:seagull/ui/all.dart';

import 'all.dart';

class FullscreenImageDialog extends StatelessWidget {
  final String fileId;
  final String filePath;
  final File tempFile;
  const FullscreenImageDialog({
    Key key,
    @required this.fileId,
    @required this.filePath,
    this.tempFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      expanded: true,
      bodyPadding: EdgeInsets.zero,
      body: FullScreenImage(
        backgroundDecoration: whiteNoBorderBoxDecoration.copyWith(
          borderRadius: BorderRadius.zero,
        ),
        fileId: fileId,
        filePath: filePath,
        tempFile: tempFile,
      ),
      backNavigationWidget: CloseButton(),
    );
  }
}
