// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditImageAndName extends StatefulWidget {
  final ImageAndName imageAndName;
  final PreferredSizeWidget appBar;
  final int maxLines, minLines;
  final bool allowEmpty;
  final String hintText;
  const EditImageAndName({
    Key key,
    this.imageAndName,
    this.appBar,
    this.maxLines,
    this.minLines,
    this.allowEmpty = false,
    this.hintText,
  }) : super(key: key);

  @override
  _EditImageAndNameState createState() => imageAndName == null
      ? _EditImageAndNameState(ImageAndName.empty)
      : _EditImageAndNameState(imageAndName);
}

class _EditImageAndNameState extends State<EditImageAndName> {
  _EditImageAndNameState(this.imageAndName);
  ImageAndName imageAndName;
  TextEditingController txtEditController;

  @override
  void initState() {
    super.initState();
    txtEditController = TextEditingController(text: imageAndName.name);
  }

  @override
  Widget build(BuildContext context) {
    final heading = Translator.of(context).translate.name;
    return Scaffold(
      appBar: widget.appBar,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SelectPictureWidget(
                  selectedImage: imageAndName.image,
                  onImageSelected: (selectedImage) => setState(
                    () => imageAndName =
                        imageAndName.copyWith(image: selectedImage),
                  ),
                ),
                SizedBox(width: 16.0.s),
                Expanded(
                  child: Tts.fromSemantics(
                    SemanticsProperties(label: heading),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SubHeading(heading),
                        TextField(
                          controller: txtEditController,
                          decoration:
                              InputDecoration(hintText: widget.hintText),
                          textCapitalization: TextCapitalization.sentences,
                          style: Theme.of(context).textTheme.bodyText1,
                          autofocus: true,
                          onEditingComplete: Navigator.of(context).maybePop,
                          onChanged: (text) => setState(() =>
                              imageAndName = imageAndName.copyWith(name: text)),
                          maxLines: widget.maxLines,
                          minLines: widget.minLines,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          BottomNavigation(
            useSafeArea: false,
            backNavigationWidget: CancelButton(),
            forwardNavigationWidget: OkButton(
              onPressed: !widget.allowEmpty && imageAndName.isEmpty
                  ? null
                  : () => Navigator.of(context).maybePop(imageAndName),
            ),
          ),
        ],
      ),
    );
  }
}
