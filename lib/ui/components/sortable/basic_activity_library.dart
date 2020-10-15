import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';

class BasicActivityLibraryItem extends StatelessWidget {
  final BaseActivityData baseActivityData;
  const BasicActivityLibraryItem({Key key, @required this.baseActivityData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 84.0;
    final imageWidth = 84.0;
    final imageId = baseActivityData.fileId;
    final name = baseActivityData.title();
    final iconPath = baseActivityData.icon;
    return Tts.fromSemantics(
      SemanticsProperties(label: name),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () =>
                Navigator.of(context).maybePop(CreateActivityDialogResponse(
              baseActivityData: baseActivityData,
            )),
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
                    child: baseActivityData.hasImage
                        ? FadeInAbiliaImage(
                            height: imageHeight,
                            width: imageWidth,
                            imageFileId: imageId,
                            imageFilePath: iconPath,
                          )
                        : Icon(
                            AbiliaIcons.day,
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
