import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

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
    return Tts.fromSemantics(
      SemanticsProperties(label: name),
      child: Padding(
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
                  SizedBox(
                    height: imageHeight,
                    child: checklist.hasImage
                        ? FadeInAbiliaImage(
                            height: imageHeight,
                            width: imageWidth,
                            imageFileId: imageId,
                            imageFilePath: iconPath,
                          )
                        : Icon(
                            AbiliaIcons.check_button,
                            size: 48,
                            color: AbiliaColors.white140,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
