import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class LibraryChecklist extends StatelessWidget {
  final Checklist checklist;
  const LibraryChecklist({Key key, @required this.checklist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 84.0;
    final imageWidth = 84.0;
    final imageId = checklist.fileId;
    final name = checklist.name;
    final iconPath = checklist.image;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(checklist),
          borderRadius: borderRadius,
          child: Container(
            decoration: boxDecoration,
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (name != null)
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: abiliaTextTheme.caption,
                  ),
                const SizedBox(height: 2),
                checklist.hasImage
                    ? FadeInAbiliaImage(
                        height: imageHeight,
                        width: imageWidth,
                        imageFileId: imageId,
                        imageFilePath: iconPath,
                      )
                    : Icon(
                        AbiliaIcons.check_button,
                        size: 84,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
